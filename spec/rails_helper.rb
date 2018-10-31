ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

require 'spec_helper'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  ## database cleaner
  require 'database_cleaner'
  config.before(:suite) do
    load Rails.root.join('db', 'seeds.rb')
    DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.clean_with :truncation, except: %w[category_types categories segments]
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  ## FactoryBot
  require 'factory_bot_rails'
  config.include FactoryBot::Syntax::Methods

  config.before(:all) do
    FactoryBot.reload
  end
end
