Feature: login navigation
  Background:
    Given a valid user

  Scenario: Logging in and adding a comment
    When I go to '/'
    Then I should see 'Sign in with MyUSA'
    Then I should not see 'Logout'
    When I login
    Then I should see alert text 'You successfully signed in'
    And I should see 'george.jetson@some-dot-gov.gov'
    And I should see 'Logout'
    When I click 'Logout'
    Then I should see 'Sign in with MyUSA'

