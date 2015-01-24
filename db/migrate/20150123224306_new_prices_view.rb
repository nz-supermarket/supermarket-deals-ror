class NewPricesView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE VIEW lowest_prices AS SELECT products.id,
      products.name, products.volume, products.sku, products.aisle, products.link_to_cd
      (SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) AS normal_price,
      (SELECT date FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) AS normal_date,
      (SELECT price FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1) AS special_price,
      (SELECT date FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1) AS special_date,
      ((SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) - (SELECT price FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1)) AS diff_price,
      (((SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1) - (SELECT price FROM special_prices where product_id = products.id ORDER BY special_prices.price LIMIT 1)) / (SELECT price FROM normal_prices where product_id = products.id ORDER BY normal_prices.price LIMIT 1)) AS discount
      FROM products;
    SQL
  end
  def down
    execute <<-SQL
    DROP VIEW lowest_prices
    SQL
  end
end
