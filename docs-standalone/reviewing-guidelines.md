## ResearchKit Reviewing Guidelines

Apple, from time to time, may grant write permissions to trusted external contributors so they can review and merge *Pull Requests*; and edit, label and close *Issues*.

### Basic Guidelines

These are the requisites that must be met before a Pull Request can be merged.

*Pull Request* must have at least two *Approve GitHub* reviews before they can be merged. The reviews must be done by at least one reviewer from *Apple*, and one reviewer who is from a different institution than the *Pull Request* initiator (either from *Apple* or an external write-access contributor).

An exception to this rule are *Pull Requests* which have been received one *Approve* review by a write-access contributor from a different organization than the initiator, and have remained inactive for five business days since the *Approval* was received (comments count as activity and invalidate this exception).

If you start reviewing a *Pull Request*, please label it as `In Review` and comment on the *Pull Request* stating so, so other contributors are aware that you will be looking into it.


### Reviewing Pull Requests

This section provides some guidance when reviewing Pull Requests from other contributors.

#### 1. Be Thorough

Reviewing contributions is an important task, so try to be thorough.

Always be polite, but don't be afraid to be too nit-picking or to annoy contributors by requesting changes. The code base will benefit from simplicity, correctness and homogeneity in any new code.   

#### 2. Check the ResearchKit Coding Style Guide

Make sure all Pull Requests follow the [*ResearchKit Coding Style Guide*](https://github.com/ResearchKit/ResearchKit/blob/master/docs-standalone/coding-style-guide.md).

Verify that the code is coherent with the existing codebase. Make sure that new APIs follow *ResearchKit* and *UIKit* patterns and conventions.

#### 3. Test new code

Before approving a Pull Request, make sure to test the submitted code.

If the *Pull Request* adds new functionality, try to test it as thoroughly as possible. Compare it to similar *ResearchKit* or *iOS* functionality, and try to think ways it could be more consistent or more simple. Request example tasks in `ORKCatalog` or `ORKTest` if you feel they do not cover all use cases.

If the Pull Request fixes an issue, verify that the issue is no longer present. Think of edge cases. For visual issues, try to test it on as many screen sizes as possible using the *iPhone and iPad Simulators*.

#### 4. A partial review is better than no review

If you feel you have valuable feedback on any *Pull Request*, don't be afraid to share your comments.

If you feel you can partially review a *Pull Request*, review what you can and request additional help.

Apple doesn't want to discourage anybody from contributing to *ResearchKit*, no matter their experience level.

Don't be discouraged by these guidelines!


### Editing Issues

This section contains some light guidance for editing *Issues*.

#### 1. Clarifying Issues

If you see a new, unlabeled issue, try to label it appropriately.

If you feel that you can clarify or provide more information on an *Issue*, please comment on it.

#### 2. Linking Issues

If you see an *Issue* which has a related *Pull Request* but they are not linked, comment on the *Issue* with a link to the *Pull Request* or vice versa so they're visibly linked.

#### 3. Closing Issues

If you feel that an *Issue* can be closed, verify that the problem is gone before doing so.

Do not close unresolved issues solely due to inactivity.

---

*Apple* and the whole *ResearchKit* community is grateful for your contributions.
