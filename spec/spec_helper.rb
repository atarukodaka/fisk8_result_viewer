################################################################

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  #config.include Helper
end


################
## Codecov
require 'simplecov'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
SimpleCov.start do
  #add_filter 'spec/updaters/consistency_spec.rb'
  add_filter 'spec'
  #add_filter 'config/initializers/direction.rb'
end

