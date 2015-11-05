ResearchKit Framework
===========

The ResearchKit™ framework is an open source software framework that makes it easy to
create apps for medical research or for other research projects.

* [Getting Started](#gettingstarted)
* Documentation:
    * [Programming Guide](http://researchkit.org/docs/docs/Overview/GuideOverview.html)
    *  [Framework Reference](http://researchkit.org/docs/index.html)
* [Best Practices](../../wiki/best-practices)
* [Contributing to ResearchKit](CONTRIBUTING.md)
* [Website](http://researchkit.org) and [Blog](http://researchkit.org/blog.html)
* [ResearchKit BSD License](#license)

Getting More Information
========================

* Join the [ResearchKit Forum](https://forums.developer.apple.com/community/researchkit) for discussing uses of the ResearchKit framework and related projects.

Use Cases
===========

A task in the ResearchKit framework contains a set of steps to present to a
user. Everything, whether it’s a survey, the consent process, or active tasks,
is represented as a task that can be presented with a task view controller.

Surveys
-------

The ResearchKit framework provides a pre-built user interface for surveys, which can be
presented modally on an iPhone, iPod Touch, or iPad. See  *[Creating Surveys](http://researchkit.org/docs/docs/Survey/CreatingSurveys.html)* for more information.


Consent
----------------

The ResearchKit framework provides visual consent templates that you can customize to
explain the details of your research study and obtain a signature if needed.  See *[Obtaining Consent](http://researchkit.org/docs/docs/InformedConsent/InformedConsent.html)* for more information.


Active Tasks
------------

Some studies may need data beyond survey questions or the passive data collection
capabilities available through use of the HealthKit and CoreMotion APIs if you are
programming for iOS. ResearchKit's active tasks invite users to perform activities
under semi-controlled conditions, while iPhone sensors actively collect data.  See *[Active Tasks](http://researchkit.org/docs/docs/ActiveTasks/ActiveTasks.html)* for more information.


Getting Started<a name="gettingstarted"></a>
===============


Requirements
------------

The primary ResearchKit framework codebase supports iOS and requires Xcode 7.0
or newer.
The ResearchKit framework has a Base SDK version of 8.0, meaning that apps
using the ResearchKit framework can run on devices with iOS 8.0 or newer.


Installation
------------

The latest stable version of ResearchKit framework can be cloned with

```
git clone -b stable https://github.com/ResearchKit/ResearchKit.git
```

Or, for the latest changes, use the `master` branch:

```
git clone https://github.com/ResearchKit/ResearchKit.git
```

Building
--------

Build the ResearchKit framework by opening `ResearchKit.xcodeproj` and running the
`ResearchKit` framework target. Optionally, run the unit tests too.


Adding the ResearchKit framework to your App
------------------------------

This walk-through shows how to embed the ResearchKit framework in your app as a
dynamic framework, and present a simple task view controller.

###1. Add the ResearchKit framework to Your Project

To get started, drag `ResearchKit.xcodeproj` from your checkout into
your iOS app project in Xcode:

<center>
<figure>
  <img src="../../wiki/AddingResearchKitXcode.png" alt="Adding the ResearchKit framework to your project" align="middle"/>
</figure>
</center>

Then, embed the ResearchKit framework as a dynamic framework in your app, by adding
it to the Embedded Binaries section of the General pane for your
target as shown in the figure below.

<center>
<figure>
  <img src="../../wiki/AddedBinaries.png" width="100%" alt="Adding the ResearchKit framework to Embedded Binaries" align="middle"/>
   <figcaption><center>Adding the ResearchKit framework to Embedded Binaries</center></figcaption>
</figure>
</center>

Note: You can also import ResearchKit into your project using a [dependency manager](./docs-standalone/dependency-management.md) such as CocoaPods or Carthage.

###2. Create a Step

In this walk-through, we will use the ResearchKit framework to modally present a
simple single-step task showing a single instruction.

Create a step for your task by adding some code, perhaps in
`viewDidAppear:` of an existing view controller. To keep things
simple, we'll use an instruction step (`ORKInstructionStep`) and name
the step `myStep`.

*Objective-C*

```objc
ORKInstructionStep *myStep =
  [[ORKInstructionStep alloc] initWithIdentifier:@"intro"];
myStep.title = @"Welcome to ResearchKit";
```

*Swift*

```swift
let myStep = ORKInstructionStep(identifier: "intro")
myStep.title = "Welcome to ResearchKit"
```

###3. Create a Task

Use the ordered task class (`ORKOrderedTask`) to create a task that
contains `myStep`. An ordered task is just a task where the order and
selection of later steps does not depend on the results of earlier
ones. Name your task `task` and initialize it with `myStep`.

*Objective-C*

```objc
ORKOrderedTask *task =
  [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[myStep]];
```

*Swift*

```swift
let task = ORKOrderedTask(identifier: "task", steps: [myStep])
```

###4. Present the Task

Create a task view controller (`ORKTaskViewController`) and initialize
it with your `task`. A task view controller manages a task and collects the
results of each step. In this case, your task view
controller simply displays your instruction step.

*Objective-C*

```objc
ORKTaskViewController *taskViewController =
  [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
taskViewController.delegate = self;
[self presentViewController:taskViewController animated:YES completion:nil];
```

*Swift*

```swift
let taskViewController = ORKTaskViewController(task: task, taskRunUUID: nil)
taskViewController.delegate = self
presentViewController(taskViewController, animated: true, completion: nil)
```

The above snippet assumes that your class implements the
`ORKTaskViewControllerDelegate` protocol. This has just one required method,
which you must implement in order to handle the completion of the task:

*Objective-C*

```objc
- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {

    ORKTaskResult *taskResult = [taskViewController result];
    // You could do something with the result here.

    // Then, dismiss the task view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}
```

*Swift*

```swift
func taskViewController(taskViewController: ORKTaskViewController,
                didFinishWithReason reason: ORKTaskViewControllerFinishReason,
                                     error: NSError?) {
  let taskResult = taskViewController.result
  // You could do something with the result here.

  // Then, dismiss the task view controller.
  dismissViewControllerAnimated(true, completion: nil)
}
```


If you now run your app, you should see your first ResearchKit framework
instruction step:

<center>
<figure>
  <img src="../../wiki/HelloWorld.png" width="50%" alt="HelloWorld example screenshot" align="middle"/>
</figure>
</center>



What else can the ResearchKit framework do?
-----------------------------

The ResearchKit [`ORKCatalog`](samples/ORKCatalog) sample app is a
good place to start. Find the project in ResearchKit's
[`samples`](samples) directory. This project includes a list of all
the types of steps supported by the ResearchKit framework in one tab, and displays a
browser for the results of the last completed task in the other tab.



License<a name="license"></a>
=======

The source in the ResearchKit repository is made available under the
following license unless another license is explicitly identified:

```
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
