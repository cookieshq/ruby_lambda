require 'spec_helper'

RSpec.describe RubyLambda::Execute do
  subject { RubyLambda::Execute.new(example_folder_path) }

  let(:example_folder_path) { "#{FileUtils.pwd}/tmp/example" }

  describe '#run' do
    before :example do
      FileUtils.mkdir_p example_folder_path

      RubyLambda::Init.new(example_folder_path).run(mute: true)
    end

    after :example do
      FileUtils.rm_rf(example_folder_path)
    end

    it do
      subject.run(mute: true)
    end
  end
end


