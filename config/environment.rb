# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

if Rails.env == 'test'
  Rails.logger = Logger.new(STDOUT)
  Rails.logger.level = 1
end
