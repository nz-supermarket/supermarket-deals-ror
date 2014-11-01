class Product < ActiveRecord::Base
  extend ActiveModel::Callbacks

  after_create :set_diff
  after_create :set_discount

  alias_attribute :index, :id

  private

  def set_diff
    self.diff = (self.normal - self.special)
    self.save
  end

  def set_discount
    self.discount = ((self.diff / self.normal) * 100)
    self.save
  end

end
