describe "communicart_mailer/_email_reply.html.erb" do
  it "renders 'Send a Comment' link with approve button" do
    approval = create(:approval)
    create(:api_token, step: approval)
    proposal = approval.proposal
    render partial: "communicart_mailer/email_reply", locals: {show_approval_actions: true, step: approval.decorate, proposal: proposal}

    expect(rendered).to include "Approve"
    expect(rendered).to include "Or Send a Comment"
    expect(rendered).to_not include "View this request"
  end
  it "renders 'View This Request' link without approve button" do
    approval = create(:approval)
    create(:api_token, step: approval)
    proposal = approval.proposal
    render partial: "communicart_mailer/email_reply", locals: {show_approval_actions: false, step: approval.decorate, proposal: proposal}

    expect(rendered).to_not include "Approve"
    expect(rendered).to_not include "Or Send a Comment"
    expect(rendered).to include "View This Request"
  end
end
