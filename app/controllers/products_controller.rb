class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    @counter = ((Time.now - Time.new(2015,7,1,10)).to_i / 604800).round
    @table_size = Product.all.count
    respond_to do |format|
      format.html
      format.json { render json: ProductsDatatable.new(view_context) }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    generate_chart
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = LowestPrice.where(id: params[:id]).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :volume, :sku, :special, :normal, :diff, :aisle, :discount)
    end

    def generate_chart
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "Price History for #{@product.name}")
        f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])
        f.series(:name => 'Normal Prices', :yAxis => 0, :data => get_product_normal_price_history_prices)
        f.series(:name => 'Special Prices', :yAxis => 1, :data => get_product_special_price_history_prices)

        f.yAxis [
          {:title => {:text => "GDP in Billions", :margin => 70} },
          {:title => {:text => "Population in Millions"}, :opposite => true},
        ]

        f.chart({:defaultSeriesType=>"line"})
      end
    end

    def combined_price_history
      prices = NormalPrice.product_price_history(@product.id) + SpecialPrice.product_price_history(@product.id)
      prices.group_by{}
    end

    def get_product_normal_price_history_prices
      NormalPrice.product_price_history(@product.id).map{ |i| i.price }
    end

    def get_product_normal_price_history_dates
      NormalPrice.product_price_history(@product.id).map{ |i| i.date }
    end

    def get_product_special_price_history_prices
      SpecialPrice.product_price_history(@product.id).map{ |i| i.price }
    end

    def get_product_special_price_history_dates
      SpecialPrice.product_price_history(@product.id).map{ |i| i.date }
    end
end
