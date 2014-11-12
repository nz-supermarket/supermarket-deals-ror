require "nokogiri"
require "open-uri"
require "active_record"
require 'iron_worker_ng'
require 'pg'
require 'models/product'

def setup_database
  puts "Database connection details: #{params['database'].inspect}"
  return unless params['database']
  # estabilsh database connection
  ActiveRecord::Base.establish_connection(params['database'])
end

def logger string
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

def extract_price item,fetch_param
  begin
    price = ""
    if fetch_param.include? "was"
      price = item.at_css("span.#{fetch_param}").child.text.gsub("was",'').strip.delete("$")
    elsif fetch_param.include? "special"
      price = item.at_css("span.special-price").child.text.strip.delete("$")
    end
    price
  rescue => e
    logger "Unable to extract price, will ignore: #{e}" 
  end
end

# data required extracted from page
# find existing product on database
# if product does not exist
# create new
def process_item(item, aisle)
  parent = item.parent
  link = parent.elements.first.at_css("a").attributes["href"].value
  img = parent.elements.first.at_css("a").children[1].attributes["src"].value

  sku = link[(link.index("Stockcode=") + 10)..(link.index("&name=") - 1)]
  product = Product.where(sku: sku).first_or_initialize

  if product.id.nil?
    # product does not exist
    product.volume = parent.elements.at_css("span.volume-size").text.strip
    product.name = parent.elements.at_css("span.description").text.strip.gsub(product.volume,'')
    if item.at_css("span.special-price").nil?
      return
    end
    product.special = extract_price item,"special-price"
    product.normal = extract_price item,"was-price"
    product.aisle = aisle + ', ' + product.name

    logger "Created product with sku: " + product.sku.to_s + ". "
  else
    logger "Product exist with sku: " + product.sku.to_s + ". "

    begin
      current_special = extract_price(item,"special-price").to_d
      if product.special > current_special and current_special != 0.0
        string = "Updated special price from " + product.special.to_d.to_s + " to "
        product.special = extract_price item,"special-price"
        logger (string + product.special.to_d.to_s + ". ")
      end

      product.save
    rescue => e
      logger("Something is wrong with to special price for "  + product.sku.to_s + ", will ignore: #{e}") 
    end

    begin
      current_normal = extract_price(item,"was-price").to_d
      if product.normal > current_normal and current_normal != 0.0
        string = "Updated normal price from " + product.normal.to_d.to_s + " to "
        product.normal = extract_price item,"was-price"
        logger (string + product.normal.to_d.to_s + ". ")
      end

      product.save
    rescue => e
      logger("Something is wrong with to normal price for "  + product.sku.to_s + ", will ignore: #{e}")
    end
  end
end

def grab_from_aisle(aisleNo)
  url = "http://shop.countdown.co.nz/Shop/UpdatePageSize?pageSize=400&snapback=%2FShop%2FDealsAisle%2F" + aisleNo.to_s
  doc = Nokogiri::HTML(open(url))

  if doc.title.strip.eql? "Shop Error - Countdown NZ Ltd"
    return
  end

  aisle = doc.at_css("div#breadcrumb-panel").elements[2].text + ', ' + doc.at_css("div#breadcrumb-panel").children[6].text.delete("/").gsub(/\A\p{Space}*/, '').strip

  doc.css("div.price-container").each do |item|
    process_item(item, aisle)
  end
end

setup_database
@string_builder = ""

(0..50).each do |i|
  grab_from_aisle(i)
end

sleep rand(50..70)

(51..100).each do |i|
  grab_from_aisle(i)
end

sleep rand(200..300)

(101..200).each do |i|
  grab_from_aisle(i)
end

sleep rand(50..70)

(201..300).each do |i|
  grab_from_aisle(i)
end