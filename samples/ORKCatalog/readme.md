# ORKCatalog

*ORKCatalog* is a sample app that demonstrates the types of elements you can use to
present tasks using the *ResearchKit framework*, such as *surveys*, *consent tasks*, and *active tasks*.

*ORKCatalog* shows you how to:

+ Use the ResearchKit framework model elements to construct a task.
+ Present a task view controller.
+ Handle the delegate callbacks from the task view controller. 

Note that the task list view controller (`TaskListViewController`) uses the
`NSLocalizedString()` function to present all content, which makes it easy for
you to localize.

ORKCatalog also shows you how to access the structure of the results collected by 
an `ORKTaskViewController` instance, which are displayed in a result view controller
(`ResultViewController`). To see the results collected by a task, start the app,
perform a task, and tap the Results tab to view the result hierarchy. Note that
this result view controller is included solely for the purpose of demonstrating
how to access the properties and methods of `ORKResult` instances; for that reason,
none of the content in the result view controller is localized. A shipping ResearchKit
app does not expose the content in a result view controller to users.

The *ORKCatalog* sample app is written in *Swift*.

For more conceptual information about the *ResearchKit framework*, see the
[ResearchKit Framework Programming Guide](http://researchkit.github.io/docs/docs/Overview/GuideOverview.html).


## Build Requirements

+ Xcode 7.0.
+ iOS 9.0 SDK or later.


## Runtime Requirements

+ iOS 8.0 or later.


## Architecture

*ORKCatalog* functionality is divided into two main parts:

1) Presenting tasks to the user.

The logic for presenting tasks is in `TaskListViewController` and `TaskListRow`.
`TaskListRow` is an enumeration of all the different types of tasks that *ORKCatalog*
demonstrates. This enum also contains all of the logic for creating an `ORKTask` 
representation of the `TaskListRow`. For example, if you have a `TaskListRow.TimeOfDayQuestion`
instance, accessing the `representedTask` property returns an `ORKOrderedTask`
instance that contains an `ORKQuestionStep` that uses a date / time answer format
(`ORKAnswerFormat.dateTimeAnswerFormat()`).

2) Displaying results of the most recently presented task.

Results are displayed inside a `ResultViewController`. The result view controller
contains a `result` property that is set in the app delegate when the `TaskListViewController`
presents a task. Even if the user does not complete a task, the result is displayed
in the result view controller (in the case of an unfinished task, the result view
controller displays the parts of the task that the user has completed).

The logic to present a specific task (that is, the result view controller's data
source and delegate) is defined in *ResultTableViewProviders.swift*. Each type of
result that's displayed in the `ResultViewController` has an associated `ResultTableViewProvider`
subclass. For example, when displaying the metadata of an `ORKChoiceQuestionResult`
instance, a `ChoiceQuestionResultTableViewProvider` is used. Each table view provider
returns more specific information about the type of task that it presents.

Results are also displayed in a hierarchy. If a result has children, you can view
the metadata by tapping the child's table view cell. When you do this, you're
presented with another `ResultViewController` instance that displays the metadata
for that specific child result.


## Using the Sample

You can run *ORKCatalog* on an *iOS device* or in the *iOS Simulator*.

Tasks are subdivided into four categories: *Surveys*, *Survey Questions*, *Consent*,
and *Active Tasks*. Each category mostly presents the examples in an alphabetically-ordered
fashion.

Note that for the most part, the *ORKCatalog* source code uses a consistent ordering
for the boilerplate code throughout the project. Within the `TaskListRow` enum potion
corresponding to the *Survey Question* section, for example, grouped sections of code always
handle the `.BooleanQuestion` case first, and the task that represents the `.BooleanQuestion`
enum is displayed first in the `TaskListViewController`. This ordering makes it easy to navigate
the sample. 

As much as possible, this ordering is also maintained in the `TaskListRow` and
`ResultTableViewProvider` code. For example, in the `resultTableViewProviderForResult()`
function, the `ORKBooleanQuestionResult` case is handled first to match the order
that is used in the `TaskListRow` enum.
 
If you want to add functionality that needs to integrate with the `TaskListRow`
or `ResultTableViewProvider` code, be sure to consider the ordering.
