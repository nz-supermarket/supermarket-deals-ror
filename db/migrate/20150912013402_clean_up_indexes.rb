class CleanUpIndexes < ActiveRecord::Migration
  def change
    remove_index :special_prices, name: 'index_special_prices_on_product_id'
    remove_index :special_prices, name: 'special_by_date_product_id'
    remove_index :special_prices, name: 'special_by_price_product_id'

    remove_index :normal_prices, name: 'index_normal_prices_on_product_id'
    remove_index :normal_prices, name: 'normal_by_date_product_id'
    remove_index :normal_prices, name: 'normal_by_price_product_id'


    add_index :special_prices,
      [:product_id, :price],
      {
        name: 'special_by_price_product_id',
        using: 'btree'
      }
    add_index :normal_prices,
      [:product_id, :price],
      {
        name: 'normal_by_price_product_id',
        using: 'btree'
      }
  end
end
