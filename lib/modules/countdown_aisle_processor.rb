require 'nokogiri'
require "#{Rails.root}/lib/modules/cacher"
require "#{Rails.root}/lib/modules/rake_logger"
require "#{Rails.root}/lib/modules/web_scrape"

class CountdownAisleProcessor < Object
  include Celluloid
  include Celluloid::Logger
  include Cacher
  extend WebScrape

  finalizer :finish

  HOME_URL = "http://shop.countdown.co.nz"
  FILTERS = "/Shop/UpdatePageSize?pageSize=400&snapback="

  def self.home_doc_fetch
    nokogiri_open_url(HOME_URL)
  end

  def grab_browse_aisle(aisle, cache)
    doc = cache_retrieve_url(cache, aisle)

    process_doc Nokogiri::HTML(doc)
  end

  def finish
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info "terminating #{self}"
    terminate
  end

  def process_doc(doc)
    return if error?(doc)

    Celluloid.logger = Rails.logger
    @logger = RakeLogger.new

    ActiveRecord::Base.establish_connection

    aisle = aisle_name(doc)

    Rails.logger.info doc.css('div.product-stamp.product-stamp-grid').count

    doc.css('div.product-stamp.product-stamp-grid').each do |item|
      process_item(item, aisle)
    end

    Rails.logger.info "finish processing #{aisle}"
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
  def process_item(item, aisle, logger = @logger)
    return if item.css('div.grid-stamp-pull-top').first.blank?
    link = item\
            .css('div.grid-stamp-pull-top')\
            .first.at_css('a').attributes['href'].value
    img = item\
            .css('div.grid-stamp-pull-top')\
            .first.at_css("a").at_css("img")\
            .attributes["src"].value

    return unless link.include?("Stockcode=") and link.index("&name=")

    sku = link[(link.index("Stockcode=") + 10)..(link.index("&name=") - 1)]
    product = Product.where(sku: sku).first_or_initialize

    if product.id.nil?
      # product does not exist
      product.volume = item.elements.at_css("span.volume-size").text.strip
      product.name = item.elements.at_css("span.description").text.strip.gsub(product.volume,'')

      product.aisle = aisle + ', ' + product.name
      product.link_to_cd = HOME_URL + link

      logger.log "Created product with sku: " + product.sku.to_s + ". " if product.save

      logger.log "Process prices for product " + product.id.to_s + " now. "
      process_prices(item, product, logger)
    else
      logger.log "Process prices for product " + product.id.to_s + " now. "
      process_prices(item, product, logger)
    end
  end

  def process_prices(item, product, logger = @logger)
    if special_price?(item)
      normal = (extract_price(item, "was-price", product, logger)).presence
    else
      normal = (extract_price(item, "price", product, logger)).presence
    end

    normal = NormalPrice.new({ price: normal, product_id: product.id })
    logger.log "Created normal price for product " + product.id.to_s + ". " if normal.save

    return unless special_price?(item) || multi_buy?(item)

    special = if multi_buy?(item)
      extract_multi(item, product, logger)
    else
      extract_price(item,"special-price", product, logger)
    end
    special = SpecialPrice.new({ price: special, product_id: product.id })
    logger.log "Created special price for product " + product.id.to_s + ". " if special.save
  end

  def extract_price(item, fetch_param, product, logger = @logger)
    item = item.at_css('div.grid-stamp-price-container')
    # do not process club price
    return nil if item.at_css('div.club-price-container').present?
    begin
      price = ''
      container = item.at_css('div.price-container')\
                  .at_css("span.#{fetch_param}")
      if fetch_param.include? 'was-price'
        logger.log 'Was price found for product ' + product.id.to_s + '. '
        price = container.child.text.gsub('was', '').strip.delete('$')
      elsif fetch_param.include? 'special-price'
        logger.log 'Special price found for product ' + product.id.to_s + '. '
        price = container.child.text.strip.delete('$')
      else
        logger.log 'Normal price found for product ' + product.id.to_s + '. '
        price = container.child.text.strip.delete('$')
      end
      return price
    rescue => e
      logger.log "Unable to extract price, will ignore: #{e}"
    end
  end

  def extract_multi(item, product, logger = @logger)
    value = item.at_css('span.multi-buy-award-value').text
    quantity = item.at_css('span.multi-buy-award-quantity')\
               .text.gsub(' for', '')

    logger.log 'Multi buy price found for product ' + product.id.to_s + '. '
    value.to_d / quantity.to_d
  end

  def special_price?(item)
    item\
      .at_css('span.price')\
      .attributes['class']\
      .value.include? 'special-price'
  end

  def multi_buy?(item)
    item.css('div.multi-buy-container').present?
  end
end
