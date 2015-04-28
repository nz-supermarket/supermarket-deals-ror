# Special Prices Records
class SpecialPrice < ActiveRecord::Base
  belongs_to :product
  before_validation :date_fix

  alias_attribute :special, :price
  alias_attribute :special_date, :date

  validates_uniqueness_of :product_id, :scope => :date

  def date_fix
    self.date = Date.today
  end
end
