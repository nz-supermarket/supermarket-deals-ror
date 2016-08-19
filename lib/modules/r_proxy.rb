require 'open-uri'

module RProxy

  def open_url_with_proxy(url)
    Tor::HTTP.get(URI(url))
  rescue RuntimeError,
         SocketError,
         Errno::ETIMEDOUT,
         Errno::EHOSTUNREACH,
         Errno::ECONNRESET,
         Errno::ECONNREFUSED,
         OpenURI::HTTPError,
         Errno::ENETUNREACH => e
    Rails.logger.error "RProxy - url: #{url}, error: #{e}"
  end

  module_function :open_url_with_proxy
end
