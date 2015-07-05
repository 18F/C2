Feature: Approving a cart from the web application expires the token
  Scenario: An approver visits the page to approve
    Given the user is 'supervisor1@test.gov'
    And a cart '1357531'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And a valid token
    Given the logged in user is 'supervisor1@test.gov'
    When I go to the approval_response page without a token
    And I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'
    When I click 'Logout'
    And I go to the approval_response page with token
    Then I should see alert text 'Please sign in to complete this action.'
