require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Fisk8ResultViewer
#module Fisk8Viewer
  VERSION = "1.0.1-pre1"
  
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.autoload_paths += %W(#{config.root}/lib)
    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.template_engine = :slim
      g.test_framework :rspec #, view_specs: false, fixture: true
    end
  end
end
