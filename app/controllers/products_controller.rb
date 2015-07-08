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
        f.title(:text => "Population vs GDP For 5 Big Countries [2009]")
        f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])
        f.series(:name => "GDP in Billions", :yAxis => 0, :data => [14119, 5068, 4985, 3339, 2656])
        f.series(:name => "Population in Millions", :yAxis => 1, :data => [310, 127, 1340, 81, 65])

        f.yAxis [
          {:title => {:text => "GDP in Billions", :margin => 70} },
          {:title => {:text => "Population in Millions"}, :opposite => true},
        ]

        f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
        f.chart({:defaultSeriesType=>"column"})
      end
    end

    def get_product_normal_price_history_prices
      NormalPrice.where(product_id: @product.id).order(:date).map{ |i| i.price }
    end

    def get_product_normal_price_history_dates
      NormalPrice.where(product_id: @product.id).order(:date).map{ |i| i.date }
    end

    def get_product_special_price_history_prices
      SpecialPrice.where(product_id: @product.id).order(:date).map{ |i| i.price }
    end

    def get_product_special_price_history_dates
      SpecialPrice.where(product_id: @product.id).order(:date).map{ |i| i.date }
    end
end
