require 'ruby_lambda/lambda_context'

module RubyLambda
  class Execute
    def initialize(current_directory)
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
    end

    def run(mute: false)
      config_file = "#{@current_directory}/config.yml"

      config_data = YAML.load_file config_file

      lambda_function, lambda_handler = config_data['handler'].split('.')

      load "#{@current_directory}/#{lambda_function}.rb"

      event_json_file = File.read("#{@current_directory}/event.json")

      event = JSON.parse(event_json_file)

      context = LambdaContext.new()

      if mute
        send(:"#{lambda_handler}", event: event, context: context)
      else
        ap send(:"#{lambda_handler}", event: event, context: context)
      end
    end
  end
end
