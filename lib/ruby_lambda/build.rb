module RubyLambda
  class Build
    def initialize(current_directory, options = {"native_extensions"=>false, 'file_name' => ''})
      @current_directory  = current_directory
      @shell = Thor::Base.shell.new
      @options = options
    end

    def run(mute: false)
      @mute = mute

      if @options['native_extensions']
        unless which('docker')
          @shell.say 'Can not find docker, you need to install docker if you want to build with native extensions', :red
          return
        end

        setup_gems_with_native_extensions
      else
        setup_gems
      end

      @shell.say('Setting up files to build', :yellow) unless @mute
      FileUtils.mkdir_p "#{@current_directory}/builds"

      @output_file = "#{@current_directory}/#{generate_build_name}"

      @shell.say('Adding files to zip', :yellow) unless @mute
      write
    end

    private

    def setup_gems
      Dir.chdir(@current_directory) do
        Bundler.with_clean_env do
          @shell.say('Installing gems for deployment', :yellow) unless @mute
          `bundle install`
          `bundle install --deployment`
        end
      end
    end

    def setup_gems_with_native_extensions

      Dir.chdir(@current_directory) do
        Bundler.with_clean_env do
          @shell.say('Installing gems for deployment', :yellow) unless @mute
          `docker run -v #{@current_directory}:#{@current_directory} -w #{@current_directory} -i -t lambci/lambda:build-ruby2.5 bundle install --deployment`
        end
      end
    end

    def generate_build_name
      new_build_number = Dir["#@current_directory/builds"].length - 1

      new_file_name = ''

      return @options['file_name'] if @options['file_name'] && @options['file_name'] != ''

      begin
        new_build_number = new_build_number  + 1

        new_file_name = "builds/build_#{new_build_number}.zip"
      end while File.exist?("#@current_directory/#{new_file_name}")

      new_file_name
    end

    def write
      git_ignore_path = "#@current_directory/.gitignore"

      files_to_ignore = %w(. .. .bundle builds tmp .gitignore .ruby-version)

      if File.exist?(git_ignore_path)
        files_to_ignore << File.readlines(git_ignore_path).map { |a| a.strip }
      end

      entries = Dir.entries(@current_directory) - files_to_ignore.flatten

      ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
        write_entries entries, '', zipfile
      end
    end

    def write_entries(entries, path, zipfile)
      entries.each do |e|
        zipfile_path = path == '' ? e : File.join(path, e)
        disk_file_path = File.join(@current_directory, zipfile_path)

        if File.directory? disk_file_path
          recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
        else
          put_into_archive(disk_file_path, zipfile, zipfile_path)
        end
      end
    end

    def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      zipfile.mkdir zipfile_path
      subdir = Dir.entries(disk_file_path) - %w(. ..)
      write_entries subdir, zipfile_path, zipfile
    end

    def put_into_archive(disk_file_path, zipfile, zipfile_path)
      zipfile.get_output_stream(zipfile_path) do |f|
        f.write(File.open(disk_file_path, 'rb').read)
      end
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        }
      end
      return nil
    end
  end
end
