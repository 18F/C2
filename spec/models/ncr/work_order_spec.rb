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

  describe '#setup_approvals_and_observers' do
    it "creates approvers when not an emergency" do
      form = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61')
      form.setup_approvals_and_observers('bob@example.com')
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
      form.setup_approvals_and_observers('bob@example.com')
      expect(form.observers.map(&:email_address)).to eq([
        'bob@example.com',
        Ncr::WorkOrder.ba61_tier1_budget_mailbox,
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ])
      expect(form.approvals.length).to eq(0)
      form.clear_association_cache
      expect(form.approved?).to eq(true)
    end

    with_env_vars(NCR_BA61_TIER1_BUDGET_MAILBOX: 'ba61one@example.gov',
                  NCR_BA61_TIER2_BUDGET_MAILBOX: 'ba61two@example.gov',
                  NCR_BA80_BUDGET_MAILBOX: 'ba80@example.gov') do
      it "accounts for approver transitions when nothing's approved" do
        wo = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61')
        wo.setup_approvals_and_observers('ao@example.gov')
        expect(wo.approvers.map(&:email_address)).to eq %w(
          ao@example.gov
          ba61one@example.gov
          ba61two@example.gov
        )

        wo.update(org_code: 'P1122021 (192X,192M) WHITE HOUSE DISTRICT')
        wo.setup_approvals_and_observers('ao@example.gov')
        expect(wo.reload.approvers.map(&:email_address)).to eq %w(
          ao@example.gov
          ba61two@example.gov
        )

        wo.setup_approvals_and_observers('ao2@example.gov')
        expect(wo.reload.approvers.map(&:email_address)).to eq %w(
          ao2@example.gov
          ba61two@example.gov
        )

        wo.update(expense_type: 'BA80')
        wo.setup_approvals_and_observers('ao@example.gov')
        expect(wo.reload.approvers.map(&:email_address)).to eq %w(
          ao@example.gov
          ba80@example.gov
        )
      end

      it "unsets the approval status" do
        wo = FactoryGirl.create(:ncr_work_order, expense_type: 'BA80')
        wo.setup_approvals_and_observers('ao@example.gov')
        expect(wo.approvers.map(&:email_address)).to eq %w(
          ao@example.gov
          ba80@example.gov
        )

        wo.individual_approvals.first.approve!
        wo.individual_approvals.second.approve!
        expect(wo.reload.approved?).to be true

        wo.update(expense_type: 'BA61')
        wo.setup_approvals_and_observers('ao@example.gov')
        expect(wo.reload.pending?).to be true
      end

      it "does not re-add observers on emergencies" do
        wo = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61', emergency: true)
        wo.setup_approvals_and_observers('ao@example.gov')

        expect(wo.approvals).to be_empty
        expect(wo.observers.count).to be 3

        wo.setup_approvals_and_observers('ao@example.gov')
        wo.reload
        expect(wo.approvals).to be_empty
        expect(wo.observers.count).to be 3
      end

      it "handles the delegate then update scenario" do
        wo = FactoryGirl.create(:ncr_work_order, expense_type: 'BA80')
        wo.setup_approvals_and_observers('ao@example.gov')
        delegate = FactoryGirl.create(:user)
        wo.approvers.second.add_delegate(delegate)
        wo.individual_approvals.second.update(user: delegate)

        wo.individual_approvals.first.approve!
        wo.individual_approvals.second.approve!

        wo.setup_approvals_and_observers('ao@example.gov')
        wo.reload
        expect(wo.approved?).to be true
        expect(wo.approvers.second).to eq delegate
      end
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
    it "skips the Tier 1 budget approver for WHSC" do
      work_order = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61', org_code: Ncr::Organization::WHSC_CODE)
      expect(work_order.system_approver_emails).to eq([
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ])
    end

    it "includes the Tier 1 budget approver for an unknown organization" do
      work_order = FactoryGirl.create(:ncr_work_order, expense_type: 'BA61', org_code: nil)
      expect(work_order.system_approver_emails).to eq([
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

      it "clears empty strings" do
        work_order.cl_number = ''
        expect(work_order).to be_valid
        expect(work_order.cl_number).to eq(nil)
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

      it "automatically adds a 'PG' prefix" do
        work_order.function_code = '123'
        expect(work_order).to be_valid
        expect(work_order.function_code).to eq('PG123')
      end

      it "is converted to uppercase" do
        work_order.function_code = 'pg1c3'
        expect(work_order).to be_valid
        expect(work_order.function_code).to eq('PG1C3')
      end

      it "clears empty strings" do
        work_order.function_code = ''
        expect(work_order).to be_valid
        expect(work_order.function_code).to eq(nil)
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

      it "clears empty strings" do
        work_order.soc_code = ''
        expect(work_order).to be_valid
        expect(work_order.soc_code).to eq(nil)
      end
    end
  end

  describe '#record_changes' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order) }

    it 'adds a change comment' do
      work_order.update(vendor: 'Mario Brothers', amount: 123.45)

      expect(work_order.proposal.comments.count).to be 1
      comment = Comment.last
      expect(comment.update_comment).to be(true)
      comment_text = "- *Vendor* was changed from Some Vend to Mario Brothers\n"
      comment_text += "- *Amount* was changed from $1,000.00 to $123.45"
      expect(comment.comment_text).to eq(comment_text)
    end

    it 'includes extra information if modified post approval' do
      work_order.approve!
      work_order.update(vendor: 'Mario Brothers', amount: 123.45)

      expect(work_order.proposal.comments.count).to be 1
      comment = Comment.last
      expect(comment.update_comment).to be(true)
      comment_text = "- *Vendor* was changed from Some Vend to Mario Brothers\n"
      comment_text += "- *Amount* was changed from $1,000.00 to $123.45\n"
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

    it "attributes the update comment to the requester by default" do
      work_order.update(vendor: 'VenVenVen')
      comment = work_order.comments.update_comments.last
      expect(comment.user).to eq(work_order.requester)
    end

    it "attributes the update comment to someone set explicitly" do
      modifier = FactoryGirl.create(:user)
      work_order.modifier = modifier
      work_order.update(vendor: 'VenVenVen')

      comment = work_order.comments.update_comments.last
      expect(comment.user).to eq(modifier)
    end
  end

  describe "#org_id" do
    it "pulls out the organization id when present" do
      wo = FactoryGirl.create(:ncr_work_order, org_code: 'P0000000 (192X,192M) PRIOR YEAR ACTIVITIES')
      expect(wo.org_id).to eq("P0000000")
    end

    it "returns nil when no organization is present" do
      wo = FactoryGirl.create(:ncr_work_order, org_code: nil)
      expect(wo.org_id).to be_nil
    end
  end

  describe "#building_id" do
    it "pulls out the building id when an identifier is present" do
      wo = FactoryGirl.build(:ncr_work_order, building_number: "AB1234CD then some more")
      expect(wo.building_id).to eq("AB1234CD")
    end

    it "defaults to the whole building number" do
      wo = FactoryGirl.build(:ncr_work_order, building_number: "Another String")
      expect(wo.building_id).to eq("Another String")
    end

    it "allows nil" do
      wo = FactoryGirl.build(:ncr_work_order, building_number: nil)
      expect(wo.building_id).to be_nil
    end
  end
end
