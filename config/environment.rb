# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

Rails.logger = Logger.new(STDOUT)
case Rails.env
when 'development'
  Rails.logger.level = 1
when 'test'
  Rails.logger.level = 3
else
  Rails.logger.level = 0
end
