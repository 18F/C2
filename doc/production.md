# 18F's Production Deployment of C2

Live at https://cap.18f.gov.

18F's [deployments](http://12factor.net/codebase) of C2 live in AWS, and are deployed via [Cloud Foundry](http://www.cloudfoundry.org). See [our Cloud Foundry documentation](https://docs.18f.gov) for more details on how to inspect and configure them.

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
1. Install [cf-blue-green](https://github.com/18F/cf-blue-green).
1. Deploy the application
    * If you want to do an official "release" to production, run [`./script/release`](../script/release), which will:
        1. Tag the release.
        1. Do a deployment to the `c2-prod` application in Cloud Foundry.
        1. Push the tag to the repository on GitHub.
    * If you want to do a deployment to another environment, run `./script/deploy <appname>`.

## [Mandrill](https://mandrillapp.com)

We will be moving to Mandrill for sending transactional emails.

### Getting access

1. Create a MailChimp account.
1. Ask to be [added to the MailChimp account](http://kb.mailchimp.com/accounts/multi-user/manage-user-levels-in-your-account).
    1. Open an issue in the devops repo.
    1. Assign the issue to @noahkunin.

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
% cf create-app-manifest c2-prod
% cf-ssh -f c2-prod_manifest.yml --verbose
vcap@someinstance:~$ rails console
Loading production environment (Rails 4.2.4)
irb(main):001:0> u = User.find_by_email_address 'user@example.gov'
irb(main):002:0> u.add_role('admin')
irb(main):003:0> u.save!
^D
vcap@someinstance:~$ exit
```
