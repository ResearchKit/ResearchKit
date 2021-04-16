/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
 Copyright (c) 2017, Macro Yau.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
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
*/

import ResearchKit
import AudioToolbox

/**
    Wraps a SystemSoundID.

    A class is used in order to provide appropriate cleanup when the sound is
    no longer needed.
*/
class SystemSound {
    var soundID: SystemSoundID = 0
    
    init?(soundURL: URL) {
        if AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID) != noErr {
           return nil
        }
    }
    
    deinit {
        AudioServicesDisposeSystemSoundID(soundID)
    }
}

/**
    An enum that corresponds to a row displayed in a `TaskListViewController`.

    Each of the tasks is composed of one or more steps giving examples of the
    types of functionality supported by the ResearchKit framework.
*/
enum TaskListRow: Int, CustomStringConvertible {
    case form = 0
    case groupedForm
    case survey
    case booleanQuestion
    case customBooleanQuestion
    case dateQuestion
    case dateTimeQuestion
    case imageChoiceQuestion
    case locationQuestion
    case numericQuestion
    case scaleQuestion
    case textQuestion
    case textChoiceQuestion
    case timeIntervalQuestion
    case timeOfDayQuestion
    case valuePickerChoiceQuestion
    case validatedTextQuestion
    case imageCapture
    case videoCapture
    case frontFacingCamera
    case wait
    case PDFViewer
    case requestPermissions
    case eligibilityTask
    case consent
    case accountCreation
    case login
    case passcode
    case audio
    case amslerGrid
    case fitness
    case holePegTest
    case psat
    case reactionTime
    case shortWalk
    case spatialSpanMemory
    case speechRecognition
    case speechInNoise
    case stroop
    case swiftStroop
    case timedWalkWithTurnAround
    case toneAudiometry
    case dBHLToneAudiometry
    case splMeter
    case towerOfHanoi
    case tremorTest
    case twoFingerTappingInterval
    case walkBackAndForth
    case heightQuestion
    case weightQuestion
    case kneeRangeOfMotion
    case shoulderRangeOfMotion
    case trailMaking
    case visualAcuityLandoltC
    case contrastSensitivityPeakLandoltC
    case videoInstruction
    case webView
    
    class TaskListRowSection {
        var title: String
        var rows: [TaskListRow]
        
        init(title: String, rows: [TaskListRow]) {
            self.title = title
            self.rows = rows
        }
    }
    
    /// Returns an array of all the task list row enum cases.
    static var sections: [ TaskListRowSection ] {
        
        return [
            TaskListRowSection(title: "Surveys", rows:
                [
                    .form,
                    .groupedForm,
                    .survey
                ]),
            TaskListRowSection(title: "Survey Questions", rows:
                [
                    .booleanQuestion,
                    .customBooleanQuestion,
                    .dateQuestion,
                    .dateTimeQuestion,
                    .heightQuestion,
                    .weightQuestion,
                    .imageChoiceQuestion,
                    .locationQuestion,
                    .numericQuestion,
                    .scaleQuestion,
                    .textQuestion,
                    .textChoiceQuestion,
                    .timeIntervalQuestion,
                    .timeOfDayQuestion,
                    .valuePickerChoiceQuestion,
                    .validatedTextQuestion,
                    .imageCapture,
                    .videoCapture,
                    .frontFacingCamera,
                    .wait,
                    .PDFViewer,
                    .requestPermissions
                ]),
            TaskListRowSection(title: "Onboarding", rows:
                [
                    .eligibilityTask,
                    .consent,
                    .accountCreation,
                    .login,
                    .passcode
                ]),
            TaskListRowSection(title: "Active Tasks", rows:
                [
                    .audio,
                    .amslerGrid,
                    .fitness,
                    .holePegTest,
                    .psat,
                    .reactionTime,
                    .shortWalk,
                    .spatialSpanMemory,
                    .speechRecognition,
                    .speechInNoise,
                    .stroop,
                    .swiftStroop,
                    .timedWalkWithTurnAround,
                    .toneAudiometry,
                    .dBHLToneAudiometry,
                    .splMeter,
                    .towerOfHanoi,
                    .tremorTest,
                    .twoFingerTappingInterval,
                    .walkBackAndForth,
                    .kneeRangeOfMotion,
                    .shoulderRangeOfMotion,
                    .trailMaking,
                    .visualAcuityLandoltC,
                    .contrastSensitivityPeakLandoltC
                ]),
            TaskListRowSection(title: "Miscellaneous", rows:
                [
                    .videoInstruction,
                    .webView
                ])
        ]}
    
    // MARK: CustomStringConvertible
    
    var description: String {
        switch self {
        case .form:
            return NSLocalizedString("Form Survey Example", comment: "")
            
        case .groupedForm:
            return NSLocalizedString("Grouped Form Survey Example", comment: "")

        case .survey:
            return NSLocalizedString("Simple Survey Example", comment: "")
            
        case .booleanQuestion:
            return NSLocalizedString("Boolean Question", comment: "")
            
        case .customBooleanQuestion:
            return NSLocalizedString("Custom Boolean Question", comment: "")
            
        case .dateQuestion:
            return NSLocalizedString("Date Question", comment: "")
            
        case .dateTimeQuestion:
            return NSLocalizedString("Date and Time Question", comment: "")
            
        case .heightQuestion:
            return NSLocalizedString("Height Question", comment: "")
    
        case .weightQuestion:
            return NSLocalizedString("Weight Question", comment: "")
            
        case .imageChoiceQuestion:
            return NSLocalizedString("Image Choice Question", comment: "")
            
        case .locationQuestion:
            return NSLocalizedString("Location Question", comment: "")
            
        case .numericQuestion:
            return NSLocalizedString("Numeric Question", comment: "")
            
        case .scaleQuestion:
            return NSLocalizedString("Scale Question", comment: "")
            
        case .textQuestion:
            return NSLocalizedString("Text Question", comment: "")
            
        case .textChoiceQuestion:
            return NSLocalizedString("Text Choice Question", comment: "")
            
        case .timeIntervalQuestion:
            return NSLocalizedString("Time Interval Question", comment: "")
            
        case .timeOfDayQuestion:
            return NSLocalizedString("Time of Day Question", comment: "")
            
        case .valuePickerChoiceQuestion:
            return NSLocalizedString("Value Picker Choice Question", comment: "")
            
        case .validatedTextQuestion:
            return NSLocalizedString("Validated Text Question", comment: "")
            
        case .imageCapture:
            return NSLocalizedString("Image Capture Step", comment: "")
            
        case .videoCapture:
            return NSLocalizedString("Video Capture Step", comment: "")
            
        case .frontFacingCamera:
            return NSLocalizedString("Front Facing Camera Step", comment: "")
            
        case .wait:
            return NSLocalizedString("Wait Step", comment: "")
        
        case .PDFViewer:
            return NSLocalizedString("PDF Viewer Step", comment: "")
            
        case .requestPermissions:
            return NSLocalizedString("Request Permissions Step", comment: "")

        case .eligibilityTask:
            return NSLocalizedString("Eligibility Task Example", comment: "")
            
        case .consent:
            return NSLocalizedString("Consent-Obtaining Example", comment: "")

        case .accountCreation:
            return NSLocalizedString("Account Creation", comment: "")
        
        case .login:
            return NSLocalizedString("Login", comment: "")

        case .passcode:
            return NSLocalizedString("Passcode Creation", comment: "")
            
        case .audio:
            return NSLocalizedString("Audio", comment: "")
        
        case .amslerGrid:
            return NSLocalizedString("Amsler Grid", comment: "")
            
        case .fitness:
            return NSLocalizedString("Fitness Check", comment: "")
        
        case .holePegTest:
            return NSLocalizedString("Hole Peg Test", comment: "")
            
        case .psat:
            return NSLocalizedString("PSAT", comment: "")
            
        case .reactionTime:
            return NSLocalizedString("Reaction Time", comment: "")
            
        case .shortWalk:
            return NSLocalizedString("Short Walk", comment: "")
            
        case .spatialSpanMemory:
            return NSLocalizedString("Spatial Span Memory", comment: "")
            
        case .speechRecognition:
            return NSLocalizedString("Speech Recognition", comment: "")
            
        case .speechInNoise:
            return NSLocalizedString("Speech in Noise", comment: "")
            
        case .stroop:
            return NSLocalizedString("Stroop", comment: "")
            
        case .swiftStroop:
            return NSLocalizedString("Swift Stroop", comment: "")
            
        case .timedWalkWithTurnAround:
            return NSLocalizedString("Timed Walk with Turn Around", comment: "")
            
        case .toneAudiometry:
            return NSLocalizedString("Tone Audiometry", comment: "")
            
        case .dBHLToneAudiometry:
            return NSLocalizedString("dBHL Tone Audiometry", comment: "")
            
        case .splMeter:
            return NSLocalizedString("Environment SPL Meter", comment: "")
            
        case .towerOfHanoi:
            return NSLocalizedString("Tower of Hanoi", comment: "")

        case .twoFingerTappingInterval:
            return NSLocalizedString("Two Finger Tapping Interval", comment: "")
            
        case .walkBackAndForth:
            return NSLocalizedString("Walk Back and Forth", comment: "")
            
        case .tremorTest:
            return NSLocalizedString("Tremor Test", comment: "")
            
        case .videoInstruction:
            return NSLocalizedString("Video Instruction Task", comment: "")
            
        case .kneeRangeOfMotion:
            return NSLocalizedString("Knee Range of Motion", comment: "")
            
        case .shoulderRangeOfMotion:
            return NSLocalizedString("Shoulder Range of Motion", comment: "")
            
        case .trailMaking:
            return NSLocalizedString("Trail Making Test", comment: "")
            
        case .visualAcuityLandoltC:
            return NSLocalizedString("Visual Acuity Landolt C", comment: "")
            
        case .contrastSensitivityPeakLandoltC:
            return NSLocalizedString("Contrast Sensitivity Peak", comment: "")

        case .webView:
            return NSLocalizedString("Web View", comment: "")
        }
    }
    
