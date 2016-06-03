Feature: Cancelling a request
As a User, I can cancel a request
so that when I don't need a request, I can see the updates in the system appropriately

Scenario: Shows and hides a cancel link for the requester
Given that I am a valid user for 'test-client'
And I login
And I have a request
And I go to the request detail page
And the request has a 'pending' status
And I click the cancel link
I should see a cancel modal
I fill in the reason "I did not use the funds"
And when I click "Yes, Cancel"
I should see "Your request has been canceled"
And I should see "Request Status Canceled"
And the request has a 'cancelled' status

Scenario: Requires a reason for the cancellation


Scenario: Ability for different roles to cancel a request
# Requester | Step Completer | Step Delegate
