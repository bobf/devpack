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

      context 'another gem name is a substring of sought gem name' do
        let(:name) { 'pry' }
        let(:gem_path) { File.join(base_path, 'gems', 'pry-0.1.0') }
        let(:other_path) { File.join(base_path, 'gems', 'pry-rails-0.1.0') }
        before { FileUtils.mkdir_p(other_path) }
        after { FileUtils.rm_r(other_path) }
        it { is_expected.to eql gem_path }
      end

      context 'older version is string-sorted higher than newer version' do
        let(:name) { 'example' }
        let(:gem_path) { File.join(base_path, 'gems', 'example-0.10.0') }
        let(:other_path) { File.join(base_path, 'gems', 'example-0.9.0') }
        before { FileUtils.mkdir_p(other_path) }
        after { FileUtils.rm_r(other_path) }
        it { is_expected.to eql gem_path }
      end
    end
  end
end
