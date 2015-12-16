module FiscalYearMixin
  extend ActiveSupport::Concern

  FISCAL_YEAR_START_MONTH = 10 # 1-based

  included do
    def self.which_fiscal_year(year, month)
      if month >= FISCAL_YEAR_START_MONTH
        year + 1
      else
        year
      end
    end

    def self.range_for_fiscal_year(year)
      start_time = Time.zone.local(year - 1, FISCAL_YEAR_START_MONTH, 1)
      end_time = start_time + 1.year
      { start_time: start_time, end_time: end_time }
    end
  end
end
