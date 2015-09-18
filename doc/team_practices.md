# C2 Team Practices

This document outlines best practices for the C2 team, and anyone wanting to contribute to the project.

## Workflow

All code changes should originate in a story on the [story tracker](https://pivotaltracker.com/n/projects/1149728).

Stories are prioritized with the product owner on a weekly basis.
Stories are further clarified, prioritized, and estimated in bi-weekly iteration planning meetings (IPM) 
which involves the delivery team members and product owner. 
A story grooming session is held the week before the start of a sprint to discuss implementation
and to add more detail into stories before IPM. Team members are encouraged to ask for clarification for stories at any time.

Team members self-select story ownership.

Production deployments may happen one to several times a week, so keep master in production-ready shape.

In the workflow below, there are two roles: Owner and Reviewer. The assumption is that all changes to the codebase
require at least one review by someone (the Reviewer) other than the person making the change (the Owner), and that the Owner
does not merge her/his own pull request. The Reviewer does the merge.

Here is an example workflow. Unless explicitly noted, actions are assumed to be taken by the Owner.

1. Click **Start** on the story in the story tracker.

1. Create a new Git branch from master. 
If you are authorized to commit on the 18F repo, branch directly on that repo. 
Otherwise, fork the 18F repo. The branch naming convention is *storyId*-*short-description*. 
Example: `git checkout -b 123456-fix-timezones`

1. Write your code and tests and documentation. You can 
[read about running tests](https://github.com/18F/C2/blob/master/doc/setup.md#running-tests) 
and [view the doc folder](https://github.com/18F/C2/tree/master/doc).

1. Push your branch to Github.

1. Create a Pull Request. The PR should reference the story URL and include a brief description
of the changes, including any rationale for how/why the story is addressed in the way it is. Use the format
`[#STORYID]` or `[Delivers #STORYID]` or `[Fixes #STORYID]` in the PR title. 
See the [story tracker documentation](https://www.pivotaltracker.com/help/api?version=v5#Tracker_Updates_in_SCM_Post_Commit_Hooks).

1. Click **Finish** on the story in the story tracker.

1. Someone from the team should review the PR. If you do not get feedback within 24 hours, assign the PR to a team member.
The Reviewer is encouraged to indicate a "Ship it" (or your favorite Ship It emoticon) before merging the pull request. 
Consider pointing out the awesomeness of your teammate's code, too.

1. The Reviewer merges the PR. Pro tip: If the PR title follows the conventions above, 
the story tracker status will change to **Accept or Reject** when the PR is merged. 
Otherwise, the Reviewer should click **Deliver** in the story tracker.

1. The Reviewer will test branch in dev or staging environment(s).

1. The Reviewer will click **Accept** or **Reject** on story tracker. If the story is rejected, 
and the change has introduced an error, the code must be rolled back as well. 
For this reason, you may prefer to merge into a copy of the master branch (e.g. `master-rc1`) and
perform QA on the copy.

1. If the change was rejected, the Owner can click **Restart** in the story tracker and take another pass at fixing
whatever was wrong. This cycle then repeats with the **Finish** step.
