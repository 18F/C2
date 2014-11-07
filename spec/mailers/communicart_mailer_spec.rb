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
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      allow(ApiToken).to receive_message_chain(:where, :where, :last).and_return(api_token)
    end

    it 'renders the subject' do
      cart.update_attributes(external_id: 13579)
      allow(cart).to receive(:approval_group).and_return(approval_group)
      allow(approval_group).to receive(:approvers).and_return([approver])
      allow(approver).to receive(:approver_comment).and_return([])
      expect(mail.subject).to eq('Communicart Approval Request from Liono Requester: Please review Cart #13579')
    end

    it 'renders the receiver email' do
      allow(cart).to receive(:approval_group).and_return(approval_group)
      allow(approval_group).to receive(:approvers).and_return([approver])
      allow(approver).to receive(:approver_comment).and_return([])
      expect(mail.to).to eq(["email.to.email@testing.com"])
    end

    it 'renders the sender email' do
      allow(cart).to receive(:approval_group).and_return(approval_group)
      allow(approval_group).to receive(:approvers).and_return([approver])
      allow(approver).to receive(:approver_comment).and_return([])
      expect(mail.from).to eq(['reply@communicart-stub.com'])
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        allow(cart).to receive(:approval_group).and_return(approval_group)
        allow(approval_group).to receive(:approvers).and_return([approver])
        allow(approver).to receive(:approver_comment).and_return([])
        allow(cart).to receive(:all_approvals_received?).and_return(true)

        expect(cart).to receive(:create_items_csv)
        expect(cart).to receive(:create_comments_csv)
        expect(cart).to receive(:create_approvals_csv)
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        allow(cart).to receive(:approval_group).and_return(approval_group)
        allow(approval_group).to receive(:approvers).and_return([approver])
        allow(approver).to receive(:approver_comment).and_return([])
        allow(cart).to receive(:all_approvals_received?).and_return(false)

        expect(cart).not_to receive(:create_items_csv)
        expect(cart).not_to receive(:create_comments_csv)
        expect(cart).not_to receive(:create_approvals_csv)
        mail
      end
    end

  end

  describe 'approval reply received email' do
    let(:requester) { FactoryGirl.create(:user, email_address: 'test-requester-1@some-dot-gov.gov') }
    let(:cart_with_approval_group) { FactoryGirl.create(:cart_with_approvals, external_id: 13579) }
    let(:approval) { cart_with_approval_group.approvals.first }
    let(:mail) { CommunicartMailer.approval_reply_received_email(approval) }

    before do
      approval.update_attribute(:status, 'approved')
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      allow(cart_with_approval_group).to receive(:requester).and_return(requester)
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('User approver1@some-dot-gov.gov has approved cart #13579')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["test-requester-1@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        allow(cart_with_approval_group).to receive(:all_approvals_received?).and_return(true)

        expect(cart_with_approval_group).to receive(:create_items_csv)
        expect(cart_with_approval_group).to receive(:create_comments_csv)
        expect(cart_with_approval_group).to receive(:create_approvals_csv)
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        allow(cart_with_approval_group).to receive(:all_approvals_received?).and_return(false)

        expect(cart_with_approval_group).not_to receive(:create_items_csv)
        expect(cart_with_approval_group).not_to receive(:create_comments_csv)
        expect(cart_with_approval_group).not_to receive(:create_approvals_csv)
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
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      cart_item.comments << comment
    end

    it 'renders the subject' do
      expect(mail.subject).to eq("A comment has been added to cart item 'A cart item in need of a comment'")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["commenter@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
    end
  end

  # TODO: describe 'rejection_update_email'
  describe 'cart observer received email' do
    let(:observer) { FactoryGirl.create(:user, email_address: 'test-observer-1@some-dot-gov.gov') }
    let(:requester) { FactoryGirl.create(:user, email_address: 'test-requester-1@some-dot-gov.gov') }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('NOTIFICATION_FROM_EMAIL').and_return('reply@communicart-stub.com')
      allow(cart_with_observers).to receive(:requester).and_return(requester)
    end

    let(:cart_with_observers) { FactoryGirl.create(:cart_with_observers, external_id: 1965) }

    let(:mail) { CommunicartMailer.cart_observer_email(cart_with_observers.observers.first.user.email_address, cart_with_observers) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Communicart Approval Request from Liono Thunder: Please review Cart #1965')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["observer1@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        allow(cart_with_observers).to receive(:all_approvals_received?).and_return(true)

        expect(cart_with_observers).to receive(:create_items_csv)
        expect(cart_with_observers).to receive(:create_comments_csv)
        expect(cart_with_observers).to receive(:create_approvals_csv)
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        allow(cart_with_observers).to receive(:all_approvals_received?).and_return(false)

        expect(cart_with_observers).not_to receive(:create_items_csv)
        expect(cart_with_observers).not_to receive(:create_comments_csv)
        expect(cart_with_observers).not_to receive(:create_approvals_csv)
        mail
      end
    end
  end

end
