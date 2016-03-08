describe "mail_shared/_email_reply.html.erb" do
  it "renders 'Send a Comment' link with approve button" do
    approval = create(:approval)
    create(:api_token, step: approval)
    proposal = approval.proposal
    render(
      partial: "mail_shared/call_to_action/email_reply",
      locals: { show_step_actions: true, step: approval.decorate, proposal: proposal }
    )

    expect(rendered).to include "Approve"
    expect(rendered).to include "Or Send a Comment"
    expect(rendered).to_not include "View this request"
  end

  it "renders 'View This Request' link without approve button" do
    approval = create(:approval)
    create(:api_token, step: approval)
    proposal = approval.proposal
    render(
      partial: "mail_shared/call_to_action/email_reply",
      locals: { show_step_actions: false, step: approval.decorate, proposal: proposal }
    )

    expect(rendered).to_not include "Approve"
    expect(rendered).to_not include "Or Send a Comment"
    expect(rendered).to include "View This Request"
  end
end
