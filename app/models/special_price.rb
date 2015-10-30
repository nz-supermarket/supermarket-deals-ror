# Special Prices Records
class SpecialPrice < Price
  alias_attribute :special, :price
  alias_attribute :special_date, :date
end
