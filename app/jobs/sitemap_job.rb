require 'sitemap_generator'
class SitemapJob < ActiveJob::Base
  queue_as :sitemap

  def perform(*args)
    Rails.logger.info('***** Sitemap Refresh *****')

    SitemapGenerator::Interpreter.run(verbose: true)
    SitemapGenerator::Sitemap.ping_search_engines
  end
end