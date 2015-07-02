module Midnight
  def seconds_to_midnight
    Time.new(Time.now.year, Time.now.month, Time.now.day, 23, 58, 00) - Time.now
  end
end
