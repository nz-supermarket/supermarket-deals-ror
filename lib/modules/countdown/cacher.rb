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
      return cached_value if cached_value && cached_value.try(:code).to_i == 200

      @cache.delete(val)

      sleep rand(1.0..10.0)

      @cache.write(val, RProxy.open_url_with_proxy(@home_url + val), expires_in: 239.minutes)

      @cache.fetch(val)
    end
  end
end
