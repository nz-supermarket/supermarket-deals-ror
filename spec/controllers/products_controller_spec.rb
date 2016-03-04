require 'rails_helper'

RSpec.describe ProductsController, :type => :controller do

  describe "GET index" do
    it "assigns all products as @products" do
      create_list(:product_with_prices, 20)
      get :index
      expect(response).to render_template('index')
    end
  end

  describe "GET show" do
    it "assigns the requested product as @product" do
      product = create(:product_with_prices)
      get :show, id: product.id
      expect(response).to render_template('show')
    end
  end
end
