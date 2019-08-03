require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Fisk8ResultViewer
  VERSION = '1.0.8'.freeze

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.logger = Logger.new(STDOUT)
    config.load_defaults 5.1
    # config.i18n.default_locale = :ja

    config.enable_dependency_loading = true # for rails 5 production
    config.autoload_paths += %W[#{config.root}/lib #{config.root}/datatables #{config.root}/refinements]
    Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.template_engine = :slim
      g.test_framework :rspec # , view_specs: false, fixture: true
    end
  end
end
