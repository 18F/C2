# C2 Team Practices

This document outlines best practices for the C2 team, and anyone wanting to
contribute to the project.

## The Lifecycle of a Story

A story is a definable piece of work to be completed, represented in the team
tracker as a card. Bug fixes, engineering tasks, and new user features are all
examples of stories. Stories are represented with a short, 1-2 sentence
description. Stories that involve user-related changes are written in the
perspective of the end user. All stories should contain details on how the
feature can be evaluated for acceptance.

By the time a story makes it to the [C2 Trello
Board](https://trello.com/b/kAW72R3m/c2-birthday-cake), it has gone through a
collaborative prioritization process that includes stakeholders, product
owners, and the delivery team. Additionally, stories are "groomed" on a weekly
basis. This involves team discussion for adding necessary details into stories.

Team members are encouraged to ask for clarification for stories at any time.

A story's life cycle will typically begin at the left of the tracker,
progressing through the stages of the tracker from left to right. This is
accomplished through team members. A member starts work on a Trello card by
dragging it into the `In Process` list and putting their face on it. Card
status is updated by moving the card to the next Trello list. For example,
moving a story to the `Code Review` signifies that the story is in code review.

## Lifecycle States

### User Experience and Visual Design Trello Lists

Design tasks are listed separately but on the same board as the development
tasks. Some stories may skip the design tasks if there are no visual needs or
if the user research has already been completed.  Here are more detailed
descriptions of what each of the design tasks entail:

**`UX: Ready to Start`**

Role: Designer

Most stories will enter the tracker here after being prioritized by
stakeholders and product owners. Stories that are visually higher in a task
list indicate a higher priority than the stories lower in the list. When a card
is in this list, a designer can start working on it.

**`UX: Discovery`**

Review of existing user research/designs. Creation of communications for shared
understanding (blueprints, journey maps, etc). User interviews.

**`UX: Initial Design + Validation`**

Low fidelity mockups, wireframes. Validation through usability testing /
feedback solicitation.

**`UX: Final Design`**

High fidelity wireframes needed for a developer to complete the story.

**`Needs Grooming`**

Needs further discussion around implementation details, resolving questions,
etc. A card can enter this list at any point in its lifecycle. Stories in this
list should contain clear questions / information about what information is
required to move forward with design and development.

### Development and Deploy Trello Lists:

In the workflow below, there are multiple roles to be played:

* Owner (owns the Story, creates the Pull Request)
* Reviewer (reads, comments on, approves the Pull Request)
* Tester (deploys the Pull Request code to a testing environment, does quality assurance testing)

The assumption is that all changes to the codebase require multiple sets of
eyes. The Reviewer and Tester role might be played by the same person, but the
Owner should not also be the Reviewer or the Tester. If you are [pairing on
code changes](https://en.wikipedia.org/wiki/Pair_programming) then you can
consider one of you the Owner and the other the Reviewer for the purposes of
this workflow. That means that your PR can immediately be merged since it was
reviewed-while-coded.

**`Ready to Start`**

These are stories that are ready to be worked on by developers, including
frontend and backend work. Stories that are visually higher in a task list
indicate a higher priority than the stories lower in the list. Although there
are often task dependencies before moving, some stories may move directly into
`Ready to Start` if the design/research needs have already been met.

In Trello, the developer will self-assign the story by putting their face on
the Trello card.

A developer can self-assign a story while it is in Ready to Start if they
intend on working on that card, but developers are encouraged to avoid selecting
stories until they are In Progress to avoid preventing others from
attempting work on a feature.

**`In Progress`**

When a developer starts a story, they move the card to this list and
self-assign. Each developer should aim to have no more than 2-3 stories in
process at a time.

The author writes code and tests and documentation. Read [read about running
tests](https://github.com/18F/C2/blob/master/doc/setup.md#running-tests) and
[view the doc folder](https://github.com/18F/C2/tree/master/doc).

**`Code Review`**

When a pull request is opened for a change, the author moves the Trello card to
the code review list. Once a card is moved to this list, the team uses
assignment in the GitHub pull request rather than in Trello.

The PR should link to the Trello card and include a brief description of the
changes, including any rationale for how/why the story is addressed in the way
it is.

The author should add any notes relevant to testing the change.

The author should link to the pull request in a comment on the Trello card.

Someone from the team should review the PR. If you do not get feedback within
24 hours, assign the PR to a team member for review. The Reviewer should
consider the automated testing status and Code Climate reports, in addition to
checking the code for architectural consistency, style and legibility. Code
reviews are encouraged early in the development process; you can always create
a PR with a `[WIP]` prefix before you are ready to deliver, and ask for review
of work-in-progress. The Reviewer is encouraged to indicate a "Ship it" (or
your favorite Ship It emoticon) Consider pointing out the awesomeness of the
code, too.

If the committer paired with someone on the story, the teammate can certainly
give a Ship It. That said, the pair is welcome to solicit additional PR
feedback from the rest of the team. If verbal approval is given by a teammate,
the committer may comment `@TEAMMATE ship it` before merging the PR.

If a card is code reviewed and requires more work before it is ready for the QA
step, the code reviewer should indicate that updates are needed and assign the
author to the pull request in Github but does not need to move the Trello card
back to In Progress.

There should be no more than 3 cards in Code Review at a time. If there are,
developers should prioritize reviewing code over writing new code for features
or bug fixes.

**`QA`**

When a reviewer is done with code review, they should move the related Trello
card to the `QA` list in Trello. If the reviewer is going to QA the feature,
they should comment that they will be QAing on the pull request.

QA requires the Tester to deploy to `c2-dev` or `c2-staging` to confirm that the
feature works as expected in a production environment. If the QA instructions
are missing from the Trello card, the person doing QA should ask the pull
request author or product manager for QA instructions.

The Tester indicates that they are QA-ing the change by making a comment on the
pull request. QA can be done on the `c2-dev` or `c2-staging` environment. Check
with your teammates (on Slack) to see which environment might already be in
use.

Example flow:

    ```bash
    cd /tmp && mkdir deploy-qa && cd deploy-qa
    git clone git@github.com:18F/C2.git
    cd C2
    git checkout -b qa-fix-timezones
    git merge -m 'temp qa branch' origin/fix-timezones
    cf push c2-dev
    ```

If there are any problems, the Tester should comment on the PR and assign it to
the Owner for follow-up.  The Owner should fix the problems and assign back to
the Tester, who can then repeat the testing steps above.

There should be no more than 3 cards in QA at a time. If there are,
developers should prioritize QA over writing new code for features
or bug fixes.

**`Ready to Deploy`**

Once a story has been QA'd and merged into `master`, it should be moved in the
`Ready to deploy` list.

Production deployments may happen one to several times a week, so keep master
in production-ready shape.

**`Deployed week of XX/XX`**

Stories deployed each week should be kept in a list for that week. This helps
the product manager communicate deployed changes to the product owner. The
board should have a new list each week and lists older than 3 weeks should be
archived.

**`Blocked`**

If a story in backlog does not have enough detail to be actionable, add a
comment asking for the required information, tag the story with the blocked tag
and assign the product manager as the owner to determine next actions.

### Q+A

What if I discover a bug or need to create a story that is relevant to the work
that we are currently doing?

If the bug is actionable, a story can be created for it and prioritized in the
`Ready to start`. If the story needs more discussion, it can be moved into
`Needs Grooming` for the next grooming session.


## Support

Support tickets for existing users are managed at [18F's User Voice account](https://18f.uservoice.com).
The delivery team rotates assignment to respond to user issues and bug reports. As support requests are
received, tickets are immediately actionable. The developer can assign the ticket to her/himself as
the work begins.