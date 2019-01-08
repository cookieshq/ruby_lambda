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

      move_template_files
      rename_env_file
      update_function_name
    end

    private

    def move_template_files
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
    end

    def rename_env_file
      File.rename("#{@current_directory}/env", "#{@current_directory}/.env")
    end

    def update_function_name
      config_file = "#{@current_directory}/config.yml"

      config_data = YAML.load_file config_file
      config_data['function_name'] = @current_directory.split('/').last

      File.open(config_file, 'w') { |f| YAML.dump(config_data, f) }
    end

  end
end
