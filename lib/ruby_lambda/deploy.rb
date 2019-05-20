module RubyLambda
  class Deploy
    def initialize(current_directory, options = {'native_extensions' => false, 'config' => 'config.yml'})
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
      @options = options
    end

    def run(mute: false)
      @mute = mute

      @config_data  = load_data_from_config_file

      Aws.config.update({
        credentials: Aws::Credentials.new(@config_data['aws_access_key'], @config_data['aws_secret_access_key'])
      })

      @iam_client = Aws::IAM::Client.new(region: @config_data['region'])

      @iam = Aws::IAM::Resource.new(client: @iam_client)

      @client = Aws::Lambda::Client.new(region: @config_data['region'])

      deploy_options = {}

      deploy_options[:role] = get_role_arn
      deploy_options[:function_name] = @config_data['function_name']
      deploy_options[:handler] = @config_data['handler']
      deploy_options[:runtime] = @config_data['runtime']
      deploy_options[:publish] = @options['publish']

      if @options['zip_file']
        zip_file = @options['zip_file']
      else
        zip_file = get_temp_build_zip
      end

      deploy_options[:code] = { zip_file: File.open(zip_file, 'rb').read }

      function = deploy_function(deploy_options)

      clean_up

      ap function
      @shell.say('Function deployed', :green) unless @mute
    end

    def load_data_from_config_file
      begin
        config_data = YAML.load(ERB.new(File.read("#{@current_directory}/#{@options['config']}")).result)

        raise RubyLambda::ExecuteError.new('Invalid config file') unless config_data.is_a?(Hash)

        config_data
      rescue Errno::ENOENT
        no_config_file_message = 'Config file missing, create a config.yml file or use the -c / --config flag to pass a different config file.'

        @shell.say(no_config_file_message, :red)

        exit 1
      rescue RubyLambda::ExecuteError
        @shell.say('Invalid config file', :red)

        exit 1
      end
    end

    def get_temp_build_zip
      @zip_file_name = "#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}_deploy_build.zip"

      RubyLambda::Build.new(@current_directory, {'file_name' => @zip_file_name, 'native_extensions' => @options['native_extensions']}).run(mute: @mute)

      @zip_file_name
    end

    def clean_up
      return if @options['zip_file'] != ''

      FileUtils.rm "#{@current_directory}/#{@zip_file_name}"
    end

    def deploy_function(deploy_options)
      begin
        if @options['update']
          update_function(deploy_options)
        else
          @client.create_function(deploy_options)
        end
      rescue Aws::Lambda::Errors::ResourceConflictException
        if @options['update']
          update_function(deploy_options)
        else
          @shell.say('Function already exists use the --update flag to update the current function', :red)
          clean_up
          exit 1
        end
      end
    end

    def update_function(deploy_options)
      begin
        update_options = {}
        update_options[:function_name] = deploy_options[:function_name]
        update_options[:publish] = deploy_options[:publish]
        update_options[:zip_file] = deploy_options[:code][:zip_file]

        @client.update_function_code(update_options)
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        @shell.say('Function was not found, remove the --update flag to create it', :red)
        clean_up
        exit 1
      end
    end

    def get_role_arn
      begin
        new_role = @iam_client.get_role({
          role_name: 'ruby_lambda_gem_basic_execution_role',
        })

        new_role.role.arn
      rescue Aws::IAM::Errors::NoSuchEntity
        create_role.data.arn
      end
    end

    def create_role
      policy_doc = {
        Version:'2012-10-17',
        Statement:[
          {
            Effect:'Allow',
            Action:'sts:AssumeRole',
            Principal:{
              Service:'lambda.amazonaws.com'
            }
          }]
      }

      role = @iam.create_role({
        role_name: 'ruby_lambda_gem_basic_execution_role',
        description: 'Role created to deploy lambda functions from ruby lambda gem',
        assume_role_policy_document: policy_doc.to_json
      })

      role.attach_policy({
        policy_arn: 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
      })

      sleep 5 # This will give the policy enough time to be attached to the role https://stackoverflow.com/a/37438525/7157278
      role
    end
  end
end
