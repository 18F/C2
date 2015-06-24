describe Ncr::WorkOrder do
  describe '#fields_for_display' do
    it "shows BA61 fields" do
      wo = Ncr::WorkOrder.new(
        amount: 1000, expense_type: "BA61", vendor: "Some Vend",
        not_to_exceed: false, emergency: true, rwa_number: "RWWAAA #",
        building_number: Ncr::Building.first,
        org_code: Ncr::Organization.all[0], description: "Ddddd", direct_pay: true)
      expect(wo.fields_for_display.sort).to eq([
        ["Amount", 1000],
        ["Building number", Ncr::Building.first],
        ["CL number", nil],
        ["Description", "Ddddd"],
        ["Direct pay", true],
        ["Emergency", true],
        ["Expense type", "BA61"],
        ["Function code", nil],
        ["Not to exceed", false],
        ["Org code", Ncr::Organization.all[0]],
        # No RWA Number
        ["SOC code", nil],
        ["Vendor", "Some Vend"]
        # No Work Order
      ])
    end
    it "shows BA80 fields" do
      wo = Ncr::WorkOrder.new(
        amount: 1000, expense_type: "BA80", vendor: "Some Vend",
        not_to_exceed: false, emergency: true, rwa_number: "RWWAAA #",
        building_number: Ncr::Building.first, code: "Some WO#",
        org_code: Ncr::Organization.all[0], description: "Ddddd", direct_pay: true)
      expect(wo.fields_for_display.sort).to eq([
        ["Amount", 1000],
        ["Building number", Ncr::Building.first],
        ["CL number", nil],
        ["Description", "Ddddd"],
        ["Direct pay", true],
        # No Emergency
        ["Expense type", "BA80"],
        ["Function code", nil],
        ["Not to exceed", false],
        ["Org code", Ncr::Organization.all[0]],
        ["RWA Number", "RWWAAA #"],
        ["SOC code", nil],
        ["Vendor", "Some Vend"],
        ["Work Order / Maximo Ticket Number", "Some WO#"]
      ])
    end
  end

  describe '#add_approvals' do
    it "creates approvers when not an emergency" do
      form = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61')
      form.add_approvals('bob@example.com')
      expect(form.observations.length).to eq(0)
      expect(form.approvers.map(&:email_address)).to eq([
        'bob@example.com',
        Ncr::WorkOrder.ba61_tier1_budget_mailbox,
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ])
      form.reload
      expect(form.approved?).to eq(false)
    end

    it "creates observers when in an emergency" do
      form = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61',
                               emergency: true)
      form.add_approvals('bob@example.com')
      expect(form.observers.map(&:email_address)).to eq([
        'bob@example.com',
        Ncr::WorkOrder.ba61_tier1_budget_mailbox,
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ])
      expect(form.approvals.length).to eq(0)
      form.clear_association_cache
      expect(form.approved?).to eq(true)
    end
  end

  describe '#organization' do
    it "returns the corresponding Organization instance" do
      org = Ncr::Organization.all.last
      work_order = Ncr::WorkOrder.new(org_code: org.code)
      expect(work_order.organization).to eq(org)
    end

    it "returns nil for no #org_code" do
      work_order = Ncr::WorkOrder.new
      expect(work_order.organization).to eq(nil)
    end
  end

  describe '#system_approvers' do
    it "skips the Tier 1 budget approver for WHSC" do
      work_order = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61', org_code: Ncr::Organization::WHSC_CODE)
      expect(work_order.system_approvers).to eq([
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ])
    end

    it "includes the Tier 1 budget approver for an unknown organization" do
      work_order = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61', org_code: nil)
      expect(work_order.system_approvers).to eq([
        Ncr::WorkOrder.ba61_tier1_budget_mailbox,
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ])
    end
  end

  describe '#total_price' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order, amount: 45.36)}
    it 'gets price from amount field' do
      expect(work_order.total_price).to eq(45.36)
    end
  end

  describe '#public_identifier' do
    it 'includes the fiscal year' do
      work_order = FactoryGirl.create(:ncr_work_order, created_at: Date.new(2007, 1, 15))
      proposal_id = work_order.proposal.id

      expect(work_order.public_identifier).to eq(
        "FY07-#{proposal_id}")

      work_order.update_attribute(:created_at, Date.new(2007, 10, 1))
      expect(work_order.public_identifier).to eq(
        "FY08-#{proposal_id}")
    end
  end

  describe 'rwa validations' do
    let (:work_order) { FactoryGirl.build(:ncr_work_order, expense_type: 'BA80') }

    it 'works with one letter followed by 7 numbers' do
      work_order.rwa_number = 'A1234567'
      expect(work_order).to be_valid
    end

    it 'must be 8 chars' do
      work_order.rwa_number = 'A123456'
      expect(work_order).not_to be_valid
    end

    it 'must have a letter at the beginning' do
      work_order.rwa_number = '12345678'
      expect(work_order).not_to be_valid
    end

    it "is required for BA80" do
      work_order.rwa_number = nil

      expect(work_order).to_not be_valid
      expect(work_order.errors.keys).to eq([:rwa_number])
    end

    it "is not required for BA61" do
      work_order.expense_type = 'BA61'

      work_order.rwa_number = nil
      expect(work_order).to be_valid
      work_order.rwa_number = ''
      expect(work_order).to be_valid
    end
  end

  describe '#record_changes' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order) }

    it 'adds a change comment' do
      work_order.update(vendor: 'VenVenVen', amount: 123.45)
      expect(work_order.proposal.comments.count).to be 1
      comment = Comment.last
      expect(comment.update_comment).to be(true)
      comment_text = "- *Vendor* was changed to VenVenVen\n"
      comment_text += "- *Amount* was changed to $123.45"
      expect(comment.comment_text).to eq(comment_text)
    end

    it 'includes extra information if modified post approval' do
      work_order.approve!
      work_order.update(vendor: 'VenVenVen', amount: 123.45)
      expect(work_order.proposal.comments.count).to be 1
      comment = Comment.last
      expect(comment.update_comment).to be(true)
      comment_text = "- *Vendor* was changed to VenVenVen\n"
      comment_text += "- *Amount* was changed to $123.45\n"
      comment_text += "_Modified post-approval_"
      expect(comment.comment_text).to eq(comment_text)
    end

    it 'does not add a change comment when nothing has changed' do
      work_order.touch
      expect(Comment.count).to be 0
    end

    it 'does not add a comment when nothing has changed and it is approved' do
      work_order.approve!
      work_order.touch
      expect(Comment.count).to be 0
    end
  end
end
