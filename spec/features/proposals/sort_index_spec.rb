feature "Sort proposals on index page" do
  include ProposalTableSpecHelper

  scenario "does not allows titles to be clicked to sort" do
    create(:proposal, observer: user)

    login_as(user)
    visit "/proposals/query?text=1"

    within(reviewable_proposals_section) do
      expect(page).not_to have_selector("th a")
    end
  end

  it "allows other table headers to be clicked to sort" do
    proposals = create_list(:proposal, 3, observer: user)
    proposals[0].requester.update(email_address: "bbb@example.com")
    proposals[1].requester.update(email_address: "ccc@example.com")
    proposals[2].requester.update(email_address: "aaa@example.com")

    login_as(user)
    visit proposals_path

    expect_order(reviewable_proposals_section, proposals.reverse)
    within(reviewable_proposals_section) { click_on "Requester" }
    expect_order(reviewable_proposals_section, [proposals[2], proposals[0], proposals[1]])
  end

  it "allows the user to click on a title again to change order" do
    proposals = create_list(:proposal, 4, observer: user)

    login_as(user)
    visit proposals_path

    expect_order(reviewable_proposals_section, proposals.reverse)
    within(reviewable_proposals_section) { click_on "Submitted" }
    expect_order(reviewable_proposals_section, proposals)
  end

  it "does not allow clicks in one table to affect the order of the other" do
    cancelled = create_list(:proposal, 2, status: "cancelled", observer: user)
    create_list(:proposal, 2, observer: user)

    login_as(user)
    visit proposals_path

    expect_order(pending_proposals_section, cancelled.reverse)
    within(reviewable_proposals_section) { click_on "Submitted" }
    expect_order(pending_proposals_section, cancelled.reverse)
  end

  context "18F procurements" do
    scenario "can be sorted by urgency" do
      user = create(:user, client_slug: "gsa18f")
      procurements = create_list(:gsa18f_procurement, 3)
      add_user_as_observer(procurements, user)
      procurements[0].update(urgency: 20)
      procurements[1].update(urgency: 30)
      procurements[2].update(urgency: 10)

      login_as(user)
      visit proposals_path

      expect_order(reviewable_proposals_section, procurements.reverse.map { |p| p.proposal })
      within(reviewable_proposals_section) { click_on "Urgency" }

      expect_order(
        reviewable_proposals_section,
        [procurements[2].proposal, procurements[0].proposal, procurements[1].proposal]
      )
    end

    scenario "can be sorted by purchase type" do
      user = create(:user, client_slug: "gsa18f")
      software_procurement = create(:gsa18f_procurement, purchase_type: "Software")
      training_procurement = create(:gsa18f_procurement, purchase_type: "Training/Event")
      office_supply_procurement = create(:gsa18f_procurement, purchase_type: "Office Supply/Miscellaneous")
      add_user_as_observer(
        [software_procurement, training_procurement, office_supply_procurement],
        user
      )

      login_as(user)
      visit proposals_path

      expect_order(
        reviewable_proposals_section,
        [office_supply_procurement.proposal, training_procurement.proposal, software_procurement.proposal]
      )

      within(reviewable_proposals_section) { click_on "Purchase Type" }

      expect_order(
        reviewable_proposals_section,
        [software_procurement.proposal, training_procurement.proposal, office_supply_procurement.proposal]
      )
    end

    def add_user_as_observer(procurements, user)
      procurements.each do |procurement|
        procurement.update(proposal: create(:proposal, observer: user))
      end
    end
  end

  def user
    @_user ||= create(:user)
  end
end
