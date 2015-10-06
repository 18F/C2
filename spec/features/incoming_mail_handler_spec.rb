describe "Handles incoming email" do
  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  let(:approval) { proposal.individual_approvals.first }
  let(:mail) { CommunicartMailer.actions_for_approver(approval) }
  let(:mandrill_inbound_noapp) { File.read(RSpec.configuration.fixture_path + '/mandrill_inbound_noapp.json') }

  def mandrill_payload_from_message(mail_msg)
    headers = {}
    mail_msg.header.fields.each do |header|
      headers[header.name] = header.value
    end
    msg = {
      'subject'  => mail_msg.subject,
      'template' => nil,
      'tags'     => [],
      'from_email' => mail_msg.to[0], # NOTE this is switched with 'email' because mail_msg is what we are *sending*
      'email'      => mail_msg.from[0],
      'sender'     => nil,
      'text'       => mail_msg.text_part.body.encoded,
      'html'       => mail_msg.html_part.body.encoded,
      'raw_msg'    => mail_msg.to_s,
      'headers'    => headers,
    }
    [ { 'event' => 'inbound', 'msg' => msg } ]
  end

  it "should drop non-app email on the floor" do
    handler = IncomingMail::Handler.new
    resp = handler.handle(JSON.parse(mandrill_inbound_noapp))
    expect(resp.action).to eq(IncomingMail::Response::DROPPED)
  end

  it "should create comment for request-related reply" do
    mandrill_event = mandrill_payload_from_message(mail)
    handler = IncomingMail::Handler.new
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment).to be_a(Comment)
    expect(resp.comment.proposal.id).to eq(proposal.id)
  end

  it "should create comment and add sender as an observer if not already" do
    my_approval = approval
    mail = CommunicartMailer.actions_for_approver(my_approval)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]['msg']['from_email'] = my_approval.user.email_address
    handler = IncomingMail::Handler.new
    expect(my_approval.proposal.existing_observation_for(my_approval.user)).to be_falsey
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment.proposal.existing_observation_for(my_approval.user)).to be_truthy
  end

  it "should parse proposal public_id from email headers" do
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]['msg']['subject'] = 'something vague'
    handler = IncomingMail::Handler.new
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment).to be_a(Comment)
    expect(resp.comment.proposal.id).to eq(proposal.id)
  end

  it "should handle Mandrill::WebHook::EventDecorator like raw JSON" do
    mandrill_event = mandrill_payload_from_message(mail)
    event_decorator = Mandrill::WebHook::EventDecorator[mandrill_event[0]]
    handler = IncomingMail::Handler.new
    resp = handler.handle(event_decorator)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
  end
end
