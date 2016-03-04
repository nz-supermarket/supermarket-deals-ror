require 'nokogiri'
require "#{Rails.root}/lib/modules/rake_logger"

module CountdownItemProcessor

  HOME_URL = 'https://shop.countdown.co.nz'

  # data required extracted from page
  # find existing product on database
  # if product does not exist
  # create new
  def process_item(thread, item, aisle)
    container = fetch_product_container(item)
    return if container.blank?
    link = container\
           .at_css('a').attributes['href'].value.downcase
    img = container\
          .at_css('a').at_css('img')\
          .attributes['src'].value.downcase

    logger = RakeLogger.new

    ActiveRecord::Base.connection_pool.with_connection do
      return unless link.include?('stockcode=') && link.index('&name=')

      sku = link[(link.index('stockcode=') + 10)..(link.index('&name=') - 1)]
      product = Product.where(sku: sku).first_or_initialize

      if product.id.nil?
        # product does not exist
        product.volume = item.elements.at_css('span.volume-size').text.strip
        product.name = item.elements\
          .at_css('span.description')\
          .text.strip.gsub(product.volume, '')

        product.aisle = aisle + ', ' + product.name
        product.link_to_cd = HOME_URL + link

        logger.log thread, 'Created product with sku: ' +
          product.sku.to_s + '. ' if product.save

        logger.log thread,
                   'Process prices for product ' + product.id.to_s + ' now. '
        process_prices(thread, item, product, logger)
      else
        logger.log thread,
                   'Process prices for product ' + product.id.to_s + ' now. '
        process_prices(thread, item, product, logger)
      end
    end
  end

  def fetch_product_container(item)
    item.css('div.grid-stamp-pull-top').first ||
      item.css('div.details-container').first
  end

  def process_prices(thread, item, product, logger = @logger)
    if special_price?(item)
      normal = (extract_price(thread,
                              item, 'was-price', product, logger)).presence
    else
      normal = (extract_price(thread, item, 'price', product, logger)).presence
    end

    normal = NormalPrice.new(price: normal,
                             product_id: product.id,
                             date: Date.today)

    logger.log thread, 'Created normal price for product ' +
      product.id.to_s + '. ' if normal.save

    return unless special_price?(item) || multi_buy?(item)

    special = if multi_buy?(item)
                extract_multi(thread, item, product, logger)
              else
                extract_price(thread, item, 'special-price', product, logger)
              end

    special = SpecialPrice.new(price: special,
                               product_id: product.id,
                               date: Date.today)

    logger.log thread, 'Created special price for product ' +
      product.id.to_s + '. ' if special.save
  end

  def extract_price(thread, item, fetch_param, product, logger = @logger)
    item = item.at_css('div.grid-stamp-price-container')
    # do not process club price
    return nil if item.at_css('div.club-price-container').present?
    begin
      price = ''
      container = item.at_css('div.price-container')\
                  .at_css("span.#{fetch_param}")
      if fetch_param.include? 'was-price'
        logger.log thread,
                   'Was price found for product ' + product.id.to_s + '. ',
                   'debug'
        price = container.child.text.gsub('was', '').strip.delete('$')
      elsif fetch_param.include? 'special-price'
        logger.log thread,
                   'Special price found for product ' + product.id.to_s + '. ',
                   'debug'
        price = container.child.text.strip.delete('$')
      else
        logger.log thread,
                   'Normal price found for product ' + product.id.to_s + '. ',
                   'debug'
        price = container.child.text.strip.delete('$')
      end
      return price
    rescue => e
      logger.log thread, "Unable to extract price, will ignore: #{e}", 'debug'
    end
  end

  def extract_multi(thread, item, product, logger = @logger)
    value = item.at_css('span.multi-buy-award-value').text
    quantity = item.at_css('span.multi-buy-award-quantity')\
               .text.gsub(' for', '')

    logger.log thread,
               'Multi buy price found for product ' + product.id.to_s + '. ',
               'debug'
    value.to_d / quantity.to_d
  end

  def special_price?(item)
    item
      .at_css('span.price')
      .attributes['class']
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
