require 'rails_helper'

RSpec.describe SpecialPrice, :type => :model do
  before do
    create_list(:special_price, 50)
  end

  describe 'SpecialPrice' do
    it 'should have 50 prices' do
      expect(SpecialPrice.all.size).to eq(50)
    end

    it 'should return a result for product_price_history' do
      expect(SpecialPrice.product_price_history(1).size).to eq(1)
    end
  end
end
