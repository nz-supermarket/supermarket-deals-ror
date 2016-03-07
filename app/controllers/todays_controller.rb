class TodaysController < ApplicationController
  respond_to :json

  def index
    table = LowestPrice.arel_table
    result = LowestPrice
             .where(table[:normal_date].eq(Date.today)
                      .or(table[:special_date].eq(Date.today)))
    result = result.all.group_by(&:aisle)
    respond_with result.to_json
  end
end