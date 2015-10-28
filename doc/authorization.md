# C2 Authorization

This document describes the data managed by the C2 application,
the various roles that users of the C2 application play vis-a-vis 
that data, and the authorization rules in place to 
ensure the security and integrity of the data.

In this document the key words "MUST", "MUST NOT", "SHOULD", "SHOULD NOT", "MAY", and "MAY NOT"
are used as defined in https://www.ietf.org/rfc/rfc2119.txt.

## Terms

A *User* represents a human being who accesses the application via the HTTP (web)
interface.

A *Proposal* represents a single funding request by a *User*.

A *Client* is a group of Users with a single set of workflow and authorization rules.
A *User* is associated with a *Client* via a `client_slug`.

A *Subscriber* is a *User* who has some explicit role associated with a *Proposal*. See
the [Roles](#roles) section.

## Data

C2 SHOULD store as little Personally Identifiable Information (PII) as possible.
Currently the only User data stored includes:

* email address
* first and last name

Each *Proposal* has a one-to-one relationship with a *ClientData* record. For example,
for the National Capital Region (NCR) there are `WorkOrder` records, each of which is
related to exactly one *Proposal*.

*ClientData* records contain client-specific funding request details: building or vendor
names, codes or numbers. Each Client may have different validation rules around their
respective details: required, min/max ranges, etc. A full list of *ClientData* specifics
is in the database schema document [`db/schema.rb`](../db/schema.rb) and the related Model
classes.

*ClientData* is not PII and is not considered legally sensitive; however *ClientData* is siloed
as a UX convenience for Users within the system.

## Roles

A User may be assigned one or more roles in relation to the system as a whole (e.g. Admin).
System roles are marked with an :anchor:.

A User may be assigned one or more roles in relation to a specific Proposal (e.g. Approver).
Proposal roles are marked with a :clipboard:.

See also discussion in [the Roles section of Overview doc](overview.md#roles).

### Approver :clipboard:

A User who MAY directly approve a Proposal.

### Client-specific approvers :clipboard:

There are several client-specific approvers, which typically represent mailboxes not tied
to a particular human being but that instead use Delegates. E.g. `BA61_tier1_budget_approver`
and `BA61_tier2_budget_approver`.

### Delegate :clipboard:

A User who MAY approve Proposals on behalf of an Approver.

### Observer :clipboard:

A User who MUST receive notifications for and MAY comment on a Proposal.

### Requester :clipboard:

The User who initiated a Proposal.

### Subscriber :clipboard:

An umbrella term, referring to an Approver, Delegate, Observer or Requester.
I.e. a User explicitly associated with a Proposal.

### Admin :anchor:

A User who MAY act on any Proposal or User in the system. Access to the *Admin* role
may only be granted by another User with the *Admin* role (via the `/admin` UI) or by
someone with console access (e.g. via `cf-ssh`).

### Client Admin :anchor:

A User who MAY view all Proposals with the same `client_slug` as part of their dashboard
aggregation reporting. NOTE this aggregation feature is a UX convenience and does not
reflect any data sensitivity, since any User MAY view any Proposal with a consisten `client_slug`. 

## Rules

When these rules refer to a *Proposal* they mean also the ClientData associated with the Proposal.

1. An Admin User MAY act upon any object in the system.

1. Any User MAY create a new Proposal consistent with their `client_slug`. E.g.
a User with a `client_slug` of **ncr** MAY only create a NCR `WorkOrder` and not any other
kind of Proposal.

1. Any Subscriber MAY add another User with the same `client_slug` as an Observer
to the subscribed Proposal.

1. Only the Requester of a Proposal MAY edit or cancel the Proposal.

1. Any Subscriber MAY comment on a Proposal, which will add that User as
an Observer on the Proposal.

1. Only the Requester and the Observer MAY remove the Observer from a Proposal.

1. Only an Approver or Delegate MAY approve a Proposal.

