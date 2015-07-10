require 'nokogiri'
require "#{Rails.root}/lib/modules/r_proxy"

module WebScrape
  include RProxy
  def nokogiri_open_url(url)
    return Nokogiri::HTML(RProxy.open_url_with_proxy(url, @aisle_processing))
  end
end
