require 'ostruct'

describe CommunicartMailer do
  def sender_names(mail)
    # http://stackoverflow.com/a/7213323/358804
    mail[:from].display_names
  end

  around(:each) do |example|
    old_val = ENV['NOTIFICATION_FROM_EMAIL']
    ENV['NOTIFICATION_FROM_EMAIL'] = 'reply@stub.gov'
    example.run
    ENV['NOTIFICATION_FROM_EMAIL'] = old_val
  end

  let(:proposal) { FactoryGirl.create(:proposal, :with_approvers) }
  let(:approval) { proposal.approvals.first }
  let(:approver) { approval.user }
  let(:requester) { proposal.requester }

  describe 'notification_for_approver' do
    let!(:token) { approval.create_api_token! }
    let(:action_mail) { CommunicartMailer.actions_for_approver('email.to.email@testing.com', approval) }
    let(:body) { action_mail.body.encoded }
    let(:approval_uri) do
      doc = Capybara.string(body)
      link = doc.find_link('Approve')
      expect(link).to_not be_nil
      url = link[:href]
      Addressable::URI.parse(url)
    end

    it 'renders the subject' do
      requester.update_attributes(first_name: 'Liono', last_name: 'Requester')
      expect(action_mail.subject).to eq("Communicart Approval Request from Liono Requester: Please review request #{proposal.public_identifier}")
    end

    it 'renders the receiver email' do
      expect(action_mail.to).to eq(["email.to.email@testing.com"])
    end

    it 'renders the sender email' do
      requester.update_attributes(first_name: 'Liono', last_name: 'Requester')
      expect(action_mail.from).to eq(['reply@stub.gov'])
      expect(sender_names(action_mail)).to eq(['Liono Requester'])
    end

    it "uses the approval URL" do
      expect(approval_uri.path).to eq("/proposals/#{proposal.id}/approve")
      expect(approval_uri.query_values).to eq(
        'cch' => token.access_token,
        'version' => proposal.version.to_s
      )
    end

    context 'comments' do
      it 'does not render comments when empty' do
        expect(proposal.comments.count).to eq 0
        expect(body).not_to include('Comments')
      end

      it 'renders comments when present' do
        FactoryGirl.create(:comment, proposal: proposal)
        expect(body).to include('Comments')
      end
    end

    context 'attachments' do
      it 'does not render attachments when empty' do
        expect(proposal.attachments.count).to eq 0
        expect(body).not_to include('Attachments')
      end

      it 'renders attachments when present' do
        FactoryGirl.create(:attachment, proposal: proposal)
        expect(body).to include('Attachments')
      end
    end

    context 'custom templates' do
      it 'renders a default template when an origin is not indicated' do
        expect(body).to include('Purchase Request')
      end

      it 'renders a custom template for ncr work orders' do
        allow(proposal).to receive(:client).and_return('ncr')
        expect(body).to include('ncr-layout')
      end
    end

    context 'alert templates' do
      it 'defaults to no specific header' do
        mail = CommunicartMailer.actions_for_approver('abc@example.com', approval)
        expect(mail.body.encoded).not_to include('updated')
        expect(mail.body.encoded).not_to include('already approved')
      end

      it 'uses already_approved as a particular template' do
        mail = CommunicartMailer.actions_for_approver('abc@example.com', approval, 'already_approved')
        expect(mail.body.encoded).to include('updated')
        expect(mail.body.encoded).to include('already approved')
      end

      it 'uses updated as a particular template' do
        mail = CommunicartMailer.actions_for_approver('abc@example.com', approval, 'updated')
        expect(mail.body.encoded).to include('updated')
        expect(mail.body.encoded).not_to include('already approved')
      end
    end

    it "doesn't include action buttons unless actions_for_approver is used" do
        mail = CommunicartMailer.notification_for_approver('abc@example.com', approval)
        expect(mail.body.encoded).not_to include('Approve')
    end

    it "does include action buttons when actions_for_approver is used" do
        mail = CommunicartMailer.actions_for_approver('abc@example.com', approval)
        expect(mail.body.encoded).to include('Approve')
    end
  end

  describe 'approval_reply_received_email' do
    let(:mail) { CommunicartMailer.approval_reply_received_email(approval) }

    before do
      approval.approve!
    end

    it 'renders the subject' do
      expect(mail.subject).to eq("User approver1@some-dot-gov.gov has approved request #{proposal.public_identifier}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@stub.gov'])
      expect(sender_names(mail)).to eq([approver.full_name])
    end

    context 'comments' do
      it 'renders comments when present' do
        FactoryGirl.create(:comment, comment_text: 'My added comment',
                           proposal: proposal)
        expect(mail.body.encoded).to include('Comments')
      end

      it 'does not render empty comments' do
        expect(mail.body.encoded).to_not include('Comments')
      end
    end

    context 'completed message' do
      it 'displays when all requests have been approved' do
        final_approval = proposal.approvals.last
        final_approval.approve!
        mail = CommunicartMailer.approval_reply_received_email(final_approval)
        expect(mail.body.encoded).to include('Your request has been fully approved. See details below.')
      end

      it 'does not display when requests are still pending' do
        mail = CommunicartMailer.approval_reply_received_email(approval)
        expect(mail.body.encoded).to_not include('Your request has been fully approved. See details below.')
      end
    end

  end

  describe 'comment_added_email' do
    let(:proposal) { FactoryGirl.create(:proposal) }
    let(:comment) { FactoryGirl.create(:comment, proposal: proposal) }
    let(:email) { "commenter@some-dot-gov.gov" }
    let(:mail) { CommunicartMailer.comment_added_email(comment, email) }

    it 'renders the subject' do
      expect(mail.subject).to eq("A comment has been added to request #{proposal.public_identifier}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["commenter@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@stub.gov'])
      expect(sender_names(mail)).to eq([comment.user.full_name])
    end
  end

  describe 'proposal_observer_email' do
    let(:observation) { proposal.add_observer('observer1@some-dot-gov.gov') }
    let(:observer) { observation.user }
    let(:mail) { CommunicartMailer.proposal_observer_email(observer.email_address, proposal) }

    it 'renders the subject' do
      expect(mail.subject).to eq("Communicart Approval Request from #{proposal.requester.full_name}: Please review request #{proposal.public_identifier}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(["observer1@some-dot-gov.gov"])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['reply@stub.gov'])
      expect(sender_names(mail)).to eq([nil])
    end
  end

  describe 'proposal_created_confirmation' do
    let(:mail) { CommunicartMailer.proposal_created_confirmation(proposal) }

    it 'renders the subject' do
      expect(mail.subject).to eq "Your request for #{proposal.public_identifier} has been sent successfully."
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(["reply@stub.gov"])
    end
  end
end
