module PeriodHelper
  YEAR_IN_SEC ||= 31_536_000
  MONTH_IN_SEC ||= 2_419_200
  WEEK_IN_SEC ||= 604_800
  DAY_IN_SEC ||= 86_400

  def human_period(seconds)
    period = [
      years(seconds),
      months(seconds),
      weeks(seconds),
      days(seconds)
    ].compact.join(', ')

    period
  end

  private

  def years(seconds)
    time_periodize(seconds, YEAR_IN_SEC, 'year')
  end

  def months(seconds)
    time_periodize(seconds, MONTH_IN_SEC, 'month', YEAR_IN_SEC)
  end

  def weeks(seconds)
    time_periodize(seconds, WEEK_IN_SEC, 'week', MONTH_IN_SEC)
  end

  def days(seconds)
    time_periodize(seconds, DAY_IN_SEC, 'day', WEEK_IN_SEC)
  end

  def time_periodize(seconds, period_in_seconds, singular_string, previous_in_seconds = 0)
    return nil if seconds < period_in_seconds

    remainder = previous_in_seconds != 0 ? seconds % previous_in_seconds : seconds

    number = remainder / period_in_seconds

    return nil if number == 0

    pluralize(number, singular_string)
  end
end
