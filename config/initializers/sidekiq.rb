require 'sidekiq/scheduler'

redis_conn = proc {
  Redis.new(host: 'dokku-redis-supermarket', port: '6379')
}

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 10, &redis_conn)
  config.average_scheduled_poll_interval = 10
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path("../../schedule.yml",__FILE__))
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 20, &redis_conn)
end