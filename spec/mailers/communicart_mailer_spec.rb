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

  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  let(:approval) { proposal.user_approvals.first }
  let(:approver) { approval.user }
  let(:requester) { proposal.requester }

  shared_examples "a Proposal email" do
    it "renders the subject" do
      expect(mail.subject).to eq("Request ##{proposal.id}")
    end

    it "uses the configured sender email" do
      expect(mail.from).to eq(['reply@stub.gov'])
    end

    it "includes the appropriate headers for threading" do
      # headers only get added when the Mail is #deliver-ed
      mail.deliver_now

      %w(In-Reply-To References).each do |header|
        expect(mail[header].value).to eq("<proposal-#{proposal.id}@#{DEFAULT_URL_HOST}>")
      end
    end
  end

  describe 'notification_for_approver' do
    let!(:token) { approval.create_api_token! }
    let(:mail) { CommunicartMailer.actions_for_approver('email.to.email@testing.com', approval) }
    let(:body) { mail.body.encoded }
    let(:approval_uri) do
      doc = Capybara.string(body)
      link = doc.find_link('Approve')
      expect(link).to_not be_nil
      url = link[:href]
      Addressable::URI.parse(url)
    end

    it_behaves_like "a Proposal email"

    it 'renders the receiver email' do
      expect(mail.to).to eq(["email.to.email@testing.com"])
    end

    it "sets the sender name" do
      requester.update_attributes(first_name: 'Liono', last_name: 'Requester')
      expect(sender_names(mail)).to eq(['Liono Requester'])
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
        FactoryGirl.create(:ncr_work_order, proposal: proposal)
        proposal.reload
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

    it_behaves_like "a Proposal email"

    it 'renders the receiver email' do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it "sets the sender name" do
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
        final_approval = proposal.user_approvals.last
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

    it_behaves_like "a Proposal email"

    it 'renders the receiver email' do
      expect(mail.to).to eq(["commenter@some-dot-gov.gov"])
    end

    it "sets the sender name" do
      expect(sender_names(mail)).to eq([comment.user.full_name])
    end
  end

  describe 'proposal_observer_email' do
    let(:observation) { proposal.add_observer('observer1@some-dot-gov.gov') }
    let(:observer) { observation.user }
    let(:mail) { CommunicartMailer.proposal_observer_email(observer.email_address, proposal) }

    it_behaves_like "a Proposal email"

    it 'renders the receiver email' do
      expect(mail.to).to eq(["observer1@some-dot-gov.gov"])
    end

    it "uses the default sender name" do
      expect(sender_names(mail)).to eq(["Communicart"])
    end
  end

  describe 'proposal_created_confirmation' do
    let(:mail) { CommunicartMailer.proposal_created_confirmation(proposal) }

    it_behaves_like "a Proposal email"

    it 'renders the receiver email' do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it "uses the default sender name" do
      expect(sender_names(mail)).to eq(["Communicart"])
    end
  end
end
