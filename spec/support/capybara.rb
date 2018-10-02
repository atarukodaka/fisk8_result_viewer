require 'capybara/rspec'

Capybara.register_driver :selenium do |app|
  args = %w(disable-gpu window-size=1680,1050)
  args.push('headless') unless ENV['HEADLESS'] == "off"
  
  Capybara::Selenium::Driver.
    new(app,
        browser: :chrome,
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
          chrome_options: {
            args: args,
          },
        )
       )
end

Capybara.javascript_driver = :selenium
                                               
