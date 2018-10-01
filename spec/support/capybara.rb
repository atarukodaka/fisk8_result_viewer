require 'capybara/rspec'

#use_driver = :poltergeist
use_driver = :chrome

case use_driver
when :poltergeist
  require 'capybara/poltergeist'
  
  Capybara.javascript_driver = :poltergeist
when :chrome
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   browser: :chrome,
                                   #driver_path: "/mnt/c/Users/foo/chromedriver.exe"
                                   desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                                     chrome_options: {
                                       args: %w(headless disable-gpu window-size=1680,1050),
                                     },
                                   )
                                  )
  end
  Capybara.javascript_driver = :selenium  
end
