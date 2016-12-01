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

  feature "status field text" do
    context "when the user is an approver" do
      it "is displays the appropriate text", :js do
        user = create(:user)
        approval_proposal = create_proposal_with_approvers(user, create(:user))
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load
        expect(@page.first_status.text).to include "Please review"
      end
    end

    context "when the user is a purchaser" do
      it "is displays the appropriate text", :js do
        user = create(:user)
        purchase_proposal = create_proposal_with_approvers(create(:user), user)
        purchase_proposal.individual_steps.first.complete!
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load
        expect(@page.first_status.text).to include "Please purchase"
      end
    end

    context "when the user's request is waiting for approval" do
      it "displays the appropriate text", :js do
        user = create(:user)
        approver = create(:user)
        approval_proposal = create_proposal_for_requester_with_approvers(user, approver, create(:user))
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load

        login_as(user)
        @page.load
        expect(@page.first_status.text).to include "Pending"
      end
    end

    context "when the user's request is waiting for purchase" do
      it "displays the appropriate text", :js do
        user = create(:user)
        purchaser = create(:user)
        purchase_proposal = create_proposal_for_requester_with_approvers(user, create(:user), purchaser)
        purchase_proposal.individual_steps.first.complete!
        @page = ProposalIndexPage.new

        login_as(user)
        @page.load
        expect(@page.first_status.text).to include("Pending")
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
