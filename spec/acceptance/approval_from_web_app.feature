Feature: Approving a cart from the web application
  Background:
    Given a cart '135797531' with a cart item

    And the cart has an approval for 'supervisor1@test.gov'
    And the cart has an approval for 'supervisor2@test.gov'
    And the cart has an approval for 'supervisor3@test.gov'

  #Parallel
  Scenario: An approver visits the page to approve
  Given The user is 'supervisor1@test.gov'
  When I go to the approval_response page without a token
  Then I should see alert text 'You have approved Cart 109876.'
  And I should see 'Request approved by'
  And I should see 'Waiting for approval from'
  And I should see 'Approve'
  And I should see 'Reject'

  Scenario: An approver visits the page to reject

  Scenario: An approver visits the page after previously responding

  Scenario: A non-approver visits the page



  #Linear
  Scenario: An approver visits the page to approve out of turn
