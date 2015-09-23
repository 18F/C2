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

In the workflow below, there are multiple roles to be played:

* Owner (owns the Story, creates the Pull Request)
* Reviewer (reads, comments on, approves the Pull Request)
* Tester (deploys the Pull Request code to a testing environment, does quality assurance testing)

The assumption is that all changes to the codebase require multiple sets of eyes. The Reviewer and Tester
role might be played by the same person, but the Owner should not also be the Reviewer or the Tester.
If you are [pairing on code changes](https://en.wikipedia.org/wiki/Pair_programming) then
you can consider one of you the Owner and the other the Reviewer for the purposes of this workflow. That
means that your PR can immediately be merged since it was reviewed-while-coded.

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
See the [story tracker documentation](https://www.pivotaltracker.com/help/api?version=v5#Tracker_Updates_in_SCM_Post_Commit_Hooks). Consider adding any notes relevant to testing the change, especially for live QA testing.

1. Click **Finish** on the story in the story tracker.

1. Someone from the team should review the PR. If you do not get feedback within 24 hours, 
assign the PR to a team member for review. The Reviewer should consider the automated
testing status and Code Climate reports, in addition to checking the code for architectural
consistency, style and legibility. Code reviews are encouraged early in the development process;
you can always create a PR with a `[WIP]` prefix before you are ready to deliver, and ask for review
of work-in-progress. The Reviewer is encouraged to indicate a "Ship it" (or your favorite Ship It emoticon)
Consider pointing out the awesomeness of the code, too.

1. The Tester tests the code. This can be done on the `c2-dev` or `c2-staging` environment.
Check with your teammates to see which environment might already be in use.
Example flow:

    ```bash
    cd /tmp && mkdir deploy-qa && cd deploy-qa
    git clone git@github.com:18F/C2.git
    cd C2
    git checkout -b qa-123456-fix-timezones
    git merge -m 'temp qa branch' origin/123456-fix-timezones
    script/deploy c2-dev
    ```

1. The Tester should test out the bugfix or new functionality.

1. If there are any problems, the Tester should comment on the PR and assign it to the Owner for follow-up.
The Owner should fix the problems and assign back to the Tester, who can then repeat the testing steps above.

1. When the Tester is satisfied, s/he merges the PR to `master`. 
Pro tip: If the PR title follows the conventions mentioned above, 
the story tracker status will change to **Accept or Reject** when the PR is merged. 
Otherwise, the Reviewer should click **Deliver** in the story tracker.

1. The Tester will click **Accept** or **Reject** on story tracker. An **Accept** means the code is merged
to master and ready for production deploy at any time. Typically **Reject** indicates
that the testing passed but for some reason the solution is not sufficient, and needs work at the
story level. 

1. If the change was rejected, the Owner can click **Restart** in the story tracker and take another pass at fixing
whatever was wrong. This cycle then repeats with the **Finish** step.
