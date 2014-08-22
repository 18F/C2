Feature: Adding an approval group
  Background:
    Given a valid user

  Scenario: Logging in and adding an approval group
    When I go to 'approval_groups/new'
    Then I should see alert text 'You need to sign in for access to this page.'
    When I login
    Then I should see alert text 'You successfully signed in'
    And I should see 'Create new Approval Group'
    When I fill out 'Name' with 'MyAwesomeApprovalGroup'
    And I fill out 'Requester' with 'test-requester-1@some-dot-gov.gov'
    And I fill out 'Approver 1' with 'test-approver-1@some-dot-gov.gov'
    And I fill out 'Approver 2' with 'test-approver-2@some-dot-gov.gov'
    And I click 'Create Approval Group' button
    Then I should see alert text 'Group created successfully'
    Then I should see a header 'MyAwesomeApprovalGroup'


