path '/tmp/rhebok.sock'
oobgc true
max_workers ENV['WEB_CONCURRENCY'] || 5
timeout 30
before_fork do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end
after_fork do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end