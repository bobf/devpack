# frozen_string_literal: true

# REVIEW: Checking logs by expecting `Kernel.warn` to be called an exact amount
# of times will break if any other warnings occur. We should ensure that each
# message starts with "[devpack]".
RSpec.describe Devpack::Gems do
  subject(:gems) { described_class.new(project_path) }

  let(:project_path) { Pathname.new(Dir.tmpdir).join('example') }
  let(:devpack_path) { project_path }
  let(:gem_home) { Pathname.new(File.join(Dir.tmpdir, 'gem_home')) }
  it { is_expected.to be_a described_class }
  its(:load) { is_expected.to be_an Array }

  describe '#load' do
    subject(:load) { gems.load }

    let(:installed_gems) { %w[installed1 installed2 installed3] }
    let(:not_installed_gems) { %w[not_installed1 not_installed2 not_installed3] }

    before do
      stub_const('ENV', ENV.to_h.merge('GEM_HOME' => gem_home.to_s))
      FileUtils.mkdir_p(project_path)
      File.write(devpack_path.join('.devpack'), requested_gems.join("\n"))
      allow(Kernel).to receive(:require).and_call_original
      installed_gems.each { |name| allow(Kernel).to receive(:require).with(name) }
    end

    after { FileUtils.rm_r(devpack_path) }

    context 'with .devpack file in provided directory' do
      context 'with all specified gems installed' do
        before { expect(Kernel).to receive(:warn).exactly(1).times }
        let(:requested_gems) { installed_gems }
        it { is_expected.to eql requested_gems }
      end

      context 'with some specified gems not installed' do
        let(:requested_gems) { installed_gems + not_installed_gems }
        before { expect(Kernel).to receive(:warn).exactly(4).times }
        it { is_expected.to eql installed_gems }
      end
    end

    context 'with .devpack file in parent of provided directory' do
      let(:devpack_path) { Pathname.new(Dir.tmpdir).join('example') }
      let(:project_path) { devpack_path.join('child', 'directory') }
      let(:requested_gems) { installed_gems }
      before { expect(Kernel).to receive(:warn).exactly(1).times }
      it { is_expected.to eql requested_gems }
    end

    context 'with too many parent directories' do
      let(:devpack_path) { Pathname.new(Dir.tmpdir).join('example') }
      let(:requested_gems) { installed_gems }
      let(:project_path) do
        next_path = devpack_path
        (Devpack::Gems::MAX_PARENTS + 1).times do
          next_path = next_path.join('child')
          FileUtils.mkdir_p(next_path)
        end
        next_path
      end

      it { is_expected.to be_empty }
    end

    context 'no .devpack file present in provided directory' do
      let(:requested_gems) { [] }
      before do
        expect(Kernel).to_not receive(:warn)
        File.delete(devpack_path.join('.devpack'))
      end
      it { is_expected.to be_empty }
    end

    context '.gemspec found in provided directory' do
      let(:requested_gems) { ['example'] }
      let(:example_gem_path) { gem_home.join('gems', 'example-1.0.0') }
      let(:gemspec_path) do
        File.expand_path(File.join(__dir__, '..', 'fixtures', 'example.gemspec'))
      end

      before do
        FileUtils.mkdir_p(example_gem_path.join('lib'))
        example_gem_path.join('example.gemspec').write(File.read(gemspec_path))
        example_gem_path.join('lib', 'example.rb').write('')
      end

      after { FileUtils.rm_r(gem_home.to_s) }

      before { expect(Kernel).to receive(:warn).exactly(1).times }
      it { is_expected.to eql requested_gems }
    end
  end
end
