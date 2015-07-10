require 'nokogiri'
require 'dalli'
require "#{Rails.root}/lib/modules/midnight"
require "#{Rails.root}/lib/modules/r_proxy"

module Cacher
  include Midnight
  include RProxy

  def cache_retrieve_url(cache, val)

    if cache.fetch(val).present?
      return cache.fetch(val) if cache.fetch(val).match(/(\s500\s)/).nil? # match " 500 " for 500 error
    end

    cache.delete(val)

    sleep rand(1.0..10.0)

    cache.write(val, Nokogiri::HTML(RProxy.open_url_with_proxy(HOME_URL + val)).to_html, expires_in: Midnight.seconds_to_midnight.seconds)

    cache.fetch(val)
  end
end
