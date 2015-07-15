module RakeLogger
  def logger(string, level = 'debug')
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
      unless @log_string_builder.include? "exist"
        @log_string_builder = string
      else
        @log_string_builder = @log_string_builder.gsub('. ', '')
        @log_string_builder = @log_string_builder + string.gsub("Product exist with sku: ", ", ")
      end
    else
      @log_string_builder = @log_string_builder + '\n'
      @log_string_builder = @log_string_builder + string
      info string
    end
  end
end
