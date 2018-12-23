require 'ruby_lambda/lambda_context'

module RubyLambda
  class Execute
    def initialize(current_directory)
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
    end

    def run
      load "#{@current_directory}/main.rb"

      event_json_file = File.read('event.json')
      event = JSON.parse(event_json_file)

      context = LambdaContext.new()

      ap lambda_handler(event: event, context: context)
    end
  end
end
