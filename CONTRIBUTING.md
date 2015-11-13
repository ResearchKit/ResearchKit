Contributing to the ResearchKit Framework
===========================

This page focuses on code contributions to the existing
codebase. However, other types of contributions are welcome too, in
keeping with the ResearchKit™ framework [best practices](../../wiki/best-practices). For example,
contributions of original free-to-use survey content, back-end integrations,
validation data, and analysis or processing tools are all welcome. Ask
on [researchkit-dev](https://lists.apple.com/mailman/listinfo/researchkit-dev) or [contact us](https://developer.apple.com/contact/researchkit/) for guidance.


Contributing software
---------------------

This page assumes you already know how to check out and build the
code. Contributions to the ResearchKit framework are expected to comply with the
[ResearchKit Contribution Terms and License Policy](#contribution); please familiarize yourself
with this policy prior to submitting a pull request. For any contribution, ensure that you own
the rights or have permission from the copyright holder.  (e.g. code, images, surveys, videos
and other content you may include)

To contribute to ResearchKit:

1. [Choose or create an issue to work on.](#create)
2. [Create a personal fork of the ResearchKit framework.](#fork)
3. [Develop your changes in your fork.](#develop)
4. [Run the tests.](#test)
5. [Submit a pull request.](#request)
6. Make any changes requested by the reviewer, and update your pull request as needed.
7. Once accepted, your pull request will be merged into master.

Choosing an issue to work on<a name="create"></a>
----------------------------

To find an issue to work on, either pick something that you need for
your app, or select one of the issues from our [issue list](../../issues). Or,
consider one of the areas where we'd like to extend ResearchKit:

* Faster 'get started' to a useful app
* More active tasks
* Data analysis for active tasks
* More consent sections
* Back end integrations

If in doubt, bring your idea up on [researchkit-dev](https://lists.apple.com/mailman/listinfo/researchkit-dev).


Creating a personal fork<a name="fork"></a>
------------------------

On GitHub, it's easy to create a personal fork. Just tap the "Fork"
button on the top right, and clone your new repository.


Develop your changes in your fork<a name="develop"></a>
---------------------------------

Develop your changes using your normal development process. If you
already have code from an existing project, you may need to adjust its
style to more closely match the [ResearchKit framework coding style](./docs-standalone/coding-style-guide.md).

New components may need to expose new Public or Private
headers. Public headers are for APIs that are likely to be a stable
part of the interface of the ResearchKit framework. Private headers are for APIs that
may need to be accessed from app-side unit tests, or that are more
subject to change than the public interface. All other headers should
be internal, "Project" headers.

Please review and ensure that any contributions you make comply with
the [ResearchKit Contribution Terms and License Policy](#contribution).

Add automated tests for your feature, where it is possible to do
so. For UI driven components where it is harder to write automated
tests, add UI to at least one test application so that the new
features can be reviewed and tested. Consider also whether to add new
code to other existing demo apps to exercise your feature.

When adding UI driven components, make sure that they are accessible. 
Follow the steps outlined in the [Best Practices](../../wiki/best-practices) 
section under Accessibility. Before submitting the pull request, you should 
audit your components with Voice Over (or other relevant assistive technologies) 
enabled.

Keep changes that fix different issues separate. For bug fixes,
separate bugs should be submitted as separate pull requests. A good
way to do this is to create a new branch in your fork for each new
bug work on.

Any new user-visible strings should be included in the English
`ResearchKit.strings` table so that they can be picked up and
localized in the next release cycle.


Run the tests<a name="test"></a>
-------------

All unit tests should pass, and there should be no warnings. Also
verify that test apps run on both device and simulator.

Where your code affects UI presentation, also test:

* Multiple device form factors (for instance, iPhone 4S, iPhone 5, iPhone 6, iPhone 6 Plus).
* Dynamic text, especially at the "Large" setting.
* Rotation between portrait and landscape, where appropriate.

You can use the apps in the `Testing` and `samples` directories to
test your changes.

Submit a pull request<a name="request"></a>
---------------------

The reviewers may request changes. Make the changes, and update your
pull request as needed. Reviews will focus on coding style,
correctness, and design consistency.

This process does not take the place of an ethical review, for example
by an institutional review board (IRB) or ethics committee.

After acceptance<a name="after"></a>
----------------

Once your pull request has been accepted, your changes will be merged
to master. You are still responsible for your change after it is
accepted. Stay in contact, in case bugs are detected that may require
your attention.

When the project is next branched for release, your changes will be
incorporated. Queries may come back to you regarding localization,
documentation, or other issues during this process.




Release process
-----------------

The `master` branch is used for work in progress. On `master`:

* All test apps should build and run error free.
* Unit tests should all pass.
* Everything should be continuously in working order in English (the
  base language).

  The project will make periodic releases. When preparing a stable release, we
  will branch from `master` to a convergence branch. During this process,
  changes will be made first to the convergence branch, and then merged into
  `master`. On the convergence branch, changes will be made only to:

  * Fix high priority issues.
  * Update documentation.
  * Bring localization up to date.
  * Ensure good behavior across all supported devices.

  After the converging process is completed, we will merge everything to the
  `stable` branch and tag with a new release number. The most recent release
  will be highlighted in the [README](../..). 


  ResearchKit Contribution Terms and License Policy<a name="contribution"></a>
  =======================================

  Thank you for your interest in contributing to the ResearchKit
  community.  In order to maintain consistency and license compatibility
  throughout the project, all contributions must comply with our
  licensing policy and terms for contributing code to the ResearchKit
  project:

  1.  If you are submitting a patch to the existing codebase, you
  represent that you have the right to license the patch, including 
  all code and content, to Apple and the community, and agree by 
  submitting the patch that your changes are
  licensed under the existing license terms of the file you are
  modifying (i.e., [ResearchKit BSD license](LICENSE)).
  You confirm that you have added your copyright (name and year) to 
  the relevant files for changes that are more than 10 lines of code.
  2.  If you are submitting a new file for inclusion in the ResearchKit 
  framework (no code or other content is copied from another source), you 
  have included your copyright (name and year) and a copy of the ResearchKit 
  BSD license. By submitting your new file you represent that you have the 
  right to license your file to Apple and the community, and agree that your 
  file submission is licensed under the ResearchKit BSD license.
  3.  If you aren't the author of the patch, you agree that you have 
  the right to submit the patch, and have included the original copyright 
  notices and licensing terms with it, to the extent that they exist. 
  If there wasn't a copyright notice or license, please make a note of it 
  in your response. Generally we can only take in patches that are 
  BSD-licensed in order to maintain license compatibility within the project.
