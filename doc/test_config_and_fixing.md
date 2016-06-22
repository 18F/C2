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
* Enable email sending by adding the `email` flag to the test or group. For example:

```ruby
describe "MyEmailSenderClass", email: true do
  ...
end
```

* Enable `:truncation` Database Cleaner strategy.
