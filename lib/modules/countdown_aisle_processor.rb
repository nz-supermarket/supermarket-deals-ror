require 'nokogiri'
require "#{Rails.root}/lib/modules/cacher"
require "#{Rails.root}/lib/modules/rake_logger"
require "#{Rails.root}/lib/modules/web_scrape"
require "#{Rails.root}/lib/modules/countdown_item_processor"

module CountdownAisleProcessor
  include Cacher
  extend WebScrape

  HOME_URL = "http://shop.countdown.co.nz"

  def self.home_doc_fetch
    nokogiri_open_url(HOME_URL)
  end

  def grab_browse_aisle(aisle, cache)
    doc = cache_retrieve_url(cache, aisle)

    process_doc Nokogiri::HTML(doc)
  end

  def process_doc(doc)
    return if error?(doc)

    aisle = aisle_name(doc)

    work_q = Queue.new
    processed = 0
    doc.css('div.product-stamp.product-stamp-grid').each{|x| work_q.push x }
    workers = (0...4).map do
      Thread.new do
        begin
          while item = work_q.pop(true)
            CountdownItemProcessor.process_item(item, aisle)
          end
        rescue ThreadError
        end
      end
    end
    workers.map(&:join)
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

  module_function :grab_browse_aisle, :process_doc, :error?, :aisle_name
end
