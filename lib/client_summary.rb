class ClientSummary
  attr_reader :fiscal_year, :client_namespace
  def initialize(fiscal_year, client_namespace)
    @fiscal_year = fiscal_year
    @client_namespace = client_namespace
    @statuses = { cancelled: 0, pending: 0, approved: 0 }
    @subtotals = { cancelled: 0, pending: 0, approved: 0 }
  end

  def add_status(status)
    @statuses[status.to_sym] += 1
  end

  def add_subtotal(status, amount)
    @subtotals[status.to_sym] += amount
  end

  def status(status)
    @statuses[status.to_sym]
  end

  def subtotal(status)
    @subtotals[status.to_sym]
  end

  def total
    total = 0
    @subtotals.values.each { |i| total += i }
    total
  end

  def subtotal_percent(status)
    (subtotal(status).to_f / total) * 100
  end

  def status_sum
    total = 0
    @statuses.values.each { |i| total += i }
    total
  end

  def status_percent(status)
    (self.status(status).to_f / status_sum) * 100
  end
end
