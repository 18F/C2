require 'spec_helper'

describe 'Rejecting a cart with multiple approvers' do

  #TODO: approve/disapprove/comment > humanResponseText
  let(:rejection_params) {
      '{
      "cartNumber": "10203040",
      "category": "approvalreply",
      "attention": "",
      "fromAddress": "approver1@some-dot-gov.gov",
      "gsaUserName": "",
      "gsaUsername": null,
      "date": "Sun, 13 Apr 2014 18:06:15 -0400",
      "approve": null,
      "disapprove": "REJECT",
      "humanResponseText": "",
      "comment" : "Please order 500 highlighters instead of 300 highlighters"
      }'
    }

  let(:approver) { FactoryGirl.create(:approver) }

  before do
    ENV['NOTIFICATION_FROM_EMAIL'] = 'sender@some-dot_gov.gov'

    @json_rejection_params = JSON.parse(rejection_params)

    approval_group = ApprovalGroup.create(name: "A Testworthy Approval Group")
    approval_group.requester = Requester.create(email_address: 'test-requestser@some-dot-gov.gov')

    cart = Cart.new(
                    name: 'My Wonderfully Awesome Communicart',
                    status: 'pending',
                    external_id: '10203040'
                    )

    cart.approval_group = approval_group
    cart.cart_items << FactoryGirl.create(:cart_item)

    (1..3).each do |num|
      email = "approver#{num}@some-dot-gov.gov"

      #TODO: Remove approvers
      approval_group.approvers << Approver.create(email_address: email)
      user = FactoryGirl.create(:user, email_address: email)
      approval_group.users << user
      cart.approvals << Approval.create!(user_id: user.id)
    end

    cart.save

  end

  # context 'User corrects the rejected mistake'

  it 'updates the cart and approver records as expected' do
    # Remove stub to view email layout in development through letter_opener
    # CommunicartMailer.stub_chain(:rejection_reply_received_email, :deliver)

    Cart.count.should == 1
    Approver.count.should == 3

    cart = Cart.first
    expect(cart.approvals.count).to eq 3
    expect(cart.approvals.where(status: 'approved').count).to eq 0

    post 'approval_reply_received', @json_rejection_params

    expect(cart.approvals.count).to eq 3
    expect(cart.approvals.where(status: 'approved').count).to eq 0
    expect(cart.approvals.where(status: 'rejected').count).to eq 1
    expect(cart.reload.status).to eq 'rejected'

    #User corrects the mistake

  end
end
