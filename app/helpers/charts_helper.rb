module ChartsHelper
  def combined_price_list(prices, method_1, method_2)
    price_extract(prices, method_1)
      .send(:+,
            price_extract(prices, method_2))
  end

  def method_from_list(list, method)
    list.compact.send(method) || 0
  end

  def week_process(list, key)
    list
      .select { |i| i[key].present? }
      .map { |i| { name: i[:date].strftime('%A'), x: (i[:date].strftime('%u').to_i - 1), y: i[key] } }
  end

  private

  def price_extract(prices, method)
    prices.values.map { |i| i[method] }
  end
end
