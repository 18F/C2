# 18F's Production Deployment of C2

Live at https://cap.18f.gov.

To spin up a server and connect to the production database, execute:

```bash
$ script/cssh c2-prod
$ RAILS_ENV=production bundle exec rails console
```

18F's [deployments](http://12factor.net/codebase) of C2 live in AWS, and are
deployed via [Cloud Foundry](http://www.cloudfoundry.org). See [the 18F Cloud
Foundry documentation](https://docs.cloud.gov) for more details on how to inspect
and configure them.

Once you're set up with Cloud Foundry, open a [new issue in the DevOps
repo](https://github.com/18F/DevOps/issues/new) to ask for access to the "cap"
organization. Include your GSA email address in the request.

## Environments

Within Cloud Foundry, our application environments are organized like so:

```
organization: cap
|
+ – space: general
    |
    + – apps:
        |
        + – c2-dev
        + - c2-staging
        + - c2-prod
```

## Deploying

1. Check out the commit you want to deploy.
1. Run `git status` and ensure that you have a clean working directory.
1. If your deploy has a destructive migration,
    * [Take a snapshot](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateSnapshot.html) of [the database](https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances:).
    * Note that you may see exceptions if doing a zero-downtime deployment, as the old copies of the application are expecting the old data format.
1. Install [autopilot](https://github.com/concourse/autopilot).
1. Run `cf target -o cap -s general`.
1. Deploy the application
    * If you want to do an official "release" to production, run [`./script/release`](../script/release), which will:
        1. Tag the release.
        1. Do a zero-downtime deployment to the `c2-prod` application in Cloud Foundry.
        1. Push the tag to the repository on GitHub.
    * If you want to do a zero-downtime deployment to another environment, run `./script/deploy <appname>`.

## [Mandrill](https://mandrillapp.com)

We use Mandrill for sending transactional emails.

### Getting access

1. Create a MailChimp account.
1. Ask to be [added to the MailChimp account](http://kb.mailchimp.com/accounts/multi-user/manage-user-levels-in-your-account).
    1. Open an issue in the devops repo. Include the GSA email address you used
       to sign up for Mailchimp.
    1. Assign the issue to @afeld.

### Signing in

1. [Log in to MailChimp.](https://login.mailchimp.com)
    * If you have multiple options, select the "General Services Administration | 18F" account.
1. Click "Reports".
1. Click "View Mandrill Reports".

You should now be signed in to Mandrill with the shared account.

## Admin accounts

18F developers can give admin access to users in the system. Here is an example:

```
# on localhost
% cd /tmp
% git checkout git@github.com:18F/C2.git
% cd C2
% script/cssh c2-prod
vcap@someinstance:~$ rails console
Loading production environment (Rails 4.2.4)
irb(main):001:0> u = User.find_by_email_address 'user@example.gov'
irb(main):002:0> u.add_role('admin')
irb(main):003:0> u.save!
^D
vcap@someinstance:~$ exit
```

## Logging

All application logs are stored via https://logs.cloud.gov/.

Logs are searchable via the Kibana UI, and are retained for 180 days.



### Setting environment variables on staging or production

Cloud.gov allows you to set environment variables manually, but they are wiped
out by a zero-downtime deploy. To get around this issue, we are accessing
environment variables via `Credentials` classes locally.

The classes pick up environment variables set in the shell by the
`UserProvidedService` module.

If you're not using Cloud Foundry to deploy, just set the environment variables
directly in your system.

Steps to set new environment variables:

1. Create a credentials class for accessing the value. Example:

  ```ruby
  # app/credentials/github_credentials.rb

  class GithubCredentials

    def self.client_id
      ENV['C2_GITHUB_CLIENT_ID']
    end

    def self.secret
      ENV['C2_GITHUB_SECRET']
    end
  end
  ```

1. Access the value with the class. Example:

  ```ruby
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider(
      :github,
      GithubCredentials.client_id,
      GithubCredentials.secret,
      scope: "user:email"
    )
  end
  ```

1. If the environment variable is needed to run the application locally, add the
  environment variable to your local `.env` file for local usage. Also add it
  to the `.env.example` file as documentation for other developers.

  ```
  # .env

  C2_GITHUB_CLIENT_ID=super_secret_key
  C2_GITHUB_SECRET=super_secret_secret
  ```

  ```
  # .env.example

  C2_GITHUB_CLIENT_ID=super_secret_key
  C2_GITHUB_SECRET=super_secret_secret
  ```

1. Create a [user-provided service](https://docs.cloudfoundry.org/devguide/services/user-provided.html):

  ```bash
  $ cf cups c2-dev-ups-github -p "client_id, secret"
  ```

  The above command will interactively prompt you for your GitHub application
  keys. **Important**: do not put quotes around input values. Cloud Foundry will
  do this for you, so if you add a value with quotes it will have double quotes.

  The naming convention strings together and dasherizes the user-provided
  service name and the parameter names to produce environment variables. In the
  example above, we are setting values for `C2_GITHUB_CLIENT_ID` and
  `C2_GITHUB_SECRET` env vars ('c2-dev-ups-github' + 'client_id'
  and 'c2-dev-ups-github' + 'secret')

1. Add the service to the manifests:

```
# manifest.yml

services:
- c2-dev-ups-github
```

1. If you want to bind your service to the app before deploying, you can do so
manually.

```bash
$ cf bind-service c2-staging c2-staging-ups-github
```

1. The service keys will automatically be bound to your app and translated into
   environment variables on deploy (which happens via Travis CI).

1. If you want to update the service parameter values, you can update the
   user-provided service:

  ```bash
  $ cf uups c2-staging-ups-github -p 'client_id, secret'
  ```

  The above command will interactively prompt you for your GitHub application
  keys. **Important**: when updating keys and/or values for a user-provided service,
  you must update *all* keys for that service. On update, Cloud Foundry removes
  all previous keys and values from the user-provided service being updated.

### To deploy a new instance of the app

Create the app (it's ok if the deploy fails):

```
$ cf push
```

Create the database service:

```
$ cf create-service rds shared-psql micropurchase-psql
```

Set up the database:

```
$ cf-ssh -f manifest.yml
$~ bundle exec rake db:migrate
```

Restage the app:

```
cf restage micropurchase
```

### Services

Cloud.gov offers multiple services to allow your application to expand its functionality.
To list all the services and plans available to your organization you can run cf marketplace from your command line.

To view the C2 services, you can run `cf services` from the command line. Each service has a process, configuration option, route and status. Using the `manifest.yml` file, services can be bound to process instances on deploys. Services can also be manually bound to server instances using:

`cf bind-service APP_NAME SERVICE_INSTANCE [-c PARAMETERS_AS_JSON]`

More details can be found using `cf help`