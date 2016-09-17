require "#{Rails.root}/lib/modules/countdown/cacher"
require "#{Rails.root}/lib/modules/countdown/item_processor"

# Process links on Countdown Website
module Countdown
  class AisleProcessor
    def initialize(cache)
      @cacher = Countdown::Cacher.new(cache)
      @total_count = 0
      @noko_doc = nil
      @aisle = nil
    end

    def grab_individual_aisle(aisle)
      resp = @cacher.retrieve_url(aisle)

      return if resp.code.to_i != 200

      convert_and_process(resp.body)

      return @total_count if @noko_doc.css('li.next').at_css('a').nil?

      # handle next page
      process_next_page
    end

    private

    def convert_and_process(doc)
      @noko_doc = Nokogiri::HTML(doc)
      process_doc @noko_doc
      @total_count += @noko_doc
                      .css('div.product-stamp.product-stamp-grid')
                      .count
    end

    def process_next_page
      last_pages = @noko_doc.css('li.page-number').css('a').map { |e| e.attr('href') }.uniq.last
      (2..last_pages.last.to_i).each do |i|
        page = last_pages[0..last_pages.size - 2] + i.to_s

        sleep(rand(10.0..30.0).seconds)
        resp = @cacher.retrieve_url(page)

        next if resp.code.to_i != 200

        convert_and_process(resp.body)
      end
      @total_count
    end

    def process_doc(doc)
      return if error?(doc)

      @aisle = aisle_name(doc)

      ip = Countdown::ItemProcessor.new(@aisle)

      items = doc.css('div.product-stamp.product-stamp-grid')

      log "count - #{items.count} items"

      start_processing(ip, items)

      log 'processed'
    end

    def error?(doc)
      return true if doc.blank? || doc.title.blank?
      doc.title.strip.eql? 'Shop Error - Countdown NZ Ltd'
    end

    def aisle_name(doc)
      text = ''
      doc.at_css('div.breadcrumbs').elements.each do |e|
        text = text + e.text + ',' if e.text.present?
      end

      text[text.length - 1] = '' # remove last comma

      text.gsub(/,\b/, ', ').downcase.gsub('groceries, ', '')
    end

    def log(string)
      values = @aisle.split(', ')
      size = values.count
      Rails.logger.info "#{values[size - 2]}, #{values[size - 1]} - " + string
    end

    def start_processing(ip, items)
      Parallel
        .each(items,
              in_threads: 4) do |item|
        ip.process_item(item)
      end
    end
  end
end
