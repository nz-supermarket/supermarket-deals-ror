source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

gem 'responders', '~> 2.0'
gem 'oj'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use postgres database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
gem 'rails_12factor', group: :production

# dependencies
gem 'foreman'

gem 'dalli', '~> 2.7'
gem 'connection_pool'

# used for rake countdown task
gem 'nokogiri'
gem 'socksify'
gem 'tor_requests'

# Use bootstrap for style and formatting
gem 'bootstrap-sass'

# Analytics with New Relic
gem 'newrelic_rpm'

# Pagination / Infinite Scrolling
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',          group: :doc

# datatable
gem 'jquery-ui-rails'

# processes and thread
gem 'parallel'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use puma killer for puma
gem 'puma_worker_killer', github: 'schneems/puma_worker_killer', ref: 'ddd5326'

# message queuing
gem 'redis-namespace'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sidekiq-failures'

# sitemap generator
gem 'sitemap_generator'

# meta tags generator
gem 'meta-tags'

# performance analyzer
gem 'peek'
gem 'peek-sidekiq'
gem 'peek-dalli'
gem 'peek-pg'

group :development, :test do
  # debugger
  gem 'pry-byebug'
  gem 'rubocop', require: false

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Test uses
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  gem 'pickle'
  gem 'rspec-rails'
  gem 'fuubar'
  gem 'capybara'
  gem 'factory_girl', '~> 4.4.0'
  gem 'factory_girl_rails'
  gem 'factory_girl_rspec'
  gem 'database_cleaner'

  # Fake data generator
  gem 'faker'

  # web mock up
  gem 'vcr'
  gem 'webmock'

  # javascript headless testing
  gem 'poltergeist'
end
