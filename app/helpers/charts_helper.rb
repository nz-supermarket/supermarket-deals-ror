module ChartsHelper
  def combined_price_list(prices, method_1, method_2)
    price_extract(prices, method_1)
      .send(:+,
            price_extract(prices, method_2))
  end

  def method_from_list(list, method)
    list.compact.send(method)
  end

  private

  def price_extract(prices, method)
    prices.values.map { |i| i[method] }
  end
end
