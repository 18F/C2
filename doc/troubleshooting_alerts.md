# Troubleshooting Alerts

You've been pinged by New Relic. Don't panic! Here are the next steps to
take to work out what's going on, who to tell and how to fix it.

## Jump into Slack

You're likely not the only person who's seen the alert. Coordination will
happen on Slack, so get on there first and see what people have ascertained
already, to avoid duplication of work and stepping on each others' toes.

## Acknowledge the alert

The New Relic incident page (or the page on the mobile app) should have a
big **Acknowledge** button. **Only press it once you're certain that the
alert is being worked on** (by you or someone else).

## Remember to close the NR incident afterwards

This may seem a little early to mention it, but it's **really important**:
if the incident isn't closed once it's fixed then new ones won't be created
by later problems, and new alerts won't go out. This has bitten us before.

## Work out what the problem is

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

## Check the state of the production app

Firstly, [go look at the front page](https://cap.18f.gov/).

  * If you see a nicely-formatted error in a white box on a grey background, that's probably coming from Rails. So Rails is running, but it can't render the front page for some reason. Take a look at [the error analytics page](https://rpm.newrelic.com/accounts/921394/applications/5480870/filterable_errors#/heatmap?top_facet=transactionUiName&barchart=barchart&_k=t9mzsc) and/or [the logs](https://logs.cloud.gov/).

  * If you see a plain-text error, such as `404 Not Found: Requested route ('cap.18f.gov') does not exist.` then Cloud Foundry can't find the app. This may mean that the app isn't running, or (less likely) that the routing has changed.

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
  * For each instance, the `state`, `cpu`, `memory` and `disk`. `state` is the most important, but the other columns can indicate why performance issues are happening if those figures are close to their upper limits.

## If the app is down

## Diagnosing exceptions

## If you need to take the site offline for fixes

Put the site into **Maintenance Mode**.
