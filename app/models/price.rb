# Standard Prices Model for inheritance
class Price < ActiveRecord::Base
  self.abstract_class = true
  belongs_to :product
  before_validation :date_fix

  validates_uniqueness_of :product_id, scope: :date

  def self.product_price_history(id)
    where(product_id: id).order(:date)
  end

  private

  def date_fix
    self.date = Time.zone.now.to_date
  end
end
