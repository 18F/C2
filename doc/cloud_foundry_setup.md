# Cloud Foundry Setup

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
