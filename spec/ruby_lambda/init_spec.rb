RSpec.describe RubyLambda::Init do
  subject { RubyLambda::Init.new(example_folder_path) }

  let(:example_folder_path) { "#{FileUtils.pwd}/tmp/example" }
  let(:template_folder_path) { "#{FileUtils.pwd}/lib/ruby_lambda/templates" }

  describe '.run' do
    context 'with writable directory' do
      before :example do
        FileUtils.mkdir_p example_folder_path
      end

      after :example do
        FileUtils.rm_rf(example_folder_path)
      end

      it 'creates files from template folder' do
        subject.run

        Dir.foreach(template_folder_path) do |template_file_name|
          next if template_file_name == '.' or template_file_name == '..'

          expect(File).to exist("#{example_folder_path}/#{template_file_name}")
        end
      end

      it 'skips files from template folder' do
        Dir.chdir example_folder_path do
          FileUtils.touch 'Gemfile'
        end

        expect($stdout).to receive(:print).with(/Created: .ruby-version/)
        expect($stdout).to receive(:print).with(/Created: main.rb/)
        expect($stdout).to receive(:print).with(/Created: event.json/)
        expect($stdout).to receive(:print).with(/Skipped: Gemfile/)

        subject.run
      end
    end


    context 'with readonly folder' do

      it do
        FileUtils.mkdir_p example_folder_path

        system("chmod -w #{example_folder_path}")

        expect($stdout).to receive(:print).with(/Can not create files as the current directory/)

        subject.run

        FileUtils.rm_rf(example_folder_path)
      end
    end
  end
end
