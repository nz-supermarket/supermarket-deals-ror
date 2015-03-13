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

  @string_builder = ""

  aisles = generate_aisle(home_doc_fetch)

  aisles.each_with_index do |aisle, index|
    grab_browse_aisle(aisle)
    sleep rand(1.0..30.0)
    if (index % 10) == 0
      sleep rand(30.0..200.0)
    end
  end
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

  puts doc.css('div.details-container.row-fluid.mrow-fluid').count

  doc.css('div.details-container.row-fluid.mrow-fluid').each do |item|
    process_item(item, aisle)
  end
end

def error?(doc)
  return true if doc.blank?
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

    if product.save
      logger "Created product with sku: " + product.sku.to_s + ". "

      process_prices item, product
    else
      logger("Something is wrong with creating "  + product.to_yaml)
    end
  else
    process_prices item, product
  end
end

def process_prices item, product
  normal = (extract_price item,"was-price").presence
  if normal
    have_special = true
  else
    normal = (extract_price item,"price").presence
  end

  normal = NormalPrice.new({price: normal, product_id: product.id})
  logger "Created normal price for product " + product.id.to_s + ". " if normal.save

  return unless have_special

  special = extract_price item,"special-price"
  return if special.blank?
  special = SpecialPrice.new({price: special, product_id: product.id})
  logger "Created special price for product " + product.id.to_s + ". " if special.save
end

def extract_price item,fetch_param
  begin
    price = ""
    if fetch_param.include? "was"
      price = item.at_css("span.#{fetch_param}").child.text.gsub("was",'').strip.delete("$")
    elsif fetch_param.include? "special-price"
      binding.pry if item.at_css("span.special-price").present?
      price = item.at_css("span.special-price").child.text.strip.delete("$")
    else
      price = item.at_css("span.#{fetch_param}").child.text.strip.delete("$")
    end
    price
  rescue => e
    logger "Unable to extract price, will ignore: #{e}"
  end
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
  begin
    Nokogiri::HTML(open(url))
  rescue OpenURI::HTTPError => e
    return nil
  end
end

HOME_URL = "http://shop.countdown.co.nz"
FILTERS = "/Shop/UpdatePageSize?pageSize=400&snapback="
LOG_LEVEL = "info"

def home_doc_fetch
  nokogiri_open_url(HOME_URL + "/Shop/BrowseAisle/")
end

def sub_cat_fetch(val)
  sleep rand(1.0..5.0)
  nokogiri_open_url(HOME_URL + val)
end

def cat_links_fetch(doc)
  print "."
  doc.at_css("div.toolbar-links-children").at_css("div.row-fluid.mrow-fluid").css("a.toolbar-slidebox-link")
end

def sub_links_fetch(doc)
  print "."
  doc.at_css("div.single-level-navigation.filter-container").css("a.browse-navigation-link")
end

def generate_aisle(doc)
  aisle_array = []

  links = cat_links_fetch(doc)

  links.each do |link|
    # category
    value = link.attributes["href"].value

    resp = sub_cat_fetch(value)

    next if resp.blank?

    sub_links = sub_links_fetch(resp)

    sub_links.each do |sub|
      value = sub.attributes["href"].value

      sub_resp = sub_cat_fetch(value)

      next if sub_resp.blank?

      sub_sub_links = sub_links_fetch(sub_resp)

      sub_sub_links.each do |sub_sub|
        value = sub_sub.attributes["href"].value

        if value.split("/").count >= 5
          aisle_array << value
        end
      end
    end
  end

  puts ""

  aisle_array
end

def setup
  require 'nokogiri'
  require 'open-uri'
  require 'thread_safe'
end
