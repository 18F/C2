require 'spec_helper'
require 'ostruct'

describe CommunicartMailer do
  let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "anotherApprovalGroupName") }
  let(:approver) { FactoryGirl.create(:user) }
  let(:cart) { FactoryGirl.create(:cart_with_approvals, name: "TestCart") }

  describe 'cart notification email' do

    let(:mail) { CommunicartMailer.cart_notification_email('email.to.email@testing.com', cart, cart.approvals.first) }
    let(:api_token) { FactoryGirl.create(:api_token) }

    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      ApiToken.stub_chain(:where, :where, :last).and_return(api_token)
    end

    it 'renders the subject' do
      cart.update_attributes(external_id: 13579)
      cart.stub(:approval_group).and_return(approval_group)
      approval_group.stub(:approvers).and_return([approver])
      approver.stub(:approver_comment).and_return([])
      mail.subject.should == 'Communicart Approval Request from Liono Requester: Please review Cart #13579'
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

   it 'renders the navigator template' do
      cart.setProp('origin','navigator')
      cart.stub(:approval_group).and_return(approval_group)
      approval_group.stub(:approvers).and_return([approver])
      approver.stub(:approver_comment).and_return([])
# This is very fragile, it is based on a particular term coming from the navigator teplate.
# If the template changes, this test will break --- I know of no other way of tesitng this.
      expect(mail.body.encoded).to match('NAVIGATOR')
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
    let(:requester) { FactoryGirl.create(:user, email_address: 'test-requester-1@some-dot-gov.gov') }

    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      cart_with_approval_group.stub(:requester).and_return(requester)
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
      mail.to.should == ["test-requester-1@some-dot-gov.gov"]
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

  describe 'comment_added_email' do
    let(:cart_item) { FactoryGirl.create(:cart_item, description: "A cart item in need of a comment") }
    let(:comment) { FactoryGirl.create(:comment, comment_text: 'Somebody give this cart item a comment') }
    let(:email) { "commenter@some-dot-gov.gov" }
    let(:mail) { CommunicartMailer.comment_added_email(comment, email) }

    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      cart_item.comments << comment
    end

    it 'renders the subject' do
      mail.subject.should == "A comment has been added to cart item 'A cart item in need of a comment'"
    end

    it 'renders the receiver email' do
      mail.to.should == ["commenter@some-dot-gov.gov"]
    end

    it 'renders the sender email' do
      mail.from.should == ['reply@communicart-stub.com']
    end
  end

  # TODO: describe 'rejection_update_email'
  describe 'cart observer received email' do
    let(:observer) { FactoryGirl.create(:user, email_address: 'test-observer-1@some-dot-gov.gov') }
    let(:requester) { FactoryGirl.create(:user, email_address: 'test-requester-1@some-dot-gov.gov') }

    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      cart_with_observers.stub(:requester).and_return(requester)
    end

    let(:cart_with_observers) { FactoryGirl.create(:cart_with_observers, external_id: 1965) }

    let(:mail) { CommunicartMailer.cart_observer_email(cart_with_observers.observers.first.user.email_address, cart_with_observers) }

    it 'renders the subject' do
      mail.subject.should == 'Communicart Approval Request from Liono Thunder: Please review Cart #1965'
    end

    it 'renders the receiver email' do
      mail.to.should == ["observer1@some-dot-gov.gov"]
    end

    it 'renders the sender email' do
      mail.from.should == ['reply@communicart-stub.com']
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        cart_with_observers.stub(:all_approvals_received?).and_return(true)

        cart_with_observers.should_receive(:create_items_csv)
        cart_with_observers.should_receive(:create_comments_csv)
        cart_with_observers.should_receive(:create_approvals_csv)
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        cart_with_observers.stub(:all_approvals_received?).and_return(false)

        cart_with_observers.should_not_receive(:create_items_csv)
        cart_with_observers.should_not_receive(:create_comments_csv)
        cart_with_observers.should_not_receive(:create_approvals_csv)
        mail
      end
    end
  end

end
