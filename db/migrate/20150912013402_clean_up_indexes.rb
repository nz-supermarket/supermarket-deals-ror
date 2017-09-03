class CleanUpIndexes < ActiveRecord::Migration
  def change
    remove_index :special_prices, name: 'index_special_prices_on_product_id' if index_name_exists?(:special_prices, 'index_special_prices_on_product_id', true)
    remove_index :special_prices, name: 'special_by_date_product_id' if index_name_exists?(:special_prices, 'special_by_date_product_id', true)
    # remove_index :special_prices, name: 'special_by_price_product_id' if index_name_exists?(:special_prices, 'special_by_price_product_id', true)

    remove_index :normal_prices, name: 'index_normal_prices_on_product_id' if index_name_exists?(:normal_prices, 'index_normal_prices_on_product_id', true)
    remove_index :normal_prices, name: 'normal_by_date_product_id' if index_name_exists?(:normal_prices, 'normal_by_date_product_id', true)
    # remove_index :normal_prices, name: 'normal_by_price_product_id' if index_name_exists?(:normal_prices, 'normal_by_price_product_id', true)


    # add_index :special_prices,
    #   [:product_id, :price],
    #   {
    #     name: 'special_by_price_product_id'
    #   }
    # add_index :normal_prices,
    #   [:product_id, :price],
    #   {
    #     name: 'normal_by_price_product_id'
    #   }
  end
end
# ,
#         using: 'btree',
#         using: 'btree'