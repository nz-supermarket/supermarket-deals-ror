json.array!(@products) do |product|
  json.extract! product, :id, :name, :volume, :sku, :special, :normal, :diff, :aisle, :discount
  json.url product_url(product, format: :json)
end
