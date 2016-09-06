require "#{Rails.root}/lib/modules/countdown/cacher"

# Process links on Countdown Website
module Countdown
  class LinksProcessor
    def initialize(doc, cache)
      @document = doc
      @cacher = Countdown::Cacher.new(cache)
    end

    def generate_aisle
      al = AisleLinks.new(cat_links_fetch, @cacher)
      al.process.compact!.flatten!.uniq
    end

    private

    def cat_links_fetch
      print '.'
      @document.at_css('div.toolbar-links-children')
        .at_css('div.row-fluid.mrow-fluid')
        .css('a.toolbar-slidebox-link')
    end

    class AisleLinks
      def initialize(links, cacher)
        @links = links
        @cacher = cacher
        @result = []
      end

      def process
        @links.each do |link|
          value = link.attr('href')

          if value.split('/').count > 5
            CountdownAisleJob.set(wait: rand(5.0..10.0).seconds).perform_later(value)
            next
          end

          retrieve_and_process(value)
        end
        return @result if @result.any?
      end

      private

      def retrieve_and_process(value)
        resp = @cacher.retrieve_url(value)

        @result << AisleLinks.new(sub_links_fetch(resp.body), @cacher).process
        return @result if @result.any?
      end

      def sub_links_fetch(doc)
        print '.'

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
