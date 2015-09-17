# ORKTest

The `ORKTest` project is an Objective-C test-bed used by the ResearchKit™ framework
developers to test API features during development. When adding a new
feature to the ResearchKit framework, please either add a way to test it in this
`ORKTest` project, or consider creating a new project to use for
testing. We also use this project to check for regressions.

This project is not intended as an example of best practice in use of
the ResearchKit framework. For that, see the samples directory or the documentation
instead.

Instead, this project should give good coverage of the features in
the ResearchKit framework. For example, the project enables localization to all the
supported languages, even though the survey content is not itself
localized. This allows us to test the localized parts of the ResearchKit framework,
but is not something you should do in a real app. As another example,
rotation is enabled on the iPhone, even though in real use it would be
atypical to enable rotation for most steps.

The `ORKTest` tests include a module called `ORKESerialization`, a
JSON serialization module for the ResearchKit framework. `ORKESerialization` can
serialize and deserialize all the ResearchKit framework model objects, and all
ResearchKit framework results, to and from JSON.


## Build Requirements

+ Xcode 7.0
+ iOS 9.0 SDK or later


## Runtime Requirements

+ iOS 8.0 or later


## Using the App

You can run `ORKTest` on a device or in the iOS Simulator.

To run on device, you will need to use a provisioning profile that
includes the appropriate HealthKit entitlement.

When launching `ORKTest`, you will see an array of buttons. Each
button corresponds to a task that can be used for testing. Information
on the results and progress of the task are logged to the console.

