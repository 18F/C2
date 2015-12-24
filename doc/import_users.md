# Importing Users

We will often need to import a set of users to prime a C2 instance,
so a few rake scripts have been written to accomplish this task. If using
Cloud Foundry, you will want to include the relevant csv/directory/etc. as
part of a deployment, then run `cf-ssh` (or use the `script/cssh` tool)
to execute the rake scripts.

## CSV

Importing from a CSV requires the CSV contain a header row and at least three
columns to indicate the users' first names, last names, and email addresses.
The import script will guess at which columns these are, but explicit column
names can also be provided.

The script requires two arguments: `FILE`, the path to the CSV, and `CLIENT`,
the `client_slug` to set per user. Optional arguments are `FIRST_NAME_COL`,
`LAST_NAME_COL`, and `EMAIL_COL`, for specifying the columns which contain
these values.

```
rake import_users:csv FILE=/path/to.csv CLIENT=gsa18f
rake import_users:csv FILE=/path/to.csv CLIENT=gsa18f FIRST_NAME_COL=fname LAST_NAME_COL=lname EMAIL_COL=addr
```

## One

It can be helpful to create or reset a specific user's information via a rake
script. This command has only one required argument, `EMAIL`, but three
optional arguments, `FIRST`, `LAST`, and `CLIENT`. Note that an existing user
_will_ be modified with this command, though only the fields specified will be
updated.

```
rake import_users:one EMAIL=anna.smith@some.gov
rake import_users:one EMAIL=anna.smith@some.gov FIRST=Anna LAST=Smith CLIENT=gsa18f
```

## Team YAML

18f has a repository of team information as YAML files. This script will
import users from that format. Node that it overrides first name, last name,
and client_slug if the user is already present. The script has only one
parameter, `DIR`, which is the path to the "team" directory.

```
rake import_users:team_yaml DIR=/path/to/data-private/team
```
