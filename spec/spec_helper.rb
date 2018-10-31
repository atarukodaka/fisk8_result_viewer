RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_excluding updater: true, feature: true, rake: true, error_handler: true

  config.around(:each) do |example|
    dest = ENV.fetch('DEST', 'stackprof-test')
    path = Rails.root.join("tmp/#{dest}-#{example.full_description.parameterize}.dump")
    interval = ENV.fetch('INTERVAL', 1000).to_i
    StackProf.run(mode: :cpu, out: path.to_s, interval: interval) do
      example.run
    end
  end
end
################
## VCR
require 'vcr'
require 'webmock'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.configure_rspec_metadata!
  c.ignore_localhost = true
end

################
## Codecov

require 'simplecov'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
SimpleCov.start do
  add_filter 'spec'
  add_filter 'config'
end
