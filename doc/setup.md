# App Setup

## Dependencies

* Ruby 2.2.3
* PostgreSQL 9.x
* Elasticsearch 1.5+
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

1. [Register an application on MyUSA](https://alpha.my.usa.gov/applications/new).
    * Set the 'Redirect uri' field to `[your_domain]/auth/myusa/callback`. For example, http://localhost:3000/auth/myusa/callback.
    * In the "Select the API Scopes..." section, select:
        * Email Address
        * First Name
        * Last Name
    * Note that the MyUSA app will need to be whitelisted on their end if you need other people to log into it. This matters for staging servers more than local development, so you probably don't need to worry about it.

1. Add the required `MYUSA_*` values in your [`.env`](../.env.example).

Per [the Twelve-Factor guidelines](http://12factor.net/config), all necessary configuration should be possible through environment variables. See [`.env.example`](../.env.example) for the full list.

### Troubleshooting

#### Can't create or connect to database

* Check that PostgreSQL is running
* Set the `DATABASE_URL` variable in [`.env`](../.env.example) to match your setup

#### Can't create or connect to Elasticsearch

* Check that Elasticsearch is running (default is localhost:9200)
* Set the `ES_URL` variable in [`.env`](../.env.example) to match your setup

#### If 'foreman' command not found, you may be using rbenv. If so, run the following...
```bash
rbenv rehash
gem install foreman
```

## Starting the application

```bash
./script/start
open http://localhost:3000
```

## Populating with data

Once you've authed locally, there will be a `user` record associated with your
email address. There won't be much for you to see until your client slug is set,
so find your user record and set it to `ncr`:

```bash
bin/rails c
user = User.find_by(email_address: 'example@gsa.gov')
user.update(client_slug: 'ncr')
```

Now you will see the link to create a new work order locally.

If you'd like to seed your dashboard with work orders, you can run this rake
task:

```bash
bin/rake populate:ncr:for_user[example@gsa.gov]
```

Now you should see 25 pending purchase requests at
http://localhost:3000/proposals.

### Viewing the mailers

As emails are sent, they will be visible at http://localhost:3000/letter_opener. If you are working on an email mailer/template, you can view all of them at http://localhost:3000/mail_view/.

## Running tests

### PhantomJS

You will need to install [PhantomJS](http://phantomjs.org/download.html) and
have it in your PATH. This is used for javascript and interface testing.

### Running the entire suite once

```bash
./bin/rake
```

### Running tests as corresponding files are changed

```bash
bundle exec guard
```

### Checking for security vulnerabilities

```bash
gem install brakeman
brakeman
```

or just [visit the project on Gemnasium](https://gemnasium.com/18F/C2).

### Re-indexing search

```bash
rake environment elasticsearch:import:model CLASS="Proposal"
```

