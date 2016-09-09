class CountdownFinishJob
  include Sidekiq::Worker
  sidekiq_options queue: :countdown

  def perform(*args)
    Rails.logger.info "New Product count: #{today_count(Product)}"
    Rails.logger.info "New Special count: #{today_count(SpecialPrice)}"
    Rails.logger.info "New Normal count: #{today_count(NormalPrice)}"

    ActiveRecord::Base
      .connection.execute('REFRESH MATERIALIZED VIEW lowest_prices')
  end

  private

  def today_count(model)
    ActiveRecord::Base.connection_pool.with_connection do
      if model == Product
        model.where('created_at >= ?', Time.zone.now.beginning_of_day).count
      else
        model.where(date: Date.today).count
      end
    end
  end
end
