describe Ncr::WorkOrder do
  include ProposalSpecHelper

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

  describe '#slug_matches?' do
    it "respects user with same client_slug" do
      wo = build(:ba80_ncr_work_order)
      user = build(:user, client_slug: 'ncr')
      expect(wo.slug_matches?(user)).to eq(true)
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
end
