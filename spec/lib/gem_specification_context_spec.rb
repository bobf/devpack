# frozen_string_literal: true

RSpec.describe Devpack::GemSpecificationContext do
  let(:gemspec_path) do
    File.expand_path(File.join(__dir__, '..', 'fixtures', 'example.gemspec'))
  end

  it 'extracts require_paths from a gemspec' do
    gemspec = File.read(gemspec_path)
    expect(described_class.require_paths).to be_nil
    described_class.class_eval(gemspec)
    expect(described_class.require_paths).to eql ['lib']
  end
end
