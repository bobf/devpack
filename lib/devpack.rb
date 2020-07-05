# frozen_string_literal: true

require 'rubygems'
require 'pathname'

require 'devpack/config'
require 'devpack/gems'
require 'devpack/gem_glob'
require 'devpack/gem_path'
require 'devpack/messages'
require 'devpack/version'

module Devpack
  class Error < StandardError; end
end

unless ENV.key?('DISABLE_DEVPACK')
  config = Devpack::Config.new(Dir.pwd)
  Devpack::Gems.new(config).load
end
