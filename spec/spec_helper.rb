# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter(%r{\/spec\/})
  minimum_coverage 95
  add_group 'lib', 'lib'
end

require_relative '../lib/codebreaker_ai'

I18n.load_path << Dir[File.expand_path('../lib/codebreaker_ai/locales', __dir__) + '/*.yml']
I18n.config.available_locales = :en

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
end
