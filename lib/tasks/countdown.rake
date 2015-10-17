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
  aisles.each{|x| work_q.push x }
  workers = (0...4).map do
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
  end; "ok"
  workers.map(&:join); "ok"

  Rails.logger.info "New Product count: #{Product.where("created_at >= ?", Time.zone.now.beginning_of_day).count}"
  Rails.logger.info "New Special count: #{SpecialPrice.where("created_at >= ?", Time.zone.now.beginning_of_day).count}"
  Rails.logger.info "New Normal count: #{NormalPrice.where("created_at >= ?", Time.zone.now.beginning_of_day).count}"
  Rails.logger.info "Time Taken: #{((Time.now - time) / 60.0 / 60.0)} hours"
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
