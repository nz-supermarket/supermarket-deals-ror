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
        if args[0].split('/').count > 5
          CountdownAisleJob.perform_in(rand(1.0..3.0).minutes, args[0])
        end

        retrieve_and_process(args[0])
      end

      private

      def retrieve_and_process(value)
        resp = RProxy.open_url_with_proxy('https://shop.countdown.co.nz' + value)

        sub_links_fetch(resp.body).each do |link|
          AisleLinks.perform_in(rand(20.0..50.0).seconds, link.attr('href'))
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
    end

    private_constant :AisleLinks
  end
end
