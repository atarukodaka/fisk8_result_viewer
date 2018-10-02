require 'capybara/rspec'

Capybara.register_driver :chrome do |app|
  # on default, it works as headless.
  # if u want to run w/o headless, run 'HEADLESS=off bundle execute rspec'

  args = %w(disable-gpu window-size=1680,1050)
  args.push('headless') unless ENV['HEADLESS'] == "off"

  options = Selenium::WebDriver::Chrome::Options.new(args: args)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome
