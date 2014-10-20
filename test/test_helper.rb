ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'capybara/rspec'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

	# RSpec
	# spec/support/factory_girl.rb
	RSpec.configure do |config|
	  config.include FactoryGirl::Syntax::Methods
	end

	# Cucumber
	World(FactoryGirl::Syntax::Methods)


end
