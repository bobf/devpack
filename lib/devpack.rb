# frozen_string_literal: true

require 'rubygems'
require 'pathname'

require 'devpack/version'
require 'devpack/gems'
require 'devpack/gem_specification_context'

module Devpack
  class Error < StandardError; end
end

Devpack::Gems.new('.').load unless ENV.key?('DISABLE_DEVPACK')
