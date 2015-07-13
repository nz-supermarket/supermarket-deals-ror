require 'nokogiri'
require "#{Rails.root}/lib/modules/cacher"
require "#{Rails.root}/lib/modules/rake_logger"
require "#{Rails.root}/lib/modules/web_scrape"

class CountdownAisleProcess < Object
  include Celluloid
  include Celluloid::Logger
  include Cacher
  include RakeLogger
  extend WebScrape

  HOME_URL = "http://shop.countdown.co.nz"
  FILTERS = "/Shop/UpdatePageSize?pageSize=400&snapback="

  Celluloid.logger = Rails.logger

  def self.home_doc_fetch
    nokogiri_open_url(HOME_URL)
  end

  def grab_browse_aisle(aisle, cache)
    @log_string_builder = ""

    doc = cache_retrieve_url(cache, FILTERS + aisle)

    process_doc Nokogiri::HTML(doc)

    @log_string_builder
  end

  def process_doc(doc)
    return if error?(doc)

    aisle = aisle_name(doc)

    puts doc.css('div.details-container.row-fluid.mrow-fluid').count

    doc.css('div.product-stamp.product-stamp-grid').each do |item|
      process_item(item, aisle)
    end
  end

  def error?(doc)
    return true if doc.blank? or doc.title.blank?
    doc.title.strip.eql? 'Shop Error - Countdown NZ Ltd'
  end

  def aisle_name(doc)
    text = ""
    doc.at_css("div.breadcrumbs").elements.each do |e|
      text = text + e.text + ',' if e.text.present?
    end

    text[text.length - 1] = "" # remove last comma

    text.gsub(/,\b/, ', ').downcase.gsub('groceries, ', '')
  end

  # data required extracted from page
  # find existing product on database
  # if product does not exist
  # create new
  def process_item(item, aisle)
    return if item.elements.first.at_css("a").blank?
    link = item.elements.first.at_css("a").attributes["href"].value
    return if item.elements.first.at_css("a").at_css("img").blank?
    img = item.elements.first.at_css("a").at_css("img").attributes["src"].value

    return unless link.include?("Stockcode=") and link.index("&name=")

    sku = link[(link.index("Stockcode=") + 10)..(link.index("&name=") - 1)]
    product = Product.where(sku: sku).first_or_initialize

    if product.id.nil?
      # product does not exist
      product.volume = item.elements.at_css("span.volume-size").text.strip
      product.name = item.elements.at_css("span.description").text.strip.gsub(product.volume,'')

      product.aisle = aisle + ', ' + product.name
      product.link_to_cd = HOME_URL + link

      logger "Created product with sku: " + product.sku.to_s + ". " if product.save

      logger "Process prices for product " + product.id.to_s + " now. "
      process_prices item, product
    else
      logger "Process prices for product " + product.id.to_s + " now. "
      process_prices item, product
    end
  end

  def process_prices(item, product)
    if has_special_price?(item)
      have_special = true
      normal = (extract_price item, "was-price").presence
    else
      normal = (extract_price item, "price").presence
    end

    normal = NormalPrice.new({ price: normal, product_id: product.id })
    logger "Created normal price for product " + product.id.to_s + ". " if normal.save

    return unless have_special

    special = extract_price item,"special-price"
    special = SpecialPrice.new({ price: special, product_id: product.id })
    logger "Created special price for product " + product.id.to_s + ". " if special.save
  end

  def extract_price(item, fetch_param)
    item = item.at_css('div.grid-stamp-price-container')
    begin
      price = ""
      if fetch_param.include? "was-price"
        logger "Was price found for product " + product.id.to_s + ". "
        price = item.at_css('div.price-container').at_css("span.#{fetch_param}").child.text.gsub("was",'').strip.delete("$")
      elsif fetch_param.include? "special-price"
        logger "Special price found for product " + product.id.to_s + ". "
        price = item.at_css('div.price-container').at_css("span.special-price").child.text.strip.delete("$")
      else
        logger "Normal price found for product " + product.id.to_s + ". "
        price = item.at_css('div.price-container').at_css("span.#{fetch_param}").child.text.strip.delete("$")
      end
      return price
    rescue => e
      logger "Unable to extract price, will ignore: #{e}"
    end
  end

  def has_special_price?(item)
    item.at_css('span.price').attributes['class'].value.include? 'special-price'
  end
end
