require "#{Rails.root}/lib/modules/rake_logger"

module Countdown
  class Item
    include Sidekiq::Worker
    sidekiq_options queue: :countdownitem

    def perform(*args)

      @logger = RakeLogger.new
      @aisle = args[1]
      process_html(args[0])

      return if @item.nil?

      ActiveRecord::Base.connection_pool.with_connection do
        return unless href.include?('stockcode=') && href.index('&name=')

        @product = Product.where(sku: sku).first_or_initialize

        new_product if @product.id.nil?

        @logger.log Parallel.worker_number,
                    'Process prices for product ' + @product.id.to_s + ' now. '
        process_prices
      end
    end

    private

    def process_html(html)
      item = Nokogiri::HTML(html)
      @item = item.css('div.grid-stamp-pull-top').first ||
              item.css('div.details-container').first

      if item.css('div.next-page-item')
        Countdown::LinksProcessor::AisleLinks
          .perform_async(
            'https://shop.countdown.co.nz' + 
            item.at_css('div.next-page-item').css('a').attr('href')
          )
      end
    end

    def href
      @link ||= @item.at_css('a')
                     .attributes['href']
                     .value.downcase
    end

    def img_href
      @img ||= @item.at_css('a')
                    .at_css('img')
                    .attributes['src']
                    .value.downcase
    end

    def sku
      href[(href.index('stockcode=') + 10)..(href.index('&name=') - 1)]
    end

    def volume
      @item.elements.at_css('span.volume-size').text.strip
    end

    def name
      @item.elements
        .at_css('span.description')
        .text.strip.gsub(@product.volume, '')
    end

    def new_product
      @product.volume = volume
      @product.name = name

      @product.aisle = @aisle + ', ' + @product.name
      @product.link_to_cd = 'https://shop.countdown.co.nz' + href

      @logger.log Parallel.worker_number, 'Created product with sku: ' +
        @product.sku.to_s + '. ' if @product.save
    end

    def process_prices
      normal = NormalPrice.new(price: normal_price,
                               product_id: @product.id,
                               date: Date.today)

      if normal.price == 1
        normal.price = NormalPrice.where(product_id: @product.id).order(:date).last.try(:price)
      end

      @logger.log Parallel.worker_number, 'Created normal price for product ' +
        @product.id.to_s + '. ' if normal.save

      return unless special_price? || multi_buy? || club_price?
      special = SpecialPrice.new(price: special_price,
                                 product_id: @product.id,
                                 date: Date.today)

      @logger.log Parallel.worker_number, 'Created special price for product ' +
        @product.id.to_s + '. ' if special.save
    end

    def extract_price(fetch_param)
      price = ''
      container = price_container
                  .at_css("span.#{fetch_param}")
      if fetch_param.include? 'was-price'
        @logger.log Parallel.worker_number,
                    'Was price found for product ' + @product.id.to_s + '. ',
                    'debug'
        price = container.child.text.gsub('was', '').strip.delete('$')
      elsif fetch_param.include? 'special-price'
        @logger.log Parallel.worker_number,
                    'Special price found for product ' + @product.id.to_s + '. ',
                    'debug'
        price = container.child.text.strip.delete('$')
      else
        @logger.log Parallel.worker_number,
                    'Normal price found for product ' + @product.id.to_s + '. ',
                    'debug'
        price = container.child.text.gsub(/[ a-zA-Z$]+/, '')
      end
      return price.to_d
    end

    def normal_price
      if special_price?
        extract_price('was-price')
      elsif club_price?
        extract_price('grid-non-club-price')
      else
        extract_price('price')
      end
    end

    def special_price
      if multi_buy?
        extract_multi
      elsif club_price?
        extract_club
      elsif special_price?
        extract_price('special-price')
      end
    end

    def extract_multi
      value = price_container.at_css('span.multi-buy-award-value').text
      quantity = price_container.at_css('span.multi-buy-award-quantity')\
                                .text.gsub(' for', '')

      @logger.log Parallel.worker_number,
                  'Multi buy price found for product ' + @product.id.to_s + '. ',
                  'debug'
      value.to_d / quantity.to_d
    end

    def extract_club
      value = price_container.at_css('span.club-price-wrapper').text.gsub(/[ a-zA-Z$]+/, '')

      @logger.log Parallel.worker_number,
                  'Club price found for product ' + @product.id.to_s + '. ',
                  'debug'
      value.to_d
    end

    def price_container
      container = @item
                  .at_css('div.grid-stamp-price-container')
      container.at_css('div.price-container') ||
        container.at_css('div.club-price-container')
    end

    def special_price?
      @item.at_css('span.price.special-price').present?
    end

    def club_price?
      @item.at_css('div.club-price-container').present?
    end

    def multi_buy?
      @item.css('div.multi-buy-container').present?
    end
  end
end