    // MARK: Types

    /**
        Every step and task in the ResearchKit framework has to have an identifier.
        Within a task, the step identifiers should be unique.

        Here we use an enum to ensure that the identifiers are kept unique. Since
        the enum has a raw underlying type of a `String`, the compiler can determine
        the uniqueness of the case values at compile time.

        In a real application, the identifiers for your tasks and steps might
        come from a database, or in a smaller application, might have some
        human-readable meaning.
    */
    enum Identifier {
        // Task with a form, where multiple items appear on one page.
        case formTask
        case groupedFormTask
        case formStep
        case groupedFormStep
        case formItem01
        case formItem02
        case formItem03
        case formItem04

        // Survey task specific identifiers.
        case surveyTask
        case introStep
        case questionStep
        case birthdayQuestion
        case summaryStep
        
        // Task with a Boolean question.
        case booleanQuestionTask
        case booleanQuestionStep

        // Task with an example of date entry.
        case dateQuestionTask
        case dateQuestionStep
        
        // Task with an example of date and time entry.
        case dateTimeQuestionTask
        case dateTimeQuestionStep

        // Task with an example of height entry.
        case heightQuestionTask
        case heightQuestionStep1
        case heightQuestionStep2
        case heightQuestionStep3
        case heightQuestionStep4

        // Task with an example of weight entry.
        case weightQuestionTask
        case weightQuestionStep1
        case weightQuestionStep2
        case weightQuestionStep3
        case weightQuestionStep4
        case weightQuestionStep5
        case weightQuestionStep6
        case weightQuestionStep7
        
        // Task with an image choice question.
        case imageChoiceQuestionTask
        case imageChoiceQuestionStep1
        case imageChoiceQuestionStep2
        
        // Task with a location entry.
        case locationQuestionTask
        case locationQuestionStep
        
        // Task with examples of numeric questions.
        case numericQuestionTask
        case numericQuestionStep
        case numericNoUnitQuestionStep

        // Task with examples of questions with sliding scales.
        case scaleQuestionTask
        case discreteScaleQuestionStep
        case continuousScaleQuestionStep
        case discreteVerticalScaleQuestionStep
        case continuousVerticalScaleQuestionStep
        case textScaleQuestionStep
        case textVerticalScaleQuestionStep

        // Task with an example of free text entry.
        case textQuestionTask
        case textQuestionStep
        
        // Task with an example of a multiple choice question.
        case textChoiceQuestionTask
        case textChoiceQuestionStep

        // Task with an example of time of day entry.
        case timeOfDayQuestionTask
        case timeOfDayQuestionStep

        // Task with an example of time interval entry.
        case timeIntervalQuestionTask
        case timeIntervalQuestionStep

        // Task with a value picker.
        case valuePickerChoiceQuestionTask
        case valuePickerChoiceQuestionStep
        
        // Task with an example of validated text entry.
        case validatedTextQuestionTask
        case validatedTextQuestionStepEmail
        case validatedTextQuestionStepDomain
        
        // Image capture task specific identifiers.
        case imageCaptureTask
        case imageCaptureStep
        
        // Video capture task specific identifiers.
        case videoCaptureTask
        case videoCaptureStep
        
        case frontFacingCameraStep
        
        // Task with an example of waiting.
        case waitTask
        case waitStepDeterminate
        case waitStepIndeterminate
        
        case pdfViewerStep
        case pdfViewerTask
        
        case requestPermissionsStep
        
        // Eligibility task specific indentifiers.
        case eligibilityTask
        case eligibilityIntroStep
        case eligibilityFormStep
        case eligibilityFormItem01
        case eligibilityFormItem02
        case eligibilityFormItem03
        case eligibilityIneligibleStep
        case eligibilityEligibleStep
        
        // Consent task specific identifiers.
        case consentTask
        case visualConsentStep
        case consentSharingStep
        case consentReviewStep
        case consentDocumentParticipantSignature
        case consentDocumentInvestigatorSignature
        
        // Account creation task specific identifiers.
        case accountCreationTask
        case registrationStep
        case waitStep
        case verificationStep
        
        // Login task specific identifiers.
        case loginTask
        case loginStep
        case loginWaitStep

        // Passcode task specific identifiers.
        case passcodeTask
        case passcodeStep

        // Active tasks.
        case audioTask
        case amslerGridTask
        case fitnessTask
        case holePegTestTask
        case psatTask
        case reactionTime
        case shortWalkTask
        case spatialSpanMemoryTask
        case speechRecognitionTask
        case speechInNoiseTask
        case stroopTask
        case swiftStroopTask
        case timedWalkWithTurnAroundTask
        case toneAudiometryTask
        case dBHLToneAudiometryTask
        case splMeterTask
        case splMeterStep
        case towerOfHanoi
        case tremorTestTask
        case twoFingerTappingIntervalTask
        case walkBackAndForthTask
        case kneeRangeOfMotion
        case shoulderRangeOfMotion
        case trailMaking
        case visualAcuityLandoltC
        case contrastSensitivityPeakLandoltC
        
        // Video instruction tasks.
        case videoInstructionTask
        case videoInstructionStep
        
        // Web view tasks.
        case webViewTask
        case webViewStep
    }
    
    // MARK: Properties
    
    /// Returns a new `ORKTask` that the `TaskListRow` enumeration represents.
    var representedTask: ORKTask {
        switch self {
        case .form:
            return formTask
            
        case .groupedForm:
            return groupedFormTask
            
        case .survey:
            return surveyTask
            
        case .booleanQuestion:
            return booleanQuestionTask
            
        case .customBooleanQuestion:
            return customBooleanQuestionTask
            
        case .dateQuestion:
            return dateQuestionTask
            
        case .dateTimeQuestion:
            return dateTimeQuestionTask

        case .heightQuestion:
            return heightQuestionTask
            
        case .weightQuestion:
            return weightQuestionTask
            
        case .imageChoiceQuestion:
            return imageChoiceQuestionTask
            
        case .locationQuestion:
            return locationQuestionTask
            
        case .numericQuestion:
            return numericQuestionTask
            
        case .scaleQuestion:
            return scaleQuestionTask
            
        case .textQuestion:
            return textQuestionTask
            
        case .textChoiceQuestion:
            return textChoiceQuestionTask

        case .timeIntervalQuestion:
            return timeIntervalQuestionTask

        case .timeOfDayQuestion:
                return timeOfDayQuestionTask
        
        case .valuePickerChoiceQuestion:
                return valuePickerChoiceQuestionTask
            
        case .validatedTextQuestion:
            return validatedTextQuestionTask
            
        case .imageCapture:
            return imageCaptureTask
            
        case .videoCapture:
            return videoCaptureTask
            
        case .frontFacingCamera:
            return frontFacingCameraStep
            
        case .wait:
            return waitTask
            
        case .PDFViewer:
            return PDFViewerTask
            
        case .requestPermissions:
            return requestPermissionsTask
        
        case .eligibilityTask:
            return eligibilityTask
            
        case .consent:
            return consentTask
            
        case .accountCreation:
            return accountCreationTask
            
        case .login:
            return loginTask

        case .passcode:
            return passcodeTask
            
        case .audio:
            return audioTask
            
        case .amslerGrid:
            return amslerGridTask

        case .fitness:
            return fitnessTask
            
        case .holePegTest:
            return holePegTestTask
            
        case .psat:
            return PSATTask
            
        case .reactionTime:
            return reactionTimeTask
            
        case .shortWalk:
            return shortWalkTask
            
        case .spatialSpanMemory:
            return spatialSpanMemoryTask

        case .speechRecognition:
            return speechRecognitionTask
            
        case .speechInNoise:
            return speechInNoiseTask
            
        case .stroop:
            return stroopTask
            
        case .swiftStroop:
            return swiftStroopTask
            
        case .timedWalkWithTurnAround:
            return timedWalkWithTurnAroundTask
            
        case .toneAudiometry:
            return toneAudiometryTask
            
        case .dBHLToneAudiometry:
            return dBHLToneAudiometryTask
            
        case .splMeter:
            return splMeterTask
            
        case .towerOfHanoi:
            return towerOfHanoiTask
            
        case .twoFingerTappingInterval:
            return twoFingerTappingIntervalTask
            
        case .walkBackAndForth:
            return walkBackAndForthTask
            
        case .tremorTest:
            return tremorTestTask

        case .kneeRangeOfMotion:
            return kneeRangeOfMotion
        
        case .shoulderRangeOfMotion:
            return shoulderRangeOfMotion
            
        case .trailMaking:
            return trailMaking
    
        case .visualAcuityLandoltC:
            return visualAcuityLandoltC
            
        case .contrastSensitivityPeakLandoltC:
            return contrastSensitivityPeakLandoltC
            
        case .videoInstruction:
            return videoInstruction
            
        case .webView:
            return webView
        }
    }

    // MARK: Task Creation Convenience
    
