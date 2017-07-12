source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'
gem 'sqlite3'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby

gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
#gem 'jbuilder', '~> 2.5'

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug' #, platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'capybara', '~> 2.13.0'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
  gem 'rspec-its'
  
  #gem 'guard-rspec', require: false
  #gem 'factory_girl_rails'

  gem 'coveralls', require: false
  gem 'codecov', :require => false
  gem 'factory_girl_rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bullet'
end

group :production do
  gem 'passenger'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

################
gem 'slim-rails'
gem 'stackprof'
#gem 'stackprof', github: "tmm1/stackprof", branch: "master"

gem 'pdftotext'
#gem 'mechanize'
gem 'bootstrap-sass'
gem 'kaminari'
gem 'google-analytics-rails'
gem 'draper'
gem 'config'

gem 'gnuplot'
gem 'open_uri_redirections'    # for http: -> https: redirect
gem 'contracts'
gem 'to_bool'
#gem 'csv_builder'
gem 'sitemap_generator'

gem 'jquery-datatables-rails'
gem 'hashie'
gem 'active_hash'
gem 'gretel'
