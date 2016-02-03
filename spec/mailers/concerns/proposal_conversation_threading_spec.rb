describe ProposalConversationThreading do
  class TestClass
    include ProposalConversationThreading
  end

  describe "#subject" do
    it "returns string with pub_id, org_code, building_id, requester email for NCR requests" do
      object = TestClass.new
      work_order = build(:ncr_work_order)
      proposal = build(:proposal, client_data: work_order)

      subject = object.subject(proposal)

      expect(subject).to eq(
        "Request #{proposal.public_id}, #{work_order.organization_code_and_name}, #{work_order.building_id} from #{proposal.requester.email_address}"
      )
    end

    it "returns the public id for non-NCR requests" do
      object = TestClass.new
      procurement = build(:gsa18f_procurement)
      proposal = build(:proposal, client_data: procurement)

      subject = object.subject(proposal)

      expect(subject).to eq "Request #{proposal.public_id}"

    end
  end
end
