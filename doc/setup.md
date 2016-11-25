# App Setup

## Dependencies

* Ruby 2.3.1
* PostgreSQL 9.x
* Elasticsearch 1.5+
* A [cloud.gov](https://alpha.my.usa.gov/) account
* An SMTP server (`production` mode only)

## Installation

C2 is a fairly typical Rails application, so the setup is straightforward:

1. If you're installing on a development machine, we recommend using [`rbenv`](https://github.com/rbenv/rbenv/)
   to manage your Ruby environment, especially since we've had problems with
   `rvm`. On a Mac, [you can use Homebrew to install it](https://github.com/rbenv/rbenv#homebrew-on-mac-os-x)
   (along with `ruby-build`).

1. Run the setup script to create a user record for your email address, make
   that user an admin, and add a few records for that user.

    ```bash
    git clone https://github.com/18F/C2.git
    cd C2

    # Will print "DONE" if successful. NOTE: This will delete any existing records in your C2 database and add a few seed records.
    ./script/bootstrap YOUR_EMAIL@gsa.gov
    ```
1. Per [the Twelve-Factor guidelines](http://12factor.net/config), all necessary configuration should be possible through environment variables. (See [`.env.example`](../.env.example) for the full list.)

    Your configuration will go in the `.env` file. Create it by copying `.env.example`:

    ```bash
    cp .env.example .env
    ```
1. [Register an application on MyUSA](https://alpha.my.usa.gov/applications/new).
    * Give the application a **Name** that gives MyUSA admins a good idea of what it is and who set it up; e.g. `Janet's laptop C2`
    * Set the **Url** field to the URL for your setup. If you're running the app locally, the default URL is `http://localhost:3000/`
    * Set the **Redirect uri** field to `[your_C2_url]/auth/myusa/callback` . For example, with the default URL: `http://localhost:3000/auth/myusa/callback`
    * In the "Select the API Scopes..." section, select **Email Address**, **First Name**, and **Last Name**.
    * By default, new applications on MyUSA have a status of **Private**, which means that only the MyUSA user who registered the app can log in. If you need other people to log into your C2 setup, then your app will need a status of **Public**. (This matters for staging servers more than local development, so you probably don't need to worry about it.)

    Since Public apps need to be approved by MyUSA admins before they're usable, it's best to leave the status as _Private_ when setting up, then [change it to _Public_ later](#myusa-wont-let-other-users-log-in).

1. Once you've registered the application, MyUSA will give you two consumer key strings for saving: the _Public Key_ and _Secret Key_. Add these to your [`.env`](../.env.example), setting `MYUSA_KEY` to the Public Key and `MYUSA_SECRET` to the Secret Key.

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

#### MyUSA won't let other users log in

This is likely because your MyUSA app registration is marked _Private_. To get _Public_ status, go to your [developer applications list](https://alpha.my.usa.gov/authorizations) and click **Request Public Access**; this will send a message to the MyUSA admins. (If your application's status hasn't changed after one business day, try mailing [the MyUSA team](mailto:myusa@gsa.gov); if you're an 18F employee, ask in the [`#myusa`](https://18f.slack.com/messages/myusa/) Slack channel.)

## Starting the application

```bash
./script/start
open http://localhost:3000
```

## Populating with data

The `bootstrap` script you ran during installation creates a user record for the
email address passed in (which should be yours), makes that user an admin, and
creates relevant records for that user.

If you'd like to generate more records, you can run the following rake task:

```bash
bin/rake populate:ncr:for_user[YOUR_EMAIL@gsa.gov]
```

Now you should see 25 pending purchase requests at
http://localhost:3000/proposals.

### Viewing the mailers

As emails are sent, they will be visible at http://localhost:3000/letter_opener.

If you are working on an email mailer/template, you can view all of them at
http://localhost:3000/rails/mailers.

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
rake search:import NPROCS=2 FORCE=y
```
