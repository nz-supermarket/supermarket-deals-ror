class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :volume
      t.integer :sku, null: false
      t.decimal :special, precision: 8, scale: 3
      t.decimal :normal, precision: 8, scale: 3
      t.decimal :diff, precision: 8, scale: 3
      t.string :aisle
      t.decimal :discount, precision: 6, scale: 3

      t.timestamps
    end

    add_index :products, :sku, unique: true
  end
end
