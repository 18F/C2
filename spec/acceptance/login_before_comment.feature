Feature: Creating a comment on a cart item
  Background:
    Given a valid user
    And the user is logged out

  Scenario: requiring a logged in user
    When I go to a cart page
    Then I should see 'Please sign in'
