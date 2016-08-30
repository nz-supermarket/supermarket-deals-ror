class CountdownJob < ActiveJob::Base
  queue_as :countdown

  def perform(*args)
    Rails.logger.info('***** Countdown Fetch Price *****')
    system 'rake fetch_prices'
  end
end