# processing log string based on log level
module RakeLogger
  def logger(string, level = 'debug')
    if level == 'debug'
      log_string string
    elsif level == 'info'
      log_string string unless string.include? 'Unable'
    elsif level == 'simple'
      print('.')
    end
  end

  private

  def log_string(string)
    @log_string_builder += '\n'
    @log_string_builder += string
    info string
  end
end
