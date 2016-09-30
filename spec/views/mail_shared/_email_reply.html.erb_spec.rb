describe "mail_shared/_email_reply.html.erb" do
  include EventSpecHelper
  
  it "renders 'Send a Comment' link with approve button" do
    approval = create(:approval_step)
    create(:api_token, step: approval)
    proposal = approval.proposal
    render(
      partial: "mail_shared/call_to_action/email_reply",
      locals: { show_step_actions: true, step: approval.decorate, proposal: proposal }
    )

    expect(rendered).to include approval.decorate.action_name
    expect(rendered).to include I18n.t("mailer.view_or_modify_request_cta")
    expect(rendered).not_to include I18n.t("mailer.view_request_cta")
  end

  it "renders 'View This Request' link without approve button" do
    approval = create(:approval_step)
    create(:api_token, step: approval)
    proposal = approval.proposal
    render(
      partial: "mail_shared/call_to_action/email_reply",
      locals: { show_step_actions: false, step: approval.decorate, proposal: proposal }
    )

    expect(rendered).not_to include approval.decorate.action_name
    expect(rendered).not_to include I18n.t("mailer.view_or_modify_request_cta")
    expect(rendered).to include I18n.t("mailer.view_request_cta")
  end

  it "renders event requests without errors" do
    proposal = create_event
    render(
      partial: "mail_shared/panel/proposal_attributes",
      locals: { proposal: proposal.decorate }
    )
    expect(rendered).not_to have_content("translation missing")
  end

  it "renders procurement requests without errors" do
    proposal = create(:gsa18f_procurement).proposal
    render(
      partial: "mail_shared/panel/proposal_attributes",
      locals: { proposal: proposal.decorate }
    )
    expect(rendered).not_to have_content("translation missing")
  end

  it "renders work order requests without errors" do
    proposal = create(:ncr_work_order).proposal
    render(
      partial: "mail_shared/panel/proposal_attributes",
      locals: { proposal: proposal.decorate }
    )
    expect(rendered).not_to have_content("translation missing")
  end
end
