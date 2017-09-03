class RewriteViewSqlForPerformance < ActiveRecord::Migration
  def change
    execute "
      CREATE OR REPLACE VIEW lowest_prices
      AS SELECT products.id,
      products.name, products.volume, products.sku, products.aisle, products.link_to_cd, 
      normal.price AS normal_price, normal.date AS normal_date,
      special.price AS special_price, special.date AS special_date,
      coalesce((normal.price - special.price), 0) AS diff_price,
      coalesce(((normal.price - special.price) / normal.price), 0) AS discount
      FROM products
      LEFT JOIN normal_prices
      AS normal
      ON normal.id = (SELECT id
        FROM normal_prices
        WHERE product_id = products.id
        ORDER BY normal_prices.price                                                                                                                                                               
        LIMIT 1)
      LEFT JOIN special_prices
      AS special
      ON special.id = (SELECT id
        FROM special_prices
        WHERE product_id = products.id
        ORDER BY special_prices.price                                                                                                                                                               
        LIMIT 1);
    "
  end
end
