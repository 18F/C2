class ProposalCleaner
  def run
    Proposal.where(client_data: nil).destroy_all
    Ncr::WorkOrder.where.not(id: ncr_client_data_ids).destroy_all
    Gsa18f::Procurement.where.not(id: gsa_client_data_ids).destroy_all
  end

  private

  def ncr_client_data_ids
    Proposal.where(client_data_type: "Ncr::WorkOrder").pluck(:client_data_id)
  end

  def gsa_client_data_ids
    Proposal.where(client_data_type: "Gsa18f::Procurement").pluck(:client_data_id)
  end
end
