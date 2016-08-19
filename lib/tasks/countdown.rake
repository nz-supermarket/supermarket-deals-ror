desc 'Fetch normal product prices'
task fetch_prices: :environment do
  setup

  time = Time.now

  lp = Countdown::LinksProcessor
         .new(Countdown::HomePageFetcher
                .nokogiri_open_url, @cache)

  aisles = lp.generate_aisle

  if @cache.exist?('last')
    last_aisle = @cache.fetch('last')
    if aisles.index(last_aisle)\
       .present? && aisles\
                    .index(last_aisle) != (aisles.count - 1)
      aisles.drop(aisles.index(last_aisle))
    end
  end

  Parallel
    .each_with_index(aisles.shuffle,
                     in_threads: 9,
                     in_process: 4) do |aisle, index|
    #CountdownAisleProcessor.grab_browse_aisle(aisle, @cache)
    @cache.write('last', aisle)
    Rails.logger.info "worker size left - #{aisles.size - index}"
    sleep rand(1.0..5.0)
    sleep rand(3.0..8.0) if (index % 10) == 0
    sleep rand(5.0..10.0) if (index % 20) == 0
  end

  Rails.logger.info "New Product count: #{today_count(Product)}"
  Rails.logger.info "New Special count: #{today_count(SpecialPrice)}"
  Rails.logger.info "New Normal count: #{today_count(NormalPrice)}"
  Rails.logger.info "Time Taken: #{((Time.now - time) / 60.0 / 60.0)} hours"

  ActiveRecord::Base
    .connection.execute('REFRESH MATERIALIZED VIEW lowest_prices')
end

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
  require 'nokogiri'
  require 'dalli'
  require 'parallel'
  require "#{Rails.root}/lib/modules/countdown/home_page_fetcher"
  require "#{Rails.root}/lib/modules/countdown/links_processor"

  require "#{Rails.root}/app/models/product"
  require "#{Rails.root}/app/models/normal_price"
  require "#{Rails.root}/app/models/special_price"

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
