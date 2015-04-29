require 'ostruct'

describe CommunicartMailer do
  def sender_names(mail)
    # http://stackoverflow.com/a/7213323/358804
    mail[:from].display_names
  end

  let(:cart) { FactoryGirl.create(:cart_with_approvals, external_id: 13579) }
  let(:approval) { cart.approvals.first }
  let(:approver) { approval.user }
  let(:requester) { cart.requester }

  def expect_csvs_to_be_exported
    expect_any_instance_of(Exporter::Comments).to receive(:to_csv)
    expect_any_instance_of(Exporter::Approvals).to receive(:to_csv)
  end

  describe 'cart notification email' do
    let!(:token) { approval.create_api_token! }
    let(:mail) { CommunicartMailer.cart_notification_email('email.to.email@testing.com', approval) }
    let(:body) { mail.body.encoded }
    let(:approval_uri) do
      doc = Capybara.string(body)
      link = doc.find_link('Approve')
      expect(link).to_not be_nil
      url = link[:href]
      Addressable::URI.parse(url)
    end

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
    end

    it 'renders the subject' do
      requester.update_attributes(first_name: 'Liono', last_name: 'Requester')
      expect(mail.subject).to eq('Communicart Approval Request from Liono Requester: Please review Cart #13579')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["email.to.email@testing.com"])
    end

    it 'renders the sender email' do
      requester.update_attributes(first_name: 'Liono', last_name: 'Requester')
      expect(mail.from).to eq(['reply@communicart-stub.com'])
      expect(sender_names(mail)).to eq(['Liono Requester'])
    end

    it "uses the approval URL" do
      expect(approval_uri.path).to eq('/approval_response')
      expect(approval_uri.query_values).to eq(
        'approver_action' => 'approve',
        'cart_id' => cart.id.to_s,
        'cch' => token.access_token,
        'version' => cart.version.to_s
      )
    end

    context 'comments' do
      it 'does not render comments when empty' do
        expect(cart.comments.count).to eq 0
        expect(body).not_to include('Comments')
      end

      it 'renders comments when present' do
        cart.proposal.comments << FactoryGirl.create(:comment)
        expect(body).to include('Comments')
      end
    end


    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        approval.proposal.update(status: 'approved')
        expect_csvs_to_be_exported
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        expect_any_instance_of(Exporter::Base).not_to receive(:to_csv)
        mail
      end
    end

    context 'custom templates' do
      it 'renders a default template when an origin is not indicated' do
        expect(body).to include('Purchase Request')
      end

      it 'renders a custom template for ncr carts' do
        work_order = FactoryGirl.create(:ncr_work_order)
        approval.cart.proposal.client_data = work_order
        approval.cart.proposal.save
        expect(body).to include('ncr-layout')
      end
    end
  end

  describe 'approval reply received email' do
    let(:mail) { CommunicartMailer.approval_reply_received_email(approval) }

    before do
      approval.approve!
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('User approver1@some-dot-gov.gov has approved cart #13579')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(['requester@some-dot-gov.gov'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@communicart-stub.com'])
      expect(sender_names(mail)).to eq([approver.full_name])
    end

    context 'comments' do
      it 'renders comments when present' do
        cart.proposal.comments << FactoryGirl.create(:comment, comment_text: 'My added comment')
        expect(mail.body.encoded).to include('Comments')
      end

      it 'does not render empty comments' do
        expect(mail.body.encoded).to_not include('Comments')
      end

    end

    context 'attaching a csv of the cart activity' do
      it 'generates csv attachments for an approved cart' do
        approval.proposal.update(status: 'approved')
        expect_csvs_to_be_exported
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
        expect_any_instance_of(Exporter::Base).not_to receive(:to_csv)
        mail
      end
    end
  end

  describe 'comment_added_email' do
    let(:cart) { FactoryGirl.create(:cart) }
    let(:comment) { FactoryGirl.create(:comment, proposal: cart.proposal) }
    let(:email) { "commenter@some-dot-gov.gov" }
    let(:mail) { CommunicartMailer.comment_added_email(comment, email) }

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq("A comment has been added to 'Test Cart needing approval'")
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
    let(:observation) { cart.add_observer('observer1@some-dot-gov.gov') }
    let(:observer) { observation.user }
    let(:mail) { CommunicartMailer.cart_observer_email(observer.email_address, cart) }

    before do
      expect_any_instance_of(CommunicartMailer).to receive(:sender).and_return('reply@communicart-stub.com')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq("Communicart Approval Request from requester@some-dot-gov.gov: Please review Cart #13579")
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
        cart.proposal.update(status: 'approved')
        expect_csvs_to_be_exported
        mail
      end

      it 'does not generate csv attachments for an unapproved cart' do
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
