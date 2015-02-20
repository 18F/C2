Feature: Approving a cart from the web application
  Scenario: An approver visits the page to approve
    Given a cart '2468642' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'supervisor1@test.gov'
    When I go to the approval_response page without a token
    And I should see 'Approve'
    And I should see 'Reject'
    When I click 'Approve'
    Then I should see alert text 'You have approved Cart 2468642.'

  Scenario: An approver visits the page to reject
    Given a cart '2468642' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'supervisor1@test.gov'
    When I go to the approval_response page without a token
    And I should see 'Approve'
    And I should see 'Reject'
    When I click 'Reject'
    Then I should see alert text 'You have rejected Cart 2468642.'

  Scenario: An approver visits the page after previously responding
    Given a cart '2468642' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'supervisor1@test.gov'
    And the cart has been approved by the logged in user
    When I go to the approval_response page without a token
    And I should not see 'Approve'
    And I should not see 'Reject'

  Scenario: A non-approver visits the page
    Given a cart '2468642' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'invalid-approver@test.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'
    And I should not see 'Reject'

  Scenario: An approver visits the page to approve in turn
    Given a linear cart '11223344' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has been approved by 'supervisor1@test.gov'
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should see 'Approve'
    And I should see 'Reject'
    When I click 'Approve'
    Then I should see alert text 'You have approved Cart 11223344.'

  Scenario: An approver visits the page to approve out of turn
    Given a linear cart '11223344' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'
    And I should not see 'Reject'

  Scenario: An approver for a parallel cart visits the page to approve
    Given a parallel cart '66778899' with a cart item
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should see 'Approve'
    And I should see 'Reject'
    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    Then I should see 'Approve'
    And I should see 'Reject'

