require 'spec_helper'
require 'ostruct'

describe CommunicartMailer do
  let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "anotherApprovalGroupName") }
  let(:approver) { FactoryGirl.create(:user) }
  let(:cart) { FactoryGirl.create(:cart, name: "TestCart") }

  describe 'cart notification email' do

    let(:mail) { CommunicartMailer.cart_notification_email('email.to.email@testing.com', cart) }

    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
    end

    it 'renders the subject' do
      cart.update_attributes(external_id: 13579)
      cart.stub(:approval_group).and_return(approval_group)
      approval_group.stub(:approvers).and_return([approver])
      approver.stub(:approver_comment).and_return([])
      mail.subject.should == 'Please approve Cart Number: 13579'
    end

    it 'renders the receiver email' do
      cart.stub(:approval_group).and_return(approval_group)
      approval_group.stub(:approvers).and_return([approver])
      approver.stub(:approver_comment).and_return([])
      mail.to.should == ["email.to.email@testing.com"]
    end

    it 'renders the sender email' do
      cart.stub(:approval_group).and_return(approval_group)
      approval_group.stub(:approvers).and_return([approver])
      approver.stub(:approver_comment).and_return([])
      mail.from.should == ['reply@communicart-stub.com']
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        cart.stub(:approval_group).and_return(approval_group)
        approval_group.stub(:approvers).and_return([approver])
        approver.stub(:approver_comment).and_return([])
        cart.stub(:all_approvals_received?).and_return(true)

        cart.should_receive(:create_items_csv)
        cart.should_receive(:create_comments_csv)
        cart.should_receive(:create_approvals_csv)
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        cart.stub(:approval_group).and_return(approval_group)
        approval_group.stub(:approvers).and_return([approver])
        approver.stub(:approver_comment).and_return([])
        cart.stub(:all_approvals_received?).and_return(false)

        cart.should_not_receive(:create_items_csv)
        cart.should_not_receive(:create_comments_csv)
        cart.should_not_receive(:create_approvals_csv)
        mail
      end
    end

  end

  describe 'approval reply received email' do
    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')

    end

    let(:analysis) {
      OpenStruct.new(
                    approve: 'APPROVE',
                    fromAddress: 'approver-test@some-dot-gov.gov',
                    cartNumber: '13579'
                    )
    }

    let(:cart_with_approval_group) { FactoryGirl.create(:cart_with_approval_group) }

    let(:mail) { CommunicartMailer.approval_reply_received_email(analysis, cart_with_approval_group) }


    it 'renders the subject' do
      mail.subject.should == 'User approver-test@some-dot-gov.gov has approved cart #13579'
    end

    it 'renders the receiver email' do
      mail.to.should == ["requester1@some-dot-gov.gov"]
    end

    it 'renders the sender email' do
      mail.from.should == ['reply@communicart-stub.com']
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        cart_with_approval_group.stub(:all_approvals_received?).and_return(true)

        cart_with_approval_group.should_receive(:create_items_csv)
        cart_with_approval_group.should_receive(:create_comments_csv)
        cart_with_approval_group.should_receive(:create_approvals_csv)
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        cart_with_approval_group.stub(:all_approvals_received?).and_return(false)

        cart_with_approval_group.should_not_receive(:create_items_csv)
        cart_with_approval_group.should_not_receive(:create_comments_csv)
        cart_with_approval_group.should_not_receive(:create_approvals_csv)
        mail
      end
    end
  end
end
