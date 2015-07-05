Feature: Approving a cart from the web application
  Scenario: An approver visits the page to approve
    Given a cart '2468642'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'supervisor1@test.gov'

    When I go to the approval_response page without a token
    And I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: An approver visits the page after previously responding
    Given a cart '2468642'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'supervisor1@test.gov'
    And the cart has been approved by the logged in user
    When I go to the approval_response page without a token
    And I should not see 'Approve'

  Scenario: A non-approver visits the page
    Given a cart '2468642'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    Given the logged in user is 'invalid-approver@test.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'

  Scenario: An approver visits the page to approve in turn
    Given a linear cart '11223344'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    And the cart has been approved by 'supervisor1@test.gov'
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: An approver visits the page to approve out of turn
    Given a linear cart '11223344'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'

  Scenario: An approver for a parallel cart visits the page to approve
    Given a parallel cart '66778899'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should see 'Approve'
    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    Then I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: A requester for a parallel cart visits the page
    Given a parallel cart '66778899'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2
    Given the logged in user is 'requester1@some-dot-gov.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'
    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    Then I should see 'Approve'
    When the logged in user is 'supervisor2@test.gov'
    And I go to the approval_response page without a token
    Then I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: Displaying approval actions for a parallel cart
    Given a parallel cart '66778899'
    And the cart has an approval for 'supervisor1@test.gov' in position 1

    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    And I should see 'Approve'

    When I click 'Approve'
    Then I should see alert text 'You have approved'
    And I should not see 'Approve'

  Scenario: Displaying approval actions for a linear cart
    Given a linear cart '99887766'
    And the cart has an approval for 'supervisor1@test.gov' in position 1
    And the cart has an approval for 'supervisor2@test.gov' in position 2

    When the logged in user is 'supervisor2@test.gov'
    And I go to the approval_response page without a token
    And I should not see 'Approve'

    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    And I should see 'Approve'

    When I click 'Approve'
    Then I should see alert text 'You have approved'
    And I should not see 'Approve'

    When the logged in user is 'supervisor2@test.gov'
    And I go to the approval_response page without a token
    And I should see 'Approve'
