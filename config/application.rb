require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Fisk8ResultViewer
  VERSION = "1.0.2-pre3"
  
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/datatables #{config.root}/refinements)
    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.template_engine = :slim
      g.test_framework :rspec #, view_specs: false, fixture: true
    end
  end
end
