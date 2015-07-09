# Common Price related stuff
class Price < ActiveRecord::Base
  belongs_to :product
  before_validation :date_fix

  validates_uniqueness_of :product_id, :scope => :date

  def date_fix
    self.date = Time.zone.now.to_date
  end
end
