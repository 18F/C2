# Environment variables

This document describes the various environment variables available in the application
and how they affect app behavior.

## API_ENABLED=true
## BULLET_ENABLED=true
## BUDGET_REPORT_RECIPIENT
## DATABASE_URL
## DEFAULT_URL_HOST
## DEFAULT_URL_PORT
## DEFAULT_URL_SCHEME

## DISABLE_CLIENT_SLUGS

Comma-delimited list of client slugs who should be denied access to the application. This is a client-wide
deactivation, and affects every user with the slug, unlike toggling user.active which only affects a single
user.

## FORCE_USER_ID

This variable should only be used in development. It is most useful when mimicking a user for whom you cannot authenticate, as when working on a production db snapshot in a local sandbox.
In this example, the current_user for every request would be User `123` regardless of how the request was authenticated.

```
% FORCE_USER_ID=123 rails server
```

## GA_TRACKING_ID

## MAINTENANCE_MODE

Set to `true` to disable the app completely, showing a maintenance page for all pages.
Remember that you need to restart the app (`cf restart APPNAME`) for the change to
take effect.

## NEW_RELIC_APP_NAME
## NEW_RELIC_LICENSE_KEY
## NOTIFICATION_FROM_EMAIL

## NOTIFICATION_FALLBACK_EMAIL

When IncomingMail::Handler fails to deliver a message as a comment, it will forward the message on to this address.
Defaults to communicart.sender@gsa.gov

## PORT
## RESTRICT_ACCESS=true

## SKIP_TRACKING

If set, the JavaScript AHoy events will *not* be fired, regardless of `Rails.env` setting. By default, AHoy
events will fire in all non-`test` environments.

## SUPPORT_EMAIL

The email address where all feedback and user support questions are sent.

## SECRET_TOKEN
## SMTP_DOMAIN
## SMTP_PASSWORD
## SMTP_USERNAME
