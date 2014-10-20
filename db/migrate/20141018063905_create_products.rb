class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :volume
      t.integer :sku
      t.decimal :special, precision: 6, scale: 2
      t.decimal :normal, precision: 6, scale: 2
      t.decimal :diff, precision: 6, scale: 2
      t.string :aisle
      t.decimal :discount, precision: 5, scale: 2

      t.timestamps
    end
  end
end
