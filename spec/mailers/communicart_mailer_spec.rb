require 'ostruct'

describe CommunicartMailer do
  def sender_names(mail)
    # http://stackoverflow.com/a/7213323/358804
    mail[:from].display_names
  end

  let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers_and_requester) }
  let(:approver) { FactoryGirl.create(:user) }
  let(:cart) { FactoryGirl.create(:cart_with_approvals) }

  def expect_csvs_to_be_exported
    expect_any_instance_of(Exporter::Items).to receive(:to_csv)
    expect_any_instance_of(Exporter::Comments).to receive(:to_csv)
    expect_any_instance_of(Exporter::Approvals).to receive(:to_csv)
  end

  describe 'cart notification email' do
    let(:approval) { cart.approvals.first }
    let(:mail) { CommunicartMailer.cart_notification_email('email.to.email@testing.com', approval) }
    let(:api_token) { FactoryGirl.create(:api_token) }

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
      expect(approval).to receive(:api_token).and_return(api_token).twice
    end

    it 'renders the subject' do
      cart.update_attributes(external_id: 13579)
      expect(mail.subject).to eq('Communicart Approval Request from Liono Requester: Please review Cart #13579')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["email.to.email@testing.com"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
      expect(sender_names(mail)).to eq(['Liono Requester'])
    end

    context 'comments' do
      it 'does not render comments when empty' do
        expect(cart.comments.count).to eq 0
        expect(mail.body.encoded).not_to include('Comments')
      end

      it 'renders comments when present' do
        cart.comments << FactoryGirl.create(:comment)
        expect(mail.body.encoded).to include('Comments')
      end
    end


    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        expect(cart).to receive(:all_approvals_received?).and_return(true)
        expect_csvs_to_be_exported
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        expect(cart).to receive(:all_approvals_received?).and_return(false)
        expect_any_instance_of(Exporter::Base).not_to receive(:to_csv)
        mail
      end
    end

    context 'custom templates' do
      it 'renders a default template when an origin is not indicated' do
        expect(mail.body.encoded).to include('Purchase Request')
      end

      it 'renders a custom template when origin is indicated' do
        approval.cart.properties << Property.create!(property: 'origin', value:'ncr')
        expect(mail.body.encoded).to include('Purchase Request')
      end
    end

  end

  describe 'approval reply received email' do
    let(:requester) { FactoryGirl.create(:user, email_address: 'test-requester-1@some-dot-gov.gov') }
    let(:cart_with_approval_group) { FactoryGirl.create(:cart_with_approvals, external_id: 13579) }
    let(:approval) { cart_with_approval_group.approver_approvals.first }
    let(:approver) { approval.user }
    let(:mail) { CommunicartMailer.approval_reply_received_email(approval) }

    before do
      approval.update_attribute(:status, 'approved')
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
      expect(cart_with_approval_group).to receive(:requester).and_return(requester).at_least(:once)
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('User approver1@some-dot-gov.gov has approved cart #13579')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["test-requester-1@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
      expect(sender_names(mail)).to eq([approver.full_name])
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        expect(cart_with_approval_group).to receive(:all_approvals_received?).and_return(true).at_least(:once)
        expect_csvs_to_be_exported
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        expect(cart_with_approval_group).to receive(:all_approvals_received?).and_return(false).at_least(:once)
        expect_any_instance_of(Exporter::Base).not_to receive(:to_csv)
        mail
      end
    end
  end

  describe 'comment_added_email' do
    let(:cart_item) { FactoryGirl.create(:cart_item) }
    let(:comment) { FactoryGirl.create(:comment) }
    let(:email) { "commenter@some-dot-gov.gov" }
    let(:mail) { CommunicartMailer.comment_added_email(comment, email) }

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
      cart_item.comments << comment
    end

    it 'renders the subject' do
      expect(mail.subject).to eq("A comment has been added to cart item 'This is a test cart item'")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["commenter@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
      expect(sender_names(mail)).to eq([comment.user.full_name])
    end
  end

  describe 'cart observer received email' do
    let(:observer) { FactoryGirl.create(:user, email_address: 'test-observer-1@some-dot-gov.gov') }
    let(:requester) { FactoryGirl.create(:user, email_address: 'test-requester-1@some-dot-gov.gov') }

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
      expect(cart_with_observers).to receive(:requester).and_return(requester).at_least(:once)
    end

    let(:cart_with_observers) { FactoryGirl.create(:cart_with_observers, external_id: 1965) }
    let(:observer) { cart_with_observers.observers.first }
    let(:mail) { CommunicartMailer.cart_observer_email(observer.user_email_address, cart_with_observers) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Communicart Approval Request from Liono Thunder: Please review Cart #1965')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["observer1@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
      expect(sender_names(mail)).to eq([nil])
    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        expect(cart_with_observers).to receive(:all_approvals_received?).and_return(true)
        expect_csvs_to_be_exported
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        expect(cart_with_observers).to receive(:all_approvals_received?).and_return(false)
        expect_any_instance_of(Exporter::Base).not_to receive(:to_csv)
        mail
      end
    end
  end

  describe 'sent confirmation email' do
    let(:mail) { CommunicartMailer.proposal_created_confirmation(cart) }

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply-communicart-stub@some-dot-gov.gov')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq "Your request for Proposal ##{cart.id} has been sent successfully."
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["requester@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(["reply-communicart-stub@some-dot-gov.gov"])
    end
  end

end
