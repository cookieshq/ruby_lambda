require 'spec_helper'

RSpec.describe RubyLambda::Execute do
  subject { RubyLambda::Execute.new(example_folder_path) }

  let(:example_folder_path) { "#{Dir.tmpdir()}/tmp/example" }

  after :example do
    FileUtils.rm_rf(example_folder_path)
  end

  describe '#run' do
    context 'with correct config' do
      before :example do
        FileUtils.mkdir_p example_folder_path

        RubyLambda::Init.new(example_folder_path).run
      end

      it 'executes function' do
        expect(subject.run).to include(statusCode: 200)
      end

      it 'it calls awesome print to display result' do
        expect(subject).to receive(:ap)

        subject.run
      end
    end

    context 'without config file' do
      before :example do
        init_without_config
      end

      after :example do
        FileUtils.rm_rf(example_folder_path)
      end

      it 'should run when handler flag is provided instead' do
        execute_function = RubyLambda::Execute.new(example_folder_path, {'handler' => 'lambda_function.handler'})

        expect(execute_function.run).to include(statusCode: 200)
      end

      it 'should fail with no handler' do
        execute_function = RubyLambda::Execute.new(example_folder_path, {})

        expect{ execute_function.run }.to raise_error SystemExit
      end
    end

    context 'with different config file' do
      before :example do
        init_without_config
      end

      it 'should execute with correct settings' do
        config_data = {'handler' => 'lambda_function.handler'}

        File.open("#{example_folder_path}/different_config.yml", 'w') { |f| YAML.dump(config_data, f) }

        execute_function = RubyLambda::Execute.new(example_folder_path, {'config' => 'different_config.yml'})

        expect(execute_function.run).to include(statusCode: 200)
      end

      it 'should not execute without correct settings' do
        execute_function = RubyLambda::Execute.new(example_folder_path, {'config' => 'different_config.yml'})

        expect{ execute_function.run }.to raise_error SystemExit
      end

      it 'should fail if the config is not yaml' do
        File.open("#{example_folder_path}/different_config.txt", 'w') { |f| f << 'Hello World' }

        execute_function = RubyLambda::Execute.new(example_folder_path, {'config' => 'different_config.txt'})

        expect{ execute_function.run }.to raise_error SystemExit
      end
    end

    context 'with different handler' do
      before :example do
        FileUtils.mkdir_p example_folder_path

        RubyLambda::Init.new(example_folder_path).run
      end

      it 'should execute with correct handler settings' do
        config_file = "#{example_folder_path}/config.yml"

        config_data = YAML.load_file config_file
        config_data['handler'] = 'my_lambda_function.my_handler'
        File.open(config_file, 'w') { |f| YAML.dump(config_data, f) }

        FileUtils.mv "#{example_folder_path}/lambda_function.rb", "#{example_folder_path}/my_lambda_function.rb"

        execute_function = RubyLambda::Execute.new(example_folder_path, {'handler' => 'my_lambda_function.handler'})

        expect(execute_function.run).to include(statusCode: 200)
      end

      it 'should fail without correct handler settings' do
        execute_function = RubyLambda::Execute.new(example_folder_path, {'handler' => 'my_lambda_function.my_handler'})

        expect{ execute_function.run }.to raise_error SystemExit
      end
    end
  end
end

def init_without_config
  FileUtils.mkdir_p example_folder_path

  RubyLambda::Init.new(example_folder_path).run

  FileUtils.rm("#{example_folder_path}/config.yml")
end
