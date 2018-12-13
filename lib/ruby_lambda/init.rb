module RubyLambda
  class Init

    MAIN_RB_TEMPLATE = File.expand_path('../templates/main.rb', __FILE__)

    def initialize(current_directory)
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
    end

    def run
      unless File.writable?(@current_directory)
        @shell.say "Can not create files as the current directory is not writable: #{@current_directory}", :red
        exit 1
      end

      create_main_rb
    end

    def create_main_rb
      main_rb = File.join(@current_directory, 'main.rb')

      if File.exist?(main_rb)
        @shell.say "Skipped: `main.rb` file already exists at #{File.expand_path(main_rb)}", :yellow
      else
        FileUtils.cp(MAIN_RB_TEMPLATE, main_rb)

        @shell.say 'Created: main.rb', :green
      end
    end
  end
end
