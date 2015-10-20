# processing log string based on log level
class RakeLogger
  def initialize(builder = '')
    @log_string_builder = builder
  end

  def log(string, level = 'info')
    if level == 'debug'
      log_string string, level
    elsif level == 'info'
      log_string string unless string.include? 'Unable'
    elsif level == 'simple'
      print('.')
    end
  end

  private

  def log_string(string, level = 'info')
    @log_string_builder += '\n'
    @log_string_builder += string
    if level == 'debug'
      Rails.logger.debug string
    else
      Rails.logger.info string
    end
  end
end
