require "#{Rails.root}/lib/modules/countdown/item"

module Countdown
  class ItemProcessor
    def initialize(name)
      @aisle_name = name
    end

    def process_item(item)
      Countdown::Item.perform_in(rand(10.0..20.0).minutes, item.to_html, @aisle_name)
    end
  end
end
