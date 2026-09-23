# ORKCatalog

*ORKCatalog* is a sample app that demonstrates the types of elements you can use to
present tasks using the *ResearchKit framework*, such as *surveys*, *onboarding flows*, and *active tasks*.

*ORKCatalog* shows you how to:

+ Use the ResearchKit framework model elements to construct a task.
+ Present a task view controller.
+ Handle the delegate callbacks from the task view controller.


*ORKCatalog* also shows you how to access the structure of the results collected by
an `ORKTaskViewController` instance, which are displayed in the Results tab. To see
the results collected by a task, start the app, perform a task, and tap the Results
tab to view the result tree. Note that the result view is included solely for the
purpose of demonstrating how to access the properties of `ORKResult`
instances; for that reason, none of its content is localized. A shipping ResearchKit
app does not expose raw results to users in this form.

The *ORKCatalog* sample app is written in *Swift*.

For more information about the *ResearchKit framework*, set ResearchKit as your
target in Xcode and select Build Documentation from the Product menu.


## Build Requirements

+ Xcode 16.0 or later.
+ iOS 17.2 SDK or later.


## Runtime Requirements

+ iOS 17.2 or later.


## Using the Sample

You can run *ORKCatalog* on an *iOS device* or in the *iOS Simulator*.

Tasks are subdivided into the following categories:

- *Surveys* — multi-step survey flows, including forms and grouped forms.
- *Survey Questions* — individual question step types (boolean, date, scale, text choice, etc.).
- *Onboarding* — account creation, login, passcode, biometric passcode, consent, and review flows.
- *Miscellaneous* — image and video capture, PDF viewer, web view, USDZ model, and other utility steps.
- *Active Tasks* — sensor-driven tasks such as gait, audiometry, reaction time, and cognitive assessments.
- *Health* — HealthKit quantity questions (available when built with `ORK_FEATURE_HEALTHKIT_AUTHORIZATION`).
- *Location* — location question (available when built with `ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION`).

Each category presents examples in alphabetical order.

The `TaskListRow` enum uses a consistent ordering throughout the project. Within each
section, enum cases are ordered alphabetically, and the task list displays them in the
same order. This makes it straightforward to navigate between the enum definition and
the corresponding task setup code.
