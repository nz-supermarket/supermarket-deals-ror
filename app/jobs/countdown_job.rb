require 'nokogiri'
require 'dalli'
require "#{Rails.root}/lib/modules/countdown/home_page_fetcher"
require "#{Rails.root}/lib/modules/countdown/links_processor"
class CountdownJob
  include Sidekiq::Worker
  sidekiq_options queue: :countdown

  def perform(*args)
    Rails.logger.info('***** Countdown Fetch Price *****')

    setup

    lp = Countdown::LinksProcessor
         .new(Countdown::HomePageFetcher
              .nokogiri_open_url, @cache)

    lp.generate_aisle
  end

  private

  ###################################################
  ## GENERAL SETTINGS
  ###################################################

  def setup
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
