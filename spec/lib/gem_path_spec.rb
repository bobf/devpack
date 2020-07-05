# frozen_string_literal: true

RSpec.describe Devpack::GemPath do
  subject(:gem_path) { described_class.new(glob, name) }

  let(:glob) { double(find: Pathname.new(Dir.tmpdir)) }
  let(:name) { 'example' }

  it { is_expected.to be_a described_class }
  its(:require_paths) { is_expected.to be_an Array }
end
