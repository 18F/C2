# C2

[![Circle CI](https://circleci.com/gh/18F/C2.svg?style=svg)](https://circleci.com/gh/18F/C2) [![Code Climate](https://codeclimate.com/github/18F/C2/badges/gpa.svg)](https://codeclimate.com/github/18F/C2) [![Test Coverage](https://codeclimate.com/github/18F/C2/badges/coverage.svg)](https://codeclimate.com/github/18F/C2)

For an overview of this project, please visit our [homepage](http://18f.github.io/C2/).

## Installation

C2 is basically a standard rails application, so it can be installed with basic approaches.

```bash
git clone https://github.com/18F/C2.git
cd C2
```

To get the database and tests running:

1. Start PostgreSQL. You will need to be able to create databases; set the
   `DB_`* variables in your environment if needed.
1. Install [PhantomJS](http://phantomjs.org/download.html) and have it in your PATH
1. Run `script/bootstrap`, which will print "DONE" if successful. *NOTE: This will delete any existing records in your C2 database.*
1. Run the specs with `bin/rspec` at the command line.
    * To run tests automatically as files are changed, run `bundle exec guard`.

To see previews of the mailers:

* Start the server (`bin/rails server`), and visit http://localhost:3000/mail_view/.

To get the app running:

1. Register an application on [MyUSA](https://myusa-staging.18f.us/authorizations).
   Note that your application will need access to the user's email.
1. Modify [`.env`](.env.example). In particular, be sure to set the `MYUSA_KEY`
  and `MYUSA_SECRET` values based on the above and set `MYUSA_URL` to
  `https://myusa-staging.18f.us`.

## More info

* [Capistrano commands](doc/capistrano.md)
