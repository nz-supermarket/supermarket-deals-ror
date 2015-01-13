require 'clockwork'
require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

include Clockwork

every(1.minutes, 'Fetch Prices') do
  (0..50).each do |i|
    Sidekiq::Client.enqueue(FetchPrices, i)
  end

  sleep rand(50..70)

  (51..100).each do |i|
    Sidekiq::Client.enqueue(FetchPrices, i)
  end

  sleep rand(200..300)

  (101..200).each do |i|
    Sidekiq::Client.enqueue(FetchPrices, i)
  end

  sleep rand(50..70)

  (201..300).each do |i|
    Sidekiq::Client.enqueue(FetchPrices, i)
  end
end
