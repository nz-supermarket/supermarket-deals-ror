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

  setup

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

  doc.css("div.price-container").each do |item|
    process_item(item, aisle)
  end
end

def error?(doc)
  doc.title.strip.eql? "Shop Error - Countdown NZ Ltd"
end

def aisle_name(doc)
  doc.at_css("div#breadcrumb-panel").elements[2].text + ', ' + doc.at_css("div#breadcrumb-panel").children[6].text.delete("/").gsub(/\A\p{Space}*/, '').strip
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
    product.aisle = aisle + ', ' + product.name
    product.link_to_cd = HOME_URL + link

    if product.save
      logger "Created product with sku: " + product.sku.to_s + ". "

      normal = (extract_price item,"was-price").presence || (extract_price item,"price").presence
      NormalPrices.create({price: normal, product_id: product.id})

      SpecialPrices.create({price: (extract_price item,"special-price"), product_id: product.id})
    else
      logger("Something is wrong with creating "  + product.to_yaml)
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

def nokogiri_open_url(url)
  Nokogiri::HTML(open(url))
end

HOME_URL = "http://shop.countdown.co.nz"
FILTERS = "/Shop/UpdatePageSize?pageSize=400&snapback="

def home_doc_fetch
  nokogiri_open_url(HOME_URL + "/Shop/BrowseAisle/")
end

def sub_cat_fetch(val)
  sleep rand(1.0..20.0)
  nokogiri_open_url(HOME_URL + val)
end

def links_fetch(doc)
  doc.at_css("div.navigation-node.navigation-root").css("a.navigation-link")
end

def generate_aisle(doc)
  aisle_array = []

  links = links_fetch(doc)

  links.each do |link|
    # category
    value = link.attributes["href"].value

    sub_links = links_fetch(sub_cat_fetch(value))

    sub_links.each do |sub|
      value = sub.attributes["href"].value

      if value.split("/").count >= 5
        aisle_array << value
      end
    end
  end

  aisle_array
end
