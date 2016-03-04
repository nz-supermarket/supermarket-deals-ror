class TodaysController < ApplicationController
  respond_to :json

  def index
    respond_with LowestPrice.where("normal_date = :date or special_date = :date", date: Date.today).all.to_json
  end
end