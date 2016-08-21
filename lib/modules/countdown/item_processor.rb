require "#{Rails.root}/lib/modules/countdown/item"

module Countdown
  class ItemProcessor
    def initialize(name)
      @aisle_name = name
    end

    def process_item(item)
      Countdown::Item.new(item, @aisle_name).process
    end
  end
end
