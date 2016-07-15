# Troubleshooting Alerts

You've been pinged by New Relic. Don't panic! Here are the next steps to
take to work out what's going on, who to tell and how to fix it.

## Getting started

### Jump into Slack

You're likely not the only person who's seen the alert. Coordination will
happen on Slack, so get on there first and see what people have ascertained
already, to avoid duplication of work and stepping on each others' toes.

### Appoint an Incident Commander

This is the person who takes point on managing the alert and the checklist
tasks around it. This person doesn't do all the work; rather, they coordinate
the work being done, understand the most about what actions are
being taken, and are keeping track of all this to make sure the incident is
resolved fully.

The appointment of an [Incident Commander](https://speakerdeck.com/alicegoldfuss/nrrd-911-ic-me-the-incident-commander-role)
is standard practice in larger Operations orgs. But we're pretty small, and
there's not as much coordination to do. Even so, it can save a lot of confusion
to have one person whose job it is to stay on top of everything.

The newly-appointed IC should announce themselves to the channel, and then take
care of the remaining "Getting Started" items.

### Acknowledge the alert

The New Relic incident page (or the page on the mobile app) should have a
big **Acknowledge** button. **Only press it once you're certain that the
alert is being worked on** (by you or someone else).

### Create a Trello card for the discussion and links about the alert

99% of the communication — everything more valuable than "hey, did
anyone see this?" — goes into our Issue Tracker. Currently, that's Trello.
Create a Trello card and post the link in Slack for others to see.

All of your notes about the problem and its resolution go into this ticket.
Start by adding the Incident Management Checklist:

 * Click the **Checklist** button
 * In the **Copy Items From...** drop-down, choose `Incident Management Checklist`
 (under `!! Incident Checklist Template`, at or near the top of the list)

Then check off the items you've done already.

## Diagnosis

### Work out what the problem is

Some of the [alert conditions](https://alerts.newrelic.com/accounts/921394/policies/34)
check for the site being down, while others check for it being slow, or for
generating a large number of errors. (At time of writing, C2 only generates
a couple of exceptions per day, on average.)

Quick guide to the alerts:

  * Synthetics Monitor failure, or `Check Failure`

    This happens when the front page either won't load or doesn't contain the
    text that it's meant to. In other words, the app is either down or the front
    page (and likely the rest of the app) is broken.

  * Low Apdex score

    Means that the site is performing unusually slowly. New Relic has some
    analysis tools that may help diagnose where in the transactions the
    slowdown is happening, such as the "Web Transactions Response Time" graph
    on [the monitoring overview page](https://rpm.newrelic.com/accounts/921394/applications/5480870),
    so take a look at those first. There may also be relevant information in
    [the logs](https://logs.cloud.gov/).

  * High error rate

    This happens if the percentage of transactions resulting in errors rises
    above a certain number (currently 5%). Given that C2 is a relatively
    low-traffic app, this can happen if one user is persistently triggering
    exceptions. Take a look at [the error analytics page](https://rpm.newrelic.com/accounts/921394/applications/5480870/filterable_errors#/heatmap?top_facet=transactionUiName&barchart=barchart&_k=t9mzsc).

### Check the state of the production app

Firstly, [go look at the front page](https://cap.18f.gov/).

  * If you see a nicely-formatted error in a white box on a grey background,
  that's probably coming from Rails. So Rails is running, but it can't render
  the front page for some reason. Take a look at [the error analytics page](https://rpm.newrelic.com/accounts/921394/applications/5480870/filterable_errors#/heatmap?top_facet=transactionUiName&barchart=barchart&_k=t9mzsc) and/or [the logs](https://logs.cloud.gov/).

  * If you see a plain-text error, such as `404 Not Found: Requested route
  ('cap.18f.gov') does not exist.` then Cloud Foundry can't find the app. This
  may mean that the app isn't running, or (less likely) that the routing has
  changed.

Then, check the state of the app in Cloud.gov:

```sh
cf t -o cap -s general
cf app c2-prod
```

If the app is running OK, you should see something like:

```
Showing health and status for app c2-prod in org cap / space general as YOURNAME@gsa.gov...
OK

requested state: started
instances: 2/2
usage: 1G x 2 instances
urls: cap.18f.gov, c2.18f.gov
last uploaded: Fri May 13 00:11:47 UTC 2016
stack: cflinuxfs2
buildpack: https://github.com/cloudfoundry/ruby-buildpack.git

     state     since                    cpu    memory         disk           details
#0   running   2016-05-17 08:48:21 PM   1.2%   610.5M of 1G   217.7M of 1G
#1   running   2016-05-17 08:17:02 PM   0.0%   517.6M of 1G   216.1M of 1G
```

Important data to note from the above:

  * The `usage` (2 instances with 1GB of RAM each)
  * The `urls` from which C2 is accessible
  * For each instance, the `state`, `cpu`, `memory` and `disk`. `state` is the
  most important, but the other columns can indicate why performance issues are
  happening if those figures are close to their upper limits.

### If the app is down

_This section still needs filling. If you have experience, please contribute!_

### Diagnosing exceptions

_This section still needs filling. If you have experience, please contribute!_

## Resolution

_This section still needs filling. If you have experience, please contribute!_

### If you need to take the site offline for fixes

Put the site into **Maintenance Mode**.

_This section still needs filling. If you have experience, please contribute!_

## Once the fix is in

_This section still needs filling. If you have experience, please contribute!_

### Remember to close the NR incident

Go to the New Relic incident page and manually close it.
If the incident isn't closed once it's fixed then new ones won't be created
by later problems, and new alerts won't go out. This has bitten us before.
