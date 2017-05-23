require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fisk8Viewer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.template_engine = :slim
      g.test_framework :rspec #, view_specs: false, fixture: true
    end

    ################################################################
    # action mailer
    config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      enable_starttls_auto: true,
      address: 'smtp.gmail.com',
      port: '587',
      domain: 'smtp.gmail.com',
      authentication: 'plain',
      user_name: Settings.notification.gmail_address,
      password: Settings.notification.gmail_password,
    }
  end
  VERSION = "1.0.0-pre1"
end
