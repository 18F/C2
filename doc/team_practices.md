# C2 Team Practices

This document outlines best practices for the C2 team, and anyone wanting to contribute to the project.

## Workflow

All code changes should originate in a story on the [story tracker](https://pivotaltracker.com/n/projects/1149728).

Stories are clarified and prioritized in weekly iteration planning meetings (IPM). Team members self-select story ownership.

Here is an example workflow:

* Click **Start** on the story in the story tracker.

* Create a new Git branch from master. The naming convention is *storyId*-*short-description*. Example:
```
% git checkout master
% git checkout -b 123456-fix-timezones
```

* Write your code and tests and documentation.

* Push your branch to Github.

* Create a Pull Request. The PR should reference the story URL and include a brief description
of the changes, including any rationale for how/why the story is addressed in the way it is.

* Click **Finish** on the story in the story tracker.

* TODO: assign PR to another team member? ping Slack channel?

* TODO: Reviewer will click **Deliver** on story tracker.

* TODO: Reviewer will test branch in dev or staging environment(s).

* TODO: Reviewer will click **Accept** or **Reject** on story tracker.

