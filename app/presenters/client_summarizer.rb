class ClientSummarizer
  attr_reader :client_namespace, :fiscal_year

  def initialize(args)
    @client_namespace = args[:client_namespace]
    now = Time.zone.now
    @fiscal_year = (args[:fiscal_year] || FiscalYearFinder.new(now.year, now.month).run).to_i
  end

  def run
    @records ||= build_records
    @summary ||= build_summary
  end

  private

  def build_records
    Proposal.for_fiscal_year(fiscal_year).where("client_data_type LIKE ?", "#{client_namespace}::%")
  end

  def build_summary
    summary = ClientSummary.new(fiscal_year, client_namespace)
    @records.each do |proposal|
      summary.add_status(proposal.status)
      summary.add_subtotal(proposal.status, proposal.client_data.total_price)
    end
    summary
  end
end
