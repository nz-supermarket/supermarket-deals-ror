class Product < ActiveRecord::Base
  extend ActiveModel::Callbacks
  alias_attribute :index, :id
end
