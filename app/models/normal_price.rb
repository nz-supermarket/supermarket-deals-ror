# Normal Prices Records
class NormalPrice < Price
  alias_attribute :normal, :price
  alias_attribute :normal_date, :date
end
