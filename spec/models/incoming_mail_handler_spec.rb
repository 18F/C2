describe "Handles incoming email" do
  include EnvVarSpecHelper
  include Test::ClientRequest

  it "should forward non-app email to NOTIFICATION_FALLBACK_EMAIL" do
    with_env_vars(NOTIFICATION_FALLBACK_EMAIL: "nowhere@example.com", NOTIFICATION_FROM_EMAIL: "noreply@example.com") do
      expect(deliveries.length).to eq(0)

      resp = IncomingMail::Handler.new.handle(JSON.parse(mandrill_inbound_noapp))

      expect(resp.action).to eq(IncomingMail::Response::FORWARDED)
      expect(deliveries.length).to eq(1)
      msg = deliveries.first
      expect(msg.to).to eq(["nowhere@example.com"])
      expect(msg.header["From"].value).to eq("Some One <noreply@example.com>")
      expect(msg.header["Reply-To"].value).to eq("Some One <someone@example.com>")
    end
  end

  it "should forward email if From and Sender do not match a valid User" do
    expect(deliveries.length).to eq(0)
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]["msg"]["from_email"] = "not-a-real-user@example.com"
    mandrill_event[0]["msg"]["headers"]["Sender"] = "still-not-a-real-user@example.com"

    resp = IncomingMail::Handler.new.handle(mandrill_event)

    expect(resp.action).to eq(IncomingMail::Response::FORWARDED)
    expect(deliveries.length).to eq(1)
  end

  it "should create comment for request-related reply" do
    client_request = create(:test_client_request)
    proposal = client_request.proposal
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    mandrill_event = mandrill_payload_from_message(mail)

    resp = IncomingMail::Handler.new.handle(mandrill_event)

    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment).to be_a(Comment)
    expect(resp.comment.proposal).to eq(proposal)
  end

  it "falls back to Sender if From is not valid" do
    client_request = create(:test_client_request)
    proposal = client_request.proposal
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    create(:approval_step, proposal: proposal, status: "actionable")
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]["msg"]["from_email"] = "not-a-valid-user@example.com"
    mandrill_event[0]["msg"]["headers"]["Sender"] = proposal.requester.email_address

    IncomingMail::Handler.new.handle(mandrill_event)

    email = deliveries.first
    expect(email.from).to eq(["noreply@example.com"])
  end

  it "should create comment for requester" do
    client_request = create(:test_client_request)
    proposal = client_request.proposal
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    create(:approval_step, proposal: proposal)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]["msg"]["from_email"] = proposal.requester.email_address

    resp = IncomingMail::Handler.new.handle(mandrill_event)

    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
  end

  it "should not create comment for non-subscriber and not add as observer" do
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    user = create(:user)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]["msg"]["from_email"] = user.email_address

    resp = IncomingMail::Handler.new.handle(mandrill_event)

    expect(resp.action).to eq(IncomingMail::Response::FORWARDED)
    expect(deliveries.length).to eq(1)
    expect(proposal.has_subscriber?(user)).to eq(false)
  end

  it "should parse proposal public_id from email headers" do
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]["msg"]["subject"] = "something vague"

    resp = IncomingMail::Handler.new.handle(mandrill_event)

    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment).to be_a(Comment)
    expect(resp.comment.proposal).to eq(proposal)
  end

  it "should handle Mandrill::WebHook::EventDecorator like raw JSON" do
    mail = ProposalMailer.proposal_created_confirmation(proposal)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event = mandrill_payload_from_message(mail)
    event_decorator = Mandrill::WebHook::EventDecorator[mandrill_event[0]]

    resp = IncomingMail::Handler.new.handle(event_decorator)

    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
  end

  private

  def proposal
    @_proposal ||= create(:proposal)
  end

  def mandrill_inbound_noapp
    @_mandrill_inbound_noapp ||= File.read(RSpec.configuration.fixture_path + "/mandrill_inbound_noapp.json")
  end

  def mandrill_payload_from_message(mail_msg)
    headers = {}
    mail_msg.header.fields.each do |header|
      headers[header.name] = header.value
    end
    msg = {
      "subject"  => mail_msg.subject,
      "template" => nil,
      "tags" => [],
      "from_email" => mail_msg.to[0], # NOTE this is switched with "email" because mail_msg is what we are *sending*
      "email" => mail_msg.from[0],
      "sender" => nil,
      "text" => mail_msg.text_part.body.encoded,
      "html" => mail_msg.html_part.body.encoded,
      "raw_msg" => mail_msg.to_s,
      "headers" => headers,
    }
    [ { "event" => "inbound", "msg" => msg } ]
  end
end
