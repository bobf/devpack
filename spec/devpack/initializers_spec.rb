# frozen_string_literal: true

RSpec.describe Devpack::Initializers do
  subject(:initializers) { described_class.new(config) }

  let(:config) do
    instance_double(
      Devpack::Config,
      devpack_initializer_paths: initializer_paths,
      devpack_initializers_path: initializers_path
    )
  end

  let(:initializers_path) { Pathname.new(Dir.tmpdir).join('.devpack_initializers') }
  let(:initializer_paths) { [initializers_path.join('example_initializer1.rb')] }

  before { FileUtils.mkdir_p(initializers_path) }
  after { FileUtils.rm_rf(initializers_path) }
  after { $LOADED_FEATURES.reject! { |path| initializer_paths.include?(Pathname.new(path)) } }

  describe '#load' do
    subject(:initializers_load) { initializers.load }

    context 'loadable initializer' do
      before do
        File.write(initializers_path.join('example_initializer1.rb'), initializer_content)
      end

      let(:initializer_content) { 'module ExampleInitializer1; end' }

      it 'loads located files' do
        subject
        expect(defined?(ExampleInitializer1)).to be_truthy
      end

      after { Object.send(:remove_const, :ExampleInitializer1) }
    end

    context 'multiple initializers' do
      before do
        File.write(initializers_path.join('example_initializer1.rb'), initializer1_content)
        File.write(initializers_path.join('example_initializer2.rb'), initializer2_content)
        File.write(initializers_path.join('example_initializer3.rb'), initializer3_content)
      end

      let(:initializer1_content) { 'module ExampleInitializer1; end' }
      let(:initializer2_content) { 'module ExampleInitializer2; end' }
      let(:initializer3_content) { 'module ExampleInitializer3; end' }
      let(:initializer_paths) do
        [
          initializers_path.join('example_initializer1.rb'),
          initializers_path.join('example_initializer2.rb'),
          initializers_path.join('example_initializer3.rb')
        ]
      end

      it 'loads located files' do
        subject
        expect(
          defined?(ExampleInitializer1) &&
          defined?(ExampleInitializer2) &&
          defined?(ExampleInitializer3)
        ).to be_truthy
      end

      after { Object.send(:remove_const, :ExampleInitializer1) }
      after { Object.send(:remove_const, :ExampleInitializer2) }
      after { Object.send(:remove_const, :ExampleInitializer3) }
    end

    context 'unloadable initializer (SyntaxError)' do
      let(:initializer_content) { 'not a valid module' }

      before do
        File.write(initializers_path.join('example_initializer1.rb'), initializer_content)
      end

      it 'suppresses errors' do
        expect { subject }.to_not raise_error
      end

      it 'issues a warning including error' do
        allow(Devpack).to receive(:warn)
        error = "SyntaxError - #{initializer_paths.first}:1: syntax error, unexpected end-of-input"
        expect(Devpack)
          .to receive(:warn)
          .at_least(:once)
          .with(:error, "Failed to load initializer `#{initializer_paths.first}`: (#{error})")
        subject
      end
    end

    context 'unloadable initializer (NameError)' do
      let(:initializer_content) { 'method_name_that_does_not_exist' }

      before do
        File.write(initializers_path.join('example_initializer1.rb'), initializer_content)
      end

      it 'suppresses errors' do
        expect { subject }.to_not raise_error
      end

      it 'issues a warning including error' do
        allow(Devpack).to receive(:warn)
        error = ['(NameError - undefined local variable or method ',
                 "`method_name_that_does_not_exist' for main:Object)"].join
        expect(Devpack)
          .to receive(:warn)
          .with(:error, "Failed to load initializer `#{initializer_paths.first}`: #{error}")
        subject
      end

      context 'with DEVPACK_DEBUG enabled' do
        before { allow(Devpack).to receive(:debug?) { true } }

        it 'issues a warning including error and traceback' do
          expect(Devpack)
            .to receive(:warn)
            .at_least(:once)
            .with(any_args) do |_level, message|
              next if message.start_with?('Loaded')

              ["/lib/devpack/initializers.rb:28:in `load_initializer'",
               "/lib/devpack/initializers.rb:24:in `block in load_initializers'",
               "/lib/devpack/initializers.rb:24:in `map'",
               "/lib/devpack/initializers.rb:24:in `load_initializers'",
               "/lib/devpack/initializers.rb:13:in `block in load'"].each do |line|
                expect(message).to include line
              end
            end
          subject
        end
      end
    end
  end
end
