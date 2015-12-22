class ProductsDatatable
  delegate :params, :h, :link_to, :number_to_currency, :number_to_percentage, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: LowestPrice.count,
      iTotalDisplayRecords: products.total_entries,
      aaData: data
    }
  end

  def data
    products.map do |product|
      [
        link_to(product.name, "/products/#{product.id}"),
        product.volume,
        product.sku,
        number_to_currency(product.special) || '',
        number_to_currency(product.normal),
        number_to_currency(product.diff),
        product.aisle,
        discount_handler(number_to_percentage(product.discount * 100, precision: 2))
      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    products = Rails.cache.read(cache_key_gen)

    if products.nil?
      products = LowestPrice.order("#{sort_column} #{sort_direction}")
      products = products.page(page).per_page(per_page)

      products = product_filter_on_search(products) if params[:sSearch].present?
    end

    Thread.new do
      begin
        Rails.cache.write(
          cache_key_gen,
          products,
          expires_in: 12.hours,
          race_condition_ttl: 10)
      rescue ThreadError => e
        Rails.logger.error e
      end
    end.join

    products
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    # database views/tables column names
    columns = %w[name volume sku special normal diff_price aisle discount]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  private
  def discount_handler value
    return value if value.nil?
    if value.to_d > 50
      content_tag(:div, value, class: "yellow")
    elsif value.to_d > 30
      content_tag(:div, value, class: "green")
    else
      value
    end
  end

  def cache_key_gen
    cache_key = 'products#'
    cache_key += Digest::SHA2.hexdigest(params.to_s)

    cache_key
  end

  def product_filter_on_search(products)
    params[:sSearch] = params[:sSearch].downcase() if !params[:sSearch].match(/\d+/)
    params[:sSearch] = params[:sSearch].split(' ').map{ |i| i = "%" + i + "%"}
    params[:sSearch].each do |text|
      products = products.where("lower(name) similar to :search or lower(aisle) similar to :search or sku::text ~ :search", search: "#{text}")
    end

    products
  end
end
