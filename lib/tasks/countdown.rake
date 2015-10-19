desc 'Fetch normal product prices'
task fetch_prices: :environment do
  setup

  time = Time.now

  aisles = CountdownLinksProcessor\
           .generate_aisle(CountdownAisleProcessor\
              .home_doc_fetch, @cache)

  if @cache.exist?('last')
    last_aisle = @cache.fetch('last')
    if aisles.index(last_aisle)\
       .present? && aisles\
                    .index(last_aisle) != (aisles.count - 1)
      aisles.drop(aisles.index(last_aisle))
    end
  end

  @aisle_processing = true

  require 'thread'
  work_q = Queue.new
  processed = 0
  aisles.each { |x| work_q.push x }
  workers = (0...8).map do
    Thread.new do
      begin
        while aisle = work_q.pop(true)
          CountdownAisleProcessor.grab_browse_aisle(aisle, @cache)
          @cache.write('last', aisle)
          sleep rand(1.0..5.0)
          sleep rand(5.0..10.0) if (processed % 10) == 0
        end
      rescue ThreadError
      end
    end
  end
  workers.map(&:join)

  Rails.logger.info "New Product count: #{today_count(Product)}"
  Rails.logger.info "New Special count: #{today_count(SpecialPrice)}"
  Rails.logger.info "New Normal count: #{today_count(NormalPrice)}"
  Rails.logger.info "Time Taken: #{((Time.now - time) / 60.0 / 60.0)} hours"
end

def today_count(model)
  if model == Product
    model.where('created_at >= ?', Time.zone.now.beginning_of_day).count
  else
    model.where(date: Date.today).count
  end
end

###################################################
## GENERAL SETTINGS
###################################################

def setup
  require 'nokogiri'
  require 'dalli'
  require "#{Rails.root}/lib/modules/cacher"
  require "#{Rails.root}/lib/modules/countdown_aisle_processor"
  require "#{Rails.root}/lib/modules/countdown_links_processor"
  require "#{Rails.root}/app/models/product"
  require "#{Rails.root}/app/models/normal_price"
  require "#{Rails.root}/app/models/special_price"

  include Cacher
  include CountdownLinksProcessor

  case Rails.env
  when 'production'
    @cache = Rails.cache
  else
    @cache = ActiveSupport::Cache::FileStore.new('/tmp')
  end

  @aisle_processing = false
end
