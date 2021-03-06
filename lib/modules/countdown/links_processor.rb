require "#{Rails.root}/lib/modules/countdown/cacher"

# Process links on Countdown Website
module Countdown
  class LinksProcessor
    def initialize(doc, cache)
      @document = doc
      @cacher = Countdown::Cacher.new(cache)
    end

    def generate_aisle
      cat_links_fetch.each do |link|
        AisleLinks.perform_async(link.attr('href'))
      end
    end

    private

    def cat_links_fetch
      @document.at_css('div.toolbar-links-children')
               .at_css('div.row-fluid.mrow-fluid')
               .css('a.toolbar-slidebox-link')
    end

    class AisleLinks
      include Sidekiq::Worker
      sidekiq_options queue: :countdown

      def perform(*args)
        @doc = get_doc(args[0])

        start_process_items(args[0])

        process_remaining if sub_aisle_exist?(args[0], @doc)
      end

      private

      def get_doc(value)
        RProxy.open_url_with_proxy('https://shop.countdown.co.nz' + value)
      end

      def start_process_items(value)
        sub_links_fetch(@doc.body).each do |link|
          next if link.attr('href') != value
          CountdownAisleJob.perform_in(rand(1.0..5.0).minutes, value)
          Rails.logger.info(" ***** #{value} Finished ***** ")
        end
      end

      def process_remaining
        sub_links_fetch(@doc.body).each do |link|
          AisleLinks.perform_in(rand(10.0..60.0).seconds, link.attr('href'))
        end
      end

      def sub_links_fetch(doc)
        return nil if error?(Nokogiri::HTML(doc))

        Nokogiri::HTML(doc)
                .at_css('div.single-level-navigation.filter-container')
                .try(:css, 'a.browse-navigation-link')
      end

      def error?(doc)
        return true if doc.blank? || doc.title.blank?
        doc.title.strip.eql? 'Shop Error - Countdown NZ Ltd'
      end

      def sub_aisle_exist?(value, doc)
        return false if sub_links_fetch(doc.body).first.nil?
        sub_path_count(sub_links_fetch(doc.body).first.attr('href')) > sub_path_count(value)
      end

      def sub_path_count(path)
        path.split('/').count
      end
    end
  end
end
