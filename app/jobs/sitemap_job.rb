class SitemapJob < ActiveJob::Base
  queue_as :sitemap

  def perform(*args)
    Rails.logger.info('***** Sitemap Refresh *****')
    system 'rake sitemap:refresh'
  end
end