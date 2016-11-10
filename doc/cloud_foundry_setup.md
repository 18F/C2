# Cloud Foundry Setup - East/West environment

These instructions are for the legacy East/West cloud.gov environment.
We're now moving to GovCloud; for setup there, please see the section below.

## Introduction

We have three main apps in Cloud Foundry:

- Development: https://c2-dev.18f.gov/
- Staging: https://c2-staging.18f.gov/
- Production: https://cap.18f.gov/

These are all in the `cap` org and `general` space.

Our other Cloud Foundry space is called `dev`. This is where developers'
individual development environments are located. The benefit of having your own
development space is that you can deploy at any time to test out a branch you're
working on or QA someone else's work.

## How to set up your own development app

1. Make sure you are targeting the right space:

    ```bash
    cf target -s dev -o cap
    ```

1. Add the necessary services for your app (the general convention is
   `c2-dev-YOURNAME`, so for `jessieay` it would look like this:

    ```bash
    cf create-service rds shared-psql c2-dev-jessieay-db
    cf create-service elasticsearch-swarm-1.7.1 1x c2-dev-jessieay-elasticsearch
    ```
1. Bind the services, eg for `jessieay`:

   ```bash
   cf bind-service c2-dev-jessieay c2-dev-jessieay-db
   cf bind-service c2-dev-jessieay c2-dev-jessieay-elasticsearch
   ```

1. Set the required env vars for your app. The required env vars are:

  - `DEFAULT_URL_HOST`: URL for your app, eg `c2-dev-jessieay.18f.gov`
  - `MYUSA_KEY`: see section on MyUSA in https://github.com/18F/C2/blob/master/doc/setup.md
  - `MYUSA_SECRET`: ditto above
  - `NEW_RELIC_APP_NAME`: you can use the dev app, which is called `C2 (Development)`
  - `NEW_RELIC_LICENSE_KEY`: copy value from env var in another app in the `dev` space
  - `S3_ACCESS_KEY_ID`: ditto above
  - `S3_BUCKET_NAME`: ditto above
  - `S3_REGION`: ditto above
  - `S3_SECRET_ACCESS_KEY`: ditto above
  - `SMTP_PASSWORD`: ditto above
  - `SMTP_USERNAME`: ditto above
  - `SECRET_TOKEN`: run `rake secret` locally and use the output as the value for this env var

1. Add a manifest file for your app. Make sure you add this file to your global
   `.gitignore` so it does not get commited. Example file:

  ```yml
  # .jessieay-manifest.yml

  ---
  command: script/server_start
  domain: 18f.gov
  instances: 1
  memory: 1536MB
  buildpack: https://github.com/cloudfoundry/ruby-buildpack.git

  applications:
  - name: c2-dev-jessieay
    host: c2-dev-jessieay
    env:
      DEFAULT_URL_HOST: c2-dev-jessieay.18f.gov
    services:
      - c2-dev-jessieay-elasticsearch
  ```

1. Push the app to Cloud Foundry, referencing your custom manifest file

  ```bash
  cf push c2-dev-jessieay -f .jessieay-manifest.yml
  ```

1. Visit your application live at https://c2-dev-YOURNAME.18f.gov/


# Cloud Foundry Setup - GovCloud environment

## Pre-requisites

These instructions are for the **GovCloud environment**, _not_ the
East/West environment where C2 was originally deployed.

Ensure that:

 - There is a dedicated Cloud Foundry **organization** in which to deploy the app
 - That organization has `prod`, `staging` and `dev` **spaces**
 - You and everyone else who needs to deploy the app has the `SpaceDeveloper` role

## Steps

 1. Choose a space, being one of `prod`, `staging` or `dev`. (If the only
    space you can see is `general`, you're on the East/West environment)
 1. make sure you have the right roles - need SpaceDeveloper
 1. create services (binding happens automatically thanks to the `services`
    section of `manifest.yml`)
    1. pgsql: `cf create-service aws-rds medium-psql c2-SPACE-db`
    1. elasticsearch: `cf create-service elasticsearch23 1x c2-SPACE-elasticsearch`
 1. Set up environment vars
    1. on `c2-SPACE`:
        - `MYUSA_KEY`
        - `MYUSA_SECRET`
        - `ASSET_HOST`
        - `DEFAULT_URL_HOST`
    1. on `c2-SPACE-worker`:
        - `MYUSA_KEY`
        - `MYUSA_SECRET`
        - `SECRET_TOKEN`
        - `SMTP_USERNAME`
        - `SMTP_PASSWORD`
 1. Deploy app
    1. `cf push c2-SPACE -f manifest.yml`
 1. Deploy worker
    1. `cf push c2-SPACE-worker -f manifest.yml`
    1. If the worker process keeps dying and doesn't deploy properly, it may
       be because health checks haven't been disabled. Ensure that
       `health-check-type: none` is set in the manifest file.


To export from pgsql in the E/W environment: 
 - SSH in using: `SSH LINE`
 - In the SSH session:
    - Install the PG tools: 
    - Get the database URL: 
    - Create an export dump: `psql/bin/pg_dump --format=custom $DATABASE_URL > backup.pg`
 - `cf files c2-prod-ssh app/backup.pg | tail -n +4 > backup.pg`

To import a pgsql dump:
 - 
