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
    @prices_history = combined_price_history
    @day_of_week = weekly_price_history
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

    def price_history(klass)
      klass.product_price_history(@product.id)
    end

    def combined_price_history
      prices = price_history(NormalPrice) + price_history(SpecialPrice)
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

    def weekly_price_history
      normal = price_history(NormalPrice)
      special = price_history(SpecialPrice)

      new_normal = []
      normal.each do |value|
        new_normal << { key: value.date.strftime('%u'), date: value.date, normal: value.price.try(:to_f) }
      end

      new_special = []
      special.each do |value|
        new_special << { key: value.date.strftime('%u'), date: value.date, special: value.price.try(:to_f) }
      end

      (new_normal + new_special).sort_by{|i| i[:key]}
    end
end
