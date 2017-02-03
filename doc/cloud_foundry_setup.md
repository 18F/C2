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

 1. Know what the given App Name is. This depends on who the customer is,
    the organisation, etc. We use this name when creating CF resources 
    such as the main app, the worker, the services, etc. Usually, it's just
    `c2` - in fact, as I'm writing these docs, it's the only App Name we have.
    (We were meant to have `requests` at some point, and maybe others.)
    If you don't know, ask someone else on your team. We'll refer to the App
    Name as `$appname` lower in the docs. 

 1. Choose a space, being one of `prod`, `staging` or `dev`. (If the only
    space you can see is `general`, you're on the East/West environment)
    We'll refer to the env/space name as `$env` lower in the docs.

 1. Determine your instance's hostname. Unless it's a production instance,
    the hostname is likely to be in the format `$appname-$env` - for example,
    `c2-staging`. If you're creating a dev instance for yourself, and it's
    going to live in the `dev` space with other developer instances, you
    should include your name in the hostname - e.g. `c2-dev-alice`. We'll
    refer to the hostname as `$hostname` lower in the docs.

 1. Make sure you have the `SpaceDeveloper` role in the current space.
    If you already have the `OrgManager` role, all you need to do is:
    `cf set-space-role USERNAME ORG SPACE SpaceDeveloper`
 
 1. Create services (binding happens automatically thanks to the `services`
    section of `manifest.yml`)
    1. pgsql: `cf create-service aws-rds medium-psql c2-SPACE-db`
    1. elasticsearch: `cf create-service elasticsearch23 1x c2-SPACE-elasticsearch`
    1. s3: `cf create-service s3`
 
 1. Create JSON files to store the data we'll load into User-Provided Services.
    You'll need to copy these five files from the `.ups.example` folder into a new
    temporary folder. Since they'll contain sensitive data, please make sure they're
    not backed up anywhere:
    - `app_config.json`
    - `app_param.json`
    - `email.json`
    - `newrelic.json`
    - `oauth.json`
    To create these files, you'll need to copy the five files from the `.ups.example`
    folder into a new temporary folder, and change the `.example` suffixes to `.json`.
    Over the next few steps you'll set the configuration in these files and then
    load them into the CF space as User-Provided Services.

 1. Obtain cloud.gov authentication credentials. Right now, these have to be
    given by cloud.gov support staff. They will ask for a unique hostname, so
    give them the `$hostname` mentioned earlier. Once you have the credentials,
    put them in the `oauth.json` file and remove the `FIXME` string. 
 
 1. Set up Mandrill mail delivery and receipt
    1. Get Mandrill `SMTP_USERNAME` & `SMTP_PASSWORD`. Set these in `email.json`
       and remove the `FIXME` string.
    1. If handling inbound mail, configure a Mandrill inbound mail webhook
       1. To manage Mandrill, first ensure that you have Mandrill access (ask in #admin-mandrill)
       1. Log into MailChimp and then visit https://mandrillapp.com/
       1. On the left nav, click **Inbound**. Then choose the email domain
          for the C2-using organization:
          - For 18F: `requests.18f.gov`
       1. Look through the URLs in the *Webhooks* column. 
          - If you find a URL already exists with the correct hostname for 
            your new instance, then the **Route** on the left gives you the
            email address to use for both the `NOTIFICATION_FROM_EMAIL` and
            `NOTIFICATION_REPLY_TO` environment variables.
          - If you don't find a URL with the hostname, click **+ Add New
            Route**. Choose an appropriate email username, and in **Post
            To URL** enter an URL of the format `https://HOSTNAME/inbox` ,
            where `HOSTNAME` is your instance's hostname.
 
 1. Set up environment vars
    1. on `c2-SPACE`:
        - `ASSET_HOST`
        - `DEFAULT_URL_HOST`
        - `UPS_BASE`
    1. on `c2-SPACE-worker`:
        - `SECRET_TOKEN`
        - `SMTP_USERNAME`
        - `SMTP_PASSWORD`
        - `UPS_BASE`
 
 1. Deploy app
    1. `cf push c2-SPACE -f manifest.yml`
 
 1. Deploy worker
    1. `cf push c2-SPACE-worker -f manifest.yml`
    1. If the worker process keeps dying and doesn't deploy properly, it may
       be because health checks haven't been disabled. Ensure that
       `health-check-type: none` is set in the manifest file.

## Exporting from Postgres to a backup file

### Exporting in the E/W cloud.gov environment

 - On your local machine, go to the root directory of the C2 repo
 - Ensure your CF target is the `c2` organisation, `general` space
 - SSH in using: `./script/cssh c2-prod` _(... to export from the 
   production database)_
 - In the SSH session:
    - Install the PG tools: `curl https://s3.amazonaws.com/18f-cf-cli/psql-9.4.4-ubuntu-14.04.tar.gz > psql.tgz; tar xzvf psql.tgz`
    - Validate that you have a `DATABASE_URL` variable set: 
      `echo $DATABASE_URL`
    - Create an export dump: `psql/bin/pg_dump --format=custom $DATABASE_URL > backup.pg`
    - Don't quit the SSH session yet!
 - In a separate terminal session on your local machine, download the
   backup file (this may take a minute): 
   `cf files c2-prod-ssh app/backup.pg | tail -n +4 > backup.pg`
 - You should now have a large file named `backup.pg` in your current
   directory, and you can quit that SSH session.

## Importing a Postgres backup file to a GovCloud app

### Pre-requisites

 - On your local machine, go to the root directory of the C2 repo. 
   (We're assuming that the `backup.pg` file, created above, is in the root directory)
 - Ensure your CF target is set to the correct organization and space in
   the GovCloud environment.
 - In this case, we're going to assume that the app/environment to which
   you're importing is `c2-dev`, and will be using that in the code below.
   Tweak as appropriate.
 - **This import process is destructive.** It will completely remove all
   existing data from the database and replace it. If the loss of the target
   database's existing contents is at all a cause for concern, back it up
   first! (Probably using a variant of the export process above.)

### Steps

 - First, upload the backup file to the app:
    - Get the app's GUID (and store it in an environment variable): 
         
          export IMPORT_APP_GUID=`cf app c2-dev --guid`

    - Get a one-time authorization code:
    
          cf ssh-code

    - SFTP into the app:

          sftp -P 2222 "cf:$IMPORT_APP_GUID/0@ssh.fr.cloud.gov"
    
    - When asked for a password, paste in the one-time code obtained above
    - At the SFTP prompt:
      - `put backup.pg`
      - `quit`
 - SSH in using: `cf ssh c2-dev` _(... or whichever app/environment)_
 - In the SSH session:
    - Install the PG tools: `curl https://s3.amazonaws.com/18f-cf-cli/psql-9.4.4-ubuntu-14.04.tar.gz > psql.tgz; tar xzvf psql.tgz`
    - Import the backup file (this may take a few minutes, and may
      produce one or two non-fatal errors at the start; ignore them unless
      there are many, or the process dies/quits):
      
          psql/bin/pg_restore --clean --no-owner --no-acl -d $DATABASE_URL backup.pg
      
    - The import process should end with a message like `WARNING: errors ignored on restore: 1`. That's fine.
    - Quit the SSH session, then delete the `backup.pg` file, because if it
      lingers in the same folder from which you do `cf push` or equivalent
      then you'll be pointlessly uploading 100+ MB of Postgres dump every
      time, and no one wins when that happens.

