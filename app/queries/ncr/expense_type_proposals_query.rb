module Ncr
  class ExpenseTypeProposalsQuery
    def initialize(expense_type:, time_delimiter:)
      @expense_type = expense_type
      @time_delimiter = time_delimiter
    end

    def find
      Proposal
        .approved
        .joins(:client_data)
        .where(client_data_type: "Ncr::WorkOrder")
        .where("created_at > ?", time_delimiter)
        .select { |proposal| proposal.client_data.expense_type == type }
    end

    private

    attr_reader :expense_type, :time_delimiter
  end
end
