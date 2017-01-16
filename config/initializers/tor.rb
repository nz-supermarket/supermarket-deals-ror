Tor.configure do |config|
   config.ip = ENV['TOR_IP']
   config.port = 9050
   config.add_header('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2958.0 Safari/537.36')
end
