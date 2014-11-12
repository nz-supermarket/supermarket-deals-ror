IronWorker.configure do |config|
  config.token = ENV['IRON_WORKER_TOKEN']
  config.project_id = ENV['IRON_WORKER_PROJECT_ID']

  # Use the line below if you're using an ActiveRecord database
  config.database = Rails.configuration.database_configuration[Rails.env]
end