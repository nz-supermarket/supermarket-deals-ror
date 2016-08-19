require "#{Rails.root}/lib/modules/countdown/cacher"

# Process links on Countdown Website
module Countdown
  class LinksProcessor

    def initialize(doc, cache)
      @document = doc
      @cacher = Countdown::Cacher.new(cache)
    end

    def generate_aisle
      aisle_array = []

      al = AisleLinks.new(cat_links_fetch, @cacher)
      al.process

      # links.each do |link|
      #   # category
      #   value = link.attr('href')

      #   resp = @cacher.retrieve_url(value)

      #   next if resp.blank?

      #   sub_links = sub_links_fetch(resp)

      #   next if sub_links.nil?

      #   Parallel
      #     .each(sub_links,
      #           in_threads: 9) do |sub|
      #     value = sub.attr('href')

      #     sub_resp = @cacher.retrieve_url(value)

      #     next if sub_resp.blank?

      #     sub_sub_links = sub_links_fetch(sub_resp)

      #     next if sub_sub_links.nil?

      #     Parallel
      #       .each(sub_sub_links,
      #             in_threads: 9) do |sub_sub|
      #       value = sub_sub.attr('href')

      #       aisle_array << value if value.split('/').count >= 5
      #     end
      #   end
      # end

      # puts ''

      # aisle_array.compact
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

          binding.pry
          resp = @cacher.retrieve_url(value)

          next if resp.blank?

          al = AisleLinks.new(sub_links_fetch(resp), @cacher)

          #next if sub_links.nil?
        end
      end

      private

      def sub_links_fetch(doc)
        print '.'

        return nil if error?(Nokogiri::HTML(doc))

        Nokogiri::HTML(doc)\
          .at_css('div.single-level-navigation.filter-container')\
          .try(:css, 'a.browse-navigation-link')
      end

      def error?(doc)
        return true if doc.blank? || doc.title.blank?
        doc.title.strip.eql? 'Shop Error - Countdown NZ Ltd'
      end
    end

    private_constant :AisleLinks

    private

    def cat_links_fetch
      print '.'
      @document.at_css('div.toolbar-links-children')
        .at_css('div.row-fluid.mrow-fluid')
        .css('a.toolbar-slidebox-link')
    end
  end
end
