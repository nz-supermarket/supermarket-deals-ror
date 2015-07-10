module RakeLogger
  def logger(string, level = 'info')
    if LOG_LEVEL == "debug"
      if string.include? "exist"
        unless @string_builder.include? "exist"
          @string_builder = string
        else
          @string_builder = @string_builder.gsub('. ', '')
          @string_builder = @string_builder + string.gsub("Product exist with sku: ", ", ")
        end
      else
        Rails.logger.info @string_builder
        @string_builder = ""
        Rails.logger.info string
      end
    elsif LOG_LEVEL == "info"
      unless string.include? "Unable"
        if string.include? "exist"
          unless @string_builder.include? "exist"
            @string_builder = string
          else
            @string_builder = @string_builder.gsub('. ', '')
            @string_builder = @string_builder + string.gsub("Product exist with sku: ", ", ")
          end
        else
          Rails.logger.info @string_builder
          @string_builder = ""
          Rails.logger.info string
        end
      end
    elsif LOG_LEVEL == "simple"
      print('.')
    end
  end
end
