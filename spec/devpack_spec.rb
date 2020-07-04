# frozen_string_literal: true

RSpec.describe Devpack do
  it 'has a version number' do
    expect(Devpack::VERSION).not_to be nil
  end
end
