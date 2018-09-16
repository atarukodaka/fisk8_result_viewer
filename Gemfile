source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby

gem 'coffee-rails', '~> 4.2'

gem 'slim-rails'
gem 'pdftotext'
gem 'bootstrap-sass'
gem 'kaminari'
gem 'draper'   ## decoration
gem 'config'
gem 'open_uri_redirections'    # for http: -> https: redirect
gem 'sitemap_generator'
gem 'active_hash', '~> 1.5'   # 2.x doenst support Ruby < 2.4 and Rails < 5
gem 'gretel'       ## breadcriumb
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'google-analytics-rails'
gem 'rspec'   ## for heroku
gem 'stackprof'  # profiling


## for each environments
group :development, :test do
  gem 'bullet'
  gem 'sqlite3'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'capybara', '~> 2.13.0'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
  gem 'rspec-its'
  
  gem 'coveralls', require: false
  gem 'codecov', require: false
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem 'rack-dev-mark'
end

group :production do
  gem 'passenger'
  gem 'pg'
end
