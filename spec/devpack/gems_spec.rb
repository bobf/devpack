# frozen_string_literal: true

RSpec.describe Devpack::Gems do
  subject(:gems) { described_class.new(config, glob) }

  let(:config) do
    instance_double(
      Devpack::Config,
      requested_gems: requested_gems,
      devpack_path: devpack_path.join('.devpack')
    )
  end
  let(:glob) { instance_double(Devpack::GemGlob) }
  let(:project_path) { Pathname.new(Dir.tmpdir).join('example') }
  let(:devpack_path) { project_path }
  let(:requested_gems) { [] }
  let(:gem_home) { Pathname.new(File.join(Dir.tmpdir, 'gem_home')) }
  it { is_expected.to be_a described_class }
  its(:load) { is_expected.to be_an Array }

  describe '#load' do
    subject(:gems_load) { gems.load }

    let(:installed_gems) { %w[installed1 installed2 installed3] }
    let(:not_installed_gems) { %w[not_installed1 not_installed2 not_installed3] }
    let(:loaded_gems) { {} }
    let(:gemspec) do
      instance_double(
        Gem::Specification,
        version: Gem::Version.new('1'),
        name: 'gem',
        runtime_dependencies: [],
        require_paths: [],
        'activated=': nil
      )
    end

    before do
      stub_const('ENV', ENV.to_h.merge('GEM_PATH' => "#{gem_home}:/some/other/directory"))
      FileUtils.mkdir_p(project_path)
      allow(Kernel).to receive(:require).and_call_original
      allow(Gem).to receive(:loaded_specs) { loaded_gems }
      allow(glob).to receive(:find).with(any_args) do |name|
        installed_gems.include?(name) ? [name] : []
      end
      allow(Gem::Specification).to receive(:load) { gemspec }

      installed_gems.each { |name| allow(Kernel).to receive(:require).with(name) }
    end

    context 'with .devpack file in provided directory' do
      context 'with all specified gems installed' do
        before { expect(Devpack).to receive(:warn).exactly(1).times }
        let(:requested_gems) { installed_gems }
        it { is_expected.to eql requested_gems }

        it 'adds gemspec to Gem.loaded_specs' do
          subject
          expect(loaded_gems.keys).to contain_exactly('installed1', 'installed2', 'installed3')
        end
      end

      context 'with some specified gems not installed' do
        let(:requested_gems) { installed_gems + not_installed_gems }
        it 'provides list of installed gems' do
          allow(Devpack).to receive(:warn)
          expect(subject).to eql installed_gems
        end

        it 'provides installation instructions for missing gems' do
          expect(Devpack).to receive(:warn).once do |message|
            puts message
          end
          expect(Devpack).to receive(:warn).once
          subject
        end
      end

      context 'with missing gems and DEVPACK_DEBUG enabled' do
        let(:requested_gems) { %w[not_installed1] }
        before { allow(Devpack).to receive(:debug?) { true } }
        it 'issues a warning including error and traceback' do
          expect(Devpack).to receive(:warn).at_least(:once).with(any_args) do |_level, message|
            next if message.include?('development gem(s)')
            next if message.include?('Install 1 missing gem(s)')

            [
              'Failed to load',
              'Devpack::GemNotFoundError',
              '/devpack/lib/devpack/gems.rb',
              "`activate'",
              "`load_gem'"
            ].each { |line| expect(message).to include line }
          end
          subject
        end
      end
    end

    context 'no .devpack file present in provided directory' do
      let(:requested_gems) { nil }
      before do
        expect(Devpack).to_not receive(:warn)
      end
      it { is_expected.to be_empty }
    end

    context '.gemspec found in specifications directory' do
      let(:requested_gems) { ['example'] }
      let(:installed_gems) { requested_gems }
      let(:example_gem_path) { gem_home.join('gems', 'example-1.0.0') }
      let(:gemspec_path) do
        File.expand_path(File.join(__dir__, '..', 'fixtures', 'example.gemspec'))
      end

      before do
        FileUtils.mkdir_p(example_gem_path.join('lib'))
        FileUtils.mkdir_p(gem_home.join('specifications'))
        gem_home.join('specifications', 'example.gemspec')
                .write(File.read(gemspec_path))
        example_gem_path.join('lib', 'example.rb').write('')
      end

      after { FileUtils.rm_r(gem_home.to_s) }
      before { expect(Devpack).to receive(:warn).exactly(1).times }

      it { is_expected.to eql requested_gems }
    end
  end
end
