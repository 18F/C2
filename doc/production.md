# 18F's Production Deployment of C2

Live at https://cap.18f.gov.

18F's [deployments](http://12factor.net/codebase) of C2 live in AWS, and are deployed via [Cloud Foundry](http://www.cloudfoundry.org). See [our Cloud Foundry documentation](https://docs.18f.gov) for more details how to inspect and configure them. Note that we are *not* currently [using manifests](http://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html) to deploy.

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
1. Install [cf-blue-green](https://github.com/18F/cf-blue-green).
1. Deploy the application
    * If you want to do an official "release" to production, run [`./script/release`](../script/release), which will:
        1. Tag the release.
        1. Do a zero-downtime deployment to the `c2-prod` application in Cloud Foundry.
        1. Push the tag to the repository on GitHub.
    * If you want to do a zero-downtime deployment to another environment, run `cf-blue-green <appname>`.
    * If you want to do a simple deployment, you can use `cf push <appname>`.
