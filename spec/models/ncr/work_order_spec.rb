describe Ncr::WorkOrder do
  include ProposalSpecHelper

  it_behaves_like "client data"

  describe "Associations" do
    it { should belong_to(:ncr_organization) }
    it { should belong_to(:approving_official) }
  end

  describe "Validations" do
    it "does not allow approving official to be changed if the first step is not actionable" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      approving_official_step = work_order.reload.individual_steps.first
      approving_official_step.update(status: "approved")

      work_order.approving_official = create(:user, client_slug: "ncr")

      expect(work_order).not_to be_valid
    end

    it "does allow approving official to be changed if the first step is actionable" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers

      work_order.approving_official = create(:user, client_slug: "ncr")

      expect(work_order).to be_valid
    end
  end

  describe "#as_indexed_json" do
    it "serializes associations" do
      whsc_org = create(:whsc_organization)
      work_order = create(:ncr_work_order, ncr_organization: whsc_org)

      indexable = work_order.as_json({include: [:ncr_organization, :approving_official]})

      expect(work_order.as_indexed_json).to eq(indexable)
    end
  end

  describe "#editable?" do
    it "is true" do
      work_order = build(:ncr_work_order)
      expect(work_order).to be_editable
    end
  end

  describe "#for_whsc_organization?" do
    it "is true if the org code is for a whsc organization" do
      organization = create(:whsc_organization)
      work_order = build(:ncr_work_order, ncr_organization: organization)

      expect(work_order).to be_for_whsc_organization
    end

    it "is false if org code is nil" do
      work_order = build(:ncr_work_order, ncr_organization: nil)

      expect(work_order).not_to be_for_whsc_organization
    end

    it "is false if org code is for a non-whsc org" do
      organization = build(:ncr_organization)
      work_order = build(:ncr_work_order, ncr_organization: organization)

      expect(work_order).not_to be_for_whsc_organization
    end
  end

  describe "#ba_6x_tier1_team?" do
    it "is true for whitelist of organizations" do
      org_letters = %w( 7 J 4 T 1 A C Z )
      org_letters.each do |org_letter|
        org_code = "P11#{org_letter}XXXX"
        ncr_org = build(:ncr_organization, code: org_code)
        work_order = build(:ncr_work_order, ncr_organization: ncr_org)

        expect(work_order).to be_ba_6x_tier1_team
      end
    end

    it "is false for non-listed organizations" do
      ncr_org = build(:ncr_organization)
      work_order = build(:ncr_work_order, ncr_organization: ncr_org)

      expect(work_order).to_not be_ba_6x_tier1_team
    end
  end

  describe "#for_ool_organization?" do
    it "is true if org code is for an ool org" do
      organization = create(:ool_organization)
      work_order = build(:ncr_work_order, ncr_organization: organization)

      expect(work_order).to be_for_ool_organization
    end

    it "is false if org code is nil" do
      work_order = build(:ncr_work_order, ncr_organization: nil)

      expect(work_order).not_to be_for_ool_organization
    end

    it "is false if org code is for non-ool org" do
      organization = build(:ncr_organization)
      work_order = build(:ncr_work_order, ncr_organization: organization)

      expect(work_order).not_to be_for_ool_organization
    end
  end

  describe "#total_price" do
    it "gets price from amount field" do
      work_order = build(:ncr_work_order, amount: 45.36)

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

    it "does not require if expense_type is BA60" do
      wo = build(:ncr_work_order, expense_type: "BA60", building_number: nil)
      expect(wo).to be_valid
    end

    it "requires if expense_type is not BA60" do
      wo = build(:ncr_work_order, expense_type: "BA61", building_number: nil)
      expect(wo).to_not be_valid
    end
  end

  describe "#final_approver" do
    it "returns the final approver" do
      wo = create(:ncr_work_order, :with_approvers)
      expect(wo.final_approver).to eq(wo.approvers.last)
      wo.individual_steps.first.approve!
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

  describe "#budget_approvers" do
    it "returns users assigned to budget approval steps" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      budget_mailbox_step = work_order.steps.last
      user = budget_mailbox_step.user

      expect(work_order.budget_approvers).to include(user)
    end

    it "returns users who completed budget approval steps" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      completer = create(:user)
      budget_mailbox_step = work_order.steps.last
      budget_mailbox_step.update(completer: completer)

      expect(work_order.budget_approvers).to include(completer)
    end
  end
end
