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

    def get_product_normal_price_history
      NormalPrice.where(product_id: @product.id).map do |i|
        { i.date.to_time.to_i => i.price }
      end
    end

    def get_product_special_price_history
      SpecialPrice.where(product_id: @product.id).map do |i|
        { i.date.to_time.to_i => i.price }
      end
    end
end
