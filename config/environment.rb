# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Remote Logging on Paper Trail
config.logger = RemoteSyslogLogger.new('logs2.papertrailapp.com', 53786, :program => "rails-#{RAILS_ENV}")
