require 'nokogiri'
require 'dalli'
require "#{Rails.root}/lib/modules/midnight"
require "#{Rails.root}/lib/modules/r_proxy"

module Countdown
  class Cacher
    include Midnight
    include RProxy

    def initialize(cache, url = 'https://shop.countdown.co.nz')
      @cache = cache
      @home_url = url
    end

    def retrieve_url(val)
      cached_value = @cache.fetch(val)

      # guard condition
      # do not write to cache if previous cache record exist
      return cached_value if cached_value.present? && cached_value.match(/(\s500\s)/).nil? # match " 500 " for 500 error

      @cache.delete(val)

      sleep rand(1.0..10.0)

      @cache.write(val, Nokogiri::HTML(RProxy.open_url_with_proxy(@home_url + val)).to_html, expires_in: 239.minutes)

      @cache.fetch(val)
    end
  end
end
