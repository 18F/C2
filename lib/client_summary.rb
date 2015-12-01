class ClientSummary
  attr_reader :fiscal_year, :client_namespace
  def initialize(fiscal_year, client_namespace)
    @fiscal_year = fiscal_year
    @client_namespace = client_namespace
    @_statuses = { cancelled: 0, pending: 0, approved: 0 }
    @_subtotals = { cancelled: 0, pending: 0, approved: 0 }
  end

  def add_status(status)
    @_statuses[status.to_sym] += 1
  end

  def add_subtotal(status, amount)
    @_subtotals[status.to_sym] += amount
  end

  def status(status)
    @_statuses[status.to_sym]
  end

  def subtotal(status)
    @_subtotals[status.to_sym]
  end

  def total
    total = 0
    @_subtotals.values.each { |i| total += i }
    total
  end
end
