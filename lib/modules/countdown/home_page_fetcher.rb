require "#{Rails.root}/lib/modules/r_proxy"

module Countdown
  class HomePageFetcher < Nokogiri::HTML::Document
    def self.nokogiri_open_url(url = 'https://shop.countdown.co.nz/')
      resp = RProxy.open_url_with_proxy(url)
      if resp.code == 200
        return Nokogiri::HTML::Document.parse(resp.body)
      else
        throw Net::HTTPServiceUnavailable
      end
    end
  end
end
