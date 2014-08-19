Feature: Creating a comment on a cart item
  Background:
    Given a valid user

  Scenario: requiring a logged in user
    When I go to 'carts/1'
    Then I should see 'You need to sign in for access to this page.'
