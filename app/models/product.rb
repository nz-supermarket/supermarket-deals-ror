class Product < ActiveRecord::Base
  extend ActiveModel::Callbacks
  has_many :special_price
  has_many :normal_price
  alias_attribute :index, :id
end
