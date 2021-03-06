class IndexForPriceProduct < ActiveRecord::Migration
  def change
    add_index(:normal_prices, [:price, :product_id], order: {price: :asc}, using: 'btree', name: 'normal_by_price_product_id')
    add_index(:special_prices, [:price, :product_id], order: {price: :asc}, using: 'btree', name: 'special_by_price_product_id')
  end
end
