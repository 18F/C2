class ProposalCleaner
  def run
    Proposal.where(client_data: nil).destroy_all
  end
end
