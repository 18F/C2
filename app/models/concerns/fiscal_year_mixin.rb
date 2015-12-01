module FiscalYearMixin
  extend ActiveSupport::Concern

  included do
    def self.which_fiscal_year(year, month)
      if month >= 10
        year + 1
      else
        year
      end
    end
  end
end
