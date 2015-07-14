# 18F's Production Deployment of C2

Live at https://cap.18f.gov.

## Deploying

1. Check out the commit you want to deploy.
1. Run `git status` and ensure that you have a clean working directory.
1. Run [`./script/release`](../script/release), which will:
    1. Tag the release.
    1. Push it to the `c2-prod` application in Cloud Foundry.
    1. Push the tag to the repository on GitHub.
