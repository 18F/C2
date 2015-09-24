describe "Handles incoming email" do
  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  let(:approval) { proposal.individual_approvals.first }
  let(:approver) { approval.user }
  let(:requester) { proposal.requester }
  let(:token) { approval.api_token }
  let(:mail) { CommunicartMailer.actions_for_approver(approval) }
  let(:body) { mail.body.encoded }

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
    # this raw json string here as much for example documentation as for test.
    mandrill_event = <<-END.gsub(/^ {6}/, '')
      [
         {
            "event" : "inbound",
            "msg" : {
               "subject" : "test via example server",
               "template" : null,
               "tags" : [],
               "spf" : {
                  "detail" : "",
                  "result" : "none"
               },
               "from_email" : "someone@example.com",
               "dkim" : {
                  "valid" : false,
                  "signed" : false
               },
               "email" : "tester@c2.18f.gov",
               "sender" : null,
               "text" : "hello world",
               "raw_msg" : "Received: from example.com (unknown [93.184.216.34])\\n\\tby ip-xx-xx-xx (Postfix) with ESMTPS id 3EB7C2C06B9\\n\\tfor <tester@c2.18f.gov>; Wed, 23 Sep 2015 21:22:46 +0000 (UTC)\\nReceived: by example.com (Postfix, from userid 500)\\n\\tid 67DDF3E841; Wed, 23 Sep 2015 16:22:45 -0500 (CDT)\\nTo: tester@c2.18f.gov\\nSubject: test via example server\\nMessage-Id: <20150923212245.67DDF3E841@example.com>\\nDate: Wed, 23 Sep 2015 16:22:45 -0500 (CDT)\\nFrom: someone@example.com\\n\\nhello world",
               "headers" : {
                  "Received" : [
                     "from example.com (unknown [93.184.216.34]) by ip-xx-xx-xx (Postfix) with ESMTPS id 3EB7C2C06B9 for <tester@c2.18f.gov>; Wed, 23 Sep 2015 21:22:46 +0000 (UTC)",
                     "by example.com (Postfix, from userid 500) id 67DDF3E841; Wed, 23 Sep 2015 16:22:45 -0500 (CDT)"
                  ],
                  "From" : "someone@example.com",
                  "Message-Id" : "<20150923212245.67DDF3E841@peknet.com>",
                  "To" : "tester@c2.18f.gov",
                  "Subject" : "test via example server",
                  "Date" : "Wed, 23 Sep 2015 16:22:45 -0500 (CDT)"
               },
               "to" : [
                  [
                     "tester@c2.18f.gov",
                     null
                  ]
               ],
               "spam_report" : {
                  "matched_rules" : [
                     {
                        "score" : 1.3,
                        "name" : "RDNS_NONE",
                        "description" : "Delivered to internal network by a host with no rDNS"
                     }
                  ],
                  "score" : 1.3
               }
            },
            "ts" : 1443043366
         }
      ]
    END
    handler = IncomingMail::Handler.new
    resp = handler.handle(JSON.parse(mandrill_event))
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
    mail = CommunicartMailer.actions_for_approver(approval)
    mandrill_event = mandrill_payload_from_message(mail)
    mandrill_event[0]['msg']['from_email'] = my_approval.user.email_address
    handler = IncomingMail::Handler.new
    expect(my_approval.proposal.existing_observation_for(my_approval.user)).to be_falsey
    resp = handler.handle(mandrill_event)
    expect(resp.action).to eq(IncomingMail::Response::COMMENT)
    expect(resp.comment.proposal.existing_observation_for(my_approval.user)).to be_truthy
  end
end
