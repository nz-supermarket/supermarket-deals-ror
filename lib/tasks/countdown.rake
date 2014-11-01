desc 'Fetch product prices'
task :fetch_prices => :environment do

  require "nokogiri"
  require "open-uri"

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
    product.special = item.at_css("span.special-price").child.text.strip.delete("$")
    product.normal = item.at_css("span.was-price").child.text.gsub("was",'').strip.delete("$")
    product.aisle = aisle + ', ' + product.name

    puts "Created product with sku: " + product.sku.to_s + ". "
  else
    puts "Product exist with sku: " + product.sku.to_s + ". "

    if product.normal > item.at_css("span.was-price").child.text.gsub("was",'').strip.delete("$").to_d
      string = "Updated normal price from " + product.normal + " to "
      product.normal = item.at_css("span.was-price").child.text.gsub("was",'').strip
      puts string + product.normal + ". "
    end

    if product.special > item.at_css("span.special-price").child.text.strip.delete("$").to_d
      string = "Updated special price from " + product.special + " to "
      product.special = item.at_css("span.special-price").child.text.strip
      puts string + product.special + ". "
    end
  end

  product.save
end