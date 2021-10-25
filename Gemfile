source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

group :development do
  gem "capistrano", "~> 3.10", require: false
  gem "capistrano-rails", "~> 1.3", require: false
end

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test, :development do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'rspec-rails'
  gem "shoulda-matchers"
  gem 'capybara-email'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  # gem 'factory_girl_rails'
  gem 'timecop'
  gem 'simplecov'
  gem 'faker'#, :git => 'https://github.com/stympy/faker.git', :branch => 'master'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise'
gem 'dotenv-rails'
gem 'sidekiq'
gem 'whenever', require: false
gem 'activeadmin'
gem 'cancancan'
gem 'draper'
gem 'pundit'
gem 'ransack', github: 'activerecord-hackery/ransack', branch: '8daa87a0389d380f7c9fd7ea9cb5bda634d5dc7d'
gem 'gon'
gem 'kaminari'
gem "bower-rails", "~> 0.11.0"
gem 'jquery-rails'
gem 'httparty', '~> 0.13.7'
gem 'rb-readline'
gem 'capistrano-ext'
gem 'capistrano-passenger'
gem 'capistrano-rvm'
gem 'capistrano-bundler'
gem 'newrelic_rpm'
gem 'jwt'
# gem 'scout_apm'
gem 'openssl'
gem "audited", "~> 4.9"
gem "roo", "~> 2.8.0"
gem "sidekiq-throttled"
gem "brakeman"
gem "sentry-raven"
gem 'rack-attack'
gem 'rubyzip'
