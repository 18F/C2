describe Commands::Approval::InitiateCartApproval do
  let(:params_request) {
    '{
      "cartName": "A Cart With No Approvals",
      "cartNumber": "13579",
      "approvalGroup": null,
      "category": "initiation",
      "email": "test.email@some-dot-gov.gov",
      "fromAddress": "requester-pcard-holder@some-dot-gov.gov",
      "toAddress": ["some-approver-1@some-dot-gov.gov","some-approver-2@some-dot-gov.gov"],
      "gsaUserName": "",
      "initiationComment": "I have to say that this is great.",
      "properties": {
        "something": "awesome",
        "another something": "awesome again"
      }
    }'
  }

  let(:command_params) { JSON.parse(params_request).with_indifferent_access }
  let(:cart) { FactoryGirl.build(:cart) }
  let(:command) { Commands::Approval::InitiateCartApproval.new }

  describe '#perform' do
    before do
      expect(Cart).to receive(:initialize_cart).and_return(cart)
      expect(command).to receive(:import_details)
      expect_any_instance_of(ParallelDispatcher).to receive(:deliver_new_proposal_emails)
    end

    context 'handling absence of approvalGroup' do
      { blank:"", nil: nil }.each do |key,val|
        it "bypasses processing the approval group with #{key} value" do
          command_params["approvalGroup"] = val
          expect(cart).to receive(:process_approvals_without_approval_group).with(command_params)
          command.perform(command_params)
        end
      end
    end

    context 'handling the presence of approvalGroup' do
      before do
        command_params["approvalGroup"] = "someApprovalGroup"
      end

      context 'no existing approvals' do
        it "processes the approval group" do
          expect(cart).to receive_message_chain(:approvals, :any?).and_return false
          expect(cart).to receive(:process_approvals_from_approval_group)
          command.perform(command_params)
        end
      end

      context 'existing approvals' do
        it 'refrains from processing the approvals' do
          expect(cart).to receive_message_chain(:approvals, :any?).and_return true
          expect(cart).not_to receive(:process_approvals_from_approval_group)
          command.perform(command_params)
        end
      end
    end
  end
end
