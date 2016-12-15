require "#{Rails.root}/lib/modules/r_proxy"

module Countdown
  class HomePageFetcher < Nokogiri::HTML::Document
    def self.nokogiri_open_url(url = 'https://shop.countdown.co.nz/')
      resp = RProxy.open_url_with_proxy(url)
      raise 'Response Not Valid' if resp == true
      raise 'Response Not Valid' if resp.try(:code).nil?
      return Nokogiri::HTML::Document.parse(resp.body) if resp.code.to_i == 200
      raise 'Response Not Valid'
    end
  end
end
