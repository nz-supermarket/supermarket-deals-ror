require 'sitemap_generator'
class SitemapJob < ActiveJob::Base
  queue_as :sitemap

  def perform(*args)
    Rails.logger.info('***** Sitemap Refresh *****')

    SitemapGenerator::Interpreter.run(:config_file => ENV["CONFIG_FILE"], :verbose => verbose)
    SitemapGenerator::Sitemap.ping_search_engines
  end
end