require 'spec_helper'
require 'ostruct'

describe CommunicartMailer do
  let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers, name: "anotherApprovalGroupName") }
  let(:approver) { FactoryGirl.create(:user) }
  let(:cart) { FactoryGirl.create(:cart, name: "TestCart") }
  let(:requester) { FactoryGirl.create(:requester, email_address: 'reply@communicart-stub.com') }

  describe 'cart notification email' do

    let(:analysis) { OpenStruct.new(email: 'email.to.email@testing.com', cartNumber: '13579', cartItems: []) }
    let(:mail) { CommunicartMailer.cart_notification_email(analysis.email, analysis, cart) }

    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
    end

    it 'renders the subject' do
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

  end

  describe 'approval reply received email' do
    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      cart
      cart.requester = requester
      cart.save
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
      mail.to.should == ["cart-requester@some-dot.gov"]
    end

    it 'renders the sender email' do
      mail.from.should == ['reply@communicart-stub.com']
    end
  end
end
