# App Setup

## Dependencies

* Ruby 1.9+
* PostgreSQL
* A [MyUSA](https://alpha.my.usa.gov/) account
* An SMTP server (`production` mode only)

## Installation

C2 is a fairly typical Rails application, so the setup is straightforward:

1. Run

    ```bash
    git clone https://github.com/18F/C2.git
    cd C2

    # Will print "DONE" if successful. NOTE: This will delete any existing records in your C2 database.
    ./script/bootstrap
    ```

1. [Register an application on MyUSA](https://alpha.my.usa.gov/applications/new) that provides the `email` scope.
1. Add the required `MYUSA_*` values in your [`.env`](.env.example).

### Troubleshooting

#### Can't create or connect to database

* Check that PostgreSQL is running
* Set the `DB_*` variables in [`.env`](../.env.example) to match your setup

## Starting the application

```bash
./bin/rails s
open http://localhost:3000
```

### Viewing the mailers

As emails are sent, they will be visible at http://localhost:3000/letter_opener. If you are working on an email mailer/template, you can view all of them at http://localhost:3000/mail_view/.

## Running tests

### Running the entire suite once

```bash
./bin/rspec
```

### Running tests as corresponding files are changed

```bash
bundle exec guard
```

## Deploying

1. [Create a token](https://github.com/settings/tokens/new?description=C2%20deploy&scopes=repo_deployment) with [`repo_deployment`](https://developer.github.com/v3/oauth/#scopes) scope
    * Note that you need `write` access to the repository.
1. Run

    ```bash
    GH_KEY=... ./deploy.sh <branch> <environment>
    ```

1. View the status at https://shipme.github.io/#/envs?repo=18f%2Fc2.
