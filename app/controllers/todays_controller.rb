class TodaysController < ApplicationController
  respond_to :json

  def index
    table = LowestPrice.arel_table
    result = LowestPrice
             .where(table[:normal_date].eq(Date.today)
                      .or(table[:special_date].eq(Date.today)))

    products = result.all.group_by do |item|
      group_aisle(item, :first)
    end

    products.each_pair do |key, values|
      products[key] = values.group_by do |item|
        group_aisle(item, :second)
      end
    end

    respond_with products.as_json
  end

  private

  def group_aisle(item, method)
    aisle_array = item.aisle.split(',').map(&:strip)
    aisle_array = aisle_array.reject { |string| string == item.name.strip }
    aisle_array.send(method)
  end
end