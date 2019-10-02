# frozen_string_literal: true

require 'rubocop'
require 'rack/utils'

require_relative 'rubocop/norb'
require_relative 'rubocop/norb/version'
require_relative 'rubocop/norb/inject'

RuboCop::Norb::Inject.defaults!

require_relative 'rubocop/cop/norb_cops'
