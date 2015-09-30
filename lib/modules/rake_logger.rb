# processing log string based on log level
class RakeLogger
  def initialize(builder = '')
    @log_string_builder = builder
  end

  def log(string, level = 'debug')
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
    if Rails.env == 'test' || Rails.env == 'development'
      Rails.logger.info string
    else
      info string
    end
  end
end
