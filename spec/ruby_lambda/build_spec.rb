RSpec.describe RubyLambda::Build do
  subject { RubyLambda::Build.new(example_folder_path) }

  let(:example_folder_path) { "#{Dir.tmpdir()}/tmp/example" }

  let(:mute) { true }

  before :example do
    FileUtils.mkdir_p example_folder_path
    RubyLambda::Init.new(example_folder_path).run(mute: true)
  end

  after :example do
    FileUtils.rm_rf(example_folder_path)
  end

  describe '#run' do
    context 'without native extensions' do
      it 'creates a zip' do
        subject.run(mute: mute)

        expect(File).to exist("#{example_folder_path}/builds/build_1.zip")
      end

      it 'creates a zip with a dynamic name' do
        FileUtils.mkdir_p "#{example_folder_path}/builds"

        Dir.chdir example_folder_path do
          FileUtils.touch 'builds/build_1.zip'
        end

        subject.run(mute: mute)

        expect(File).to exist("#{example_folder_path}/builds/build_2.zip")
      end

      it 'creates a zip with a folder' do
        FileUtils.mkdir_p "#{example_folder_path}/src"

        Dir.chdir example_folder_path do
          FileUtils.touch 'src/main.rb'
        end

        subject.run(mute: mute)

        expect(File).to exist("#{example_folder_path}/builds/build_1.zip")
      end

      it 'creates a zip with the right files' do
        subject.run(mute: mute)

        zip_contents = []
        Zip::File.open("#{example_folder_path}/builds/build_1.zip") do |zip_file|
          zip_contents = zip_file.map(&:name)
        end

        expect(zip_contents).to include 'lambda_function.rb', 'event.json', 'Gemfile', 'config.yml'
        expect(zip_contents).not_to include '.ruby-version'
      end

      it 'creates a zip with a folder and correct files' do
        FileUtils.mkdir_p "#{example_folder_path}/src"

        Dir.chdir example_folder_path do
          FileUtils.touch 'src/main.rb'
        end

        subject.run(mute: mute)

        zip_contents = []
        Zip::File.open("#{example_folder_path}/builds/build_1.zip") do |zip_file|
          zip_contents = zip_file.map(&:name)
        end

        expect(zip_contents).to include 'src/', 'src/main.rb'
      end
    end
  end

  context 'with native extensions' do
    it 'checks for docker'
  end
end

