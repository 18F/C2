describe "communicart_mailer/_email_reply.html.erb" do
  it "renders 'Send a Comment' link with approve button" do
    approval = FactoryGirl.create(:approval, :with_proposal, :with_user)
    approval.create_api_token!
    render partial: "communicart_mailer/email_reply", locals: {show_approval_actions: true, approval: approval}

    expect(rendered).to include "Approve"
    expect(rendered).to include "Or Send a Comment"
    expect(rendered).to_not include "View this request"
  end
  it "renders 'View This Request' link without approve button" do
    approval = FactoryGirl.create(:approval, :with_proposal, :with_user)
    approval.create_api_token!
    render partial: "communicart_mailer/email_reply", locals: {show_approval_actions: false, approval: approval}

    expect(rendered).to_not include "Approve"
    expect(rendered).to include "Or Send a Comment"
    expect(rendered).to_not include "View This Request"
  end
end