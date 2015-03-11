# Technical overview

C2 is, at its core, a state machine wrapped in email notifications. The system centers around Proposals, which are submitted by a "requester" and sent out to the "approvers" via email. Approvers can either ask questions or leave comments, then approve" or reject the request. The requester (and any "observers") get notifications about the overall progress. Aside from receiving email notifications for updates, users can log in at any time and see the details for outstanding and past Proposals they were involved with.

Note: You will see references to "Carts" throughout the interface and the code...this is a legacy term, which is in the middle of being split into Proposals and their associated domain-(a.k.a. "use case")-specific models. The name "Communicart" is a reference to this initial use case as well.

## Proposal "flows"

Proposals have two types of workflows:

* Parallel
    * Once the request is submitted, all approvers receive a notification.
* Linear (a.k.a serial)
    * Once the request is submitted, it goes to the first approver. Iff they approve, it goes to the next, and so forth.

## Use cases

This application contains code for several independent but similar use cases. Users will generally be segmented into one use case or another in terms of how the Proposals are initiated, though the approval workflow is (largely) the same.

### Navigator

* Submitted via the `/send_cart` API

### National Capitol Region (NCR) service centers

The NCR use case was built around GSA service centers (paint shops, landscapers, etc.) needing approvals for their superiors and various budget officials for credit card purchases. They use the "linear" workflow described [above](#proposal-flows):

1. The requester logs in via MyUSA.
1. The requester submits a new purchase request via the form at `/ncr/proposals/new`.
1. Their "approving officer" (the "AO" – their supervisor) receives an email notification with the request.
1. If the AO approves, it goes to one or two other budget office approvers, depending on the type of request.
1. Once all approvers have approved (or any one of them reject) the Proposal, the requester gets a notification.

## TODO

* Data types
    * Proposals
    * Carts
* Accounts
    * Authentication
        * MyUSA
    * Creation via being added as an approver/observer
    * Roles
        * Proposal-by-proposal basis
* Reporting
    * When logged in, users are able to see past Proposals they were involved with, as approvers, observers, or the original requester
* For information about how 18F's deployment of C2 is configured, see [the Chef cookbook in cloud-cutter](https://github.com/18F/cloud-cutter/blob/master/chef/site-cookbooks/c2/).
