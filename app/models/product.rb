class Product < ActiveRecord::Base
  extend ActiveModel::Callbacks

  after_save :set_diff, :set_discount

  alias_attribute :index, :id

  private

  def set_diff
    update_column(:diff, (self.normal - self.special))
  end

  def set_discount
    update_column(:discount, ((self.diff / self.normal) * 100))
  end

end
