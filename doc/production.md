# 18F's Production Deployment of C2

Live at https://cap.18f.gov.

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
1. Install [cf-blue-green](https://github.com/18F/cf-blue-green) v0.2.1+.
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
