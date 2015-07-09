module Midnight
  def seconds_to_midnight
    Time.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 23, 58, 00) - Time.zone.now
  end
end
