desc 'Fetch deals product prices'
task :fetch_offer_prices => :environment do

  setup

  @string_builder = ""
  # could do the same as fetch_prices
  # go thru every aisle in the array and
  # replace "Browse" with "Deals"

  (0..50).each do |i|
    grab_deals_aisle(i)
    sleep rand(1..20)
  end

  sleep rand(50.0..70.0)

  (51..100).each do |i|
    grab_deals_aisle(i)
    sleep rand(1..20)
  end

  sleep rand(200.0..300.0)

  (101..200).each do |i|
    grab_deals_aisle(i)
    sleep rand(1..20)
  end

  sleep rand(50..70)

  (201..300).each do |i|
    grab_deals_aisle(i)
    sleep rand(1..20)
  end
end

desc 'Fetch normal product prices'
task :fetch_prices => :environment do

  setup

  time = Time.now

  @string_builder = ""

  aisles = generate_aisle(home_doc_fetch)

  if @cache.fetch('last').present? and aisles.index(@cache.fetch('last')).present? and aisles.index(@cache.fetch('last')) != (aisles.count - 1)
    aisles.drop(aisles.index(@cache.fetch('last')))
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

def grab_deals_aisle(aisleNo)
  doc = nokogiri_open_url(HOME_URL + FILTERS + "%2FShop%2FDealsAisle%2F" + aisleNo.to_s)

  process_doc doc
end

def grab_browse_aisle(aisle)
  doc = nokogiri_open_url(HOME_URL + FILTERS + aisle)

  process_doc doc
end

def process_doc(doc)
  return if error?(doc)

  aisle = aisle_name(doc)

  process_doc doc
end

def grab_browse_aisle(aisle)
  doc = cache_retrieve_url(FILTERS + aisle)

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

  return unless link.include?("Stockcode=")

  sku = link[(link.index("Stockcode=") + 10)..(link.index("&name=") - 1)]
  product = Product.where(sku: sku).first_or_initialize

  if product.id.nil?
    # product does not exist
    product.volume = item.elements.at_css("span.volume-size").text.strip
    product.name = item.elements.at_css("span.description").text.strip.gsub(product.volume,'')

    product.aisle = aisle + ', ' + product.name
    product.link_to_cd = HOME_URL + link

    logger "Created product with sku: " + product.sku.to_s + ". " if product.save

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
  logger "Created normal price for product " + product.id.to_s + ". " if normal.save

  return unless have_special

  special = extract_price item,"special-price"
  special = SpecialPrice.new({price: special, product_id: product.id})
  logger "Created special price for product " + product.id.to_s + ". " if special.save
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
    logger "Unable to extract price, will ignore: #{e}"
  end
end

def has_special_price?(item)
  item.at_css('span.price').attributes['class'].value.include? 'special-price'
end

def logger string
  if LOG_LEVEL == "debug"
    if string.include? "exist"
      unless @string_builder.include? "exist"
        @string_builder = string
      else
        @string_builder = @string_builder.gsub('. ', '')
        @string_builder = @string_builder + string.gsub("Product exist with sku: ", ", ")
      end
    else
      puts @string_builder
      @string_builder = ""
      puts string
    end
  elsif LOG_LEVEL == "info"
    unless string.include? "Unable"
      if string.include? "exist"
        unless @string_builder.include? "exist"
          @string_builder = string
        else
          @string_builder = @string_builder.gsub('. ', '')
          @string_builder = @string_builder + string.gsub("Product exist with sku: ", ", ")
        end
      else
        puts @string_builder
        @string_builder = ""
        puts string
      end
    end
  elsif LOG_LEVEL == "simple"
    print('.')
  end
end

def nokogiri_open_url(url)
  return Nokogiri::HTML(open_url_with_proxy(url))
end

def home_doc_fetch
  nokogiri_open_url(HOME_URL)
end

def cache_retrieve_url(val)

  if @cache.fetch(val).present?
    return @cache.fetch(val) if @cache.fetch(val) =~ /\s/
  end

  @cache.delete(val)

  sleep rand(1.0..10.0)

  seconds_to_midnight = Time.new(Time.now.year, Time.now.month, Time.now.day, 23, 58, 00) - Time.now
  @cache.write(val, nokogiri_open_url(HOME_URL + val).to_html, expires_in: seconds_to_midnight.seconds)

  @cache.fetch(val)
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

    resp = cache_retrieve_url(value)

    next if resp.blank?

    sub_links = sub_links_fetch(resp)

    next if sub_links.nil?

    sub_links.each do |sub|
      value = sub.attributes["href"].value

      sub_resp = cache_retrieve_url(value)

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

def open_url_with_proxy(url)
  proxies = PROXY_LIST
  proxies = PROXY_LIST[0..3] if @aisle_processing
  result = nil
  number_of_retries = 0

  while result.blank?
    begin
      proxy = proxies.sample

      proxies.delete(proxy)

      number_of_retries += 1 if proxies.count <= 1
      break if number_of_retries >= 20

      result = open(url, :read_timeout => 30)
    rescue RuntimeError, SocketError => e
      log_proxy_error(url, proxy, e)
      result = nil
    rescue Errno::ETIMEDOUT => e
      log_proxy_error(url, proxy, e)
      result = nil
    rescue Errno::ENETUNREACH => e
      log_proxy_error(url, proxy, e)
      result = nil
    rescue Errno::EHOSTUNREACH => e
      log_proxy_error(url, proxy, e)
      result = nil
    rescue Errno::ECONNRESET => e
      log_proxy_error(url, proxy, e)
      result = nil
    rescue Errno::ECONNREFUSED => e
      log_proxy_error(url, proxy, e)
      result = nil
    rescue OpenURI::HTTPError => e
      log_proxy_error(url, proxy, e)
      result = nil
    end
  end
  return result
end

def log_proxy_error(url, proxy, error)
  puts "Unable to connect with #{proxy} and #{url}, will ignore: #{error}"
end

###################################################
## GENERAL SETTINGS
###################################################

HOME_URL = "http://shop.countdown.co.nz"
FILTERS = "/Shop/UpdatePageSize?pageSize=400&snapback="
LOG_LEVEL = "info"
PROXY_LIST = [nil,
              'http://202.27.212.58:8080', ##
              'http://202.27.212.136:8080',
              'http://203.86.202.222:80', ##
              'http://202.49.183.14:8080',
              'http://60.234.51.62:8118',
              'http://114.134.6.21:443',
              'http://203.86.202.167:9001',
              'http://203.184.12.247:443',
              'http://125.236.198.134:8080',
              'http://121.99.222.224:443',
              'http://156.62.100.35:80',
              'http://60.234.119.141:443',
              'http://103.247.194.152:80',
              'http://121.73.85.80:2132',
              '',
              ''
              ]

def setup
  require 'nokogiri'
  require 'open-uri'
  require 'thread_safe'

  @cache = ActiveSupport::Cache::FileStore.new("/tmp")
  @aisle_processing = false
end
