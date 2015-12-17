describe FiscalYearFinder do
  describe "#run" do
    it "returns the fiscal year for a year and month" do
      year = 2015
      month = 10

      finder = FiscalYearFinder.new(year, month).run

      expect(finder).to eq 2016
    end
  end
end
