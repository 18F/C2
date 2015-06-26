describe Ncr::WorkOrder do
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

  describe 'validations' do
    describe 'cl_number' do
      let (:work_order) { FactoryGirl.build(:ncr_work_order) }

      it "works with a 'CL' prefix" do
        work_order.cl_number = 'CL1234567'
        expect(work_order).to be_valid
      end

      it "automatically adds a 'CL' prefix" do
        work_order.cl_number = '1234567'
        expect(work_order).to be_valid
        expect(work_order.cl_number).to eq('CL1234567')
      end

      it "requires seven numbers" do
        work_order.cl_number = '123'
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:cl_number])
      end

      it "is converted to uppercase" do
        work_order.cl_number = 'cl1234567'
        expect(work_order).to be_valid
        expect(work_order.cl_number).to eq('CL1234567')
      end
    end

    describe 'function_code' do
      let (:work_order) { FactoryGirl.build(:ncr_work_order) }

      it "works with 'PG' followed by three characters" do
        work_order.function_code = 'PG123'
        expect(work_order).to be_valid
      end

      it "must have five characters" do
        work_order.function_code = 'PG12'
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:function_code])
      end

      it "must start with 'PG'" do
        work_order.function_code = 'ABC'
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:function_code])
      end

      it "is converted to uppercase" do
        work_order.function_code = 'pg1c3'
        expect(work_order).to be_valid
        expect(work_order.function_code).to eq('PG1C3')
      end
    end

    describe 'RWA' do
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

    describe 'soc_code' do
      let (:work_order) { FactoryGirl.build(:ncr_work_order) }

      it "works with three characters" do
        work_order.soc_code = '123'
        expect(work_order).to be_valid
      end

      it "must be three characters" do
        work_order.soc_code = '12'
        expect(work_order).to_not be_valid
        expect(work_order.errors.keys).to eq([:soc_code])
      end

      it "is converted to uppercase" do
        work_order.soc_code = 'ab2'
        expect(work_order).to be_valid
        expect(work_order.soc_code).to eq('AB2')
      end
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
