describe Ncr::WorkOrder do
  include ProposalSpecHelper

  describe "#editabe?" do
    it "is true" do
      work_order = build(:ncr_work_order)
      expect(work_order).to be_editable
    end
  end

  describe '#relevant_fields' do
    it "shows BA61 fields" do
      wo = Ncr::WorkOrder.new
      expect(wo.relevant_fields.sort).to eq([
        :amount,
        :building_number,
        :cl_number,
        # No :code
        :description,
        :direct_pay,
        :expense_type,
        :function_code,
        :not_to_exceed,
        :org_code,
        # No :rwa_number
        :soc_code,
        :vendor
      ])
    end

    it "shows BA80 fields" do
      wo = Ncr::WorkOrder.new(expense_type: 'BA80')
      expect(wo.relevant_fields.sort).to eq([
        :amount,
        :building_number,
        :cl_number,
        :code,
        :description,
        :direct_pay,
        # No Emergency
        :expense_type,
        :function_code,
        :not_to_exceed,
        :org_code,
        :rwa_number,
        :soc_code,
        :vendor
      ])
    end
  end

  describe '#setup_approvals_and_observers' do
    let (:ba61_tier_one_email) { Ncr::WorkOrder.ba61_tier1_budget_mailbox }
    let (:ba61_tier_two_email) { Ncr::WorkOrder.ba61_tier2_budget_mailbox }

    it "creates approvers when not an emergency" do
      form = create(:ncr_work_order, expense_type: 'BA61')
      form.setup_approvals_and_observers
      expect(form.observations.length).to eq(0)
      expect(form.approvers.map(&:email_address)).to eq([
        form.approving_official_email,
        ba61_tier_one_email,
        ba61_tier_two_email
      ])
      form.reload
      expect(form.approved?).to eq(false)
    end

    it "reuses existing approvals" do
      form = create(:ncr_work_order, expense_type: 'BA61')
      form.setup_approvals_and_observers
      first_approval = form.individual_approvals.first

      form.reload.setup_approvals_and_observers
      expect(form.individual_approvals.first).to eq(first_approval)
    end

    it "creates observers when in an emergency" do
      form = create(:ncr_work_order, expense_type: 'BA61',
                               emergency: true)
      form.setup_approvals_and_observers
      expect(form.observers.map(&:email_address)).to match_array([
        form.approving_official_email,
        ba61_tier_one_email,
        ba61_tier_two_email
      ].uniq)
      expect(form.steps.length).to eq(0)
      form.clear_association_cache
      expect(form.approved?).to eq(true)
    end

    it "accounts for approver transitions when nothing's approved" do
      ba80_budget_email = Ncr::WorkOrder.ba80_budget_mailbox
      wo = create(:ncr_work_order, approving_official_email: 'ao@example.com', expense_type: 'BA61')
      wo.setup_approvals_and_observers
      expect(wo.approvers.map(&:email_address)).to eq [
        'ao@example.com',
        ba61_tier_one_email,
        ba61_tier_two_email
      ]

      wo.update(org_code: 'P1122021 (192X,192M) WHITE HOUSE DISTRICT')
      wo.setup_approvals_and_observers
      expect(wo.reload.approvers.map(&:email_address)).to eq [
        'ao@example.com',
        ba61_tier_two_email
      ]

      wo.approving_official_email = 'ao2@example.com'
      wo.setup_approvals_and_observers
      expect(wo.reload.approvers.map(&:email_address)).to eq [
        'ao2@example.com',
        ba61_tier_two_email
      ]

      wo.approving_official_email = 'ao@example.com'
      wo.update(expense_type: 'BA80')
      wo.setup_approvals_and_observers
      expect(wo.reload.approvers.map(&:email_address)).to eq [
        'ao@example.com',
        ba80_budget_email
      ]
    end

    it "unsets the approval status" do
      ba80_budget_email = Ncr::WorkOrder.ba80_budget_mailbox
      wo = create(:ba80_ncr_work_order)
      wo.setup_approvals_and_observers
      expect(wo.approvers.map(&:email_address)).to eq [
        wo.approving_official_email,
        ba80_budget_email
      ]

      wo.individual_approvals.first.approve!
      wo.individual_approvals.second.approve!
      expect(wo.reload.approved?).to be true

      wo.update(expense_type: 'BA61')
      wo.setup_approvals_and_observers
      expect(wo.reload.pending?).to be true
    end

    it "does not re-add observers on emergencies" do
      wo = create(:ncr_work_order, expense_type: 'BA61', emergency: true)
      wo.setup_approvals_and_observers

      expect(wo.steps).to be_empty
      expect(wo.observers.count).to be 3

      wo.setup_approvals_and_observers
      wo.reload
      expect(wo.steps).to be_empty
      expect(wo.observers.count).to be 3
    end

    it "handles the delegate then update scenario" do
      wo = create(:ba80_ncr_work_order)
      wo.setup_approvals_and_observers
      delegate = create(:user)
      wo.approvers.second.add_delegate(delegate)
      wo.individual_approvals.second.update(user: delegate)

      wo.individual_approvals.first.approve!
      wo.individual_approvals.second.approve!

      wo.setup_approvals_and_observers
      wo.reload
      expect(wo.approved?).to be true
      expect(wo.approvers.second).to eq delegate
    end

    it "respects user with same client_slug" do
      wo = create(:ba80_ncr_work_order)
      user = create(:user, client_slug: "ncr")
      expect(wo.slug_matches?(user)).to eq(true)
    end

    it "identifies eligible observers based on client_slug" do
      wo = create(:ba80_ncr_work_order)
      user = create(:user, client_slug: 'ncr')
      expect(wo.proposal.eligible_observers.to_a).to include(user)
      expect(wo.proposal.eligible_observers.to_a).to_not include(wo.observers)
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

  describe '#system_approver_emails' do
    let (:ba61_tier_one_email) { Ncr::WorkOrder.ba61_tier1_budget_mailbox }
    let (:ba61_tier_two_email) { Ncr::WorkOrder.ba61_tier2_budget_mailbox }

    context "for a BA61 request" do
      it "skips the Tier 1 budget approver for WHSC" do
        work_order = create(:ncr_work_order, expense_type: 'BA61', org_code: Ncr::Organization::WHSC_CODE)
        expect(work_order.system_approver_emails).to eq([
          ba61_tier_two_email
        ])
      end

      it "includes the Tier 1 budget approver for an unknown organization" do
        work_order = create(:ncr_work_order, expense_type: 'BA61', org_code: nil)
        expect(work_order.system_approver_emails).to eq([
          ba61_tier_one_email,
          ba61_tier_two_email
        ])
      end
    end

    context "for a BA80 request" do
      it "uses the general budget email" do
       ba80_budget_email = Ncr::WorkOrder.ba80_budget_mailbox
        work_order = create(:ba80_ncr_work_order)
        expect(work_order.system_approver_emails).to eq([ba80_budget_email])
      end

      it "uses the OOL budget email for their org code" do
        budget_email = Ncr::WorkOrder.ool_ba80_budget_mailbox
        org_code = Ncr::Organization::OOL_CODES.first
        work_order = create(:ba80_ncr_work_order, org_code: org_code)
        expect(work_order.system_approver_emails).to eq([budget_email])
      end
    end
  end

  describe '#total_price' do
    let (:work_order) { create(:ncr_work_order, amount: 45.36)}
    it 'gets price from amount field' do
      expect(work_order.total_price).to eq(45.36)
    end
  end

  describe "#pubic_identifier" do
    it "prepends proposal ID with 'FY' and fiscal year" do
      work_order = build(:ncr_work_order)
      proposal = work_order.proposal
      fiscal_year = work_order.fiscal_year.to_s.rjust(2, "0")

      expect(work_order.public_identifier).to eq "FY#{fiscal_year}-#{proposal.id}"
    end
  end

  describe '#fiscal_year' do
    it 'ends the fiscal year on September 30th' do
      work_order = create(:ncr_work_order, created_at: Date.new(2014, 9, 30))
      expect(work_order.fiscal_year).to eq 14
    end

    it 'starts a new fiscal year on October first' do
      work_order = create(:ncr_work_order, created_at: Date.new(2014, 10, 1))
      expect(work_order.fiscal_year).to eq 15
    end
  end

  describe 'validations' do
    describe 'cl_number' do
      let (:work_order) { build(:ncr_work_order) }

      it "works with a 'CL' prefix" do
        work_order.cl_number = 'CL1234567'
        expect(work_order).to be_valid
      end

      it "requires seven numbers" do
        work_order.cl_number = '123'
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:cl_number])
      end
    end

    describe 'function_code' do
      let (:work_order) { build(:ncr_work_order) }

      it "works with 'PG' followed by three characters" do
        work_order.function_code = 'PG123'
        expect(work_order).to be_valid
      end

      it "must have five characters" do
        work_order.function_code = 'PG12'
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:function_code])
      end
    end

    describe 'RWA' do
      let (:work_order) { build(:ncr_work_order, expense_type: 'BA80') }

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

    describe "soc_code" do
      let (:work_order) { build(:ncr_work_order) }

      it "works with three characters" do
        work_order.soc_code = "123"
        expect(work_order).to be_valid
      end

      it "must be three characters" do
        work_order.soc_code = "12"
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:soc_code])
      end
    end
  end

  describe "#org_id" do
    it "pulls out the organization id when present" do
      wo = create(:ncr_work_order, org_code: 'P0000000 (192X,192M) PRIOR YEAR ACTIVITIES')
      expect(wo.org_id).to eq("P0000000")
    end

    it "returns nil when no organization is present" do
      wo = create(:ncr_work_order, org_code: nil)
      expect(wo.org_id).to be_nil
    end
  end

  describe "#building_id" do
    it "pulls out the building id when an identifier is present" do
      wo = build(:ncr_work_order, building_number: "AB1234CD then some more")
      expect(wo.building_id).to eq("AB1234CD")
    end

    it "defaults to the whole building number" do
      wo = build(:ncr_work_order, building_number: "Another String")
      expect(wo.building_id).to eq("Another String")
    end

    it "allows nil" do
      wo = build(:ncr_work_order, building_number: nil)
      expect(wo.building_id).to be_nil
    end
  end

  describe "#current_approver" do
    it "returns the first pending approver" do
      wo = create(:ncr_work_order, :with_approvers)
      expect(wo.current_approver).to eq(wo.approvers.first)
      wo.individual_approvals.first.approve!
      expect(wo.current_approver).to eq(wo.approvers.second)
    end

    it "returns the first approver when fully approved" do
      wo = create(:ncr_work_order, :with_approvers)
      fully_approve(wo.proposal)
      expect(wo.reload.current_approver).to eq(wo.approvers.first)
    end
  end

  describe "#final_approver" do
    it "returns the final approver" do
      wo = create(:ncr_work_order, :with_approvers)
      expect(wo.final_approver).to eq(wo.approvers.last)
      wo.individual_approvals.first.approve!
      expect(wo.final_approver).to eq(wo.approvers.last)
    end

    it "returns the last approver when fully approved" do
      wo = create(:ncr_work_order, :with_approvers)
      fully_approve(wo.proposal)
      expect(wo.final_approver).to eq(wo.approvers.last)
    end
  end

  describe '#restart_budget_approvals' do
    it "sets the approvals to the proper state" do
      work_order = create(:ncr_work_order)
      proposal = work_order.proposal
      work_order.setup_approvals_and_observers
      fully_approve(proposal)

      work_order.restart_budget_approvals

      expect(work_order.status).to eq('pending')
      expect(work_order.proposal.root_step.status).to eq('actionable')
      expect(linear_approval_statuses(proposal)).to eq(%w(
        approved
        actionable
        pending
      ))
    end
  end
end
