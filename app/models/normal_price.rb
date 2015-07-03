# Normal Prices Records
class NormalPrice < ActiveRecord::Base
  belongs_to :product
  before_validation :date_fix

  alias_attribute :normal, :price
  alias_attribute :normal_date, :date

  validates_uniqueness_of :product_id, :scope => :date

  def date_fix
    self.date = Time.zone.now.to_date
  end
end
