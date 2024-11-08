![ResearchKit](https://github.com/user-attachments/assets/0384c1a6-ec67-45d3-be68-136a2e4cacff)

ResearchKit Framework
===========

> [!NOTE]  
> This repository is a [StanfordBDHG](https://github.com/StanfordBDHG) fork of the [ResearchKit project](https://github.com/ResearchKit/ResearchKit) by Apple, adding support for:
> - The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) by building ResearchKit to an [XCFramework](https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle) via GitHub Actions and exposing the built XCFramework as a SPM binary target to speed up build times of projects / packages consuming our ResearchKit fork.
> - SwiftUI support to easily interact with the `ORKTaskViewController` using the [`ORKOrderedTaskView`](https://swiftpackageindex.com/stanfordbdhg/researchkit/documentation/researchkitswiftui/orkorderedtaskview).
> - Building ResearchKit with enabled [Swift's C++ Interoperability](https://www.swift.org/documentation/cxx-interop/), requiring minor code adjustments (not additive) to the ResearchKit codebase.
> - Building ResearchKit natively on [visionOS to run on Apple Vision Pro](https://developer.apple.com/visionos/).

[![Create XCFramework and Release](https://github.com/StanfordBDHG/ResearchKit/actions/workflows/release.yml/badge.svg)](https://github.com/StanfordBDHG/ResearchKit/actions/workflows/release.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordBDHG%2FResearchKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordBDHG/ResearchKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordBDHG%2FResearchKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordBDHG/ResearchKit)
[![License](https://img.shields.io/badge/license-BSD-green.svg?style=flat)](https://github.com/ResearchKit/ResearchKit#license)


The *ResearchKit™ framework* is an open source software framework that makes it easy to create apps
for medical research or for other research projects.

# Table of Contents

* [Requirements](#requirements)
* [Documentation](#documentation)
* [Getting Started](#gettingstarted)
	* [Installing](#installation)
	* [ORKCatalog App](#orkcatalog-app)
* [Surveys](#surveys)
* [Consent](#consent)
* [Active Tasks](#active-tasks)
* [Getting Help](#getting-help)
* [License](#license)

# Requirements <a name="requirements"></a>

The *ResearchKit framework* codebase supports iOS and requires Xcode 12.0 or newer. The *ResearchKit framework* has a Base SDK version of 13.0.

# Documentation <a name="documentation"></a>

<img width="1000" alt="ebedded-framework" src="https://github.com/ResearchKit/ResearchKit/assets/29615893/19d6edd3-3d95-4416-9ac4-24ccb35e09c2">

View the *ResearchKit framework* documentation by setting ResearchKit as your target in Xcode and selecting 'Build Documentation' in the Product menu dropdown.


# Getting Started <a name="gettingstarted"></a>

* [Website](https://www.researchandcare.org)
* [WWDC: ResearchKit and CareKit Reimagined](https://developer.apple.com/videos/play/wwdc2019/217/)


### Installation<a name="installation"></a>

Follow the article about [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) using the following repository URL: `https://github.com/StanfordBDHG/ResearchKit`.

### ORKCatalog App <a name="orkcatalog-app"></a>

The included catalog app demonstrates the different modules that are available in *ResearchKit*. Find the
project in ResearchKit's [`samples`](samples) directory.

|   |   |
|---|---|
| ![catalog-home](https://github.com/ResearchKit/ResearchKit/assets/29615893/45357cf8-17bf-4f38-aebc-bdf1c3395eb5) | ![catalog-survey](https://github.com/ResearchKit/ResearchKit/assets/29615893/a850f20b-7a05-4d14-bc2d-2d6dab7af30d) |

# Surveys <a name="surveys"></a>

The *ResearchKit framework* provides a pre-built user interface for surveys, which can be presented
modally on an *iPhone* or *iPad*. The example below shows the process to present a height question for a participant to answer.

```swift
import ResearchKit
import ResearchKitUI
    
let sectionHeaderFormItem = ORKFormItem(sectionTitle: "Your question here.")

let heightQuestionFormItem = ORKFormItem(identifier: "heightQuestionFormItem1", text: nil, answerFormat: ORKAnswerFormat.heightAnswerFormat())
heightQuestionFormItem.placeholder = "Tap here"

let formStep = ORKFormStep(identifier: "HeightQuestionIdentifier", title: "Height", text: "Local system")
formStep.formItems = [sectionHeaderFormItem, heightQuestionFormItem]

return formStep
```

The height question is presented in the figure below.

|   |   |
|---|---|
| ![height-question](https://github.com/ResearchKit/ResearchKit/assets/29615893/4f425329-83b7-45c3-84f9-58cdbcaf2529) | ![height-question-2](https://github.com/ResearchKit/ResearchKit/assets/29615893/2cc0dc2c-5c2a-4b50-a4be-834363fb64b5) |

### ResearchKit SwiftUI 

We are excited to announce the release of a new beta API for surveys in ResearchKit. This API is designed to enhance the flexibility, customization, and cross-platform compatibility of surveys in your ResearchKit apps. Below are the key features and usage details.

New Form APIs offer an easily configurable and flexible UI, with the same look and feel of `ORKFormStep`: 
* `ResearchForm`
    * Manages the navigation between steps in a survey.
* `ResearchFormStep`
    *  Represents a step in a survey and lays out the header and questions on one page. Question numbers (e.g. 1 of 3) are automatically added at the top of each question to denote progress in a step.
* `ResearchFormCompletion`
    * Represents the context for a survey's completion
* `ResearchFormResult`
    * Represents responses for the different kinds of questions.
* `StepHeader`
    * A step header containing an image, title, and subtitle.
* `QuestionHeader`
    * A question header containing a title and detail.
* `InstructionBodyItem`
    * Displays an image and text side by side.
* `questionRequired` (`ViewModifier`)
    * Designates a question as required or optional.

#### Survey Question Types:
* `MultipleChoiceQuestion`
* `HeightQuestion`
* `WeightQuestion`
* `SliderQuestion`
* `TextQuestion`
* `DateTimeQuestion`
* `NumericQuestion`
* `ImageChoiceQuestion`    

The example below shows how to create a `ResearchForm` to present a text question for the participant to answer, and then save their results. 

```swift
import ResearchKitSwiftUI

ResearchForm(
    id: "SurveyTask",
    steps: {
        ResearchFormStep(
            title: "Demographics",
            subtitle: "Tell us about yourself",
            content: {
                TextQuestion(
                    id: "textQuestion",
                    title: "What is your name?",
                    prompt: "Enter your name here",
                    lineLimit: .singleLine,
                    characterLimit: 0
                )
                .questionRequired(true)
            }
        )
    },
    onResearchFormCompletion: { completion in
        switch completion {
        case .completed(let results):
            save(results)
        case .discarded:
            cancel()
        default:
            cancel()
        }
    }
)
```

#### Install as an embedded framework

Download the project source code and drag in the *ResearchKitSwiftUI* folder. In the dialog that pops up, choose to copy files to destination and create folders. Then hit the finish button. Finally, embed the *ResearchKitSwiftUI* framework in your app by adding it to the "Frameworks, Libraries, and Embedded Content" section for your target.

# Consent <a name="consent"></a>

The *ResearchKit framework* provides classes that you can customize to explain the
details of your research study and obtain a signature if needed. Use *ResearchKit's* provided classes to quickly welcome, and inform your participants of what the study entails.

```swift
import ResearchKit
import ResearchKitUI

// Welcome page.
let welcomeStep = ORKInstructionStep(identifier: String(describing: Identifier.consentWelcomeInstructionStep))
welcomeStep.iconImage = UIImage(systemName: "hand.wave")
welcomeStep.title = "Welcome!"
welcomeStep.detailText = "Thank you for joining our study. Tap Next to learn more before signing up."
        
// Before You Join page.
let beforeYouJoinStep = ORKInstructionStep(identifier: String(describing: Identifier.informedConsentInstructionStep))
beforeYouJoinStep.iconImage = UIImage(systemName: "doc.text.magnifyingglass")
beforeYouJoinStep.title = "Before You Join"
        
let sharingHealthDataBodyItem = ORKBodyItem(text: "The study will ask you to share some of your Health data.",
                                            detailText: nil,
                                            image: UIImage(systemName: "heart.fill"),
                                            learnMoreItem: nil,
                                            bodyItemStyle: .image)
        
let completingTasksBodyItem = ORKBodyItem(text: "You will be asked to complete various tasks over the duration of the study.",
                                          detailText: nil,
                                          image: UIImage(systemName: "checkmark.circle.fill"),
                                          learnMoreItem: nil,
                                          bodyItemStyle: .image)
        
let signatureBodyItem = ORKBodyItem(text: "Before joining, we will ask you to sign an informed consent document.",
                                    detailText: nil,
                                    image: UIImage(systemName: "signature"),
                                    learnMoreItem: nil,
                                    bodyItemStyle: .image)
        
let secureDataBodyItem = ORKBodyItem(text: "Your data is kept private and secure.",
                                     detailText: nil,
                                     image: UIImage(systemName: "lock.fill"),
                                     learnMoreItem: nil,
                                     bodyItemStyle: .image)
        
beforeYouJoinStep.bodyItems = [
    sharingHealthDataBodyItem,
    completingTasksBodyItem,
    signatureBodyItem,
    secureDataBodyItem
]
```
The consent steps are presented in the figure below.

|   |   |
|---|---|
| ![consent-welcome-page](https://github.com/ResearchKit/ResearchKit/assets/29615893/e6cbbe07-47ed-4bb4-a84a-f3bf612e9122) | ![consent-before-you-join](https://github.com/ResearchKit/ResearchKit/assets/29615893/687fe345-14d9-4356-9c37-c6a2714875ae) |

Vist the `Obtaining Consent`article in ResearchKit's Documentation for
more examples that include signature collection and PDF file storage.

# Active Tasks <a name="active-tasks"></a>

Some studies may need data beyond survey questions or the passive data collection capabilities
available through use of the *HealthKit* and *CoreMotion* APIs if you are programming for *iOS*.
*ResearchKit*'s active tasks invite users to perform activities under semi-controlled conditions,
while *iPhone* sensors actively collect data.
ResearchKit active tasks are not diagnostic tools nor medical devices of any kind and output from those active tasks may not be used for diagnosis. Developers and researchers are responsible for complying with all applicable laws and regulations with respect to further development and use of the active tasks.

Use predefined tasks provided by *ResearchKit* to guide your participants through specific actions.

```swift
import ResearchKit
import ResearchKitUI
import ResearchKitActiveTask

let orderedTask = ORKOrderedTask.dBHLToneAudiometryTask(withIdentifier: "dBHLToneAudiometryTaskIdentifier",
							intendedUseDescription: nil, options: [])
							
let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
taskViewController.delegate = self

present(taskViewController, animated: true)
```
The dBHL Tone Audiometry task is presented in the figure below.

|   |   |
|---|---|
| ![noise-check](https://github.com/ResearchKit/ResearchKit/assets/29615893/d8fb669c-bb60-482d-9a2d-e5b6b6696aa5) | ![dbhl-tone-test](https://github.com/ResearchKit/ResearchKit/assets/29615893/04df862b-46bc-4749-8c3e-02d2e54dbcbf) |

# Getting Help <a name="getting-help"></a>

GitHub is our primary forum for ResearchKit. Feel free to open up issues about questions, problems, or ideas.

# License <a name="license"></a>

This project is made available under the terms of a BSD license. See the [LICENSE](LICENSE) file.
