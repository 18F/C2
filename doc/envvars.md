# Environment variables

This document describes the various environment variables available in the application
and how they affect app behavior.

## GSA18F_APPROVER_EMAIL

## GSA18F_PURCHASER_EMAIL

## MYUSA_KEY

## MYUSA_SECRET

## API_ENABLED=true
## BULLET_ENABLED=true
## BUDGET_REPORT_RECIPIENT
## DATABASE_URL
## DEFAULT_URL_HOST
## DEFAULT_URL_PORT
## DEFAULT_URL_SCHEME

## FORCE_USER_ID

This variable should only be used in development. It is most useful when mimicking a user for whom you cannot authenticate, as when working on a production db snapshot in a local sandbox.
In this example, the current_user for every request would be User `123` regardless of how the request was authenticated.

```
% FORCE_USER_ID=123 rails server
```

## GA_TRACKING_ID
## MAX_THREADS
## MYUSA_URL
## NCR_BA61_TIER1_BUDGET_MAILBOX
## NCR_BA61_TIER2_BUDGET_MAILBOX
## NCR_BA80_BUDGET_MAILBOX
## NCR_OOL_BA80_BUDGET_MAILBOX
## NEW_RELIC_APP_NAME
## NEW_RELIC_LICENSE_KEY
## NOTIFICATION_FROM_EMAIL

## NOTIFICATION_FALLBACK_EMAIL

When IncomingMail::Handler fails to deliver a message as a comment, it will forward the message on to this address.
Defaults to communicart.sender@gsa.gov

## PORT
## RESTRICT_ACCESS=true

## SUPPORT_EMAIL

The email address where all feedback and user support questions are sent.

## WEB_CONCURRENCY

## SECRET_TOKEN
## SMTP_DOMAIN
## SMTP_PASSWORD
## SMTP_USERNAME
