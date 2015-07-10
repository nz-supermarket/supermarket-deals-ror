module RakeLogger
  def logger(string, level = 'info')
    if level == "debug"
      log_string string
    elsif level == "info"
      unless string.include? "Unable"
        log_string string
      end
    elsif level == "simple"
      print('.')
    end
  end

  private

  def log_string(string)
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
end
