describe InboxController do
  it "handles mandrill POST of inbound email" do
    proposal = FactoryGirl.create(:proposal)
    requester = proposal.requester
    mandrill_event = [{
      'event' => 'inbound',
      'msg' => {
        'subject' => 'please add my comment',
        'from_email' => requester.email_address,
        'text' => 'my comment is important!',
        'headers' => {
          'References' => "<proposal-#{proposal.id.to_s}@some.gov>",
        }
      }
    }]
    post :create, mandrill_events: mandrill_event.to_json, format: :json
    expect(response.status).to eq(200)
    expect(proposal.reload.comments.last.comment_text).to eq('my comment is important!')
  end

  it "handles mandrill GET to confirm inbound route" do
    get :show

    expect(response.status).to eq(200)
  end
end
