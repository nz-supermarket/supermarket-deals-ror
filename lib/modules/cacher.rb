require 'nokogiri'
require 'dalli'
require "#{Rails.root}/lib/modules/midnight"
require "#{Rails.root}/lib/modules/r_proxy"

module Cacher
  include Midnight
  include RProxy

  def cache_retrieve_url(cache, val, home_url = 'https://shop.countdown.co.nz')

    cached_value = cache.fetch(val)

    if cached_value.present?
      return cached_value if cached_value.match(/(\s500\s)/).nil? # match " 500 " for 500 error
    end

    cache.delete(val)

    sleep rand(1.0..10.0)

    cache.write(val, Nokogiri::HTML(RProxy.open_url_with_proxy(home_url + val)).to_html, expires_in: 239.minutes)

    cache.fetch(val)
  end

  module_function :cache_retrieve_url
end
