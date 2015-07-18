desc 'Fetch normal product prices'
task fetch_prices: :environment do

  setup

  time = Time.now

  aisles = CountdownLinksProcessor\
           .generate_aisle(CountdownAisleProcess\
              .home_doc_fetch, @cache)

  if @cache.exist?('last')
    last_aisle = @cache.fetch('last')
    if aisles.index(last_aisle)\
       .present? && aisles.index(last_aisle) != (aisles.count - 1)
      aisles.drop(aisles.index(last_aisle))
    end
  end

  @aisle_processing = true

  pool_size = (Celluloid.cores / 2.0).ceil
  pool_size = 3 if pool_size < 2
  puts "pool size: #{pool_size}"

  pool = CountdownAisleProcess.pool(size: pool_size)

  aisles.each_with_index do |aisle, index|
    pool.async.grab_browse_aisle(aisle, @cache)
    @cache.write('last', aisle)
    sleep rand(1.0..5.0)
    sleep rand(5.0..10.0) if (index % 10) == 0
  end

  sleep(1) while pool.idle_size < pool_size

  puts "Time Taken: #{((Time.now - time) / 60.0 / 60.0)} hours"
end

###################################################
## GENERAL SETTINGS
###################################################

def setup
  require 'nokogiri'
  require 'dalli'
  require 'celluloid'
  require "#{Rails.root}/lib/modules/cacher"
  require "#{Rails.root}/lib/modules/countdown_aisle_process"
  require "#{Rails.root}/lib/modules/countdown_links_processor"

  include Cacher
  include CountdownLinksProcessor

  WebMock.allow_net_connect! if Rails.env != 'test'

  case Rails.env
  when 'production'
    @cache = Rails.cache
  else
    @cache = ActiveSupport::Cache::FileStore.new('/tmp')
  end

  @aisle_processing = false
end
