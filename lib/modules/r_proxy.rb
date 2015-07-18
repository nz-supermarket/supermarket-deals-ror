require 'open-uri'

module RProxy

PROXY_LIST = [nil,
              'http://202.27.212.58:8080', ##
              'http://202.27.212.136:8080',
              'http://203.86.202.222:80', ##
              'http://202.49.183.14:8080',
              'http://60.234.51.62:8118',
              'http://114.134.6.21:443',
              'http://203.86.202.167:9001',
              'http://203.184.12.247:443',
              'http://125.236.198.134:8080',
              'http://121.99.222.224:443',
              'http://156.62.100.35:80',
              'http://60.234.119.141:443',
              'http://103.247.194.152:80',
              'http://121.73.85.80:2132',
              '',
              ''
              ]

  def open_url_with_proxy(url, processing_aisle = false)
    proxies = PROXY_LIST
    proxies = PROXY_LIST[0..3] if processing_aisle
    result = nil
    number_of_retries = 0

    while result.blank?
      begin
        proxy = proxies.sample

        proxies.delete(proxy)

        number_of_retries += 1 if proxies.count <= 1
        break if number_of_retries >= 20

        result = open(url, :read_timeout => 30)
      rescue RuntimeError, SocketError => e
        log_proxy_error(url, proxy, e)
        result = nil
      rescue Errno::ETIMEDOUT => e
        log_proxy_error(url, proxy, e)
        result = nil
      rescue Errno::ENETUNREACH => e
        log_proxy_error(url, proxy, e)
        result = nil
      rescue Errno::EHOSTUNREACH => e
        log_proxy_error(url, proxy, e)
        result = nil
      rescue Errno::ECONNRESET => e
        log_proxy_error(url, proxy, e)
        result = nil
      rescue Errno::ECONNREFUSED => e
        log_proxy_error(url, proxy, e)
        result = nil
      rescue OpenURI::HTTPError => e
        log_proxy_error(url, proxy, e)
        result = nil
      end
    end
    return result
  end

  module_function :open_url_with_proxy

  def log_proxy_error(url, proxy, error)
    Rails.logger.error "Unable to connect with #{proxy} and #{url}, will ignore: #{error}"
  end
end
