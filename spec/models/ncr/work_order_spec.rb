describe Ncr::WorkOrder do
  include ProposalSpecHelper

  it_behaves_like "client data"

  describe "#editabe?" do
    it "is true" do
      work_order = build(:ncr_work_order)
      expect(work_order).to be_editable
    end
  end

  describe ".relevant_fields" do
    it "shows BA61 fields" do
      expect(Ncr::WorkOrder.relevant_fields("BA61").sort).to eq([
        :amount,
        :approving_official_email,
        :building_number,
        :cl_number,
        # No :code
        :description,
        :direct_pay,
        :emergency,
        :expense_type,
        :function_code,
        :not_to_exceed,
        :org_code,
        :project_title,
        # No :rwa_number
        :soc_code,
        :vendor
      ])
    end

    it "shows BA80 fields" do
      expect(Ncr::WorkOrder.relevant_fields("BA80").sort).to eq([
        :amount,
        :approving_official_email,
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
        :project_title,
        :rwa_number,
        :soc_code,
        :vendor
      ])
    end
  end

  describe "#ncr_organization" do
    it "returns the corresponding Organization instance" do
      org = Ncr::Organization.all.last
      work_order = build(:ncr_work_order, org_code: org.code)
      expect(work_order.ncr_organization).to eq(org)
    end

    it "returns nil for no #org_code" do
      work_order = build(:ncr_work_order)
      expect(work_order.ncr_organization).to eq(nil)
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

  describe "#organization_code" do
    context "work order has an ncr organization" do
      it "returns the ncr organization code" do
        work_order = build(:ncr_work_order)
        organization = Ncr::Organization.all.first
        allow(work_order).to receive(:ncr_organization).and_return(organization)

        expect(work_order.organization_code).to eq organization.code
      end
    end

    context "work order does not have an ncr organization" do
      it "returns nil" do
        work_order = build(:ncr_work_order, org_code: nil)

        expect(work_order.organization_code).to be_nil
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
  end

  describe "#current_approver" do
    it "returns the first pending approver" do
      wo = create(:ncr_work_order, :with_approvers)
      expect(wo.current_approver).to eq(wo.approvers.first)
      wo.individual_steps.first.approve!
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
end
