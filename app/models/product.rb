class Product < ActiveRecord::Base

	# attr_accessor :name, :volume, :sku, :special, :normal, :diff, :aisle, :discount

	def after_create 
		@diff ||= (self.normal - self.special)
		@discount ||= ((self.diff / self.normal) * 100)
		self.save
	end

end
