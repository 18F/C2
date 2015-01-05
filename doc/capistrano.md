# Capistrano

You can list available Capistrano commands with

```bash
bundle exec cap -T
```

and run them with

```bash
bundle exec cap <environment> <command>
```

The `environment` corresponds to the stack on EC2: `development`, `staging`, or `production`. To report production uptimes, for example, use

```bash
bundle exec cap production uptime
```

See the Capistrano [documentation](http://capistranorb.com/) for more info.
