class ProductsDatatable
  delegate :params, :h, :link_to, :number_to_currency, :number_to_percentage, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      bDestroy: true,
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Product.count,
      iTotalDisplayRecords: products.total_entries,
      aaData: data
    }
  end

  def data
    products.map do |product|
      [
        product.id,
        product.name,
        product.volume,
        product.sku,
        number_to_currency(product.special, unit: "NZ$", delimiter: ","),
        number_to_currency(product.normal, unit: "NZ$", delimiter: ","),
        number_to_currency(product.diff, unit: "NZ$", delimiter: ","),
        product.aisle,
        number_to_percentage(product.discount, precision: 2)
      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    products = Product.order("#{sort_column} #{sort_direction}")
    products = products.page(page).per_page(per_page)
    if params[:sSearch].present?
      params[:sSearch] = params[:sSearch] if !params[:sSearch].match(/\d+/)
      params[:sSearch] = params[:sSearch].split(' ').map{ |i| i = "%" + i + "%"}
      search = ""
      params[:sSearch].each{|i| search = search + i + "," }
      search = search.gsub(/\,$/, '').gsub(',', '|')
      binding.pry
      products = products.where("name ~* :search or aisle ~* :search or sku::text ~ :search", search: "#{search}")
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
    columns = %w[id name volume sku special normal diff aisle discount]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
