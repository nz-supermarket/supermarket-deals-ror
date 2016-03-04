require 'rails_helper'

RSpec.describe TodaysController, :type => :controller do
  before :all do
    create_list(:product_with_prices, 30)

    @today_size = (1..10).to_a.sample
    @today_list = today_product_list([], @today_size)

    ActiveRecord::Base
      .connection.execute('REFRESH MATERIALIZED VIEW lowest_prices')
  end

  describe 'GET index' do
    it 'returns json format of today lowest' do
      get :index, format: :json
      expect(response).to be_success

      @today_list.each do |id|
        expect(JSON.parse(response.body)).to have_content(id)
      end

      expect(JSON.parse(response.body).count).to eq(@today_size)
    end
  end

  private

  def today_product_list(list, number)
    (1..number).each do
      today_product = create(:product_with_prices)
      today_special = SpecialPrice
                      .where(product_id: today_product.id,
                             date: Date.today).first

      list << today_product.id

      today_special_fix(today_special, today_product.id)
    end

    list
  end

  def today_special_fix(special, product_id)
    if special
      lowest_special_fix(special, product_id)
    else
      create(:special_price,
             date: Date.today,
             price: 0.01,
             product_id: product_id)
    end
  end

  def lowest_special_fix(special, product_id)
    lowest = NormalPrice
             .where(product_id: product_id)
             .all.send(:+,
                       SpecialPrice
                       .where(product_id: product_id)
                       .all).map(&:price).min
    special.price = lowest - 0.01
    special.save
  end
end