    /**
    This task demonstrates a form step, in which multiple items are presented
    in a single scrollable form. This might be used for entering multi-value
    data, like taking a blood pressure reading with separate systolic and
    diastolic values.
    */
    private var formTask: ORKTask {
        let step = ORKFormStep(identifier: String(describing: Identifier.formStep), title: NSLocalizedString("Form Step", comment: ""), text: exampleDetailText)

        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("Field01", comment: "")
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.formItem01), text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem01.placeholder = NSLocalizedString("Your placeholder here", comment: "")

        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString("Field02", comment: "")
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.formItem02), text: formItem02Text, answerFormat: ORKTimeIntervalAnswerFormat())
        formItem02.placeholder = NSLocalizedString("Your placeholder here", comment: "")

        let formItem03Text = NSLocalizedString(exampleQuestionText, comment: "")
        let scaleAnswerFormat = ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1)//ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1)
        scaleAnswerFormat.shouldHideRanges = true
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.formItem03), text: formItem03Text, answerFormat: scaleAnswerFormat)

        let textChoices: [ORKTextChoice] = [
            ORKTextChoice(text: "choice 1", detailText: "detail 1", value: 1 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
            ORKTextChoice(text: "choice 2", detailText: "detail 2", value: 2 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
            ORKTextChoice(text: "choice 3", detailText: "detail 3", value: 3 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
            ORKTextChoice(text: "choice 4", detailText: "detail 4", value: 4 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
            ORKTextChoice(text: "choice 5", detailText: "detail 5", value: 5 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
            ORKTextChoice(text: "choice 6", detailText: "detail 6", value: 6 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false)
        ]
        
        let textScaleAnswerFormat = ORKTextScaleAnswerFormat(textChoices: textChoices, defaultIndex: 10)
        textScaleAnswerFormat.shouldHideLabels = true
        textScaleAnswerFormat.shouldShowDontKnowButton = true
        let formItem04 = ORKFormItem(identifier: String(describing: Identifier.formItem04), text: exampleQuestionText, answerFormat: textScaleAnswerFormat)
        
        let appleChoices: [ORKTextChoice] = [ORKTextChoice(text: "Granny Smith", value: 1 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Honeycrisp", value: 2 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Fuji", value: 3 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "McIntosh", value: 10 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Kanzi", value: 5 as NSCoding & NSCopying & NSObjectProtocol)]
        
        let appleAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: appleChoices)
        
        let appleFormItem = ORKFormItem(identifier: "appleFormItemIdentifier", text: "Which is your favorite apple?", answerFormat: appleAnswerFormat)
        
        
        step.formItems = [
            appleFormItem,
            formItem03,
            formItem04,
            formItem01,
            formItem02
        ]
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = NSLocalizedString("All Done!", comment: "")
        completionStep.detailText = NSLocalizedString("You have completed the questionnaire.", comment: "")
        return ORKOrderedTask(identifier: String(describing: Identifier.formTask), steps: [step, completionStep])
    }
    
    private var groupedFormTask: ORKTask {
        let step = ORKFormStep(identifier: String(describing: Identifier.groupedFormStep), title: NSLocalizedString("Form Step", comment: ""), text: exampleDetailText)
        
        //Start of first section
        let learnMoreInstructionStep01 = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep01.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep01.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem01 = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep01)
        let section01 = ORKFormItem(sectionTitle: NSLocalizedString("Section title", comment: ""), detailText: NSLocalizedString("Section detail text", comment: ""), learnMoreItem: learnMoreItem01, showsProgress: true)
        
        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("Field01", comment: "")
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.formItem01), text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem01.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString("Field02", comment: "")
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.formItem02), text: formItem02Text, answerFormat: ORKTimeIntervalAnswerFormat())
        formItem02.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        
        let sesAnswerFormat = ORKSESAnswerFormat(topRungText: "Best Off", bottomRungText: "Worst Off")
        let sesFormItem = ORKFormItem(identifier: "sesIdentifier", text: "Select where you are on the socioeconomic ladder.", answerFormat: sesAnswerFormat)
        
        
        //Start of section for scale question
        let formItem03Text = NSLocalizedString(exampleQuestionText, comment: "")
        let scaleAnswerFormat = ORKContinuousScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0.0, maximumFractionDigits: 1)//ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1)
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.formItem03), text: formItem03Text, detailText: nil, learnMoreItem: nil, showsProgress: true, answerFormat: scaleAnswerFormat, tagText: nil, optional: true)
       
        step.formItems = [
            section01,
            formItem01,
            formItem02,
            formItem03,
            sesFormItem
        ]
        
        // Add a question step.
        let question1StepAnswerFormat = ORKBooleanAnswerFormat()
        
        let question1 = NSLocalizedString("Would you like to subscribe to our newsletter?", comment: "")
        
        let learnMoreInstructionStep = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep)
        
        let question1Step = ORKQuestionStep(identifier: String(describing: Identifier.questionStep), title: "Questionnaire", question: question1, answer: question1StepAnswerFormat, learnMoreItem: learnMoreItem)
        question1Step.text = exampleDetailText
        
        //Add a question step with different layout format.
        let question2StepAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: nil, minimumDate: nil, maximumDate: Date(), calendar: nil)
        
        let question2 = NSLocalizedString("When is your birthday?", comment: "")
        let question2Step = ORKQuestionStep(identifier: String(describing: Identifier.birthdayQuestion), title: "Questionnaire", question: question2, answer: question2StepAnswerFormat)
        question2Step.text = exampleDetailText
        
        
        let appleChoices: [ORKTextChoice] = [ORKTextChoice(text: "Granny Smith", value: 1 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Honeycrisp", value: 2 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Fuji", value: 3 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "McIntosh", value: 10 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Kanzi", value: 5 as NSCoding & NSCopying & NSObjectProtocol)]
        
        let appleAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: appleChoices)
        
        let appleFormItem = ORKFormItem(identifier: "appleFormItemIdentifier", text: "Which is your favorite apple?", answerFormat: appleAnswerFormat)
        
        let appleFormStep = ORKFormStep(identifier: "appleFormStepIdentifier", title: "Fruit!", text: "Select the fruit you like.")
        
        appleFormStep.formItems = [appleFormItem]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.groupedFormTask), steps: [step, question1Step, question2Step, appleFormStep])
    }

    /**
    A task demonstrating how the ResearchKit framework can be used to present a simple
    survey with an introduction, a question, and a conclusion.
    */
    private var surveyTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.introStep))
        instructionStep.title = NSLocalizedString("Simple Survey", comment: "")
        instructionStep.text = exampleDescription
        instructionStep.detailText = NSLocalizedString("Please use this space to provide instructions for participants.  Please make sure to provide enough information so that users can progress through the survey and complete with ease.", comment: "")
        
        // Add a question step.
        let question1StepAnswerFormat = ORKBooleanAnswerFormat()
        
        let question1 = NSLocalizedString("Would you like to subscribe to our newsletter?", comment: "")
        
        let learnMoreInstructionStep = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep)
        
        let question1Step = ORKQuestionStep(identifier: String(describing: Identifier.questionStep), title: "Questionnaire", question: question1, answer: question1StepAnswerFormat, learnMoreItem: learnMoreItem)
        question1Step.text = exampleDetailText
        
        //Add a question step with different layout format.
        let question2StepAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: nil, minimumDate: nil, maximumDate: Date(), calendar: nil)
        
        let question2 = NSLocalizedString("When is your birthday?", comment: "")
        let question2Step = ORKQuestionStep(identifier: String(describing: Identifier.birthdayQuestion), title: "Questionnaire", question: question2, answer: question2StepAnswerFormat)
        question2Step.text = exampleDetailText
        
        // Add a summary step.
        let summaryStep = ORKInstructionStep(identifier: String(describing: Identifier.summaryStep))
        summaryStep.title = NSLocalizedString("Thanks", comment: "")
        summaryStep.text = NSLocalizedString("Thank you for participating in this sample survey.", comment: "")
        
        return ORKOrderedTask(identifier: String(describing: Identifier.surveyTask), steps: [
            instructionStep,
            question1Step,
            question2Step,
            summaryStep
            ])
    }

    /// This task presents just a single "Yes" / "No" question.
    private var booleanQuestionTask: ORKTask {
        let answerFormat = ORKBooleanAnswerFormat()
        
        // We attach an answer format to a question step to specify what controls the user sees.
        let questionStep = ORKQuestionStep(identifier: String(describing: Identifier.booleanQuestionStep), title: NSLocalizedString("Boolean", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        // The detail text is shown in a small font below the title.
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.booleanQuestionTask), steps: [questionStep])
    }
    
    /// This task presents a customized "Yes" / "No" question.
    private var customBooleanQuestionTask: ORKTask {
        let answerFormat = ORKBooleanAnswerFormat(yesString: "Agree", noString: "Disagree")
        
        // We attach an answer format to a question step to specify what controls the user sees.
        let questionStep = ORKQuestionStep(identifier: String(describing: Identifier.booleanQuestionStep), title: NSLocalizedString("Custom Boolean", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        // The detail text is shown in a small font below the title.
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.booleanQuestionTask), steps: [questionStep])
    }

    /// This task demonstrates a question which asks for a date.
    private var dateQuestionTask: ORKTask {
        /*
        The date answer format can also support minimum and maximum limits,
        a specific default value, and overriding the calendar to use.
        */
        let answerFormat = ORKAnswerFormat.dateAnswerFormat()
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.dateQuestionStep), title: NSLocalizedString("Date", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.dateQuestionTask), steps: [step])
    }
    
    /// This task demonstrates a question asking for a date and time of an event.
    private var dateTimeQuestionTask: ORKTask {
        /*
        This uses the default calendar. Use a more detailed constructor to
        set minimum / maximum limits.
        */
        let answerFormat = ORKAnswerFormat.dateTime()
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.dateTimeQuestionStep), title: NSLocalizedString("Date and Time", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.dateTimeQuestionTask), steps: [step])
    }

    /// This task demonstrates a question asking for the user height.
    private var heightQuestionTask: ORKTask {
        let answerFormat1 = ORKAnswerFormat.heightAnswerFormat()
        
        let step1 = ORKQuestionStep(identifier: String(describing: Identifier.heightQuestionStep1), title: NSLocalizedString("Height", comment: ""), question: exampleQuestionText, answer: answerFormat1)
        
        step1.text = "Local system"

        let answerFormat2 = ORKAnswerFormat.heightAnswerFormat(with: ORKMeasurementSystem.metric)
        
        let step2 = ORKQuestionStep(identifier: String(describing: Identifier.heightQuestionStep2), title: NSLocalizedString("Height", comment: ""), question: exampleQuestionText, answer: answerFormat2)
        
        step2.text = "Metric system"

        let answerFormat3 = ORKAnswerFormat.heightAnswerFormat(with: ORKMeasurementSystem.USC)
        
        let step3 = ORKQuestionStep(identifier: String(describing: Identifier.heightQuestionStep3), title: NSLocalizedString("Height", comment: ""), question: exampleQuestionText, answer: answerFormat3)
        
        step3.text = "USC system"

        let answerFormat4 = ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!, unit: HKUnit.meterUnit(with: .centi), style: .decimal)
        
        let step4 = ORKQuestionStep(identifier: String(describing: Identifier.heightQuestionStep4), title: NSLocalizedString("Height", comment: ""), question: exampleQuestionText, answer: answerFormat4)
        
        step4.text = "HealthKit, height"
        
        return ORKOrderedTask(identifier: String(describing: Identifier.heightQuestionTask), steps: [step1, step2, step3, step4])
    }

    /// This task demonstrates a question asking for the user weight.
    private var weightQuestionTask: ORKTask {
        let answerFormat1 = ORKAnswerFormat.weightAnswerFormat()
        
        let step1 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep1), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat1)
        
        step1.text = "Local system, default precision"
        
        let answerFormat2 = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric)
        
        let step2 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep2), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat2)
        
        step2.text = "Metric system, default precision"
        
        let answerFormat3 = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric, numericPrecision: ORKNumericPrecision.low, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        
        let step3 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep3), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat3)
        
        step3.text = "Metric system, low precision"

        let answerFormat4 = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric, numericPrecision: ORKNumericPrecision.high, minimumValue: 20.0, maximumValue: 100.0, defaultValue: 45.50)
        
        let step4 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep4), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat4)
        
        step4.text = "Metric system, high precision"

        let answerFormat5 = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.USC)
        
        let step5 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep5), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat5)
        
        step5.text = "USC system, default precision"
        
        let answerFormat6 = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.USC, numericPrecision: ORKNumericPrecision.high, minimumValue: 50.0, maximumValue: 150.0, defaultValue: 100.0)
        
        let step6 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep6), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat6)
        
        step6.text = "USC system, high precision"

        let answerFormat7 = ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, unit: HKUnit.gramUnit(with: .kilo), style: .decimal)
        
        let step7 = ORKQuestionStep(identifier: String(describing: Identifier.weightQuestionStep7), title: NSLocalizedString("Weight", comment: ""), question: exampleQuestionText, answer: answerFormat7)
        
        step7.text = "HealthKit, body mass"

        return ORKOrderedTask(identifier: String(describing: Identifier.weightQuestionTask), steps: [step1, step2, step3, step4, step5, step6, step7])
    }
    
    /**
    This task demonstrates a survey question involving picking from a series of
    image choices. A more realistic applciation of this type of question might be to
    use a range of icons for faces ranging from happy to sad.
    */
    private var imageChoiceQuestionTask: ORKTask {
        let roundShapeImage = UIImage(named: "round_shape")!
        let roundShapeText = NSLocalizedString("Round Shape", comment: "")
        
        let squareShapeImage = UIImage(named: "square_shape")!
        let squareShapeText = NSLocalizedString("Square Shape", comment: "")
        
        let imageChoces = [
            ORKImageChoice(normalImage: roundShapeImage, selectedImage: nil, text: roundShapeText, value: roundShapeText as NSCoding & NSCopying & NSObjectProtocol),
            ORKImageChoice(normalImage: squareShapeImage, selectedImage: nil, text: squareShapeText, value: squareShapeText as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let answerFormat1 = ORKAnswerFormat.choiceAnswerFormat(with: imageChoces)
        
        let questionStep1 = ORKQuestionStep(identifier: String(describing: Identifier.imageChoiceQuestionStep1), title: NSLocalizedString("Image Choice", comment: ""), question: exampleQuestionText, answer: answerFormat1)

        questionStep1.text = exampleDetailText

        let answerFormat2 = ORKAnswerFormat.choiceAnswerFormat(with: imageChoces, style: .singleChoice, vertical: true)
        
        let questionStep2 = ORKQuestionStep(identifier: String(describing: Identifier.imageChoiceQuestionStep2), title: NSLocalizedString("Image Choice", comment: ""), question: exampleQuestionText, answer: answerFormat2)

        questionStep2.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.imageChoiceQuestionTask), steps: [questionStep1, questionStep2])
    }
    
    /// This task presents just a single location question.
    private var locationQuestionTask: ORKTask {
        let answerFormat = ORKLocationAnswerFormat()
        
        // We attach an answer format to a question step to specify what controls the user sees.
        let questionStep = ORKQuestionStep(identifier: String(describing: Identifier.locationQuestionStep), title: NSLocalizedString("Location", comment: ""), question: exampleQuestionText, answer: answerFormat)
        // The detail text is shown in a small font below the title.
        questionStep.text = exampleDetailText
        questionStep.placeholder = NSLocalizedString("Address", comment: "")
        
        return ORKOrderedTask(identifier: String(describing: Identifier.locationQuestionTask), steps: [questionStep])
    }
    
    /**
        This task demonstrates use of numeric questions with and without units.
        Note that the unit is just a string, prompting the user to enter the value
        in the expected unit. The unit string propagates into the result object.
    */
    private var numericQuestionTask: ORKTask {
        // This answer format will display a unit in-line with the numeric entry field.
        let localizedQuestionStep1AnswerFormatUnit = NSLocalizedString("Your unit", comment: "")
        let questionStep1AnswerFormat = ORKAnswerFormat.decimalAnswerFormat(withUnit: localizedQuestionStep1AnswerFormatUnit)
        
        let questionStep1 = ORKQuestionStep(identifier: String(describing: Identifier.numericQuestionStep), title: NSLocalizedString("Numeric", comment: ""), question: exampleQuestionText, answer: questionStep1AnswerFormat)
        
        questionStep1.text = exampleDetailText
        questionStep1.placeholder = NSLocalizedString("Your placeholder.", comment: "")
                
        // This answer format is similar to the previous one, but this time without displaying a unit.
        let questionStep2 = ORKQuestionStep(identifier: String(describing: Identifier.numericNoUnitQuestionStep), title: NSLocalizedString("Numeric", comment: ""), question: exampleQuestionText, answer: ORKAnswerFormat.decimalAnswerFormat(withUnit: nil))
        
        questionStep2.text = exampleDetailText
        questionStep2.placeholder = NSLocalizedString("Placeholder without unit.", comment: "")
        
        return ORKOrderedTask(identifier: String(describing: Identifier.numericQuestionTask), steps: [
            questionStep1,
            questionStep2
        ])
    }
    
    /// This task presents two options for questions displaying a scale control.
    private var scaleQuestionTask: ORKTask {
        // The first step is a scale control with 10 discrete ticks.
        let stepTitle = NSLocalizedString("Scale", comment: "")
        
        let step1AnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: false, maximumValueDescription: exampleHighValueText, minimumValueDescription: exampleLowValueText)
        
        let questionStep1 = ORKQuestionStep(identifier: String(describing: Identifier.discreteScaleQuestionStep), title: stepTitle, question: exampleQuestionText, answer: step1AnswerFormat)
        
        questionStep1.text = NSLocalizedString("Discrete Scale", comment: "")
        
        // The second step is a scale control that allows continuous movement with a percent formatter.
        let step2AnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: 1.0, minimumValue: 0.0, defaultValue: 99.0, maximumFractionDigits: 0, vertical: false, maximumValueDescription: nil, minimumValueDescription: nil)
        step2AnswerFormat.numberStyle = .percent
        
        let questionStep2 = ORKQuestionStep(identifier: String(describing: Identifier.continuousScaleQuestionStep), title: stepTitle, question: exampleQuestionText, answer: step2AnswerFormat)
        
        questionStep2.text = NSLocalizedString("Continuous Scale", comment: "")
        
        // The third step is a vertical scale control with 10 discrete ticks.
        let step3AnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: true, maximumValueDescription: nil, minimumValueDescription: nil)
        
        let questionStep3 = ORKQuestionStep(identifier: String(describing: Identifier.discreteVerticalScaleQuestionStep), title: stepTitle, question: exampleQuestionText, answer: step3AnswerFormat)
        
        questionStep3.text = NSLocalizedString("Discrete Vertical Scale", comment: "")
        
        // The fourth step is a vertical scale control that allows continuous movement.
        let step4AnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: 5.0, minimumValue: 1.0, defaultValue: 99.0, maximumFractionDigits: 2, vertical: true, maximumValueDescription: exampleHighValueText, minimumValueDescription: exampleLowValueText)
        
        let questionStep4 = ORKQuestionStep(identifier: String(describing: Identifier.continuousVerticalScaleQuestionStep), title: stepTitle, question: exampleQuestionText, answer: step4AnswerFormat)
        
        questionStep4.text = "Continuous Vertical Scale"
        
        // The fifth step is a scale control that allows text choices.
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Poor", value: 1 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Fair", value: 2 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Good", value: 3 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Above Average", value: 10 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Excellent", value: 5 as NSCoding & NSCopying & NSObjectProtocol)]

        let step5AnswerFormat = ORKAnswerFormat.textScale(with: textChoices, defaultIndex: NSIntegerMax, vertical: false)
        
        let questionStep5 = ORKQuestionStep(identifier: String(describing: Identifier.textScaleQuestionStep), title: stepTitle, question: exampleQuestionText, answer: step5AnswerFormat)
        
        questionStep5.text = "Text Scale"
        
        // The sixth step is a vertical scale control that allows text choices.
        let step6AnswerFormat = ORKAnswerFormat.textScale(with: textChoices, defaultIndex: NSIntegerMax, vertical: true)
        
        let questionStep6 = ORKQuestionStep(identifier: String(describing: Identifier.textVerticalScaleQuestionStep), title: stepTitle, question: exampleQuestionText, answer: step6AnswerFormat)
        
        questionStep6.text = "Text Vertical Scale"
        
        return ORKOrderedTask(identifier: String(describing: Identifier.scaleQuestionTask), steps: [
            questionStep1,
            questionStep2,
            questionStep3,
            questionStep4,
            questionStep5,
            questionStep6
            ])
    }
    
    /**
    This task demonstrates asking for text entry. Both single and multi-line
    text entry are supported, with appropriate parameters to the text answer
    format.
    */
    private var textQuestionTask: ORKTask {
        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        answerFormat.multipleLines = true
        answerFormat.maximumLength = 280
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.textQuestionStep), title: NSLocalizedString("Text", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.textQuestionTask), steps: [step])
    }
    
    /**
    This task demonstrates a survey question for picking from a list of text
    choices. In this case, the text choices are presented in a table view
    (compare with the `valuePickerQuestionTask`).
    */
    private var textChoiceQuestionTask: ORKTask {
        let textChoiceOneText = NSLocalizedString("Choice 1", comment: "")
        let textChoiceTwoText = NSLocalizedString("Choice 2", comment: "")
        let textChoiceThreeText = NSLocalizedString("Choice 3", comment: "")
        let textChoiceFourText = NSLocalizedString("Other", comment: "")
        
        // The text to display can be separate from the value coded for each choice:
        let textChoices = [
            ORKTextChoice(text: textChoiceOneText, value: "choice_1" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: textChoiceTwoText, value: "choice_2" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: textChoiceThreeText, value: "choice_3" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoiceOther.choice(withText: textChoiceFourText, detailText: nil, value: "choice_4" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "enter additional information")
        ]
        
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)

        let questionStep = ORKQuestionStep(identifier: String(describing: Identifier.textChoiceQuestionStep), title: NSLocalizedString("Text Choice", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.textChoiceQuestionTask), steps: [questionStep])
    }

    /**
        This task demonstrates requesting a time interval. For example, this might
        be a suitable answer format for a question like "How long is your morning
        commute?"
    */
    private var timeIntervalQuestionTask: ORKTask {
        /*
            The time interval answer format is constrained to entering a time
            less than 24 hours and in steps of minutes. For times that don't fit
            these restrictions, use another mode of data entry.
        */
        let answerFormat = ORKAnswerFormat.timeIntervalAnswerFormat()
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.timeIntervalQuestionStep), title: NSLocalizedString("Time Interval", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.timeIntervalQuestionTask), steps: [step])
    }

    /// This task demonstrates a question asking for a time of day.
    private var timeOfDayQuestionTask: ORKTask {
        /*
        Because we don't specify a default, the picker will default to the
        time the step is presented. For questions like "What time do you have
        breakfast?", it would make sense to set the default on the answer
        format.
        */
        let answerFormat = ORKAnswerFormat.timeOfDayAnswerFormat()
        
        let questionStep = ORKQuestionStep(identifier: String(describing: Identifier.timeOfDayQuestionStep), title: NSLocalizedString("Time", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.timeOfDayQuestionTask), steps: [questionStep])
    }

    /**
        This task demonstrates a survey question using a value picker wheel.
        Compare with the `textChoiceQuestionTask` and `imageChoiceQuestionTask`
        which can serve a similar purpose.
    */
    private var valuePickerChoiceQuestionTask: ORKTask {
        let textChoiceOneText = NSLocalizedString("Choice 1", comment: "")
        let textChoiceTwoText = NSLocalizedString("Choice 2", comment: "")
        let textChoiceThreeText = NSLocalizedString("Choice 3", comment: "")
        
        // The text to display can be separate from the value coded for each choice:
        let textChoices = [
            ORKTextChoice(text: textChoiceOneText, value: "choice_1" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: textChoiceTwoText, value: "choice_2" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: textChoiceThreeText, value: "choice_3" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let answerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: textChoices)
        
        let questionStep = ORKQuestionStep(identifier: String(describing: Identifier.valuePickerChoiceQuestionStep), title: NSLocalizedString("Value Picker", comment: ""), question: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = NSLocalizedString("Text Value picker", comment: "")
        
        return ORKOrderedTask(identifier: String(describing: Identifier.valuePickerChoiceQuestionTask), steps: [questionStep])
    }

    /**
     This task demonstrates asking for text entry. Both single and multi-line
     text entry are supported, with appropriate parameters to the text answer
     format.
     */
    private var validatedTextQuestionTask: ORKTask {
        let answerFormatEmail = ORKAnswerFormat.emailAnswerFormat()
        let stepEmail = ORKQuestionStep(identifier: String(describing: Identifier.validatedTextQuestionStepEmail), title: NSLocalizedString("Validated Text", comment: ""), question: NSLocalizedString("Email", comment: ""), answer: answerFormatEmail)
        stepEmail.text = exampleDetailText
        
        let domainRegularExpressionPattern = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        let domainRegularExpression = try? NSRegularExpression(pattern: domainRegularExpressionPattern)
        let answerFormatDomain = ORKAnswerFormat.textAnswerFormat(withValidationRegularExpression: domainRegularExpression!, invalidMessage: "Invalid URL: %@")
        answerFormatDomain.multipleLines = false
        answerFormatDomain.keyboardType = .URL
        answerFormatDomain.autocapitalizationType = UITextAutocapitalizationType.none
        answerFormatDomain.autocorrectionType = UITextAutocorrectionType.no
        answerFormatDomain.spellCheckingType = UITextSpellCheckingType.no
        answerFormatDomain.textContentType = UITextContentType.URL
        let stepDomain = ORKQuestionStep(identifier: String(describing: Identifier.validatedTextQuestionStepDomain), title: NSLocalizedString("Validated Text", comment: ""), question: NSLocalizedString("URL", comment: ""), answer: answerFormatDomain)
        stepDomain.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.validatedTextQuestionTask), steps: [stepEmail, stepDomain])
    }
    
    /// This task presents the image capture step in an ordered task.
    private var imageCaptureTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.introStep))
        
        instructionStep.title = NSLocalizedString("Image Capture Survey", comment: "")
        
        instructionStep.text = exampleDescription
        
        let handSolidImage = UIImage(named: "hand_solid")!
        instructionStep.image = handSolidImage.withRenderingMode(.alwaysTemplate)
        
        let imageCaptureStep = ORKImageCaptureStep(identifier: String(describing: Identifier.imageCaptureStep))
        imageCaptureStep.title = NSLocalizedString("Image Capture", comment: "")
        imageCaptureStep.isOptional = false
        imageCaptureStep.accessibilityInstructions = NSLocalizedString("Your instructions for capturing the image", comment: "")
        imageCaptureStep.accessibilityHint = NSLocalizedString("Captures the image visible in the preview", comment: "")
        
        imageCaptureStep.templateImage = UIImage(named: "hand_outline_big")!
        
        imageCaptureStep.templateImageInsets = UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05)
        
        return ORKOrderedTask(identifier: String(describing: Identifier.imageCaptureTask), steps: [
            instructionStep,
            imageCaptureStep
            ])
    }
    
    /// This task presents the video capture step in an ordered task.
    private var videoCaptureTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.introStep))
        
        instructionStep.title = NSLocalizedString("Video Capture Survey", comment: "")
        
        instructionStep.text = exampleDescription
        
        let handSolidImage = UIImage(named: "hand_solid")!
        instructionStep.image = handSolidImage.withRenderingMode(.alwaysTemplate)
        
        let videoCaptureStep = ORKVideoCaptureStep(identifier: String(describing: Identifier.videoCaptureStep))
        videoCaptureStep.title = NSLocalizedString("Video Capture", comment: "")
        videoCaptureStep.accessibilityInstructions = NSLocalizedString("Your instructions for capturing the video", comment: "")
        videoCaptureStep.accessibilityHint = NSLocalizedString("Captures the video visible in the preview", comment: "")
        videoCaptureStep.templateImage = UIImage(named: "hand_outline_big")!
        videoCaptureStep.templateImageInsets = UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05)
        videoCaptureStep.duration = 30.0; // 30 seconds
        
        return ORKOrderedTask(identifier: String(describing: Identifier.videoCaptureTask), steps: [
            instructionStep,
            videoCaptureStep
            ])
    }
    
    /// This task presents a wait task.
    private var waitTask: ORKTask {
        let waitStepIndeterminate = ORKWaitStep(identifier: String(describing: Identifier.waitStepIndeterminate))
        waitStepIndeterminate.title = NSLocalizedString("Wait Step", comment: "")
        waitStepIndeterminate.text = exampleDescription
        waitStepIndeterminate.indicatorType = ORKProgressIndicatorType.indeterminate
        
        let waitStepDeterminate = ORKWaitStep(identifier: String(describing: Identifier.waitStepDeterminate))
        waitStepDeterminate.title = NSLocalizedString("Wait Step", comment: "")
        waitStepDeterminate.text = exampleDescription
        waitStepDeterminate.indicatorType = ORKProgressIndicatorType.progressBar
        
        return ORKOrderedTask(identifier: String(describing: Identifier.waitTask), steps: [waitStepIndeterminate, waitStepDeterminate])
    }
    
    /// This task presents the PDF Viewer Step
    private var PDFViewerTask: ORKTask {

        let PDFViewerStep = ORKPDFViewerStep(identifier: String(describing: Identifier.pdfViewerStep), pdfURL: Bundle.main.bundleURL.appendingPathComponent("ResearchKit.pdf"))
        PDFViewerStep.title = NSLocalizedString("PDF Step", comment: "")
        
        return ORKOrderedTask(identifier: String(describing: Identifier.pdfViewerTask), steps: [PDFViewerStep])
    }
    
    private var requestPermissionsTask: ORKTask {
        let healthKitTypesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.workoutType()]
        
        
        let healthKitPermissionType = ORKHealthKitPermissionType(sampleTypesToWrite: healthKitTypesToWrite,
                                                                 objectTypesToRead: healthKitTypesToRead)

        let notificationsPermissionType = ORKNotificationPermissionType(
            authorizationOptions: [.alert, .badge, .sound])

        let motionActivityPermissionType = ORKMotionActivityPermissionType()

        let requestPermissionsStep = ORKRequestPermissionsStep(
            identifier: String(describing: Identifier.requestPermissionsStep),
            permissionTypes: [
                healthKitPermissionType,
                notificationsPermissionType,
                motionActivityPermissionType
            ])
       
        requestPermissionsStep.title = "Authorization Requests"
        requestPermissionsStep.text = "Please review the authorizations below and enable to contribute to the study."
        
        return ORKOrderedTask(identifier: String(describing: Identifier.requestPermissionsStep), steps: [requestPermissionsStep])
    }
    
    /**
    A task demonstrating how the ResearchKit framework can be used to determine
    eligibility using a navigable ordered task.
    */
    private var eligibilityTask: ORKTask {
        // Intro step
        let introStep = ORKInstructionStep(identifier: String(describing: Identifier.eligibilityIntroStep))
        introStep.title = NSLocalizedString("Eligibility Task", comment: "")
        introStep.text = exampleDescription
        introStep.detailText = NSLocalizedString("Please use this space to provide instructions for participants.  Please make sure to provide enough information so that users can progress through the survey and complete with ease.", comment: "")
        
        // Form step
        let formStep = ORKFormStep(identifier: String(describing: Identifier.eligibilityFormStep))
        formStep.title = NSLocalizedString("Eligibility", comment: "")
        formStep.isOptional = false
        
        // Form items
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "N/A", value: "N/A" as NSCoding & NSCopying & NSObjectProtocol)]
        let answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem01), text: exampleQuestionText, answerFormat: answerFormat)
        formItem01.isOptional = false
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem02), text: exampleQuestionText, answerFormat: answerFormat)
        formItem02.isOptional = false
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem03), text: exampleQuestionText, answerFormat: answerFormat)
        formItem03.isOptional = false
        
        formStep.formItems = [
            formItem01,
            formItem02,
            formItem03
        ]
        
        // Ineligible step
        let ineligibleStep = ORKInstructionStep(identifier: String(describing: Identifier.eligibilityIneligibleStep))
        ineligibleStep.title = NSLocalizedString("Eligibility Result", comment: "")
        ineligibleStep.detailText = NSLocalizedString("You are ineligible to join the study", comment: "")
        
        // Eligible step
        let eligibleStep = ORKCompletionStep(identifier: String(describing: Identifier.eligibilityEligibleStep))
        eligibleStep.title = NSLocalizedString("Eligibility Result", comment: "")
        eligibleStep.detailText = NSLocalizedString("You are eligible to join the study", comment: "")
        
        // Create the task
        let eligibilityTask = ORKNavigableOrderedTask(identifier: String(describing: Identifier.eligibilityTask), steps: [
            introStep,
            formStep,
            ineligibleStep,
            eligibleStep
            ])
        
        // Build navigation rules.
        var resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep), resultIdentifier: String(describing: Identifier.eligibilityFormItem01))
        let predicateFormItem01 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "Yes" as NSCoding & NSCopying & NSObjectProtocol)
        
        resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep), resultIdentifier: String(describing: Identifier.eligibilityFormItem02))
        let predicateFormItem02 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "Yes" as NSCoding & NSCopying & NSObjectProtocol)
        
        resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep), resultIdentifier: String(describing: Identifier.eligibilityFormItem03))
        let predicateFormItem03 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "No" as NSCoding & NSCopying & NSObjectProtocol)
        
        let predicateEligible = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFormItem01, predicateFormItem02, predicateFormItem03])
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [ (predicateEligible, String(describing: Identifier.eligibilityEligibleStep)) ])
        
        eligibilityTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: String(describing: Identifier.eligibilityFormStep))
        
        // Add end direct rules to skip unneeded steps
        let directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
        eligibilityTask.setNavigationRule(directRule, forTriggerStepIdentifier: String(describing: Identifier.eligibilityIneligibleStep))
        
        return eligibilityTask
    }
    
    /// A task demonstrating how the ResearchKit framework can be used to obtain informed consent.
    private var consentTask: ORKTask {
        /*
        Informed consent starts by presenting an animated sequence conveying
        the main points of your consent document.
        */
        let visualConsentStep = ORKVisualConsentStep(identifier: String(describing: Identifier.visualConsentStep), document: consentDocument)
        
        let investigatorShortDescription = NSLocalizedString("Institution", comment: "")
        let investigatorLongDescription = NSLocalizedString("Institution and its partners", comment: "")
        let localizedLearnMoreHTMLContent = NSLocalizedString("Your sharing learn more content here.", comment: "")
        
        /*
        If you want to share the data you collect with other researchers for
        use in other studies beyond this one, it is best practice to get
        explicit permission from the participant. Use the consent sharing step
        for this.
        */
        let sharingConsentStep = ORKConsentSharingStep(identifier: String(describing: Identifier.consentSharingStep), investigatorShortDescription: investigatorShortDescription, investigatorLongDescription: investigatorLongDescription, localizedLearnMoreHTMLContent: localizedLearnMoreHTMLContent)
        
        /*
        After the visual presentation, the consent review step displays
        your consent document and can obtain a signature from the participant.
        
        The first signature in the document is the participant's signature.
        This effectively tells the consent review step which signatory is
        reviewing the document.
        */
        let signature = consentDocument.signatures!.first
        
        let reviewConsentStep = ORKConsentReviewStep(identifier: String(describing: Identifier.consentReviewStep), signature: signature, in: consentDocument)
        reviewConsentStep.requiresScrollToBottom = true
        
        // In a real application, you would supply your own localized text.
        reviewConsentStep.title = NSLocalizedString("Consent Document", comment: "")
        reviewConsentStep.text = loremIpsumText
        reviewConsentStep.reasonForConsent = loremIpsumText

        return ORKOrderedTask(identifier: String(describing: Identifier.consentTask), steps: [
            visualConsentStep,
            sharingConsentStep,
            reviewConsentStep
            ])
    }
    
    /// This task presents the Account Creation process.
    private var accountCreationTask: ORKTask {
        /*
        A registration step provides a form step that is populated with email and password fields.
        If you wish to include any of the additional fields, then you can specify it through the `options` parameter.
        */
        let registrationTitle = NSLocalizedString("Registration", comment: "")
        let passcodeValidationRegexPattern = "^(?=.*\\d).{4,8}$"
        let passcodeValidationRegularExpression = try? NSRegularExpression(pattern: passcodeValidationRegexPattern)
        let passcodeInvalidMessage = NSLocalizedString("A valid password must be 4 to 8 characters long and include at least one numeric character.", comment: "")
        let registrationOptions: ORKRegistrationStepOption = [.includeGivenName, .includeFamilyName, .includeGender, .includeDOB, .includePhoneNumber]
        let registrationStep = ORKRegistrationStep(identifier: String(describing: Identifier.registrationStep), title: registrationTitle, text: exampleDetailText, passcodeValidationRegularExpression: passcodeValidationRegularExpression, passcodeInvalidMessage: passcodeInvalidMessage, options: registrationOptions)
        registrationStep.phoneNumberValidationRegularExpression = try? NSRegularExpression(pattern: "^[+]{1,1}[1]{1,1}\\s{1,1}[(]{1,1}[1-9]{3,3}[)]{1,1}\\s{1,1}[1-9]{3,3}\\s{1,1}[1-9]{4,4}$")
        registrationStep.phoneNumberInvalidMessage = "Expected format +1 (555) 555 5555"
        
        /*
        A wait step allows you to upload the data from the user registration onto your server before presenting the verification step.
        */
        let waitTitle = NSLocalizedString("Creating account", comment: "")
        let waitText = NSLocalizedString("Please wait while we upload your data", comment: "")
        let waitStep = ORKWaitStep(identifier: String(describing: Identifier.waitStep))
        waitStep.title = waitTitle
        waitStep.text = waitText
        
        /*
        A verification step view controller subclass is required in order to use the verification step.
        The subclass provides the view controller button and UI behavior by overriding the following methods.
        */
        class VerificationViewController: ORKVerificationStepViewController {
            override func resendEmailButtonTapped() {
                let alertTitle = NSLocalizedString("Resend Verification Email", comment: "")
                let alertMessage = NSLocalizedString("Button tapped", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let verificationStep = ORKVerificationStep(identifier: String(describing: Identifier.verificationStep), text: exampleDetailText, verificationViewControllerClass: VerificationViewController.self)
        
        return ORKOrderedTask(identifier: String(describing: Identifier.accountCreationTask), steps: [
            registrationStep,
            waitStep,
            verificationStep
            ])
    }
    
    /// This tasks presents the login step.
    private var loginTask: ORKTask {
        /*
        A login step view controller subclass is required in order to use the login step.
        The subclass provides the behavior for the login step forgot password button.
        */
        class LoginViewController: ORKLoginStepViewController {
            override func forgotPasswordButtonTapped() {
                let alertTitle = NSLocalizedString("Forgot password?", comment: "")
                let alertMessage = NSLocalizedString("Button tapped", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        /*
        A login step provides a form step that is populated with email and password fields,
        and a button for `Forgot password?`.
        */
        let loginTitle = NSLocalizedString("Login", comment: "")
        let loginStep = ORKLoginStep(identifier: String(describing: Identifier.loginStep), title: loginTitle, text: exampleDetailText, loginViewControllerClass: LoginViewController.self)
        
        /*
        A wait step allows you to validate the data from the user login against your server before proceeding.
        */
        let waitTitle = NSLocalizedString("Logging in", comment: "")
        let waitText = NSLocalizedString("Please wait while we validate your credentials", comment: "")
        let waitStep = ORKWaitStep(identifier: String(describing: Identifier.loginWaitStep))
        waitStep.title = waitTitle
        waitStep.text = waitText
        
        return ORKOrderedTask(identifier: String(describing: Identifier.loginTask), steps: [loginStep, waitStep])
    }
    
    /// This task demonstrates the Passcode creation process.
    private var passcodeTask: ORKTask {
        /*
        If you want to protect the app using a passcode. It is reccomended to
        ask user to create passcode as part of the consent process and use the
        authentication and editing view controllers to interact with the passcode.
        
        The passcode is stored in the keychain.
        */
        let passcodeConsentStep = ORKPasscodeStep(identifier: String(describing: Identifier.passcodeStep))
        passcodeConsentStep.title = NSLocalizedString("Passcode", comment: "")
        return ORKOrderedTask(identifier: String(describing: Identifier.passcodeTask), steps: [passcodeConsentStep])
    }
    
    /// This task presents the Audio pre-defined active task.
    private var audioTask: ORKTask {
        return ORKOrderedTask.audioTask(withIdentifier: String(describing: Identifier.audioTask), intendedUseDescription: exampleDescription, speechInstruction: exampleSpeechInstruction, shortSpeechInstruction: exampleSpeechInstruction, duration: 20, recordingSettings: nil, checkAudioLevel: true, options: [])
    }
    
    /**
        Amsler Grid
     */
    private var amslerGridTask: ORKTask {
        return ORKOrderedTask.amslerGridTask(withIdentifier: String(describing: Identifier.amslerGridTask), intendedUseDescription: exampleDescription, options: [])
    }
    
    /**
        This task presents the Fitness pre-defined active task. For this example,
        short walking and rest durations of 20 seconds each are used, whereas more
        realistic durations might be several minutes each.
    */
    private var fitnessTask: ORKTask {
        return ORKOrderedTask.fitnessCheck(withIdentifier: String(describing: Identifier.fitnessTask), intendedUseDescription: exampleDescription, walkDuration: 20, restDuration: 20, options: [])
    }
    
    /// This task presents the Hole Peg Test pre-defined active task.
    private var holePegTestTask: ORKTask {
        return ORKNavigableOrderedTask.holePegTest(withIdentifier: String(describing: Identifier.holePegTestTask), intendedUseDescription: exampleDescription, dominantHand: .right, numberOfPegs: 9, threshold: 0.2, rotated: false, timeLimit: 300, options: [])
    }
    
    /// This task presents the PSAT pre-defined active task.
    private var PSATTask: ORKTask {
        return ORKOrderedTask.psatTask(withIdentifier: String(describing: Identifier.psatTask), intendedUseDescription: exampleDescription, presentationMode: ORKPSATPresentationMode.auditory.union(.visual), interStimulusInterval: 3.0, stimulusDuration: 1.0, seriesLength: 60, options: [])
    }
    
    /// This task presents the Reaction Time pre-defined active task.
    private var reactionTimeTask: ORKTask {
        /// An example of a custom sound.
        let successSoundURL = Bundle.main.url(forResource: "tap", withExtension: "aif")!
        let successSound = SystemSound(soundURL: successSoundURL)!
        return ORKOrderedTask.reactionTime(withIdentifier: String(describing: Identifier.reactionTime), intendedUseDescription: exampleDescription, maximumStimulusInterval: 10, minimumStimulusInterval: 4, thresholdAcceleration: 0.5, numberOfAttempts: 3, timeout: 3, successSound: successSound.soundID, timeoutSound: 0, failureSound: UInt32(kSystemSoundID_Vibrate), options: [])
    }
    
    /// This task presents the Gait and Balance pre-defined active task.
    private var shortWalkTask: ORKTask {
        return ORKOrderedTask.shortWalk(withIdentifier: String(describing: Identifier.shortWalkTask), intendedUseDescription: exampleDescription, numberOfStepsPerLeg: 20, restDuration: 20, options: [])
    }
    
    /// This task presents the Spatial Span Memory pre-defined active task.
    private var spatialSpanMemoryTask: ORKTask {
        return ORKOrderedTask.spatialSpanMemoryTask(withIdentifier: String(describing: Identifier.spatialSpanMemoryTask), intendedUseDescription: exampleDescription, initialSpan: 3, minimumSpan: 2, maximumSpan: 15, playSpeed: 1.0, maximumTests: 5, maximumConsecutiveFailures: 3, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: [])
    }
    
    /// This task presents the Speech Recognition pre-defined active task.
    private var speechRecognitionTask: ORKTask {
        return ORKOrderedTask.speechRecognitionTask(withIdentifier: String(describing: Identifier.speechRecognitionTask), intendedUseDescription: exampleDescription, speechRecognizerLocale: .englishUS, speechRecognitionImage: nil, speechRecognitionText: NSLocalizedString("A quick brown fox jumps over the lazy dog.", comment: ""), shouldHideTranscript: false, allowsEdittingTranscript: true, options: [])
    }
    
    /// This task presents the Speech in Noise pre-defined active task.
    private var speechInNoiseTask: ORKTask {
        return ORKOrderedTask.speechInNoiseTask(withIdentifier: String(describing: Identifier.speechInNoiseTask), intendedUseDescription: nil, options: [])
    }
    
    /// This task presents the Stroop pre-defined active task.
    private var stroopTask: ORKTask {
        return ORKOrderedTask.stroopTask(withIdentifier: String(describing: Identifier.stroopTask), intendedUseDescription: exampleDescription, numberOfAttempts: 10, options: [])
    }
    
    /// This task presents the swift Stroop pre-defined active task.
    private var swiftStroopTask: ORKTask {
        let instructionStep = ORKInstructionStep(identifier: "stroopInstructionStep")
        instructionStep.title = "Stroop"
        instructionStep.text = "Your description goes here."
        instructionStep.image = UIImage(named: "stroop")
        instructionStep.imageContentMode = .center
        instructionStep.detailText = "Every time a word appears, select the first letter of the name of the COLOR that is shown."
        
        let instructionStep2 = ORKInstructionStep(identifier: "stroopInstructionStep2")
        instructionStep2.title = "Stroop"
        instructionStep2.text = "Your description goes here."
        instructionStep2.detailText = "Every time a word appears, select the first letter of the name of the COLOR that is shown."
        instructionStep2.image = UIImage(named: "stroop")
        instructionStep2.imageContentMode = .center
        
        let countdownStep = ORKCountdownStep(identifier: "stroopCountdownStep")
        countdownStep.title = "Stroop"
        
        let stroopStep = ORKSwiftStroopStep(identifier: "stroopStep")
        stroopStep.numberOfAttempts = 10
        stroopStep.title = "Stroop"
        stroopStep.text = "Select the first letter of the name of the COLOR that is shown."
        stroopStep.spokenInstruction = stroopStep.text
        
        let completionStep = ORKCompletionStep(identifier: "stroopCompletionStep")
        completionStep.title = "Activity Complete"
        completionStep.text = "Your data will be analyzed and you will be notified when your results are ready."
        
        return ORKOrderedTask(identifier: "stroopTask", steps: [instructionStep, instructionStep2, countdownStep, stroopStep, completionStep])
    }

    /// This task presents the Timed Walk with turn around pre-defined active task.
    private var timedWalkWithTurnAroundTask: ORKTask {
        return ORKOrderedTask.timedWalk(withIdentifier: String(describing: Identifier.timedWalkWithTurnAroundTask), intendedUseDescription: exampleDescription, distanceInMeters: 100.0, timeLimit: 180.0, turnAroundTimeLimit: 60.0, includeAssistiveDeviceForm: true, options: [])
    }

    /// This task presents the Tone Audiometry pre-defined active task.
    private var toneAudiometryTask: ORKTask {
        return ORKOrderedTask.toneAudiometryTask(withIdentifier: String(describing: Identifier.toneAudiometryTask), intendedUseDescription: exampleDescription, speechInstruction: nil, shortSpeechInstruction: nil, toneDuration: 20, options: [])
    }
    
    /// This task presents the dBHL Tone Audiometry pre-defined active task.
    private var dBHLToneAudiometryTask: ORKTask {
        return ORKOrderedTask.dBHLToneAudiometryTask(withIdentifier: String(describing: Identifier.dBHLToneAudiometryTask), intendedUseDescription: nil, options: [])
    }
    
    /// This task presents the environment spl meter step.
    private var splMeterTask: ORKTask {
        let splMeterStep = ORKEnvironmentSPLMeterStep(identifier: String(describing: Identifier.splMeterStep))
        splMeterStep.samplingInterval = 2
        splMeterStep.requiredContiguousSamples = 10
        splMeterStep.thresholdValue = 60
        splMeterStep.title = NSLocalizedString("SPL Meter", comment: "")
        return ORKOrderedTask(identifier: String(describing: Identifier.splMeterTask), steps: [splMeterStep])
    }

    private var towerOfHanoiTask: ORKTask {
        return ORKOrderedTask.towerOfHanoiTask(withIdentifier: String(describing: Identifier.towerOfHanoi), intendedUseDescription: exampleDescription, numberOfDisks: 5, options: [])
    }
    
    /// This task presents the Two Finger Tapping pre-defined active task.
    private var twoFingerTappingIntervalTask: ORKTask {
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: String(describing: Identifier.twoFingerTappingIntervalTask), intendedUseDescription: exampleDescription, duration: 10,
        handOptions: [.both], options: [])
    }
    
    /// This task presents a walk back-and-forth task
    private var walkBackAndForthTask: ORKTask {
        return ORKOrderedTask.walkBackAndForthTask(withIdentifier: String(describing: Identifier.walkBackAndForthTask), intendedUseDescription: exampleDescription, walkDuration: 30, restDuration: 30, options: [])
    }
    
    /// This task presents the Tremor Test pre-defined active task.
    private var tremorTestTask: ORKTask {
        return ORKOrderedTask.tremorTest(withIdentifier: String(describing: Identifier.tremorTestTask),
                                                           intendedUseDescription: exampleDescription,
                                                           activeStepDuration: 10,
                                                           activeTaskOptions: [],
                                                           handOptions: [.both],
                                                           options: [])
    }
    
    /// This task presents a knee range of motion task
    private var kneeRangeOfMotion: ORKTask {
        return ORKOrderedTask.kneeRangeOfMotionTask(withIdentifier: String(describing: Identifier.kneeRangeOfMotion), limbOption: .right, intendedUseDescription: exampleDescription, options: [])
    }
    
    /// This task presents a shoulder range of motion task
    private var shoulderRangeOfMotion: ORKTask {
        return ORKOrderedTask.shoulderRangeOfMotionTask(withIdentifier: String(describing: Identifier.shoulderRangeOfMotion), limbOption: .left, intendedUseDescription: exampleDescription, options: [])
    }
    
    /// This task presents a trail making task
    private var trailMaking: ORKTask {
        let intendedUseDescription = "Tests visual attention and task switching"
        return ORKOrderedTask.trailmakingTask(withIdentifier: String(describing: Identifier.trailMaking), intendedUseDescription: intendedUseDescription, trailmakingInstruction: nil, trailType: .B, options: [])
    }

    // This task presents a visual acuity landolt C task
    private var visualAcuityLandoltC: ORKTask {
        let orderedTask = ORKOrderedTask.landoltCVisualAcuityTask(withIdentifier: String(describing: Identifier.visualAcuityLandoltC), intendedUseDescription: "lorem ipsum")
        return orderedTask
    }
    
    // This task presents a contrast sensitivity peak landolt C task
    private var contrastSensitivityPeakLandoltC: ORKTask {
        let orderedTask = ORKOrderedTask.landoltCContrastSensitivityTask(withIdentifier: String(describing: Identifier.contrastSensitivityPeakLandoltC), intendedUseDescription: "lorem ipsum")
        return orderedTask
    }
    
    /// This task presents a video instruction step
    private var videoInstruction: ORKTask {
        let videoInstructionStep = ORKVideoInstructionStep(identifier: String(describing: Identifier.videoInstructionStep))
        videoInstructionStep.title = NSLocalizedString("Video Instruction Step", comment: "")
        videoInstructionStep.videoURL = URL(string: "https://www.apple.com/media/us/researchkit/2016/a63aa7d4_e6fd_483f_a59d_d962016c8093/films/carekit/researchkit-carekit-cc-us-20160321_r848-9dwc.mov")
        videoInstructionStep.thumbnailTime = 2 // Customizable thumbnail timestamp
        return ORKOrderedTask(identifier: String(describing: Identifier.videoInstructionTask), steps: [videoInstructionStep])
    }
    

    /// This task presents a video instruction step
    private var frontFacingCameraStep: ORKTask {
        let frontFacingCameraStep = ORKFrontFacingCameraStep(identifier: String(describing: Identifier.frontFacingCameraStep))
        frontFacingCameraStep.maximumRecordingLimit = 30.0
        frontFacingCameraStep.title = "Front Facing Camera Step"
        frontFacingCameraStep.text = "Your text goes here."
        frontFacingCameraStep.allowsRetry = true
        frontFacingCameraStep.allowsReview = true

        return ORKOrderedTask(identifier: String(describing: Identifier.videoInstructionTask), steps: [frontFacingCameraStep])
    }
    
    
    /// This task presents a web view step
    private var webView: ORKTask {
        let webViewStep = ORKWebViewStep(identifier: String(describing: Identifier.webViewStep), html: exampleHtml)
        webViewStep.title = NSLocalizedString("Web View", comment: "")
        webViewStep.showSignatureAfterContent = true
        return ORKOrderedTask(identifier: String(describing: Identifier.webViewTask), steps: [webViewStep])
    }
    
    // MARK: Consent Document Creation Convenience
    
    /**
        A consent document provides the content for the visual consent and consent
        review steps. This helper sets up a consent document with some dummy
        content. You should populate your consent document to suit your study.
    */
    private var consentDocument: ORKConsentDocument {
        let consentDocument = ORKConsentDocument()
        
        /*
            This is the title of the document, displayed both for review and in
            the generated PDF.
        */
        consentDocument.title = NSLocalizedString("Example Consent", comment: "")
        
        // This is the title of the signature page in the generated document.
        consentDocument.signaturePageTitle = NSLocalizedString("Consent", comment: "")
        
        /*
            This is the line shown on the signature page of the generated document,
            just above the signatures.
        */
        consentDocument.signaturePageContent = NSLocalizedString("I agree to participate in this research study.", comment: "")
        
        /*
            Add the participant signature, which will be filled in during the
            consent review process. This signature initially does not have a
            signature image or a participant name; these are collected during
            the consent review step.
        */
        let participantSignatureTitle = NSLocalizedString("Participant", comment: "")
        let participantSignature = ORKConsentSignature(forPersonWithTitle: participantSignatureTitle, dateFormatString: nil, identifier: String(describing: Identifier.consentDocumentParticipantSignature))
        
        consentDocument.addSignature(participantSignature)
        
        /*
            Add the investigator signature. This is pre-populated with the
            investigator's signature image and name, and the date of their
            signature. If you need to specify the date as now, you could generate
            a date string with code here.
          
            This signature is only used for the generated PDF.
        */
        let signatureImage = UIImage(named: "signature")!
        let investigatorSignatureTitle = NSLocalizedString("Investigator", comment: "")
        let investigatorSignatureGivenName = NSLocalizedString("Jonny", comment: "")
        let investigatorSignatureFamilyName = NSLocalizedString("Appleseed", comment: "")
        let investigatorSignatureDateString = "3/10/15"

        let investigatorSignature = ORKConsentSignature(forPersonWithTitle: investigatorSignatureTitle, dateFormatString: nil, identifier: String(describing: Identifier.consentDocumentInvestigatorSignature), givenName: investigatorSignatureGivenName, familyName: investigatorSignatureFamilyName, signatureImage: signatureImage, dateString: investigatorSignatureDateString)
        
        consentDocument.addSignature(investigatorSignature)
        
        /*
            This is the HTML content for the "Learn More" page for each consent
            section. In a real consent, this would be your content, and you would
            have different content for each section.
          
            If your content is just text, you can use the `content` property
            instead of the `htmlContent` property of `ORKConsentSection`.
        */
        let htmlContentString = "<ul><li>Lorem</li><li>ipsum</li><li>dolor</li></ul><p>\(loremIpsumLongText)</p><p>\(loremIpsumMediumText)</p>"
        
        /*
            These are all the consent section types that have pre-defined animations
            and images. We use them in this specific order, so we see the available
            animated transitions.
        */
        let consentSectionTypes: [ORKConsentSectionType] = [
            .overview,
            .dataGathering,
            .privacy,
            .dataUse,
            .timeCommitment,
            .studySurvey,
            .studyTasks,
            .withdrawing
        ]
        
        /*
            For each consent section type in `consentSectionTypes`, create an
            `ORKConsentSection` that represents it.

            In a real app, you would set specific content for each section.
        */
        var consentSections: [ORKConsentSection] = consentSectionTypes.map { contentSectionType in
            let consentSection = ORKConsentSection(type: contentSectionType)
            
            consentSection.summary = loremIpsumShortText
            
            if contentSectionType == .overview {
                consentSection.htmlContent = htmlContentString
            } else {
                consentSection.content = loremIpsumLongText
            }
            
            return consentSection
        }
        
        /*
            This is an example of a section that is only in the review document
            or only in the generated PDF, and is not displayed in `ORKVisualConsentStep`.
        */
        let consentSection = ORKConsentSection(type: .onlyInDocument)
        consentSection.summary = NSLocalizedString(".OnlyInDocument Scene Summary", comment: "")
        consentSection.title = NSLocalizedString(".OnlyInDocument Scene", comment: "")
        consentSection.content = loremIpsumLongText
        
        consentSections += [consentSection]
        
        // Set the sections on the document after they've been created.
        consentDocument.sections = consentSections
        
        return consentDocument
    }
    
    // MARK: `ORKTask` Reused Text Convenience
    
    private var exampleDescription: String {
        return NSLocalizedString("Your description goes here.", comment: "")
    }
    
    private var exampleSpeechInstruction: String {
        return NSLocalizedString("Your more specific voice instruction goes here. For example, say 'Aaaah'.", comment: "")
    }
    
    private var exampleQuestionText: String {
        return NSLocalizedString("Your question goes here.", comment: "")
    }
    
    private var exampleHighValueText: String {
        return NSLocalizedString("High Value", comment: "")
    }
    
    private var exampleLowValueText: String {
        return NSLocalizedString("Low Value", comment: "")
    }
    
    private var exampleDetailText: String {
        return NSLocalizedString("Additional text can go here.", comment: "")
    }
    
    private var exampleEmailText: String {
        return NSLocalizedString("jappleseed@example.com", comment: "")
    }
    
    private var loremIpsumText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    }
    
    private var loremIpsumShortText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    }
    
    private var loremIpsumMediumText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?"
    }
    
    private var loremIpsumLongText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?"
    }
    
    private var exampleHtml: String {
        return """
        <!DOCTYPE html>

        <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <meta name="viewport" content="width=400, user-scalable=no">
            <meta charset="utf-8" />
            <style type="text/css">
            body
            {
                background: #FFF;
                font-family: Helvetica, sans-serif;
                text-align: center;
            }

            .container
            {
                width: 100%;
                padding: 10px;
                box-sizing: border-box;
            }

            .answer-box
            {
                width: 100%;
                box-sizing: border-box;
                padding: 10px;
                border: solid 1px #ddd;
                border-radius: 2px;
                -webkit-appearance: none;
            }

            .continue-button
            {
                width: 140px;
                text-align: center;
                padding-top: 10px;
                padding-bottom: 10px;
                font-size: 16px;
                color: #2e6e9e;
                border-radius: 2px;
                border: solid 1px #2e6e9e;
                background: #FFF;
                cursor: pointer;
                margin-top: 40px;
            }
            </style>
            <script type="text/javascript">
            function completeStep() {
                var answer = document.getElementById("answer").value;
                window.webkit.messageHandlers.ResearchKit.postMessage(answer);
            }
            </script>
        </head>
        <body>
            <div class="container">
                <input type="text" id="answer" class="answer-box" placeholder="Answer" />
                <button onclick="completeStep();" class="continue-button">Continue</button>
            </div>
        </body>
        </html>
        """
    }
}
