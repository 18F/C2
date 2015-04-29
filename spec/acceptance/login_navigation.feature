Feature: login navigation
  Scenario: Guests
    When I go to '/'
    Then I should see 'Sign in with MyUSA'
    Then I should not see 'Logout'

  Scenario: Logged in users
    When I go to '/'
    When the user is 'liono1@some-cartoon-show.com'
    And I login
    Then I should see alert text 'You successfully signed in'
    And I should see 'liono1@some-cartoon-show.com'
    And I should see 'Logout'

  Scenario: Logging out
    When I go to '/'
    When I login
    When I click 'Logout'
    Then I should see 'Sign in with MyUSA'
