class ProductsDatatable
  delegate :params, :h, :link_to, :number_to_currency, :number_to_percentage, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      bDestroy: true,
      sEcho: params[:sEcho].to_i,
      iTotalRecords: LowestPrice.count,
      iTotalDisplayRecords: products.total_entries,
      aaData: data
    }
  end

  def data
    products.map do |product|
      [
        product.name,
        product.volume,
        product.sku,
        price_handler(product.special, product.normal, product.diff),
        product.aisle,
        discount_handler(number_to_percentage(product.discount, precision: 2))
      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    products = LowestPrice.order("#{sort_column} #{sort_direction}")
    products = products.page(page).per_page(per_page)
    if params[:sSearch].present?
      params[:sSearch] = params[:sSearch].downcase() if !params[:sSearch].match(/\d+/)
      params[:sSearch] = params[:sSearch].split(' ').map{ |i| i = "%" + i + "%"}
      params[:sSearch].each do |text|
        products = products.where("lower(name) similar to :search or lower(aisle) similar to :search or sku::text ~ :search", search: "#{text}")
      end
    end
    products
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name volume sku diff aisle discount]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  private
  def discount_handler value
    return 0.0 if value.nil?
    if value.to_d > 50
      content_tag(:div, value, class: "yellow")
    elsif value.to_d > 30
      content_tag(:div, value, class: "green")
    else
      value
    end
  end

  def price_handler special, normal, diff

    prices = [special, normal, diff]
    prices_names = ["Special: ", "Normal: ", "Variance: "]
    content = ""

    (0..2).each do |i|
      each = content_tag(:td, prices_names[i]) + content_tag(:td, number_to_currency(prices[i]))
      content << content_tag(:div, each, class: "row")
    end

    content
  end
end
