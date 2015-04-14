The ResearchKit™ framework is an open source framework that developers and researchers can use to create apps that let iOS users participate in medical research.

This is the API documentation for the ResearchKit framework. For an overview of framework and a more general guide to using and extending the framework, see the [Programming Guide](GuideOverview).


Constructing Tasks
--------------------

ResearchKit tasks are actions to be performed by participants in a research study. Tasks are the building blocks for ResearchKit modules, which address the most common components of medical studies: surveys, consent documents, and active tasks.

Tasks are constructed using a hierarchy of model objects.
At the root of the hierarchy is an ORKOrderedTask object (or another object that implements the ORKTask protocol). The task defines the order in which steps are presented, and how progress through the task is represented.

A task consists of steps, which are subclasses of ORKStep. Most steps are designed for data presentation or data entry, but the ORKActiveStep subclasses can also enable data collection.
The ORKQuestionStep and ORKFormStep survey step classes describe a question to be asked. The format of the answer is modeled with subclasses of ORKAnswerFormat.


Presenting Tasks
--------------------

To present a task, you create an ORKTaskViewController object and give it the task. The task view controller manages the task and returns the result through delegate methods.

For each step, ORKTaskViewController instantiates an appropriate subclass of ORKStepViewController to display the step.


Getting Results
--------------------

The `result` property of ORKTaskViewController provides the results of the task, both while the task is in progress, and upon completion of the task.

Results are constructed with a hierarchy that’s similar to the task model hierarchy. In the hierarchy for a result, ORKTaskResult is the root and ORKStepResult objects form the immediate children.

For survey question steps, the answers collected are reported as ORKQuestionResult objects, which are children of ORKStepResult. Active steps may include additional result objects as children, depending on the types of data that are recorded. To help you get data from various device features, such as the accelerometer or HealthKit, the ResearchKit framework provides the ORKRecorder and ORKRecorderConfiguration classes, which work together to collect and configure data into a serialized format during the duration of an active step.


Predefined Active Tasks
--------------------

An active task invites users to perform activities under semi-controlled conditions, while iPhone sensors actively collect data. A category on ORKOrderedTask provides factory methods for generating ORKOrderedTask instances that correspond to ResearchKit's predefined active tasks, such as the short walk or fitness task.


Consent
--------------------

The consent features in the ResearchKit framework are implemented using three special steps that can be added to tasks:

* ORKVisualConsentStep. The visual consent step presents a series of simple graphics to help participants understand the content of an consent document. The default graphics have animated transitions.

* ORKConsentSharingStep. The consent sharing step has predefined transitions that can be used to establish user preferences regarding how widely personal data can be shared.

* ORKConsentReviewStep. The consent review step makes the consent document available for review, and provides facilities for collecting the user's name and signature.

Creating the visual consent step and the consent review step requires a consent document model (that is, an ORKConsentDocument object).
