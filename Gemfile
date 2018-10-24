source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# ruby '2.4.4'

gem 'rails', '~> 5.1.0'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby

gem 'json'    # , '>= 2.0.0'
gem 'coffee-rails', '~> 4.2'

gem 'slim-rails'
gem 'pdftotext'
gem 'bootstrap-sass'
gem 'kaminari'                           ## paging
gem 'draper'                              ## decoration
gem 'config'
gem 'open_uri_redirections'         ## for http: -> https: redirect
gem 'sitemap_generator'
gem 'active_hash', '~> 1.5'         ## 2.x doenst support Ruby < 2.4 and Rails < 5
gem 'gretel'                                 ## breadcriumb
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'rspec'                                 ## for heroku
gem 'stackprof'                           # # profiling

group :development, :test do
  gem 'bullet'
  gem 'sqlite3'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rubocop', require: false
end

group :test do
  gem 'capybara', '~> 3.8.0'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'rspec-its'

  gem 'database_cleaner'
  gem 'factory_bot_rails'

  gem 'coveralls', require: false
  gem 'codecov', require: false
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem 'rack-mini-profiler'
  gem 'activerecord-cause'
  gem 'rack-dev-mark'
  # gem 'pg'
end

group :production do
  gem 'pg'
end

# gem 'daru'  # , '~> 0.2'
# gem 'statsample' # , '~> 2.1.0'
