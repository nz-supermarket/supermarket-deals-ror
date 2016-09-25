Tor.configure do |config|
   config.ip = "172.20.9.115"
   config.port = 9050
   config.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1')
end