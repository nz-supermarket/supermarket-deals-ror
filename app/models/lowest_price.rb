# Database View with Lowest Prices for each Product
class LowestPrice < ActiveRecord::Base
  alias_attribute :special, :special_price
  alias_attribute :normal, :normal_price
  alias_attribute :diff, :diff_price
end
