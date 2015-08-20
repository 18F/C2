# Technical overview

C2 is, at its core, a state machine wrapped in email notifications. The system centers around Proposals, which are submitted by a "requester" and sent out to the "approvers" via email. Approvers can either ask questions or leave comments, then approve" the request. The requester (and any "observers") get notifications about the overall progress. Aside from receiving email notifications for updates, users can log in at any time and see the details for outstanding and past Proposals they were involved with.

## Proposal "flows"

Proposals have two types of workflows:

* Parallel
    * Once the request is submitted, all approvers receive a notification.
* Linear (a.k.a serial)
    * Once the request is submitted, it goes to the first approver. Iff they approve, it goes to the next, and so forth.

## User accounts

User records are created in C2 one of two ways:

* Via MyUSA, where they give C2 permission to use their email address via OAuth
* By being added as an approver or observer on a Proposal

They can then log in one of two ways:

* Via OAuth with MyUSA
* By clicking a link in a notification email, which contain a short-lived one-time-use token

### Roles

The system doesn't have any notion of user-level "roles", other than on a Proposal-by-Proposal basis. They can be one of:

#### Approver

A User who can approve a Proposal directly.

#### Delegate

A User who can approve Proposals on behalf of an approver. They can be added via the console with

```ruby
approver.add_delegate(other_user)
```

#### Observer

A User who gets notifications for and can comment on a Proposal.

#### Requester

The User who initiated a Proposal.

## Data types

You can see the up-to-date database schema in [`db/schema.rb`](../db/schema.rb).

## Use cases

This application contains code for several independent but similar use cases. Users will generally be segmented into one use case or another in terms of how the Proposals are initiated, though the approval workflow is (largely) the same. Learn about how they are structured code-wise (and how to add new ones) in our [developer guide](use_case_development.md).

### 18F Equipment

In the "old days", 18F staff would make requests for software and equipment via a spreadsheet that our Operations team lead would check periodically. The team is growing quickly and we now ask that employees get sign-off on their equipment/software requests from their manager before it goes to the Ops team, so are moving this process to C2. You will see references to `Gsa18f` throughout the code.

https://hub.18f.gov/private/request-supplies/

### [National Capital Region (NCR) service centers](http://www.gsa.gov/portal/content/104717)

The NCR use case was built around GSA service centers (paint shops, landscapers, etc.) needing approvals for their superiors and various budget officials for credit card purchases. They use the "linear" workflow described [above](#proposal-flows):

1. The requester logs in via MyUSA.
1. The requester submits a new purchase request via the form at `/ncr/work_orders/new`.
1. Their "approving officer" (the "AO" – their supervisor) receives an email notification with the request.
1. If the AO approves, it goes to one or two other budget office approvers, depending on the type of request.
1. Once all approvers have approved the Proposal, the requester gets a notification.

#### Additional resources

* [GSA CFO Financial Systems & Resources Glossary](https://insite.gsa.gov/portal/content/537294) (only visible on GSA network)

## Performance

C2 has the [Peek](https://github.com/peek/peek) performance bar loaded in development, and in production for admins. It's hidden by default – press the backtick (`` ` ``) key to display it.
