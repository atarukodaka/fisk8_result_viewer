require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :chrome do |app|
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(disable-gpu window-size=1680,1050) }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: caps)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=1680,1050) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end


Capybara.javascript_driver = (jsd = ENV['JAVASCRIPT_DRIVER']) ? jsd.to_sym : :headless_chrome

