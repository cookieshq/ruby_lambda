module RubyLambda
  class Init

    TEMPLATE_DIR = "#{__dir__}/templates"

    def initialize(current_directory)
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
    end

    def run(mute: false)
      @mute = mute

      unless File.writable?(@current_directory)
        @shell.say "Can not create files as the current directory is not writable: #{@current_directory}", :red
        return
      end

      move_template_files
      create_env_file
      update_function_name
    end

    private

    def move_template_files
      Dir.foreach(TEMPLATE_DIR) do |template_file_name|
        next if special_handling?(filename: template_file_name)

        init_file = File.join(@current_directory, template_file_name)

        template_file_path = File.join(TEMPLATE_DIR, template_file_name)

        if File.exist?(init_file)
          @shell.say_status("Skipped:", "#{template_file_name} file already exists at #{File.expand_path(init_file)}", :yellow) unless @mute
        else
          FileUtils.cp(template_file_path, init_file)

          @shell.say_status("Created:", "#{template_file_name}", :green) unless @mute
        end
      end
    end

    def create_env_file
      env_sample = File.join(TEMPLATE_DIR, 'env.sample')
      env_hidden = File.join(@current_directory, '.env')
      FileUtils.cp(env_sample, env_hidden)
      @shell.say_status('Created:', '.env', :green)
    end

    def update_function_name
      config_file = "#{@current_directory}/config.yml"

      config_data = YAML.load_file config_file
      config_data['function_name'] = @current_directory.split('/').last

      File.open(config_file, 'w') { |f| YAML.dump(config_data, f) }
    end

    def special_handling?(filename:)
      current_directory?(filename: filename) or
        parent_directory?(filename: filename) or
        filename == 'env.sample'
    end

    def current_directory?(filename:)
      filename == '.'
    end

    def parent_directory?(filename:)
      filename == '..'
    end
  end
end
