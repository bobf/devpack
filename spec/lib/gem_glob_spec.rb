# frozen_string_literal: true

RSpec.describe Devpack::GemGlob do
  subject(:gem_glob) { described_class.new }

  it { is_expected.to be_a described_class }
  describe '#find' do
    subject(:find) { gem_glob.find(name) }
    let(:name) { 'example' }

    context 'gem not present in GEM_PATH' do
      it { is_expected.to be_nil }
    end

    context 'gem present in GEM_PATH' do
      let(:base_path) { File.join(Dir.tmpdir, 'gem_path') }
      let(:gem_path) { File.join(base_path, 'gems', 'example-0.1.0') }

      before do
        stub_const('ENV', ENV.to_h.merge('GEM_PATH' => base_path))
        FileUtils.mkdir_p(gem_path)
      end

      after { FileUtils.rm_r(gem_path) }

      it { is_expected.to eql gem_path }

      context 'gem version provided' do
        let(:name) { 'example:0.1.0' }

        it { is_expected.to eql gem_path }
      end
    end
  end
end
