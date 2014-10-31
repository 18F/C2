Feature: Approving a cart from approval link
  Background:
    Given a cart '109876' with a cart item and approvals
    And a valid user

  Scenario: Approving with a valid token
    Given the user is associated with one of the cart's approvals
    And a valid token
    When I go to the approval_response page with token
    Then I should see alert text 'You have successfully updated Cart 109876. See the cart details below'
    And show me the page
    And I should see 'Approval Status: 1 of 3 approved.'

  Scenario: Approving with a non-existent token
    When I go to the approval_response page with invalid token '1a2b3c4d'
    Then I should see alert text 'something went wrong with the token (nonexistent)'
