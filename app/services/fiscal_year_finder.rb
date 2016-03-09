class FiscalYearFinder
  FISCAL_YEAR_START_MONTH = 10 # 1-based

  def initialize(year, month)
    @year = year
    @month = month
  end

  def run
    if month >= FISCAL_YEAR_START_MONTH
      year + 1
    else
      year
    end
  end

  private

  attr_reader :year, :month
end
