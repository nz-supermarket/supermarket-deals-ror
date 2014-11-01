web: bundle exec rails server -p $PORT -c ./config/unicorn.rb
worker: bundle exec whenever -w 
worker: bundle exec rake db:create RAILS_ENV=production
worker: bundle exec rake db:migrate RAILS_ENV=production