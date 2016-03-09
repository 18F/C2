module FiscalYearMixin
  extend ActiveSupport::Concern

  FISCAL_YEAR_START_MONTH = 10 # 1-based

  included do
    scope :for_fiscal_year, lambda { |year|
      range = range_for_fiscal_year(year)
      where(created_at: range[:start_time]...range[:end_time])
    }

    def self.range_for_fiscal_year(year)
      start_time = Time.zone.local(year - 1, FISCAL_YEAR_START_MONTH, 1)
      end_time = start_time + 1.year
      { start_time: start_time, end_time: end_time }
    end
  end
end
