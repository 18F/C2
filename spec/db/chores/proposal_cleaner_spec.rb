require "#{Rails.root}/db/chores/proposal_cleaner"

describe ProposalCleaner do
  describe "#run" do
    it "removes proposals without client data" do
      _client_data_with_proposal = create(:ncr_work_order)
      create(:proposal, client_data: nil)

      expect {
        ProposalCleaner.new.run
      }.to change { Proposal.count }.from(2).to(1)
    end
  end
end
