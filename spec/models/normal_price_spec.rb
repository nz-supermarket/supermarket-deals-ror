require 'rails_helper'

RSpec.describe NormalPrice, :type => :model do
  before do
    create_list(:normal_price, 50)
  end

  describe 'NormalPrice' do
    it 'should have 50 prices' do
      expect(NormalPrice.all.size).to eq(50)
    end

    it 'should return a result for product_price_history' do
      expect(NormalPrice.product_price_history(1).size).to eq(1)
    end
  end
end
