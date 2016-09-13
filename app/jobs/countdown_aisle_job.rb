require 'nokogiri'
require 'dalli'
require "#{Rails.root}/lib/modules/countdown/aisle_processor"
class CountdownAisleJob
  include Sidekiq::Worker
  sidekiq_options queue: :countdownitem

  def perform(*args)
    Rails.logger.info('***** Countdown Aisle *****')

    setup

    ap = Countdown::AisleProcessor
         .new(@cache)

    ap.grab_individual_aisle(args[0])
  end

  private

  ###################################################
  ## GENERAL SETTINGS
  ###################################################

  def setup
    ActiveRecord::Base.connection_pool.checkout_timeout = 15

    case Rails.env
    when 'production'
      @cache = Rails.cache
    when 'development'
      WebMock.disable!
      @cache = ActiveSupport::Cache::FileStore.new('/tmp')
    else
      @cache = ActiveSupport::Cache::FileStore.new('/tmp')
    end
  end
end
