describe "communicart_mailer/_email_reply.html.erb" do
  it "renders 'Send a Comment' link with approve button" do
    approval = FactoryGirl.create(:approval)
    approval.create_api_token!
    proposal = approval.proposal
    render partial: "communicart_mailer/email_reply", locals: {show_approval_actions: true, approval: approval, proposal: proposal}

    expect(rendered).to include "Approve"
    expect(rendered).to include "Or Send a Comment"
    expect(rendered).to_not include "View this request"
  end
  it "renders 'View This Request' link without approve button" do
    approval = FactoryGirl.create(:approval)
    approval.create_api_token!
    proposal = approval.proposal
    render partial: "communicart_mailer/email_reply", locals: {show_approval_actions: false, approval: approval, proposal: proposal}

    expect(rendered).to_not include "Approve"
    expect(rendered).to_not include "Or Send a Comment"
    expect(rendered).to include "View This Request"
  end
end
