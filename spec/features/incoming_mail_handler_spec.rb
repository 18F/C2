describe "Handles incoming email" do
  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  let(:approval) { proposal.individual_approvals.first }
  let(:mail) { CommunicartMailer.actions_for_approver(approval) }
  let(:mandrill_inbound_noapp) { File.read(RSpec.configuration.fixture_path + '/mandrill_inbound_noapp.json') }

  with_env_vars(NOTIFICATION_FALLBACK_EMAIL: 'nowhere@some.gov', NOTIFICATION_FROM_EMAIL: 'noreply@some.gov') do
    it "should forward non-app email to NOTIFICATION_FALLBACK_EMAIL" do
      expect(deliveries.length).to eq(0)
      handler = IncomingMail::Handler.new
      resp = handler.handle(JSON.parse(mandrill_inbound_noapp))
      expect(resp.action).to eq(IncomingMail::Response::FORWARDED)
      expect(deliveries.length).to eq(1)
      msg = deliveries.first
      expect(msg.to).to eq(['nowhere@some.gov'])
      expect(msg.header['From'].value).to eq('Some One <noreply@some.gov>')
      expect(msg.header['Reply-To'].value).to eq('Some One <someone@example.com>')
    end
  end

  it "should create comment for request-related reply" do
    mandrill_event = mandrill_payload_from_message(mail)
    handler = IncomingMail::Handler.new
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment).to be_a(Comment)
    expect(resp.comment.proposal.id).to eq(proposal.id)
  end

  it "should create comment by approver" do
    my_approval = approval
    mail = CommunicartMailer.actions_for_approver(my_approval)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]['msg']['from_email'] = my_approval.user.email_address
    handler = IncomingMail::Handler.new
    expect(my_approval.proposal.existing_observation_for(my_approval.user)).to be_falsey
    expect(my_approval.proposal.existing_approval_for(my_approval.user)).to be_truthy
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(my_approval.proposal.existing_observation_for(my_approval.user)).to be_truthy
    expect(my_approval.proposal.existing_approval_for(my_approval.user)).to be_truthy
    expect(deliveries.length).to eq(2) # 1 each to requester and approver
  end

  it "should create comment for non-subscriber and add as observer" do
    my_approval = approval
    my_proposal = my_approval.proposal
    user = create(:user)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]['msg']['from_email'] = user.email_address
    handler = IncomingMail::Handler.new
    expect(my_approval.proposal.existing_observation_for(user)).to be_falsey
    expect(my_approval.proposal.existing_approval_for(user)).to be_falsey
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment.proposal.existing_observation_for(user)).to be_truthy
    expect(resp.comment.proposal.existing_approval_for(user)).to be_falsey
    expect(my_approval.user).to_not eq(my_proposal.individual_approvals.last.user)
    recipients = [
      user.email_address, # observer notification
      my_proposal.requester.email_address, # comment
      my_proposal.individual_approvals.last.user.email_address, # comment
      my_approval.user.email_address, # comment
    ]
    expect(deliveries.length).to eq(recipients.size)
    expect(deliveries.map{|m| m.to.first}.sort).to eq(recipients.sort)
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

  private

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
end
