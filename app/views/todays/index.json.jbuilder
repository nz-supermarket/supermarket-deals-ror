json.array!(@products) do |aisle|
  json.extract! aisle[0]
  json.array!(aisle[1]) do |product|
    json.extract! product, :name, :volume, :sku, :special, :normal, :discount
    json.url product_url(product, format: :json)
  end
end
