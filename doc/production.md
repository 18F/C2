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
1. Run [`./script/release`](../script/release), which will:
    1. Tag the release.
    1. Push it to the `c2-prod` application in Cloud Foundry.
    1. Push the tag to the repository on GitHub.
