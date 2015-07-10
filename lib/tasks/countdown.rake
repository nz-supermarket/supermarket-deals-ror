desc 'Fetch normal product prices'
task :fetch_prices => :environment do

  setup

  time = Time.now

  @string_builder = ""

  aisles = generate_aisle(home_doc_fetch)

  if @cache.exist?('last')
    last_aisle = @cache.fetch('last')
    if aisles.index(last_aisle).present? and aisles.index(last_aisle) != (aisles.count - 1)
      aisles.drop(aisles.index(last_aisle))
    end
  end

  @aisle_processing = true

  aisles.each_with_index do |aisle, index|
    grab_browse_aisle(aisle)
    @cache.write('last', aisle)
    sleep rand(1.0..5.0)
    if (index % 10) == 0
      sleep rand(5.0..10.0)
    end
  end

  puts "Time Taken: #{((Time.now - time) / 60.0 / 60.0)} hours"
end

def home_doc_fetch
  nokogiri_open_url(HOME_URL)
end

def grab_browse_aisle(aisle)
  doc = Cacher.cache_retrieve_url(@cache, FILTERS + aisle)

  process_doc Nokogiri::HTML(doc)
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

    RakeLogger.logger "Created product with sku: " + product.sku.to_s + ". " if product.save

    process_prices item, product
  else
    process_prices item, product
  end
end

def process_prices item, product
  if has_special_price?(item)
    have_special = true
    normal = (extract_price item,"was-price").presence
  else
    normal = (extract_price item,"price").presence
  end

  normal = NormalPrice.new({price: normal, product_id: product.id})
  RakeLogger.logger "Created normal price for product " + product.id.to_s + ". " if normal.save

  return unless have_special

  special = extract_price item,"special-price"
  special = SpecialPrice.new({price: special, product_id: product.id})
  RakeLogger.logger "Created special price for product " + product.id.to_s + ". " if special.save
end

def extract_price item,fetch_param
  item = item.at_css('div.grid-stamp-price-container')
  begin
    price = ""
    if fetch_param.include? "was-price"
      price = item.at_css('div.price-container').at_css("span.#{fetch_param}").child.text.gsub("was",'').strip.delete("$")
    elsif fetch_param.include? "special-price"
      price = item.at_css('div.price-container').at_css("span.special-price").child.text.strip.delete("$")
    else
      price = item.at_css('div.price-container').at_css("span.#{fetch_param}").child.text.strip.delete("$")
    end
    return price
  rescue => e
    RakeLogger.logger "Unable to extract price, will ignore: #{e}"
  end
end

def has_special_price?(item)
  item.at_css('span.price').attributes['class'].value.include? 'special-price'
end

def nokogiri_open_url(url)
  return Nokogiri::HTML(RProxy.open_url_with_proxy(url, @aisle_processing))
end

def cat_links_fetch(doc)
  print "."
  doc.at_css("div.toolbar-links-children").at_css("div.row-fluid.mrow-fluid").css("a.toolbar-slidebox-link")
end

def sub_links_fetch(doc)
  print "."

  return nil if error?(Nokogiri::HTML(doc))

  Nokogiri::HTML(doc).at_css("div.single-level-navigation.filter-container").css("a.browse-navigation-link")
end

def generate_aisle(doc)
  aisle_array = []

  links = cat_links_fetch(doc)

  links.each do |link|
    # category
    value = link.attributes["href"].value

    resp = Cacher.cache_retrieve_url(@cache, value)

    next if resp.blank?

    sub_links = sub_links_fetch(resp)

    next if sub_links.nil?

    sub_links.each do |sub|
      value = sub.attributes["href"].value

      sub_resp = Cacher.cache_retrieve_url(@cache, value)

      next if sub_resp.blank?

      sub_sub_links = sub_links_fetch(sub_resp)

      next if sub_sub_links.nil?

      sub_sub_links.each do |sub_sub|
        value = sub_sub.attributes["href"].value

        if value.split("/").count >= 5
          aisle_array << value
        end
      end
    end
  end

  puts ""

  aisle_array.compact
end

###################################################
## GENERAL SETTINGS
###################################################

HOME_URL = "http://shop.countdown.co.nz"
FILTERS = "/Shop/UpdatePageSize?pageSize=400&snapback="
LOG_LEVEL = "info"

def setup
  require 'nokogiri'
  require 'dalli'
  require "#{Rails.root}/lib/modules/r_proxy"
  require "#{Rails.root}/lib/modules/cacher"
  require "#{Rails.root}/lib/modules/rake_logger"

  include RProxy
  include Cacher
  include RakeLogger

  case Rails.env
  when 'production'
    @cache = Rails.cache
  else
    @cache = ActiveSupport::Cache::FileStore.new("/tmp")
  end

  @aisle_processing = false
end
