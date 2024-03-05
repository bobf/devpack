# frozen_string_literal: true

RSpec.describe Devpack::Config do
  subject(:config) { described_class.new(pwd) }

  let(:pwd) { File.join(Dir.tmpdir, 'example') }
  let(:config_path) { File.join(pwd, '.devpack') }
  let(:lines) { %w[gem1 gem2 gem3] }
  let(:initializers) do
    %w[initializer1.rb initializer2.rb initializer3.rb].map do |path|
      File.join(pwd, '.devpack_initializers', path)
    end
  end

  context 'without initializers directory' do
    its(:devpack_initializer_paths) { is_expected.to eql [] }
    its(:devpack_initializers_path) { is_expected.to be_nil }
  end

  context 'with initializers directory' do
    before do
      FileUtils.mkdir_p(pwd)
      File.write(config_path, lines.join("\n")) unless config_path.nil?
      FileUtils.mkdir_p(File.join(pwd, '.devpack_initializers'))
      initializers.each { |initializer| FileUtils.touch(initializer) }
    end

    after { FileUtils.rm_r(pwd) if File.exist?(pwd) }

    it { is_expected.to be_a described_class }
    its(:requested_gems) do
      is_expected.to eql [
        Devpack::GemRef.new(name: 'gem1', version: nil, no_require: false),
        Devpack::GemRef.new(name: 'gem2', version: nil, no_require: false),
        Devpack::GemRef.new(name: 'gem3', version: nil, no_require: false)
      ]
    end

    its(:devpack_path) { is_expected.to eql Pathname.new(config_path) }
    its(:devpack_initializers_path) do
      is_expected.to eql Pathname.new(File.join(pwd, '.devpack_initializers'))
    end

    context 'config located in parent directory' do
      let(:pwd) { File.join(Dir.tmpdir, 'parent1', 'parent2', 'parent3', 'example') }
      let(:config_path) { File.join(Dir.tmpdir, 'parent1', '.devpack') }
      let(:initializers_path) { File.join(Dir.tmpdir, '.devpack_initializers') }

      its(:devpack_path) { is_expected.to eql Pathname.new(config_path) }
      its(:devpack_initializer_paths) { is_expected.to eql initializers }
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
        its(:devpack_initializer_paths) { is_expected.to eql initializers }
      end

      context 'with maximum parent directories' do
        let(:parents) { Devpack::Config::MAX_PARENTS - 1 }
        its(:devpack_path) { is_expected.to eql Pathname.new(config_path) }
        its(:devpack_initializer_paths) { is_expected.to eql initializers }
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
          'gem3 # an in-line comment',
          '*gem4 # will not be required'
        ]
      end

      its(:requested_gems) do
        is_expected.to eql [
          Devpack::GemRef.new(name: 'gem1', version: nil, no_require: false),
          Devpack::GemRef.new(name: 'gem2', version: nil, no_require: false),
          Devpack::GemRef.new(name: 'gem3', version: nil, no_require: false),
          Devpack::GemRef.new(name: 'gem4', version: nil, no_require: true)
        ]
      end
    end
  end
end
