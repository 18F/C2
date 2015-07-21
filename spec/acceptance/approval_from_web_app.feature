Feature: Approving a proposal from the web application
  Scenario: An approver visits the page to approve
    Given a proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
    Given the logged in user is 'supervisor1@test.gov'

    When I go to the approval_response page without a token
    And I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: An approver visits the page after previously responding
    Given a proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
    Given the logged in user is 'supervisor1@test.gov'
    And the proposal has been approved by the logged in user
    When I go to the approval_response page without a token
    And I should not see 'Approve'

  Scenario: A non-approver visits the page
    Given a proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
    Given the logged in user is 'invalid-approver@test.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'

  Scenario: An approver visits the page to approve in turn
    Given a linear proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
      | supervisor2@test.gov |
    And the proposal has been approved by 'supervisor1@test.gov'
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: An approver visits the page to approve out of turn
    Given a linear proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
      | supervisor2@test.gov |
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should not see 'Approve'

  Scenario: An approver for a parallel proposal visits the page to approve
    Given a parallel proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
      | supervisor2@test.gov |
    And the logged in user is 'supervisor2@test.gov'
    When I go to the approval_response page without a token
    Then I should see 'Approve'
    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    Then I should see 'Approve'
    When I click 'Approve'
    Then I should see alert text 'You have approved'

  Scenario: A requester for a parallel proposal visits the page
    Given a parallel proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
      | supervisor2@test.gov |
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

  Scenario: Displaying approval actions for a parallel proposal
    Given a parallel proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |

    When the logged in user is 'supervisor1@test.gov'
    And I go to the approval_response page without a token
    And I should see 'Approve'

    When I click 'Approve'
    Then I should see alert text 'You have approved'
    And I should not see 'Approve'

  Scenario: Displaying approval actions for a linear proposal
    Given a linear proposal
    And the proposal has the following approvers:
      | supervisor1@test.gov |
      | supervisor2@test.gov |

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
