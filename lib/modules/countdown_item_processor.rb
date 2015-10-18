require 'nokogiri'
require "#{Rails.root}/lib/modules/rake_logger"

module CountdownItemProcessor

  HOME_URL = 'http://shop.countdown.co.nz'

  # data required extracted from page
  # find existing product on database
  # if product does not exist
  # create new
  def process_item(item, aisle)
    container = fetch_product_container(item)
    return if container.blank?
    link = container\
           .at_css('a').attributes['href'].value
    img = container\
          .at_css('a').at_css('img')\
          .attributes['src'].value

    logger = RakeLogger.new

    ActiveRecord::Base.connection_pool.reap

    return unless link.include?('Stockcode=') && link.index('&name=')

    sku = link[(link.index('Stockcode=') + 10)..(link.index('&name=') - 1)]
    product = Product.first_or_initialize(sku: sku)

    if product.id.nil?
      # product does not exist
      product.volume = item.elements.at_css('span.volume-size').text.strip
      product.name = item.elements\
        .at_css('span.description')\
        .text.strip.gsub(product.volume, '')

      product.aisle = aisle + ', ' + product.name
      product.link_to_cd = HOME_URL + link

      logger.log 'Created product with sku: ' +
        product.sku.to_s + '. ' if product.save

      logger.log 'Process prices for product ' + product.id.to_s + ' now. '
      process_prices(item, product, logger)
    else
      logger.log 'Process prices for product ' + product.id.to_s + ' now. '
      process_prices(item, product, logger)
    end

    ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
  end

  def fetch_product_container(item)
    item.css('div.grid-stamp-pull-top').first ||
      item.css('div.details-container').first
  end

  def process_prices(item, product, logger = @logger)
    if special_price?(item)
      normal = (extract_price(item, 'was-price', product, logger)).presence
    else
      normal = (extract_price(item, 'price', product, logger)).presence
    end

    normal = NormalPrice.new(price: normal, product_id: product.id)

    logger.log 'Created normal price for product ' +
      product.id.to_s + '. ' if normal.save

    return unless special_price?(item) || multi_buy?(item)

    special = if multi_buy?(item)
                extract_multi(item, product, logger)
              else
                extract_price(item, 'special-price', product, logger)
              end

    special = SpecialPrice.new(price: special, product_id: product.id)

    logger.log 'Created special price for product ' +
      product.id.to_s + '. ' if special.save
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

  module_function :process_item,
                  :process_prices,
                  :extract_price,
                  :extract_multi,
                  :special_price?,
                  :multi_buy?,
                  :fetch_product_container
end