host '0.0.0.0'
port ENV['HTTP_PORT']
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