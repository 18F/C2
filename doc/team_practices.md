# C2 Team Practices

This document outlines best practices for the C2 team, and anyone wanting to contribute to the project.

## Workflow

All code changes should originate in a story on the [story tracker](https://pivotaltracker.com/n/projects/1149728).

Stories are clarified and prioritized in weekly iteration planning meetings (IPM). Team members self-select story ownership.
Production deployments may happen one to several times a week, so keep master in production-ready shape.

Here is an example workflow:

1. Click **Start** on the story in the story tracker.

1. Create a new Git branch from master. If you are authorized to commit on the 18F repo, branch directly on that repo. Otherwise, fork the 18F repo. The branch naming convention is *storyId*-*short-description*. Example: `git checkout -b 123456-fix-timezones`

1. Write your code and tests and documentation. You can [read about running tests](https://github.com/18F/C2/blob/master/doc/setup.md#running-tests) and [view the doc folder](https://github.com/18F/C2/tree/master/doc).

1. Push your branch to Github.

1. Create a Pull Request. The PR should reference the story URL and include a brief description
of the changes, including any rationale for how/why the story is addressed in the way it is. Use the format
`[#STORYID]` or `[Delivers #STORYID]` or `[Fixes #STORYID]` in the PR title. See the [story tracker documentation](https://www.pivotaltracker.com/help/api?version=v5#Tracker_Updates_in_SCM_Post_Commit_Hooks).

1. Click **Finish** on the story in the story tracker.

1. Someone from the team should review the PR. If you do not get feedback within 24 hours, assign the PR to a team member. (TODO??)

1. If the PR title follows the conventions above, the story tracker status will change to **Accept or Reject** when the PR is merged.

1. Reviewer will test branch in dev or staging environment(s).

1. Reviewer will click **Accept** or **Reject** on story tracker.


