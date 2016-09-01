require 'nokogiri'
require 'dalli'
require 'parallel'
require "#{Rails.root}/lib/modules/countdown/home_page_fetcher"
require "#{Rails.root}/lib/modules/countdown/links_processor"
class CountdownJob < ActiveJob::Base
  queue_as :countdown

  def perform(*args)
    Rails.logger.info('***** Countdown Fetch Price *****')

    setup

    lp = Countdown::LinksProcessor
         .new(Countdown::HomePageFetcher
              .nokogiri_open_url, @cache)

    aisles = lp.generate_aisle

    puts ''

    CountdownAisleJob.perform_later(aisles)
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