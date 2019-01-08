module RubyLambda
  class Init

    TEMPLATE_DIR = "#{__dir__}/templates"

    def initialize(current_directory)
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
    end

    def run
      unless File.writable?(@current_directory)
        @shell.say "Can not create files as the current directory is not writable: #{@current_directory}", :red
        return
      end

      Dir.foreach(TEMPLATE_DIR) do |template_file_name|
        next if template_file_name == '.' or template_file_name == '..'

        init_file = File.join(@current_directory, template_file_name)

        template_file_path = File.join(TEMPLATE_DIR, template_file_name)

        if File.exist?(init_file)
          @shell.say "Skipped: #{template_file_name} file already exists at #{File.expand_path(init_file)}", :yellow
        else
          FileUtils.cp(template_file_path, init_file)

          @shell.say "Created: #{template_file_name}", :green
        end
      end

      File.rename("#{@current_directory}/env", "#{@current_directory}/.env")
    end
  end
end
