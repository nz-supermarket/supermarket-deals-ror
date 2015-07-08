class RecreateViewWithDefault < ActiveRecord::Migration
  def change
    execute "
    CREATE VIEW lowest_prices AS SELECT products.id,
      products.name, products.volume, products.sku, products.aisle, products.link_to_cd,
      (SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) AS normal_price,
      (SELECT date FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) AS normal_date,
      (SELECT price FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1) AS special_price,
      (SELECT date FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1) AS special_date,
      coalesce(((SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) - (SELECT price FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1)), 0) AS diff_price,
      coalesce((((SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) - (SELECT price FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1)) / (SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1)), 0) AS discount
      FROM products;"
  end
end
