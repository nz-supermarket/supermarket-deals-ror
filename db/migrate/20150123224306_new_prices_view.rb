class NewPricesView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE VIEW lowest_prices AS SELECT (SELECT prices FROM normal_prics) AS normal, (SELECT prices FROM special_prices) AS special 
    SQL
  end
  def down
    execute <<-SQL
    DROP VIEW lowest_prices
    SQL
  end
end
