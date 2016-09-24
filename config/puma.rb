threads 16,32
workers 2
preload_app!
pidfile 'tmp/pids/puma.pid'
quiet false

bind 'unix:///tmp/puma.sock'

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
  PumaWorkerKiller.config do |config|
    config.ram           = 512 # mb
    config.frequency     = 5    # seconds
    config.percent_usage = 0.97
    config.rolling_restart_frequency = 1 * ( 60 * 60 ) # 1 hours in seconds
    config.reaper_status_logs = false
  end
  PumaWorkerKiller.start
end