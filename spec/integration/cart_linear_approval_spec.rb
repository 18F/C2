describe "Approving a cart with multiple approvers in parallel" do
  let(:approval_params) {
    '{
    "cartNumber": "10203040",
    "category": "approvalreply",
    "attention": "",
    "fromAddress": "approver1@some-dot-gov.gov",
    "gsaUserName": "",
    "gsaUsername": null,
    "date": "Sun, 13 Apr 2014 18:06:15 -0400",
    "approve": "APPROVE",
    "disapprove": null,
    "comment" : "spudcomment"
    }'
  }
  let(:json_approval_params) { JSON.parse(approval_params) }
  let(:cart) { FactoryGirl.build(:cart, external_id: '10203040') }

  before do
    ENV['NOTIFICATION_FROM_EMAIL'] = 'sender@some-dot_gov.gov'

    cart.proposal.update_attribute(:flow, 'linear')
    approval_group = FactoryGirl.create(:approval_group)
    user = User.create!(email_address: 'test-requester@some-dot-gov.gov')
    UserRole.create!(user_id: user.id, approval_group_id: approval_group.id, role: 'requester')
    cart.approval_group = approval_group
    cart.approvals << Approval.create!(user_id: user.id, role: 'requester')

    (1..3).each do |num|
      email = "approver#{num}@some-dot-gov.gov"
      user = FactoryGirl.create(:user, email_address: email)
      approval_group.user_roles << UserRole.create!(user_id: user.id, approval_group_id: approval_group.id, role: 'approver')
      cart.approvals << Approval.create!(user_id: user.id, role: 'approver')
    end

    cart.save!
  end

  def approve
    ActionMailer::Base.deliveries.clear
    post 'approval_reply_received', json_approval_params
    cart.reload
  end

  it 'updates the cart and approval records as expected' do
    expect(User.count).to eq(4)
    expect(cart.status).to eq 'pending'
    expect(cart.approvals.where(status: 'approved').count).to eq 0

    approve

    expect(cart.status).to eq 'pending'
    expect(cart.approvals.count).to eq 4
    expect(cart.approvals.where(status: 'approved').count).to eq 1
    expect(cart.requester.email_address).to eq 'test-requester@some-dot-gov.gov'
    expect(email_recipients).to eq([
      'approver2@some-dot-gov.gov',
      'test-requester@some-dot-gov.gov'
    ])

    json_approval_params["fromAddress"] = "approver2@some-dot-gov.gov"
    approve

    expect(cart.approvals.where(status: 'approved').count).to eq 2
    expect(email_recipients).to eq([
      'approver3@some-dot-gov.gov',
      'test-requester@some-dot-gov.gov'
    ])

    json_approval_params["fromAddress"] = "approver3@some-dot-gov.gov"
    approve

    expect(cart.status).to eq 'approved'
    expect(cart.approvals.where(status: 'approved').count).to eq 3
    expect(email_recipients).to eq(['test-requester@some-dot-gov.gov'])
  end
end
