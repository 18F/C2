Test Configuration and Fixing
=============================

To Diagnose Issues
------------------
For strange test failures which may be order-dependent,
`rspec --bisect` is extremely helpful. Run the result
with `--format documentation` to see which early tests
cause the later ones to fail.

Common Fixes to Try
-------------------
* Change a `before(:all)` to `before(:each)`.
* Enable email sending with this code at the top of the spec file:

```ruby
before(:all) { ENV["DISABLE_EMAIL"] = nil }
after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }
```

* Enable `:truncation` Database Cleaner strategy.
