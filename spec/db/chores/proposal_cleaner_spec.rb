require "#{Rails.root}/db/chores/proposal_cleaner"

describe ProposalCleaner do
  before(:all) { ENV["DISABLE_EMAIL"] = nil }
  after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }

  describe "#run" do
    it "removes proposals without client data" do
      _client_data_with_proposal = create(:ncr_work_order)
      create(:proposal, client_data: nil)
      orig_count = Proposal.count

      ProposalCleaner.new.run

      expect(Proposal.count).to eq(orig_count - 1)
    end

    it "removes client data without a proposal" do
      _ncr_with_proposal = create(:ncr_work_order)
      ncr_without_proposal = build(:ncr_work_order, proposal: nil)
      ncr_without_proposal.save(validate: false)

      expect {
        ProposalCleaner.new.run
      }.to change { Ncr::WorkOrder.count }.from(2).to(1)

      _18f_with_proposal = create(:gsa18f_procurement)
      gsa_without_proposal = build(:gsa18f_procurement, proposal: nil)
      gsa_without_proposal.save(validate: false)

      expect {
        ProposalCleaner.new.run
      }.to change { Gsa18f::Procurement.count }.from(2).to(1)
    end
  end
end
