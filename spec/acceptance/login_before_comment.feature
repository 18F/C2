Feature: Creating a comment on a cart item
  Background:
    Given a valid user
    And a cart with a cart item and approvals

  Scenario: Logging in and adding a comment
    When I go to the cart view page
    Then I should see 'You need to sign in for access to this page.' alert text
    When I login
    Then I should see 'You successfully signed in' success text
    And I should see 'Requested by: Liono Requester'
    And I should see 'No comments have been added yet'
    When I fill out 'comment_comment_text' with 'This is my first comment'
    And I click 'Add a comment' button
    Then I should see 'You successfully added a comment for CartItem 1'
    And I should see 'This is my first comment'


