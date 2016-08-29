class CountdownJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Rails.logger.info('***** Countdown Fetch Price *****')
    system 'rake fetch_prices'
  end
end