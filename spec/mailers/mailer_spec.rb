describe Mailer do
  include MailerSpecHelper

  let(:proposal) { create(:proposal, :with_parallel_approvers) }
  let(:approval) { proposal.individual_steps.first }
  let(:approver) { approval.user }
  let(:requester) { proposal.requester }

  describe 'actions_for_approver' do
    let(:token) { approval.api_token }
    let(:mail) { Mailer.actions_for_approver(approval) }
    let(:body) { mail.body.encoded }
    let(:approval_uri) do
      doc = Capybara.string(body)
      link = doc.find_link('Approve')
      expect(link).to_not be_nil
      url = link[:href]
      Addressable::URI.parse(url)
    end

    it_behaves_like "a proposal email"

    it 'renders the receiver email' do
      expect(mail.to).to eq([approver.email_address])
    end

    it "sets the sender name" do
      requester.update_attributes(first_name: 'Liono', last_name: 'Requester')
      expect(sender_names(mail)).to eq(['Liono Requester'])
    end

    it "uses the approval URL" do
      expect(approval_uri.path).to eq("/proposals/#{proposal.id}/complete")
      expect(approval_uri.query_values).to eq(
        'cch' => token.access_token,
        'version' => proposal.version.to_s
      )
    end

    it 'alerts subscribers that they have been removed' do
      mail = Mailer.actions_for_approver(approval, 'removed')
      expect(mail.body.encoded).to include('You have been removed from this request.')
    end

    it "creates a new token" do
      expect(proposal.api_tokens).to eq([])

      Timecop.freeze(Time.zone.now) do
        mail.deliver_now
        approval.reload
        expect(approval.api_token.expires_at).to be_within(1.second).of(7.days.from_now(Time.zone.now))
      end
    end

    context 'comments' do
      it 'does not render comments when empty' do
        expect(proposal.comments.count).to eq 0
        expect(body).not_to include('Comments')
      end

      it 'renders comments when present' do
        create(:comment, proposal: proposal)
        expect(body).to include('Comments')
      end
    end

    context 'attachments' do
      it 'does not render attachments when empty' do
        expect(proposal.attachments.count).to eq 0
        expect(body).not_to include('Attachments')
      end

      it 'renders attachments when present' do
        create(:attachment, proposal: proposal)
        expect(body).to include('Attachments')
      end
    end

    context 'custom templates' do
      it 'renders a default template when an origin is not indicated' do
        expect(body).to include('Purchase Request')
      end
    end

    context 'alert templates' do
      it 'defaults to no specific header' do
        mail = Mailer.actions_for_approver(approval)
        expect(mail.body.encoded).not_to include('updated')
        expect(mail.body.encoded).not_to include('already approved')
      end

      it 'uses already_approved as a particular template' do
        mail = Mailer.actions_for_approver(approval, 'already_approved')
        expect(mail.body.encoded).to include('updated')
        expect(mail.body.encoded).to include('already approved')
      end

      it 'uses updated as a particular template' do
        mail = Mailer.actions_for_approver(approval, 'updated')
        expect(mail.body.encoded).to include('updated')
        expect(mail.body.encoded).not_to include('already approved')
      end
    end

    describe "action buttons" do
      context "when the step requires approval" do
        it "email includes an 'Approve' button" do
          mail = Mailer.actions_for_approver(approval)

          expect(mail.body.encoded).to have_link('Approve')
        end
      end

      context "when the step requires purchase" do
        it "email includes a 'Mark as Purchased' button" do
          proposal = create(:proposal, :with_approval_and_purchase, client_slug: "gsa18f")
          purchase_step = proposal.individual_steps.second

          mail = Mailer.actions_for_approver(purchase_step)

          expect(mail.body.encoded).to have_link('Mark as Purchased')
        end
      end
    end
  end

  describe "notification_for_subscriber" do
    it "doesn't include action buttons" do
      mail = Mailer.notification_for_subscriber("abc@example.com", proposal, nil, approval)
      expect(mail.body.encoded).not_to have_link("Approve")
    end
  end
end
