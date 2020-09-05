# frozen_string_literal: true

RSpec.describe Devpack::GemSpec do
  subject(:gem_spec) { described_class.new(glob, name, requirement) }

  let(:requirement) { instance_double(Gem::Requirement, satisfied_by?: true) }
  let(:root) { Pathname.new(Dir.tmpdir) }
  let(:glob) { instance_double(Devpack::GemGlob, find: [root.join('gems', 'example-0.1.0')]) }
  let(:name) { 'example' }
  let(:gemspec_content) do
    File.read(File.expand_path(File.join(__dir__, '..', 'fixtures', 'example.gemspec')))
  end

  before do
    FileUtils.mkdir_p(root.join('gems', 'example-0.1.0'))
    FileUtils.mkdir_p(root.join('specifications', 'example-0.1.0'))
    File.write(root.join('specifications', 'example-0.1.0.gemspec'), gemspec_content)
    allow(Gem).to receive(:loaded_specs) { {} }
  end

  it { is_expected.to be_a described_class }
  its(:require_paths) { is_expected.to eql [root.join('gems', 'example-0.1.0', 'lib').to_s] }
  its(:gemspec) { is_expected.to be_a Gem::Specification }
end
