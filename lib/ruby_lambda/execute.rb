require 'ruby_lambda/lambda_context'

module RubyLambda
  class Execute
    def initialize(current_directory, options = {"config"=>"config.yml"})
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
      @options = options
    end

    def run
      begin
        if @options.has_key?('handler')

          lambda_function, lambda_handler = @options['handler'].split('.')
        elsif @options.has_key?('config')
          lambda_function, lambda_handler = load_handler_from_file
        end

        check_for_handler(lambda_function, lambda_handler)

        load "#{@current_directory}/#{lambda_function}.rb"

        event = JSON.parse(File.read("#{@current_directory}/event.json"))

        context = LambdaContext.new()

        ap send(:"#{lambda_handler}", event: event, context: context), options = { :indent => -2 }
      rescue LoadError
        @shell.say('Handler file or function, can not be found', :red)

        exit 1
      end
    end

    def load_handler_from_file
      begin
        config_data = YAML.load_file "#{@current_directory}/#{@options['config']}"

        raise RubyLambda::ExecuteError.new('Invalid config file') unless config_data.is_a?(Hash)

        config_data['handler'].split('.')
      rescue Errno::ENOENT
        no_config_file_message = 'Config file missing, create a config.yml file or use the -c / --config flag to use a different config file. Alternativly you can use the -H flag to pass the name of the handler that should be executed'

        @shell.say(no_config_file_message, :red)

        exit 1
      rescue RubyLambda::ExecuteError
        @shell.say('Invalid config file', :red)

        exit 1
      end
    end

    def check_for_handler(lambda_function, lambda_handler)
      if lambda_handler.nil? || lambda_handler.nil?
        no_defined_handler_message = 'No config or handler function defined, create a config.yml file or use the -c / --config flag to use a different config file. Alternativly you can use the -H flag to pass the name of the handler that should be executed'

        @shell.say(no_defined_handler_message, :red)

        exit 1
      end
    end
  end
end
