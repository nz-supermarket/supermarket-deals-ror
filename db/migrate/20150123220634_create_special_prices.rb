class CreateSpecialPrices < ActiveRecord::Migration
  def change
    create_table :special_prices do |t|
      t.decimal :price, precision: 8, scale: 3
      t.date :date
      t.references :product, index: true
    end
  end
end
