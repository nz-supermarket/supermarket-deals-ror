class AddIndexToPriceTable < ActiveRecord::Migration
  def change
    add_index(:normal_prices, [:date, :product_id], order: {date: :desc}, unique: true, using: 'btree', name: 'normal_by_date_product_id')
    add_index(:special_prices, [:date, :product_id], order: {date: :desc}, unique: true, using: 'btree', name: 'special_by_date_product_id')
  end
end
