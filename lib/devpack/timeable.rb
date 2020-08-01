# frozen_string_literal: true

# Provides result and run time of a given block.
module Timeable
  def timed
    start = Time.now.utc
    result = yield
    [result, Time.now.utc - start]
  end
end
