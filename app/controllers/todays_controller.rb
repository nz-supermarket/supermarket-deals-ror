class TodaysController < ApplicationController
  respond_to :json

  def index
    table = LowestPrice.arel_table
    result = LowestPrice
             .where(table[:normal_date].eq(Date.today)
                      .or(table[:special_date].eq(Date.today)))
    @products = result.all.group_by do |item|
      item.aisle.split(',').first(3).join(',')
    end
  end
end
