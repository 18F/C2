# App Setup

## Installation

C2 is basically a standard Rails application, so it can be installed with basic approaches. It requires Ruby 1.9+ and PostgreSQL.

1. Run

    ```bash
    git clone https://github.com/18F/C2.git
    cd C2

    # Will print "DONE" if successful. NOTE: This will delete any existing records in your C2 database.
    ./script/bootstrap
    ```

1. Register an application on [MyUSA](https://myusa-staging.18f.us/authorizations). Note that your application will need the `email` scope.
1. Add the required `MYUSA_*` values in your [`.env`](.env.example).

### Troubleshooting

#### Can't create or connect to database

* Check that PostgreSQL is running
* Set the `DB_*` variables in [`.env`](../.env.example) to match your setup

## Starting the application

```bash
./bin/rails s
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
