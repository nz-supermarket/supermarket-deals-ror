source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', '>= 5.0.2', github: 'rails/rails'
gem 'rails'

gem 'responders', '~> 2.3', '>= 2.3.0'
gem 'oj'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use postgres database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '>= 4.2.1'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
gem 'rails_12factor', group: :production

# dependencies
gem 'foreman'

gem 'dalli', '~> 2.7'
gem 'connection_pool'

# used for rake countdown task
gem 'nokogiri', '>= 1.8.2'
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
gem 'jquery-rails', '>= 4.3.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'jquery-turbolinks', '>= 2.1.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',          group: :doc

# datatable
gem 'jquery-ui-rails', '>= 6.0.1'

# processes and thread
gem 'parallel'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'puma', '~> 3.6.0'
# Use puma killer for puma
gem 'puma_worker_killer', github: 'schneems/puma_worker_killer', ref: 'ddd5326'

# message queuing
gem 'redis-namespace'
gem 'sidekiq', '>= 5.0.4'
gem 'sidekiq-scheduler', '>= 2.1.2'
gem 'sidekiq-statistic', git: 'https://github.com/davydovanton/sidekiq-statistic.git', branch: 'master'
gem 'sidekiq-failures', '>= 1.0.0'

# sitemap generator
gem 'sitemap_generator'

# meta tags generator
gem 'meta-tags', '>= 2.4.0'

# performance analyzer
gem 'peek', '>= 0.2.0'
gem 'peek-sidekiq', '>= 1.0.3'
gem 'peek-dalli', '>= 1.1.3'
gem 'peek-pg', '>= 1.3.0'

group :development, :test do
  # debugger
  gem 'pry-byebug'
  gem 'rubocop', '>= 0.49.0', require: false

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Test uses
  gem 'cucumber'
  gem 'cucumber-rails', '>= 1.4.5', :require => false
  gem 'pickle'
  gem 'rspec-rails', '>= 3.5.2'
  gem 'fuubar'
  gem 'capybara', '>= 2.13.0'
  gem 'factory_girl', '~> 4.4.0'
  gem 'factory_girl_rails', '>= 4.4.1'
  gem 'factory_girl_rspec'
  gem 'database_cleaner'

  # Fake data generator
  gem 'faker'

  # web mock up
  gem 'vcr'
  gem 'webmock'

  # javascript headless testing
  gem 'poltergeist', '>= 1.14.0'
end
