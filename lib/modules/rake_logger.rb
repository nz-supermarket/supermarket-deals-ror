# processing log string based on log level
class RakeLogger
  def initialize(builder = '')
    @log_string_builder = builder
  end

  def log(thread, string, level = 'info')
    if level == 'debug'
      log_string thread, string, level
    elsif level == 'info'
      log_string thread, string unless string.include? 'Unable'
    elsif level == 'simple'
      print('.')
    end
  end

  private

  def log_string(thread, string, level = 'info')
    @log_string_builder += '\n'
    @log_string_builder += string
    if level == 'debug'
      Rails.logger.debug thread.inspect.split('/').first + ' - ' + string
    else
      Rails.logger.info thread.inspect.split('/').first + ' - ' + string
    end
  end
end
