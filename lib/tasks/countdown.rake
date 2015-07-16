desc 'Fetch normal product prices'
task :fetch_prices => :environment do

  setup

  time = Time.now

  aisles = generate_aisle(CountdownAisleProcess.home_doc_fetch)

  if @cache.exist?('last')
    last_aisle = @cache.fetch('last')
    if aisles.index(last_aisle).present? and aisles.index(last_aisle) != (aisles.count - 1)
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
    if (index % 10) == 0
      sleep rand(5.0..10.0)
    end
  end

  sleep(1) while pool.idle_size < pool_size

  puts "Time Taken: #{((Time.now - time) / 60.0 / 60.0)} hours"
end

def cat_links_fetch(doc)
  print "."
  doc.at_css("div.toolbar-links-children").at_css("div.row-fluid.mrow-fluid").css("a.toolbar-slidebox-link")
end

def sub_links_fetch(doc)
  print "."

  return nil if error?(Nokogiri::HTML(doc))

  Nokogiri::HTML(doc).at_css("div.single-level-navigation.filter-container").css("a.browse-navigation-link")
end

def error?(doc)
  return true if doc.blank? or doc.title.blank?
  doc.title.strip.eql? 'Shop Error - Countdown NZ Ltd'
end

def generate_aisle(doc)
  aisle_array = []

  links = cat_links_fetch(doc)

  links.each do |link|
    # category
    value = link.attributes["href"].value

    resp = Cacher.cache_retrieve_url(@cache, value)

    next if resp.blank?

    sub_links = sub_links_fetch(resp)

    next if sub_links.nil?

    sub_links.each do |sub|
      value = sub.attributes["href"].value

      sub_resp = Cacher.cache_retrieve_url(@cache, value)

      next if sub_resp.blank?

      sub_sub_links = sub_links_fetch(sub_resp)

      next if sub_sub_links.nil?

      sub_sub_links.each do |sub_sub|
        value = sub_sub.attributes["href"].value

        if value.split("/").count >= 5
          aisle_array << value
        end
      end
    end
  end

  puts ""

  aisle_array.compact
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

  include Cacher

  case Rails.env
  when 'production'
    @cache = Rails.cache
  else
    @cache = ActiveSupport::Cache::FileStore.new("/tmp")
  end

  @aisle_processing = false
end
