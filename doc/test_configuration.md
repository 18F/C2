Test Configuration and Debugging
================================

To Set Up the Test Environment
------------------------------

We unfortunately have the technical debt of a very
complex test environment. This recipe will run tests
reliably:

```bash
$ bin/spring stop
$ RAILS=test bundle exec rake db:reset
$ bundle exec rspec ...
```


To Help Diagnose Problems
-------------------------

* Try `rspec --bisect`


Common Solutions to Odd Test Failures
-------------------------------------

* Enable mail sending
* Switch to `:truncation` Database Cleaner strategy
