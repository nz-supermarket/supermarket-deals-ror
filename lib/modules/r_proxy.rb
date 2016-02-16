require 'open-uri'

module RProxy
  PROXY_LIST = [nil,
                'http://202.27.212.58:8080', ##
                'http://202.27.212.136:8080',
                'http://203.86.202.222:80', ##
                'http://60.234.51.62:8118',
                'http://60.234.119.141:443',
                'http://103.247.194.152:80',
                'http://103.250.48.105:80',
                'http://114.134.6.21:443',
                'http://121.73.85.80:2132',
                'http://121.99.222.224:443',
                'http://125.214.82.50:8080',
                'http://125.236.198.134:8080',
                'http://140.200.236.125:8080',
                'http://156.62.100.35:80',
                'http://180.95.19.77:80',
                'http://202.37.28.168:8080',
                'http://202.49.183.14:8080',
                'http://202.165.89.18:80',
                'http://203.86.202.167:9001',
                'http://203.97.29.15:3128',
                'http://203.97.49.252:3128',
                'http://203.97.196.6:3128',
                'http://203.184.12.247:443',
                'http://210.54.175.130:3128',
                'http://210.55.248.134:80',
                '',
                '']

  def open_url_with_proxy(url)
    proxies = PROXY_LIST
    result = nil
    number_of_retries = 0

    while result.blank?
      begin
        proxy = proxies.sample

        proxies.delete(proxy)

        number_of_retries += 1 if proxies.count <= 1
        break if number_of_retries >= 20

        result = open(url, proxy: proxy, read_timeout: 30)
      rescue RuntimeError,
             SocketError,
             Errno::ETIMEDOUT,
             Errno::EHOSTUNREACH,
             Errno::ECONNRESET,
             Errno::ECONNREFUSED,
             OpenURI::HTTPError,
             Errno::ENETUNREACH => e
        log_proxy_error(url, proxy, e)
        result = nil
      end
      return result
    end
  end

  def log_proxy_error(url, proxy, error)
    Rails.logger.error "RProxy - proxy: #{proxy}, url: #{url}, error: #{error}"
  end

  module_function :open_url_with_proxy
end
