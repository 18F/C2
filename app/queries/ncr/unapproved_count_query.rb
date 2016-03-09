module Ncr
  class UnapprovedCountQuery
    def find
      Proposal.pending.where(client_data_type: "Ncr::WorkOrder").count
    end
  end
end
