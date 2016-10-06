class ProposalModifier
  def initialize(proposal, client_data)
    @proposal = proposal
    @client_data = client_data
  end

  def run
    Object.const_get(@proposal.client_data_type).prepare_frontend(@client_data)
  end

  private

  attr_accessor :proposal, :client_data
end
