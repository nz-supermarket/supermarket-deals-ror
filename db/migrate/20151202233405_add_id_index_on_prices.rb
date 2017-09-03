class AddIdIndexOnPrices < ActiveRecord::Migration
  def change
    add_index(:normal_prices, [:id], unique: true, name: 'normal_by_id')#, using: 'btree'
    add_index(:special_prices, [:id], unique: true, name: 'special_by_id')#, using: 'btree'
  end
end
