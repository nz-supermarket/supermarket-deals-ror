class TodaysController < ApplicationController
  respond_to :json

  def index
    table = LowestPrice.arel_table
    result = LowestPrice
             .where(table[:normal_date].eq(1.days.ago)
                      .or(table[:special_date].eq(1.days.ago)))
    @products = result.all.group_by do |item|
      item.aisle.split(',').first(3).join(',')
    end
  end
end