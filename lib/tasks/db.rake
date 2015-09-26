desc "Database tasks"
namespace :db do
  desc "Reset db"
  task :reset do

    target_environment = Rails.env || RAILS_ENV || 'test'
    ActiveRecord::Base.connection.disconnect!

    `dropdb deals_test`
    `createdb deals_test`
    `bundle exec rake db:migrate RAILS_ENV=#{target_environment} --trace`

    puts "Reset database"
  end
end