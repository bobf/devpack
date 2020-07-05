# frozen_string_literal: true

RSpec.describe Devpack::Config do
  subject(:config) { described_class.new(pwd) }

  let(:pwd) { File.join(Dir.tmpdir, 'example') }
  let(:config_path) { File.join(pwd, '.devpack') }
  let(:lines) { %w[gem1 gem2 gem3] }

  before do
    FileUtils.mkdir_p(pwd)
    File.write(config_path, lines.join("\n")) unless config_path.nil?
  end

  after { FileUtils.rm_r(pwd) if File.exist?(pwd) }

  it { is_expected.to be_a described_class }
  its(:requested_gems) { is_expected.to eql %w[gem1 gem2 gem3] }
  its(:devpack_path) { is_expected.to eql Pathname.new(config_path) }

  context 'config located in parent directory' do
    let(:pwd) { File.join(Dir.tmpdir, 'parent1', 'parent2', 'parent3', 'example') }
    let(:config_path) { File.join(Dir.tmpdir, 'parent1', '.devpack') }

    its(:devpack_path) { is_expected.to eql Pathname.new(config_path) }
  end

  describe 'parent directory limiting' do
    let(:base) { File.join(Dir.tmpdir, 'example') }
    let(:config_path) { File.join(base, '.devpack') }
    let(:pwd) { File.join(base, ['parent'] * parents) }

    before do
      FileUtils.mkdir_p(pwd)
    end

    after { FileUtils.rm_r(base) }

    context 'with too many parent directories' do
      let(:parents) { Devpack::Config::MAX_PARENTS }
      its(:devpack_path) { is_expected.to be_nil }
    end

    context 'with maximum parent directories' do
      let(:parents) { Devpack::Config::MAX_PARENTS - 1 }
      its(:devpack_path) { is_expected.to eql Pathname.new(config_path) }
    end
  end

  describe 'comments in config file' do
    let(:lines) do
      [
        '# a comment',
        'gem1',
        '  # an indented comment',
        '',
        'gem2', "\t # a tab-indented comment",
        'gem3 # an in-line comment'
      ]
    end

    its(:requested_gems) { is_expected.to eql %w[gem1 gem2 gem3] }
  end
end
