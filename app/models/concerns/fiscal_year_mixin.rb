module FiscalYearMixin
  extend ActiveSupport::Concern

  FISCAL_YEAR_START_MONTH = 10 # 1-based

  included do
    def self.which_fiscal_year(year, month)
      if month >= 10
        year + 1
      else
        year
      end
    end

    def self.for_fiscal_year(year)
      start_time = Time.zone.local(year - 1, FISCAL_YEAR_START_MONTH, 1)
      end_time = start_time + 1.year
      where(created_at: start_time...end_time)
    end
  end
end
