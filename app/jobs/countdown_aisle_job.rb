require 'nokogiri'
require 'dalli'
require 'parallel'
require "#{Rails.root}/lib/modules/countdown/aisle_processor"
require "#{Rails.root}/app/models/product"
require "#{Rails.root}/app/models/normal_price"
require "#{Rails.root}/app/models/special_price"
class CountdownAisleJob < ActiveJob::Base
  queue_as :countdown

  def perform(*args)
    Rails.logger.info('***** Countdown Aisle *****')

    setup

    ap = Countdown::AisleProcessor
         .new(@cache)

    Parallel
      .each_with_index(&args.shuffle,
                       in_threads: 9,
                       in_process: 4) do |aisle, index|
      ap.grab_individual_aisle(aisle)
      Rails.logger.info "worker size left - #{&args.size - index}"
      sleep rand(1.0..5.0)
      sleep rand(3.0..8.0) if (index % 10) == 0
      sleep rand(5.0..10.0) if (index % 20) == 0
    end

    Rails.logger.info "New Product count: #{today_count(Product)}"
    Rails.logger.info "New Special count: #{today_count(SpecialPrice)}"
    Rails.logger.info "New Normal count: #{today_count(NormalPrice)}"

    ActiveRecord::Base
      .connection.execute('REFRESH MATERIALIZED VIEW lowest_prices')
  end

  private

  def today_count(model)
    ActiveRecord::Base.connection_pool.with_connection do
      if model == Product
        model.where('created_at >= ?', Time.zone.now.beginning_of_day).count
      else
        model.where(date: Date.today).count
      end
    end
  end

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