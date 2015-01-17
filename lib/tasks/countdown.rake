desc 'Fetch deals product prices'
task :fetch_offer_prices => :environment do

  require "nokogiri"
  require "open-uri"

  @string_builder = ""

  (0..50).each do |i|
    grab_deals_aisle(i)
    sleep rand(1..20)
  end

  sleep rand(50..70)

  (51..100).each do |i|
    grab_deals_aisle(i)
    sleep rand(1..20)
  end

  sleep rand(200..300)

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

  require "nokogiri"
  require "open-uri"

  @string_builder = ""

  aisles = generate_aisle(home_doc_fetch)

  aisles.each_with_index do |aisle, index|
    grab_browse_aisle(aisle)
    sleep rand(1.0..30.0)
    if (index % 10) == 0
      sleep rand(50.0..200.0)
    end
  end
end

def grab_deals_aisle(aisleNo)
  doc = nokogiri_open_url("http://shop.countdown.co.nz/Shop/UpdatePageSize?pageSize=400&snapback=%2FShop%2FDealsAisle%2F" + aisleNo.to_s)

  return if error?(doc)

  aisle = aisle_name(doc)

  doc.css("div.price-container").each do |item|
    process_item(item, aisle)
  end
end

def grab_browse_aisle(aisle)
  doc = nokogiri_open_url(HOME_URL + FILTERS + aisle)

  return if error?(doc)

  aisle = aisle_name(doc)

  doc.css("div.price-container").each do |item|
    process_item(item, aisle)
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

    if product.save
      logger "Created product with sku: " + product.sku.to_s + ". "
    else
      logger("Something is wrong with creating "  + product.to_yaml)
    end
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

def generate_aisle doc
  aisle_array = []

  links = doc.at_css("div.navigation-node.navigation-root").css("a.navigation-link")

  links.each do |link|
    value = link.attributes["href"].value
    if value.split("/").count >= 5
      aisle_array << value
    end
  end

  aisle_array
end
