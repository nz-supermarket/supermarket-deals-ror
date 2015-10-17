require 'nokogiri'
require "#{Rails.root}/lib/modules/cacher"
require "#{Rails.root}/lib/modules/rake_logger"
require "#{Rails.root}/lib/modules/web_scrape"
require "#{Rails.root}/lib/modules/countdown_item_processor"

module CountdownAisleProcessor
  include Celluloid
  include Celluloid::Logger
  include Cacher
  extend WebScrape

  finalizer :finish

  HOME_URL = "http://shop.countdown.co.nz"

  def self.home_doc_fetch
    nokogiri_open_url(HOME_URL)
  end

  def grab_browse_aisle(aisle, cache)
    doc = cache_retrieve_url(cache, aisle)

    process_doc Nokogiri::HTML(doc)
  end

  def finish
    Rails.logger.info "terminating #{self}"
    terminate
  end

  def process_doc(doc)
    return if error?(doc)

    aisle = aisle_name(doc)

    Rails.logger.info "#{doc.css('div.product-stamp.product-stamp-grid').count} item for #{aisle}"

    pool = CountdownItemProcessor.pool(size: 3)

    doc.css('div.product-stamp.product-stamp-grid').each do |item|
      pool.async.process_item(item, aisle)
    end

    Rails.logger.info "finish processing #{aisle}"
  end

  def error?(doc)
    return true if doc.blank? or doc.title.blank?
    doc.title.strip.eql? 'Shop Error - Countdown NZ Ltd'
  end

  def aisle_name(doc)
    text = ""
    doc.at_css("div.breadcrumbs").elements.each do |e|
      text = text + e.text + ',' if e.text.present?
    end

    text[text.length - 1] = "" # remove last comma

    text.gsub(/,\b/, ', ').downcase.gsub('groceries, ', '')
  end
end
