feature "Proposals index" do
  include ProposalTableSpecHelper
  include ResponsiveHelper

  scenario "load new index page based on current_user for all requests", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)
    login_as(user)
    visit "/proposals"
    expect(page).to have_selector('tbody tr', count: 7)
  end

  scenario "filters new index page for pending requests", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)

    login_as(user)

    visit "/proposals"
    expect(page).to have_css(".pending-button")
    first(".pending-button").click
    sleep(1)

    expect(page).to have_selector('tbody tr', count: 4)
  end

  scenario "order list by descending alphabetical in new index page for all requests", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)

    login_as(user)

    visit "/proposals"

    expect(page).to have_css("th.th-value-id .table-header")
    first("th.th-value-id .table-header").click
    sleep(1)

    pp = Proposal.search(user)

    expect(first('tbody tr td.public_id a')).to have_content(pp.result.last.public_id)
  end

  scenario "Responsive layout should restructure based on screensize", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)

    login_as(user)
    visit "/proposals"

    resize_window_to_mobile
    expect(page).to have_selector('thead tr th', count: 4)

    Capybara.page.driver.browser.resize(940, 800)
    expect(page).to have_selector('thead tr th', count: 4)

    resize_window_default
    expect(page).to have_selector('thead tr th', count: 5)

    resize_window_large
    expect(page).to have_selector('thead tr th', count: 7)
  end

  scenario "click on item on new index page to load new page", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)

    login_as(user)

    visit "/proposals"

    expect(page).to have_css("tbody tr td.name a")
    first('tbody tr td.name a').click
    sleep(1)

    proposals = Proposal.where(status: "pending", requester_id: user.id)

    expect(current_path).to have_content("/proposals/" + proposals.last.id.to_s)
  end

  scenario "filters new index page for canceled requests", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)

    login_as(user)

    visit "/proposals"
    expect(page).to have_css(".canceled-button")
    first(".canceled-button").click
    sleep(1)

    expect(page).to have_selector('tbody tr', count: 2)
  end

  scenario "filters new index page for completed requests", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    user = work_order_ba80.requester
    _reviewable_proposals = create_list(:proposal, 2, :with_approver, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _canceled = create_list(:proposal, 2, status: "canceled", observer: user)

    login_as(user)

    visit "/proposals"
    expect(page).to have_css(".completed-button")
    first(".completed-button").click
    sleep(1)

    expect(page).to have_content('No matching records found')
  end

  scenario "defaults to sorted by created date", :js do
    user = create(:user, client_slug: 'ncr')
    proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    canceled = create_list(:proposal, 2, :with_approver, status: "canceled", approver_user: user)
    @page = ProposalIndexPage.new

    login_as(user)
    @page.load
    click_on "Pending"
    expect_order(@page.pending, proposals) #TODO: move back to reverse chronology 'proposals.reverse', setting before the redesign
  end

  feature "The 'needing review' section" do
    context "when there are requests that can be acted on by the user" do
      scenario "contains those requests" do
        user = create(:user)
        proposal = create(:proposal, :with_approver, approver_user: user)

        login_as(user)
        @page = ProposalIndexPage.new
        @page.load

        expect(@page.needing_review).to have_content "Purchase Requests Needing Review"
        expect(@page.needing_review.requests.first.public_id_link.text).to eq proposal.public_id
      end
    end

    context "when there are no requests that can be acted on by the user" do
      scenario "does not exist" do
        login_as(create(:user))
        @page = ProposalIndexPage.new
        @page.load

        expect(@page.needing_review).to_not have_content "Purchase Requests Needing Review"
        expect(@page.needing_review.requests).to be_empty
      end
    end
  end

  feature "new feature flag" do
    context "when the user hasn't seen a feature" do
      scenario "shows an icon when the user hasn't seen the help doc", :js do
        beta_active = create(:user, :beta_active, client_slug: "ncr")

        login_as(beta_active)
        visit proposals_path
        expect(page.find('.new-features-button img')['src']).to have_content('new_feature_icon.svg')
        click_on "New features"

        visit proposals_path
        expect(page.find('.new-features-button img')['src']).to have_content('new_feature_icon_none.svg')
      end
    end
  end


  feature "status field text" do
    context "when the user is an approver" do
      scenario "is correct for the user" do
        user = create(:user)
        approval_proposal = create_proposal_with_approvers(user, create(:user))
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load

        expect(@page.needing_review.requests[0].public_id_link.text).to eq approval_proposal.public_id
        expect(@page.needing_review.requests[0].status.text).to eq "Please review"
      end
    end

    context "when the user is a purchaser" do
      scenario "is correct for the user" do
        user = create(:user)
        purchase_proposal = create_proposal_with_approvers(create(:user), user)
        purchase_proposal.individual_steps.first.complete!
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load

        expect(@page.needing_review.requests[0].public_id_link.text).to eq purchase_proposal.public_id
        expect(@page.needing_review.requests[0].status.text).to eq "Please purchase"
      end
    end

    context "when the user's request is waiting for approval" do
      scenario "is correct for the user" do
        user = create(:user)
        approver = create(:user)
        approval_proposal = create_proposal_for_requester_with_approvers(user, approver, create(:user))
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load

        expect(@page.pending.requests[0].public_id_link.text).to eq approval_proposal.public_id
        expect(@page.pending.requests[0].status.text).to eq "Pending Waiting for review from: #{approver.full_name}"
      end
    end

    context "when the user's request is waiting for purchase" do
      scenario "is correct for the user" do
        user = create(:user)
        purchaser = create(:user)
        purchase_proposal = create_proposal_for_requester_with_approvers(user, create(:user), purchaser)
        purchase_proposal.individual_steps.first.complete!
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load

        expect(@page.pending.requests[0].public_id_link.text).to eq purchase_proposal.public_id
        expect(@page.pending.requests[0].status.text).to eq "Pending Waiting for purchase from: #{purchaser.full_name}"
      end
    end
  end

  def create_proposal_with_approvers(first_approver, second_approver)
    proposal = create(:proposal)
    steps = [
      create(:approval_step, user: first_approver),
      create(:purchase_step, user: second_approver)
    ]
    proposal.add_initial_steps(steps)
    proposal
  end

  def create_proposal_for_requester_with_approvers(requester, first_approver, second_approver)
    proposal = create_proposal_with_approvers(first_approver, second_approver)
    proposal.update(requester: requester)
    proposal
  end
end
