class NewProductsTable < ActiveRecord::Migration
  def change
    remove_column :products, :special
    remove_column :products, :normal
    remove_column :products, :diff
    remove_column :products, :discount
    add_column :products, :link_to_cd, :string
  end
end
