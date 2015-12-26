class AddIdIndexOnPrices < ActiveRecord::Migration
  def change
    add_index(:normal_prices, [:id], unique: true, using: 'btree', name: 'normal_by_id')
    add_index(:special_prices, [:id], unique: true, using: 'btree', name: 'special_by_id')
  end
end
