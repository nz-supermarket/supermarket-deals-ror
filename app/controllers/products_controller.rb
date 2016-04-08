class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    @table_size = Product.all.count
    start_date = NormalPrice.select(:date).order(:date).first.date
    @counter = (Time.now - start_date.to_time).to_i
    respond_to do |format|
      format.html
      format.json { render json: ProductsDatatable.new(view_context) }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @prices = combined_price_history
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

    def combined_price_history
      prices = NormalPrice.product_price_history(@product.id) + SpecialPrice.product_price_history(@product.id)
      prices = prices.group_by { |i| i.date.strftime('%^a, %Y-%m-%d') }

      prices.each do |key, values|
        new_value = Hash.new(nil)

        values.each do |value|
          if value.class == NormalPrice
            new_value[:normal] = value.price.try(:to_f)
          elsif value.class == SpecialPrice
            new_value[:special] = value.price.try(:to_f)
          end
        end

        prices[key] = new_value
      end
    end
end
