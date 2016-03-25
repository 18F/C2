# 18F Developer Onboarding Checklist

Create a [new issue](https://github.com/18F/C2/issues/new), and copy the [raw Markdown](https://raw.githubusercontent.com/18F/C2/master/doc/developer_onboarding.md) from below into it:

---

# Onboarding for @newmember

## Tasks for @newmember

* [ ] [Set up your development environment](https://github.com/18F/C2/blob/master/doc/setup.md)
* [ ] Go through the rest of the [general documentation](https://github.com/18F/C2#general)
* [ ] Subscribe to the project on CircleCI
    1. [Authorize With GitHub](https://circleci.com/signup)
    1. Go to [the project page](https://circleci.com/gh/18F/C2) and "follow the C2 project"

### Later

* [ ] [Set up the Cloud Foundry CLI](https://docs.cloud.gov/getting-started/setup/) (which you will need to deploy)
* [ ] [Learn more about Cloud Foundry](https://docs.cloud.gov)
* [ ] Deploy C2 to `c2-dev` (or `c2-staging`)
* [ ] [Set up your own development
  app on Cloud Foundry](https://github.com/18F/C2/blob/master/doc/cloud_foundry_setup.md)
* [ ] [Get added to the MailChimp account](production.md#getting-access) (and thus Mandrill)
* [ ] Access support emails `capdevs@gsa.gov`, `communicart.sender@gsa.gov`, and `gatewaycommunicator`
    1. Make sure someone has requested/completed access for you (See tasks for @oldmember)
    1. Go to Gmail and click 'Add Account'. Enter in each of these email addresses. If you are asked for a password, leave it blank. As long as you are already logged into your GSA email, the email addresses should be loaded.
    1. One would expect the newly added email to load automatically, but it doesn't. To load the new email, simply click on your email address at the top right of the page to show all of your loaded email accounts. Click on the newly added email address (capdevs or communicart.sender) to load it.

## Tasks for @oldmember

* [ ] Add to Slack channels
* [ ] [Add to the kanban board](https://trello.com/b/kAW72R3m/c2-birthday-cake)
* [ ] [Add to Trello](https://trello.com/b/kAW72R3m/c2-birthday-cake)
* [ ] Add to [@18F/cap](https://github.com/orgs/18F/teams/cap) team on GitHub
* [ ] Add to support emails: `capdevs`, `communicart.sender`, and `gatewaycommunicator` through [IT Service Desk](https://gsa.service-now.com)
* [ ] Send access information for developer test email: `gsa.approver@gmail.com`
* [ ] [Add to New Relic](https://rpm.newrelic.com/accounts/921394)
* [ ] Add to calendar items: standups, IPM, and story grooming sessions
* [ ] Schedule a code walkthrough
* [ ] Set up pairing session
* [ ] Give intro to [current stories](https://trello.com/b/kAW72R3m/c2-birthday-cake)
* [ ] Give intro to weekly ceremonies and team workflow

### Later

* [ ] [Add them to `cap` organization on Cloud Foundry](https://docs.cloudfoundry.org/adminguide/cli-user-management.html#org-roles) (`cf set-org-role USERNAME cap OrgManager`)
* [ ] [Add them to the repository on Hakiri.](https://hakiri.io/projects/ed076f492b8f5a/edit)
* [ ] Admin access to C2 production (add UserRole `admin` to User record)
* [ ] Access [application logs](https://logs.cloud.gov/app/kibana)
* [ ] Access to [User Voice](https://www.uservoice.com/)
* [ ] Access to [Stories on Board](https://www.storiesonboard.com/)
* [ ] Link to Google Drive files
