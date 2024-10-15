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

import AudioToolbox
import ResearchKit
import ResearchKit_Private
import ResearchKitActiveTask
import ResearchKitActiveTask_Private
import ResearchKitUI

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
    case groupedFormNoScroll
    case survey
    case dontknowSurvey
    case surveyWithMultipleOptions
    case booleanQuestion
    case customBooleanQuestion
    case dateQuestion
    case dateTimeQuestion
    case date3DayLimitQuestionTask
    case imageChoiceQuestion
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
    case locationQuestion
#endif
    case numericQuestion
    case scaleQuestion
    case textQuestion
    case textChoiceQuestion
    case textChoiceQuestionWithImageTask
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
    case accountCreation
    case login
    case passcode
    case biometricPasscode
    case audio
    case amslerGrid
    case tecumsehCubeTest
    case sixMinuteWalk
    case fitness
    case holePegTest
    case psat
    case reactionTime
    case normalizedReactionTime
    case shortWalk
    case spatialSpanMemory
    case speechRecognition
    case speechInNoise
    case stroop
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
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    case healthQuantity
#endif
    case kneeRangeOfMotion
    case shoulderRangeOfMotion
    case trailMaking
    case videoInstruction
    case review
    case webView
    case consentTask
    case consentDoc
    case usdzModel
    case ageQuestion
    case colorChoiceQuestion
    case familyHistory
    
    
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
        
        var defaultSections = [
            TaskListRowSection(title: "Surveys", rows:
                [
                    .dontknowSurvey,
                    .groupedForm,
                    .groupedFormNoScroll,
                    .form,
                    .survey,
                    .surveyWithMultipleOptions
                ]),
            TaskListRowSection(title: "Survey Questions", rows:
                [
                    .ageQuestion,
                    .booleanQuestion,
                    .colorChoiceQuestion,
                    .customBooleanQuestion,
                    .dateTimeQuestion,
                    .dateQuestion,
                    .date3DayLimitQuestionTask,
                    .familyHistory,
                    .heightQuestion,
                    .imageChoiceQuestion,
                    .numericQuestion,
                    .scaleQuestion,
                    .textChoiceQuestion,
                    .textChoiceQuestionWithImageTask,
                    .textQuestion,
                    .timeIntervalQuestion,
                    .timeOfDayQuestion,
                    .validatedTextQuestion,
                    .valuePickerChoiceQuestion,
                    .weightQuestion,
                ]),
            TaskListRowSection(title: "Onboarding", rows:
                [
                    .accountCreation,
                    .biometricPasscode,
                    .consentDoc,
                    .consentTask,
                    .eligibilityTask,
                    .login,
                    .passcode,
                    .review
                ]),
            TaskListRowSection(title: "Miscellaneous", rows:
                [
                    .frontFacingCamera,
                    .imageCapture,
                    .PDFViewer,
                    .requestPermissions,
                    .usdzModel,
                    .videoCapture,
                    .videoInstruction,
                    .wait,
                    .webView
                ]),
            TaskListRowSection(title: "Active Tasks", rows:
                [
                    .audio,
                    .amslerGrid,
                    .dBHLToneAudiometry,
                    .fitness,
                    .holePegTest,
                    .kneeRangeOfMotion,
                    .normalizedReactionTime,
                    .psat,
                    .reactionTime,
                    .shortWalk,
                    .shoulderRangeOfMotion,
                    .sixMinuteWalk,
                    .spatialSpanMemory,
                    .speechInNoise,
                    .speechRecognition,
                    .splMeter,
                    .stroop,
                    .tecumsehCubeTest,
                    .timedWalkWithTurnAround,
                    .toneAudiometry,
                    .towerOfHanoi,
                    .tremorTest,
                    .twoFingerTappingInterval,
                    .walkBackAndForth,
                ])]
        
        
            #if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
             let healthSections:[TaskListRowSection] = [
                 TaskListRowSection(title: "Health", rows:
                     [
                         .healthQuantity
                     ])
             ]
             defaultSections = defaultSections + healthSections
             #endif
            
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
        let locationSections:[TaskListRowSection] = [
            TaskListRowSection(title: "Location", rows:
                [
                    .locationQuestion,
                ])
            ]
        defaultSections = defaultSections + locationSections
#endif
        
            return defaultSections
        }
    
    // MARK: CustomStringConvertible
    
    var description: String {
        switch self {
        case .form:
            return NSLocalizedString("Form Survey", comment: "")
            
        case .groupedForm:
            return NSLocalizedString("Grouped Form Survey", comment: "")
            
        case .groupedFormNoScroll:
            return NSLocalizedString("Grouped Form Survey No AutoScroll", comment: "")

        case .survey:
            return NSLocalizedString("Simple Survey", comment: "")
            
        case .dontknowSurvey:
            return NSLocalizedString("Don't Know Survey", comment: "")
            
        case .booleanQuestion:
            return NSLocalizedString("Boolean Question", comment: "")
            
        case .customBooleanQuestion:
            return NSLocalizedString("Custom Boolean Question", comment: "")

        case .dateQuestion:
            return NSLocalizedString("Date Question", comment: "")
            
        case .dateTimeQuestion:
            return NSLocalizedString("Date and Time Question", comment: "")
            
        case .date3DayLimitQuestionTask:
            return NSLocalizedString("Date and Time 3 day Limit Question", comment: "")

        case .heightQuestion:
            return NSLocalizedString("Height Question", comment: "")
    
        case .weightQuestion:
            return NSLocalizedString("Weight Question", comment: "")
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        case .healthQuantity:
            return NSLocalizedString("Health Quantity Question", comment: "")
#endif
        case .imageChoiceQuestion:
            return NSLocalizedString("Image Choice Question", comment: "")
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
        case .locationQuestion:
            return NSLocalizedString("Location Question", comment: "")
#endif
            
        case .numericQuestion:
            return NSLocalizedString("Numeric Question", comment: "")
            
        case .scaleQuestion:
            return NSLocalizedString("Scale Question", comment: "")
            
        case .textQuestion:
            return NSLocalizedString("Text Question", comment: "")
            
        case .textChoiceQuestion:
            return NSLocalizedString("Text Choice Question", comment: "")
        
        case .textChoiceQuestionWithImageTask:
            return NSLocalizedString("Text Choice Image Question", comment: "")
            
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

        case .review:
            return NSLocalizedString("Review Step", comment: "")
            
        case .eligibilityTask:
            return NSLocalizedString("Eligibility Task Example", comment: "")

        case .accountCreation:
            return NSLocalizedString("Account Creation", comment: "")
        
        case .login:
            return NSLocalizedString("Login", comment: "")

        case .passcode:
            return NSLocalizedString("Passcode Creation", comment: "")
        
        case .biometricPasscode:
            return NSLocalizedString("Biometric Passcode Creation and Authorization", comment: "")
            
        case .audio:
            return NSLocalizedString("Audio", comment: "")
        
        case .amslerGrid:
            return NSLocalizedString("Amsler Grid", comment: "")

        case .tecumsehCubeTest:
            return NSLocalizedString("Tecumseh Cube Test", comment: "")

        case .sixMinuteWalk:
            return NSLocalizedString("Six Minute Walk", comment: "")

        case .fitness:
            return NSLocalizedString("Fitness Check", comment: "")
        
        case .holePegTest:
            return NSLocalizedString("Hole Peg Test", comment: "")
            
        case .psat:
            return NSLocalizedString("PSAT", comment: "")
            
        case .reactionTime:
            return NSLocalizedString("Reaction Time", comment: "")
        
        case .normalizedReactionTime:
            return NSLocalizedString("Normalized Reaction Time", comment: "")

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
            
        case .webView:
            return NSLocalizedString("Web View", comment: "")
            
        case .consentTask:
            return NSLocalizedString("Consent Task", comment: "")
            
        case .consentDoc:
            return NSLocalizedString("Consent Document Review", comment: "")
            
        case .usdzModel:
            return NSLocalizedString("USDZ Model", comment: "")
            
        case .ageQuestion:
            return NSLocalizedString("Age Question", comment: "")
            
        case .colorChoiceQuestion:
            return NSLocalizedString("Color Choice Question", comment: "")
        
        case .familyHistory:
            return NSLocalizedString("Family History Step", comment: "")
            
            
        case .surveyWithMultipleOptions:
            return NSLocalizedString("Survey With Multiple Options", comment: "")
        }
    }
    
    // MARK: Properties
    
    /// Returns a new `ORKTask` that the `TaskListRow` enumeration represents.
    var representedTask: ORKTask {
        switch self {
        case .form:
            return formTask
            
        case .groupedForm:
            return groupedFormTask
            
        case .groupedFormNoScroll:
            return groupedFormTaskNoScroll
    
        case .surveyWithMultipleOptions:
            return formTaskWithMultipleOptions
            
        case .survey:
            return surveyTask
            
        case .dontknowSurvey:
            return dontKnowTask
            
        case .booleanQuestion:
            return booleanQuestionTask
            
        case .customBooleanQuestion:
            return customBooleanQuestionTask
            
        case .dateQuestion:
            return dateQuestionTask
            
        case .dateTimeQuestion:
            return dateTimeQuestionTask
            
        case .date3DayLimitQuestionTask:
            return dateLimited3DayQuestionTask

        case .heightQuestion:
            return heightQuestionTask
            
        case .weightQuestion:
            return weightQuestionTask
  
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        case .healthQuantity:
            return healthQuantityTypeTask
#endif
            
        case .imageChoiceQuestion:
            return imageChoiceQuestionTask
            
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
        case .locationQuestion:
            return locationQuestionTask
#endif
            
        case .numericQuestion:
            return numericQuestionTask
            
        case .review:
            return reviewTask
            
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
            
        case .accountCreation:
            return accountCreationTask
            
        case .login:
            return loginTask

        case .passcode:
            return passcodeTask
        
        case .biometricPasscode:
            return biometricPasscodeTask
            
        case .audio:
            return audioTask
            
        case .amslerGrid:
            return amslerGridTask

        case .tecumsehCubeTest:
            return tecumsehCubeTestTask

        case .sixMinuteWalk:
            return sixMinuteWalkTask

        case .fitness:
            return fitnessTask
            
        case .holePegTest:
            return holePegTestTask
            
        case .psat:
            return PSATTask
            
        case .reactionTime:
            return reactionTimeTask
        
        case .normalizedReactionTime:
            return normalizedReactionTimeTask
            
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
        
        case .videoInstruction:
            return videoInstruction
            
        case .webView:
            return webView
            
        case .consentTask:
            return consentTask
            
        case .consentDoc:
            return consentDoc
            
        case .usdzModel:
            return usdzModel
            
        case .ageQuestion:
            return ageQuestionTask
            
        case .colorChoiceQuestion:
            return colorChoiceQuestionTask
            
        case .familyHistory:
            return familyHistoryTask
            
        case .textChoiceQuestionWithImageTask:
            return textChoiceQuestionWithImageTask

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
        let step = ORKFormStep(identifier: String(describing: Identifier.formStep), title: NSLocalizedString("Form Step", comment: ""), text: TaskListRowStrings.exampleDetailText)

        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("Field01", comment: "")
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.formItem01), text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem01.placeholder = NSLocalizedString("Your placeholder here", comment: "")

        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString("Field02", comment: "")
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.formItem02), text: formItem02Text, answerFormat: ORKTimeIntervalAnswerFormat())
        formItem02.placeholder = NSLocalizedString("Your placeholder here", comment: "")

        let formItem03Text = TaskListRowStrings.exampleQuestionText
        let scaleAnswerFormat = ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1)//ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1)
        scaleAnswerFormat.shouldHideRanges = true
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.formItem03), text: formItem03Text, answerFormat: scaleAnswerFormat)

        let textChoices: [ORKTextChoice] = [
            ORKTextChoice(text: "choice 1", detailText: "detail 1", value: 1 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 2", detailText: "detail 2", value: 2 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 3", detailText: "detail 3", value: 3 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 4", detailText: "detail 4", value: 4 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 5", detailText: "detail 5", value: 5 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 6", detailText: "detail 6", value: 6 as NSNumber, exclusive: false),
            ORKTextChoiceOther.choice(withText: "choice 7", detailText: "detail 7", value: "choice 7" as NSString, exclusive: true, textViewPlaceholderText: "enter additional information")
        ]
        
        let textScaleAnswerFormat = ORKTextScaleAnswerFormat(textChoices: textChoices, defaultIndex: 10)
        textScaleAnswerFormat.shouldHideLabels = true
        textScaleAnswerFormat.shouldShowDontKnowButton = true
        let formItem04 = ORKFormItem(identifier: String(describing: Identifier.formItem04), text: TaskListRowStrings.exampleQuestionText, answerFormat: textScaleAnswerFormat)
        
        let textChoiceAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        textChoiceAnswerFormat.shouldShowDontKnowButton = true
        let textChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.textChoiceFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: textChoiceAnswerFormat)
        
        
        let appleChoices: [ORKTextChoice] = [ORKTextChoice(text: "Granny Smith", value: 1 as NSNumber), ORKTextChoice(text: "Honeycrisp", value: 2 as NSNumber), ORKTextChoice(text: "Fuji", value: 3 as NSNumber), ORKTextChoice(text: "McIntosh", value: 10 as NSNumber), ORKTextChoice(text: "Kanzi", value: 5 as NSNumber)]
        
        let appleAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: appleChoices)
        
        let appleFormItem = ORKFormItem(identifier: String(describing: Identifier.appleFormItemIdentifier), text: "Which is your favorite apple?", answerFormat: appleAnswerFormat)
        
        let roundShapeImage = UIImage(named: "round_shape")!
        let roundShapeText = NSLocalizedString("Round Shape", comment: "")
        
        let squareShapeImage = UIImage(named: "square_shape")!
        let squareShapeText = NSLocalizedString("Square Shape", comment: "")
        
        let imageChoices = [
            ORKImageChoice(normalImage: roundShapeImage, selectedImage: nil, text: roundShapeText, value: roundShapeText as NSString),
            ORKImageChoice(normalImage: squareShapeImage, selectedImage: nil, text: squareShapeText, value: squareShapeText as NSString)
        ]
        
        let imageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices)
        let imageChoiceItem = ORKFormItem(identifier: String(describing: Identifier.imageChoiceItem), text: "Enter your favorite shape", answerFormat: imageChoiceAnswerFormat)
        
        let freeTextSection = ORKFormItem(identifier: String(describing: Identifier.freeTextSectionIdentifier), text: "Enter your text below", answerFormat: nil)
        
        let freeTextAnswerFormat = ORKAnswerFormat.textAnswerFormat(withMaximumLength: 200)
        freeTextAnswerFormat.multipleLines = true
        
        let freeTextItem = ORKFormItem(identifier:String(describing: Identifier.freeTextItemIdentifier), text: nil, answerFormat: freeTextAnswerFormat)
        
        step.formItems = [
            appleFormItem,
            formItem03,
            formItem04,
            formItem01,
            formItem02,
            textChoiceFormItem,
            imageChoiceItem,
            freeTextSection,
            freeTextItem
        ]
        let completionStep = ORKCompletionStep(identifier:  String(describing: Identifier.completionStep))
        completionStep.title = NSLocalizedString("All Done!", comment: "")
        completionStep.detailText = NSLocalizedString("You have completed the questionnaire.", comment: "")
        return ORKOrderedTask(identifier: String(describing: Identifier.formTask), steps: [step, completionStep])
    }
    
    private var dontKnowTask: ORKTask {
        let step = ORKFormStep(identifier: String(describing: Identifier.formStep), title: NSLocalizedString("Form Step", comment: ""), text: TaskListRowStrings.exampleDetailText)

        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("What is your Zip Code", comment: "")
        let answerFormat = ORKAnswerFormat.integerAnswerFormat(withUnit: nil)
        answerFormat.shouldShowDontKnowButton = true
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.formItem01), text: nil, answerFormat: answerFormat)
        formItem01.placeholder = NSLocalizedString("Add Zip Code", comment: "")
        
        let formItem02Text = NSLocalizedString("What is your height", comment: "")
        let answerFormat02 = ORKAnswerFormat.heightAnswerFormat()
        answerFormat02.shouldShowDontKnowButton = true
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.formItem02), text: nil, answerFormat: answerFormat02)
        formItem02.placeholder = NSLocalizedString("Add Height", comment: "")

        let formItem03Text = NSLocalizedString("What is your weight", comment: "")
        let formItem03Section = ORKFormItem(identifier: formItem03Text, text: formItem03Text, answerFormat: nil)
        
        let answerFormat03 = ORKAnswerFormat.weightAnswerFormat()
        answerFormat03.shouldShowDontKnowButton = true
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.formItem03), text: nil, answerFormat: answerFormat03)
        formItem03.placeholder = NSLocalizedString("Add Weight", comment: "")

        let formItem04Text = NSLocalizedString("What is your Attitude", comment: "")
        let answerFormat04 = ORKAnswerFormat.textAnswerFormat()
        answerFormat04.multipleLines = true
        answerFormat04.shouldShowDontKnowButton = true
        let formItem04 = ORKFormItem(identifier: String(describing: Identifier.formItem04), text: nil, answerFormat: answerFormat04)
        formItem04.placeholder = NSLocalizedString("Add your Attitude", comment: "")
        
        let formItem05Text = NSLocalizedString("What is your Pain Level", comment: "")
        let answerFormat05 = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 1, step: 1, vertical: false, maximumValueDescription: "Low", minimumValueDescription: "High")
        answerFormat05.shouldShowDontKnowButton = true
        let formItem05 = ORKFormItem(identifier: String(describing: Identifier.formItem05), text: formItem05Text, answerFormat: answerFormat05)
        formItem05.placeholder = NSLocalizedString("Pain Level", comment: "")
        
        let attitudeSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.formStep), resultIdentifier: String(describing: Identifier.formItem04))
        let predicateForAttitudeSelector = ORKResultPredicate.predicateForTextQuestionResult(with: attitudeSelector, expectedString: "Happy")
        
        let formItem06Text =  NSLocalizedString("SES Level", comment: "")
        let answerFormat06 = ORKSESAnswerFormat(topRungText: "top", bottomRungText: "bottom")
        answerFormat06.shouldShowDontKnowButton = true
        let formItem06 = ORKFormItem(identifier: String(describing: Identifier.formItem06), text: formItem06Text, answerFormat: answerFormat06)
        formItem06.placeholder = formItem06Text
        
        
        let appleChoices: [ORKTextChoice] = [ORKTextChoice(text: "Granny Smith", value: 1 as NSNumber),
                                             ORKTextChoice(text: "Honeycrisp", value: 2 as NSNumber),
                                             ORKTextChoice(text: "Fuji", value: 3 as NSNumber),
                                             ORKTextChoice(text: "McIntosh", value: 10 as NSNumber),
                                             ORKTextChoice(text: "Kanzi", value: 5 as NSNumber),
                                             ORKTextChoice(text: NSLocalizedString("I don't know", comment: ""), value: NSString("dunno"))]
        
        let appleAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: appleChoices)
        
        let appleFormItem = ORKFormItem(identifier: "appleFormItemIdentifier", text: "Which is your favorite apple?", answerFormat: appleAnswerFormat)

        appleFormItem.visibilityRule = ORKPredicateFormItemVisibilityRule(predicate: predicateForAttitudeSelector)
        formItem03Section.visibilityRule = ORKPredicateFormItemVisibilityRule(predicate: predicateForAttitudeSelector)
        formItem03.visibilityRule = ORKPredicateFormItemVisibilityRule(predicate: predicateForAttitudeSelector)

        step.formItems = [
            ORKFormItem(identifier: formItem01Text, text: formItem01Text, answerFormat: nil),
            formItem01,
            ORKFormItem(identifier: formItem02Text, text: formItem02Text, answerFormat: nil),
            formItem02,
            formItem03Section,
            formItem03,
            ORKFormItem(identifier: formItem04Text, text: formItem04Text, answerFormat: nil),
            formItem04,
            formItem05,
            formItem06,
            appleFormItem
        ]
        
        let fruitSizeStep = { step in
            step.title = NSLocalizedString("Picking Fruit", comment: "")
            let weightAnswerFormat = ORKNumericAnswerFormat(style: .integer, unit: "lb")
            weightAnswerFormat.shouldShowDontKnowButton = true

            step.formItems = [
                ORKFormItem(
                    identifier: "fruitHarvestTiming",
                    text: NSLocalizedString("Was the fruit picked early?", comment: ""),
                    answerFormat: .choiceAnswerFormat(
                        with: .singleChoice,
                        textChoices: [
                            ORKTextChoice(text: NSLocalizedString("Yes", comment: ""), value: NSString("yes")),
                            ORKTextChoice(text: NSLocalizedString("No", comment: ""), value: NSString("no")),
                            ORKTextChoice(text: NSLocalizedString("I don't know", comment: ""), value: NSString("dunno")),
                            ORKTextChoice(text: NSLocalizedString("Prefer not to answer", comment: ""), value: NSString("no_answer")),
                        ]
                    )
                ),
                ORKFormItem(sectionTitle: "What was the weight?"),
                ORKFormItem(
                    identifier: "fruitHarvestWeight",
                    text: nil,
                    answerFormat: weightAnswerFormat
                )
            ]
            return step
        }( ORKFormStep(identifier: "FruitWeightFormStep") )
        
        
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = NSLocalizedString("All Done!", comment: "")
        completionStep.detailText = NSLocalizedString("You have completed the questionnaire.", comment: "")
        return ORKOrderedTask(identifier: String(describing: Identifier.formTask), steps: [step, fruitSizeStep, completionStep])
    }
    
    private var formTaskWithMultipleOptions: ORKTask {
        let textChoices: [ORKTextChoice] = [1...50]
            .flatMap({ $0 })
            .compactMap({ index in
                ORKTextChoiceOther(text: "Option \(index)", value: index as NSNumber)
            })
                
        let steps: [ORKFormStep] = [
            {
                let step = ORKFormStep(identifier: String(describing: Identifier.formStepWithMultipleSelection), title: NSLocalizedString("Form Step with Multiple Selections", comment: ""), text: TaskListRowStrings.exampleDetailText)
                step.formItems = [
                    ORKFormItem(identifier: String(describing: Identifier.formItem01), text: TaskListRowStrings.exampleQuestionText, answerFormat: ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)),
                    ORKFormItem(identifier: String(describing: Identifier.formItem02), text: TaskListRowStrings.exampleQuestionText, answerFormat: ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices))

                ]
                return step
            }(),
            {
                let step = ORKFormStep(identifier: String(describing: Identifier.formStepWithSingleSelection), title: NSLocalizedString("Form Step with Single Selection", comment: ""), text: TaskListRowStrings.exampleDetailText)
                step.formItems = [
                    ORKFormItem(identifier: String(describing: Identifier.formItem01), text: "Select only one", answerFormat: ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices))
                ]
                return step
            }()
        ]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.surveyTaskWithMultipleSelection), steps: steps)
    }
    
    private var groupedFormTask: ORKTask {
        let step = TaskListRowSteps.groupFormExample
        
        let booleanQuestionFormStep = TaskListRowSteps.booleanExample
        
        //Add a question step with different layout format.
        let birthdayQuestionFormStep = TaskListRowSteps.birthdayExample
        
        let appleChoices: [ORKTextChoice] = [ORKTextChoice(text: "Granny Smith", value: 1 as NSNumber), ORKTextChoice(text: "Honeycrisp", value: 2 as NSNumber), ORKTextChoice(text: "Fuji", value: 3 as NSNumber), ORKTextChoice(text: "McIntosh", value: 10 as NSNumber), ORKTextChoice(text: "Kanzi", value: 5 as NSNumber)]
        
        let appleAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: appleChoices)
        
        let appleFormItem = ORKFormItem(identifier: "appleFormItemIdentifier", text: "Which is your favorite apple?", answerFormat: appleAnswerFormat)
        let conditionalFormItem = ORKFormItem(identifier: "newletterFormItemIdentifier", text: "Include apples with your newletter?", answerFormat: ORKBooleanAnswerFormat())
        conditionalFormItem.visibilityRule = ORKPredicateFormItemVisibilityRule(
            predicate: ORKResultPredicate.predicateForBooleanQuestionResult(
                with: .init(stepIdentifier: booleanQuestionFormStep.identifier, resultIdentifier: String(describing: Identifier.booleanFormItem)),
                expectedAnswer: true
            )
        )
        
        let appleFormStep = ORKFormStep(identifier: "appleFormStepIdentifier", title: "Fruit!", text: "Select the fruit you like.")
        
        appleFormStep.formItems = [
            appleFormItem,
            conditionalFormItem
        ]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.groupedFormTask), steps: [step, booleanQuestionFormStep, birthdayQuestionFormStep, appleFormStep])
    }
    
    private var groupedFormTaskNoScroll: ORKTask {
        let groupedFormStep = TaskListRowSteps.groupFormExample
        groupedFormStep.autoScrollEnabled = false
        
        return ORKOrderedTask(identifier: String(describing: Identifier.groupedFormTask), steps: [groupedFormStep])
    }

    /**
    A task demonstrating how the ResearchKit framework can be used to present a simple
    survey with an introduction, a question, and a conclusion.
    */
    private var surveyTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.introStep))
        instructionStep.title = NSLocalizedString("Simple Survey", comment: "")
        instructionStep.text = TaskListRowStrings.exampleDescription
        instructionStep.detailText = NSLocalizedString("Please use this space to provide instructions for participants.  Please make sure to provide enough information so that users can progress through the survey and complete with ease.", comment: "")
        
        let booleanQuestionFormStep = TaskListRowSteps.booleanExample
        
        //Add a question step with different layout format.
        let birthdayQuestionFormStep = TaskListRowSteps.birthdayExample
        
        let textChoiceFormStep = TaskListRowSteps.textChoiceExample
        
        let summaryStep = ORKInstructionStep(identifier: String(describing: Identifier.summaryStep))
        summaryStep.title = NSLocalizedString("Thanks", comment: "")
        summaryStep.text = NSLocalizedString("Thank you for participating in this sample survey.", comment: "")
    
        return ORKOrderedTask(identifier: String(describing: Identifier.surveyTask), steps: [
            instructionStep,
            booleanQuestionFormStep,
            birthdayQuestionFormStep,
            textChoiceFormStep,
            summaryStep
            ])
    }
    
    private var consentTask: ORKTask {
        let welcomeInstructionStep = TaskListRowSteps.consentWelcomeStepExample
        let informedConsentInstructionStep = TaskListRowSteps.informedConsentStepExample
        let webViewStep = TaskListRowSteps.webViewStepExample
        let consentSharingFormStep = TaskListRowSteps.informedConsentSharingStepExample
        
        var steps: [ORKStep] = [
            welcomeInstructionStep,
            informedConsentInstructionStep,
            webViewStep,
            consentSharingFormStep,
        ]
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        let requestPermissionStep = TaskListRowSteps.requestPermissionsStepExample
        steps.append(requestPermissionStep)
#endif
        
        let consentCompletionStep = TaskListRowSteps.consentCompletionStepExample
        steps.append(consentCompletionStep)
        
        return ORKOrderedTask(identifier: String(describing: Identifier.consentTask), steps: steps)
    }
    
    private var consentDoc: ORKTask {
        let pdfURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("consentTask")
            .appendingPathExtension("pdf")
        let pdfStep = ORKPDFViewerStep(identifier: "pdfStep", pdfURL: pdfURL)
        
        return ORKOrderedTask(identifier: String(describing: Identifier.consentDoc), steps: [pdfStep])
    }

    private var booleanQuestionTask: ORKTask {
        let booleanQuestionFormStep = TaskListRowSteps.booleanGenericExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.booleanQuestionTask), steps: [booleanQuestionFormStep])
    }
    
    /// This task presents a customized "Yes" / "No" question.
    private var customBooleanQuestionTask: ORKTask {
        // Add a question step.
        let booleanQuestionAnswerFormat = ORKBooleanAnswerFormat(yesString: "Agree", noString: "Disagree")
        
        let learnMoreInstructionStep = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep.text = NSLocalizedString("Learn more text", comment: "")
        let booleanQuestionLearnMoreItem = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep)
        
        let booleanQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.booleanFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: booleanQuestionAnswerFormat)
        booleanQuestionFormItem.learnMoreItem = booleanQuestionLearnMoreItem
        let booleanQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.booleanFormStep), title: NSLocalizedString("Custom Boolean", comment: ""), text: TaskListRowStrings.exampleDetailText)
        booleanQuestionFormStep.formItems = [booleanQuestionFormItem]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.booleanQuestionTask), steps: [booleanQuestionFormStep])
    }

    /// This task demonstrates a question which asks for a date.
    private var dateQuestionTask: ORKTask {
        /*
        The date answer format can also support minimum and maximum limits,
        a specific default value, and overriding the calendar to use.
        */
        let dateAnswerFormat = ORKAnswerFormat.dateAnswerFormat()
        
        let dateQuestionSectionHeaderFormItem = ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
        let dateQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.dateQuestionFormItem), text: nil, answerFormat: dateAnswerFormat)
        dateQuestionFormItem.placeholder = "Select Date"
        let dateQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.dateQuestionStep), title: NSLocalizedString("Date", comment: ""), text: TaskListRowStrings.exampleDetailText)
        dateQuestionFormStep.formItems = [dateQuestionSectionHeaderFormItem, dateQuestionFormItem]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.dateQuestionTask), steps: [dateQuestionFormStep])
    }
    
    /// This task demonstrates a question which asks for a date.
    private var dateLimited3DayQuestionTask: ORKTask {
        /*
        The date answer format can also support minimum and maximum limits,
        a specific default value, and overriding the calendar to use.
        */
        
        let dateAnswerFormat = ORKAnswerFormat.dateAnswerFormatWithDays(beforeCurrentDate: 3, daysAfterCurrentDate: 3, calendar: nil)
        
        let dateQuestionSectionHeaderFormItem = ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
        let dateQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.dateQuestionFormItem), text: nil, answerFormat: dateAnswerFormat)
        dateQuestionFormItem.placeholder = "Select Date"
        let dateQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.dateQuestionStep), title: NSLocalizedString("Date", comment: ""), text: TaskListRowStrings.exampleDate3DayLimitQuestionTask)
        dateQuestionFormStep.formItems = [dateQuestionSectionHeaderFormItem, dateQuestionFormItem]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.dateQuestionTask), steps: [dateQuestionFormStep])
    }
    
    /// This task demonstrates a question asking for a date and time of an event.
    private var dateTimeQuestionTask: ORKTask {
        /*
        This uses the default calendar. Use a more detailed constructor to
        set minimum / maximum limits.
        */
        
        let dateTimeAnswerFormat = ORKAnswerFormat.dateTime()
        
        let dateTimeQuestionSectionHeaderFormItem = ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
        let dateTimeQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.dateTimeQuestionFormStep), text: nil, answerFormat: dateTimeAnswerFormat)
        dateTimeQuestionFormItem.placeholder = "Select Date & Time"
        let dateTimeQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.dateTimeQuestionFormItem), title: NSLocalizedString("Date and Time", comment: ""), text: TaskListRowStrings.exampleQuestionText)
        dateTimeQuestionFormStep.formItems = [dateTimeQuestionSectionHeaderFormItem, dateTimeQuestionFormItem]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.dateTimeQuestionTask), steps: [dateTimeQuestionFormStep])
    }

    /// This task demonstrates a question asking for the user height.
    private var heightQuestionTask: ORKTask {
        let step1 = TaskListRowSteps.heightExample
        let step2 = TaskListRowSteps.heightMetricSystemExample
        let step3 = TaskListRowSteps.heightUSCSystemExample
        
        var steps = [step1, step2, step3]
        
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        let step4 = TaskListRowSteps.heightHealthKitExample
        steps.append(contentsOf:[step4])
#endif
        return ORKOrderedTask(identifier: String(describing: Identifier.heightQuestionTask), steps: steps)
    }

    /// This task demonstrates a question asking for the user weight.
    private var weightQuestionTask: ORKTask {
        let step1 = TaskListRowSteps.weightExample
        let step2 = TaskListRowSteps.weightMetricSystemExample
        let step3 = TaskListRowSteps.weightMetricSystemLowPrecisionExample
        let step4 = TaskListRowSteps.weightMetricSystemHighPrecisionExample
        let step5 = TaskListRowSteps.weightUSCSystemExample
        let step6 = TaskListRowSteps.weightUSCSystemHighPrecisionExample
        
        var steps = [step1, step2, step3, step4, step5, step6]
        
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        let step7 = TaskListRowSteps.weightHealthKitBodyMassExample
        steps.append(contentsOf:[step7])
#endif
        return ORKOrderedTask(identifier: String(describing: Identifier.weightQuestionTask), steps: steps)
    }

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    private var healthQuantityTypeTask: ORKTask {
        let heartRateQuestion = TaskListRowSteps.heartRateExample
        let bloodTypeQuestion = TaskListRowSteps.bloodTypeExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.healthQuantityTask), steps: [heartRateQuestion, bloodTypeQuestion])
    }
#endif
    
    /**
    This task demonstrates a survey question involving picking from a series of
    image choices. A more realistic applciation of this type of question might be to
    use a range of icons for faces ranging from happy to sad.
    */
    private var imageChoiceQuestionTask: ORKTask {
        let questionStep1 = TaskListRowSteps.imageChoiceExample
        let questionStep2 = TaskListRowSteps.imageChoiceVerticalExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.imageChoiceQuestionTask), steps: [questionStep1, questionStep2])
    }

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
    /// This task presents just a single location question.
    private var locationQuestionTask: ORKTask {
        let locationFormStep = TaskListRowSteps.locationExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.locationQuestionTask), steps: [locationFormStep])
    }
#endif
    
    /// This task presents a few different ORKReviewSteps
    private var reviewTask: ORKTask {
        let embeddedReviewStep = TaskListRowSteps.embeddedReviewStepExample
        
        let standAloneInstructionStep1 =  ORKInstructionStep(identifier: "standAloneInstruction1")
        standAloneInstructionStep1.text = "First Item"
        standAloneInstructionStep1.detailText = "There is a lot of detail to cover in this Instruction Step"
        
        let standAloneInstructionStep2 =  ORKInstructionStep(identifier: "standAloneInstruction2")
        standAloneInstructionStep2.text = "Second Item"
        standAloneInstructionStep2.detailText = "There is a lot of detail to cover in this Instruction Step"

        let standAloneInstructionStep3 =  ORKInstructionStep(identifier: "standAloneInstruction3")
        standAloneInstructionStep3.text = "Third Item"
        standAloneInstructionStep3.detailText = "There is a lot of detail to cover in this Instruction Step"
        
        let textAnswerFormStep = TaskListRowSteps.textAnswerExample
        
        let standAloneReviewStep = ORKReviewStep.standaloneReviewStep(withIdentifier:String(describing: Identifier.standAloneReviewStep), steps:[standAloneInstructionStep1, standAloneInstructionStep2, standAloneInstructionStep3, textAnswerFormStep], resultSource: nil)
        standAloneReviewStep.title = "Standalone Review"
        return ORKOrderedTask(identifier: String(describing: Identifier.reviewTask), steps: [embeddedReviewStep, standAloneReviewStep])
    }
    
    /**
        This task demonstrates use of numeric questions with and without units.
        Note that the unit is just a string, prompting the user to enter the value
        in the expected unit. The unit string propagates into the result object.
    */
    private var numericQuestionTask: ORKTask {
        let questionStep1 = TaskListRowSteps.decimalExample
        let questionStep2 = TaskListRowSteps.decimalNoUnitExample
        let questionStep3 = TaskListRowSteps.decimalWithDisplayUnitExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.numericQuestionTask), steps: [
            questionStep1,
            questionStep2,
            questionStep3
        ])
    }
    
    /// This task presents two options for questions displaying a scale control.
    private var scaleQuestionTask: ORKTask {
        let questionStep1 = TaskListRowSteps.scaleExample
        let questionStep2 = TaskListRowSteps.continuousScaleWithPercentExample
        let questionStep3 = TaskListRowSteps.verticalScaleWithPercentExample
        let questionStep4 = TaskListRowSteps.continuousVerticalScaleExample
        let questionStep5 = TaskListRowSteps.scaleWithTextChoicesExample
        let questionStep6 = TaskListRowSteps.verticalScaleWithTextChoicesExample
        
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
        let textFormStep = TaskListRowSteps.textMultiLineAnswerExample
        return ORKOrderedTask(identifier: String(describing: Identifier.textQuestionTask), steps: [textFormStep])
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
            ORKTextChoice(text: textChoiceOneText, value: "choice_1" as NSString),
            ORKTextChoice(text: textChoiceTwoText, value: "choice_2" as NSString),
            ORKTextChoice(text: textChoiceThreeText, value: "choice_3" as NSString),
            ORKTextChoiceOther.choice(withText: textChoiceFourText, detailText: nil, value: textChoiceFourText as NSString, exclusive: true, textViewPlaceholderText: "enter additional information")
        ]
        
        let answerFormat1 = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)

        let formItem1 = ORKFormItem(identifier: String(describing: Identifier.formItem01), text: "Select an option", answerFormat: answerFormat1)

        let formStep1 = ORKFormStep(identifier: String(describing: Identifier.formStep), title: "Your title here", text: "Your text here")
        formStep1.formItems = [formItem1]
        
        let answerFormat2 = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: textChoices)
        let formItem2 = ORKFormItem(identifier: String(describing: Identifier.formItem02), text: "Select one or more options", answerFormat: answerFormat2)
        let formStep2 = ORKFormStep(identifier: String(describing: Identifier.formStep02), title: "Your title here", text: "Your text here")
        formStep2.formItems = [formItem2]
        
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.completionStep))
        completionStep.title = "Task Complete"
        
        return ORKOrderedTask(identifier: String(describing: Identifier.textChoiceQuestionTask), steps: [formStep1, formStep2, completionStep])
    }

    private var textChoiceQuestionWithImageTask: ORKTask {
        let textChoiceFormStep = TaskListRowSteps.textChoiceImagesExample

        return ORKOrderedTask(identifier: String(describing: Identifier.textChoiceQuestionWithImageTask), steps: [textChoiceFormStep])
    }
    
    /**
        This task demonstrates requesting a time interval. For example, this might
        be a suitable answer format for a question like "How long is your morning
        commute?"
    */
    private var timeIntervalQuestionTask: ORKTask {
        let timeIntervalFormStep = TaskListRowSteps.timeIntervalExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.timeIntervalQuestionTask), steps: [timeIntervalFormStep])
    }

    /// This task demonstrates a question asking for a time of day.
    private var timeOfDayQuestionTask: ORKTask {
        let timeOfDayFormStep = TaskListRowSteps.timeOfDayExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.timeOfDayQuestionTask), steps: [timeOfDayFormStep])
    }

    /**
        This task demonstrates a survey question using a value picker wheel.
        Compare with the `textChoiceQuestionTask` and `imageChoiceQuestionTask`
        which can serve a similar purpose.
    */
    private var valuePickerChoiceQuestionTask: ORKTask {
        let valuePickerFormStep = TaskListRowSteps.valuePickerChoicesExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.valuePickerChoiceQuestionTask), steps: [valuePickerFormStep])
    }

    /**
     This task demonstrates asking for text entry. Both single and multi-line
     text entry are supported, with appropriate parameters to the text answer
     format.
     */
    private var validatedTextQuestionTask: ORKTask {
        let validatedEmailFormStep = TaskListRowSteps.emailExample
        let validatedTextFormStep = TaskListRowSteps.validatedTextExample
        
        return ORKOrderedTask(identifier: String(describing: Identifier.validatedTextQuestionTask), steps: [validatedEmailFormStep, validatedTextFormStep])
    }
    
    /// This task presents the image capture step in an ordered task.
    private var imageCaptureTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.introStep))
        
        instructionStep.title = NSLocalizedString("Image Capture Survey", comment: "")
        
        instructionStep.text = TaskListRowStrings.exampleDescription
        
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
        
        instructionStep.text = TaskListRowStrings.exampleDescription
        
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
        waitStepIndeterminate.text = "Will navigate forward after 5 seconds"
        waitStepIndeterminate.indicatorType = ORKProgressIndicatorType.indeterminate
        
        let waitStepDeterminate = ORKWaitStep(identifier: String(describing: Identifier.waitStepDeterminate))
        waitStepDeterminate.title = NSLocalizedString("Wait Step", comment: "")
        waitStepDeterminate.text = TaskListRowStrings.exampleDescription
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

        let notificationsPermissionType = ORKNotificationPermissionType(authorizationOptions: [.alert, .badge, .sound])

        let motionActivityPermissionType = ORKMotionActivityPermissionType()

        
        var permissionTypes = [notificationsPermissionType, motionActivityPermissionType]
        
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        let healthKitTypesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()]

        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.workoutType()]


        let healthKitPermissionType = ORKHealthKitPermissionType(
            sampleTypesToWrite: healthKitTypesToWrite,
            objectTypesToRead: healthKitTypesToRead
        )
        
        permissionTypes.append(healthKitPermissionType)
#endif
        
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
        let locationPermissionType = ORKLocationPermissionType()
        permissionTypes.append(locationPermissionType)
#endif
        
        let requestPermissionsStep = ORKRequestPermissionsStep(
            identifier: String(describing: Identifier.requestPermissionsStep),
            permissionTypes: permissionTypes)

        requestPermissionsStep.title = "Health Data Request"
        requestPermissionsStep.detailText = "Some details here"
        requestPermissionsStep.useExtendedPadding = false
        requestPermissionsStep.text = "Please review the health data types below and enable sharing to contribute to the study."

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
        introStep.text = TaskListRowStrings.exampleDescription
        introStep.detailText = NSLocalizedString("Please use this space to provide instructions for participants.  Please make sure to provide enough information so that users can progress through the survey and complete with ease.", comment: "")
        
        // Form step
        let formStep = ORKFormStep(identifier: String(describing: Identifier.eligibilityFormStep))
        formStep.title = NSLocalizedString("Eligibility", comment: "")
        formStep.isOptional = false
        
        // Form items
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSString), ORKTextChoice(text: "No", value: "No" as NSString), ORKTextChoice(text: "N/A", value: "N/A" as NSString)]
        let answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem01), text: TaskListRowStrings.exampleQuestionText, answerFormat: answerFormat)
        formItem01.isOptional = false
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem02), text: TaskListRowStrings.exampleQuestionText, answerFormat: answerFormat)
        formItem02.isOptional = false
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem03), text: TaskListRowStrings.exampleQuestionText, answerFormat: answerFormat)
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
        let predicateFormItem01 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "Yes" as NSString)
        
        resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep), resultIdentifier: String(describing: Identifier.eligibilityFormItem02))
        let predicateFormItem02 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "Yes" as NSString)
        
        resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep), resultIdentifier: String(describing: Identifier.eligibilityFormItem03))
        let predicateFormItem03 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "No" as NSString)
        
        let predicateEligible = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFormItem01, predicateFormItem02, predicateFormItem03])
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [ (predicateEligible, String(describing: Identifier.eligibilityEligibleStep)) ])
        
        eligibilityTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: String(describing: Identifier.eligibilityFormStep))
        
        // Add end direct rules to skip unneeded steps
        let directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
        eligibilityTask.setNavigationRule(directRule, forTriggerStepIdentifier: String(describing: Identifier.eligibilityIneligibleStep))
        
        return eligibilityTask
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
        let registrationStep = ORKRegistrationStep(identifier: String(describing: Identifier.registrationStep), title: registrationTitle, text: TaskListRowStrings.exampleDetailText, passcodeValidationRegularExpression: passcodeValidationRegularExpression, passcodeInvalidMessage: passcodeInvalidMessage, options: registrationOptions)
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
        
        let verificationStep = ORKVerificationStep(identifier: String(describing: Identifier.verificationStep), text: TaskListRowStrings.exampleDetailText, verificationViewControllerClass: VerificationViewController.self)
        
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
        let loginStep = ORKLoginStep(identifier: String(describing: Identifier.loginStep), title: loginTitle, text: TaskListRowStrings.exampleDetailText, loginViewControllerClass: LoginViewController.self)
        
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
        If you want to protect the app using a passcode. It is recommended to
        ask user to create passcode as part of the consent process and use the
        authentication and editing view controllers to interact with the passcode.
        
        The passcode is stored in the keychain.
        */
        let passcodeConsentStep = ORKPasscodeStep(identifier: String(describing: Identifier.passcodeStep))
        passcodeConsentStep.title = NSLocalizedString("Passcode", comment: "")
        return ORKOrderedTask(identifier: String(describing: Identifier.passcodeTask), steps: [passcodeConsentStep])
    }
    
    private var biometricPasscodeTask: ORKTask {
        /*
        If you want to protect the app using a passcode. It is recommended to
        ask user to create passcode as part of the consent process and use the
        authentication and editing view controllers to interact with the passcode.
        
        The passcode is stored in the keychain.
        */
        let passcodeConsentStep = ORKPasscodeStep(identifier: String(describing: Identifier.biometricPasscodeStep))
        passcodeConsentStep.useBiometrics = true
        passcodeConsentStep.title = NSLocalizedString("Passcode", comment: "")
        
        let passcodeAuthConsentStep = ORKPasscodeStep(identifier: String(describing: Identifier.biometricPasscodeStep) + "auth", passcodeFlow: .authenticate)
        passcodeAuthConsentStep.useBiometrics = true
        passcodeAuthConsentStep.title = NSLocalizedString("Passcode", comment: "")

        return ORKOrderedTask(identifier: String(describing: Identifier.biometricPasscodeTask), steps: [passcodeConsentStep, passcodeAuthConsentStep])
    }
    
    /// This task presents the Audio pre-defined active task.
    private var audioTask: ORKTask {
        return ORKOrderedTask.audioTask(withIdentifier: String(describing: Identifier.audioTask), intendedUseDescription: TaskListRowStrings.exampleDescription, speechInstruction: TaskListRowStrings.exampleSpeechInstruction, shortSpeechInstruction: TaskListRowStrings.exampleSpeechInstruction, duration: 20, recordingSettings: nil, checkAudioLevel: true, options: [])
    }
    
    /**
        Amsler Grid
     */
    private var amslerGridTask: ORKTask {
        return ORKOrderedTask.amslerGridTask(withIdentifier: String(describing: Identifier.amslerGridTask), intendedUseDescription: TaskListRowStrings.exampleDescription, options: [])
    }
    
    /**
        This task presents the Fitness pre-defined active task. For this example,
        short walking and rest durations of 20 seconds each are used, whereas more
        realistic durations might be several minutes each.
    */
    private var fitnessTask: ORKTask {
        return ORKOrderedTask.fitnessCheck(withIdentifier: String(describing: Identifier.fitnessTask), intendedUseDescription: TaskListRowStrings.exampleDescription, walkDuration: 20, restDuration: 20, options: [])
    }

    private var tecumsehCubeTestTask: ORKTask {
        if #available(iOS 14, *) {
            return ORKOrderedTask.tecumsehCubeTask(
                withIdentifier: String(describing: Identifier.tecumsehCubeTestTask),
                intendedUseDescription: TaskListRowStrings.exampleDescription,
                audioBundleIdentifier: Bundle.main.bundleIdentifier!,
                audioResourceName: "",
                audioFileExtension: "",
                options: []
            )

        } else {
            return ORKOrderedTask.fitnessCheck(
                withIdentifier: String(describing: Identifier.tecumsehCubeTestTask),
                intendedUseDescription: TaskListRowStrings.exampleDescription,
                walkDuration: 180,
                restDuration: 180,
                options: [])
        }
    }

    private var sixMinuteWalkTask: ORKTask {
        if #available(iOS 14, *) {
            return ORKOrderedTask.sixMinuteWalk(
                withIdentifier: String(describing: Identifier.sixMinuteWalkTask),
                intendedUseDescription: TaskListRowStrings.exampleDescription,
                options: []
            )
        } else {
            return ORKOrderedTask.fitnessCheck(
                withIdentifier: String(describing: Identifier.sixMinuteWalkTask),
                intendedUseDescription: TaskListRowStrings.exampleDescription,
                walkDuration: 360,
                restDuration: 0,
                options: []
            )
        }
    }

    /// This task presents the Hole Peg Test pre-defined active task.
    private var holePegTestTask: ORKTask {
        return ORKNavigableOrderedTask.holePegTest(withIdentifier: String(describing: Identifier.holePegTestTask), intendedUseDescription: TaskListRowStrings.exampleDescription, dominantHand: .right, numberOfPegs: 9, threshold: 0.2, rotated: false, timeLimit: 300, options: [])
    }
    
    /// This task presents the PSAT pre-defined active task.
    private var PSATTask: ORKTask {
        return ORKOrderedTask.psatTask(withIdentifier: String(describing: Identifier.psatTask), intendedUseDescription: TaskListRowStrings.exampleDescription, presentationMode: ORKPSATPresentationMode.auditory.union(.visual), interStimulusInterval: 3.0, stimulusDuration: 1.0, seriesLength: 60, options: [])
    }
    
    /// This task presents the Reaction Time pre-defined active task.
    private var reactionTimeTask: ORKTask {
        /// An example of a custom sound.
        let successSoundURL = Bundle.main.url(forResource: "tap", withExtension: "aif")!
        let successSound = SystemSound(soundURL: successSoundURL)!
        return ORKOrderedTask.reactionTime(withIdentifier: String(describing: Identifier.reactionTime), intendedUseDescription: TaskListRowStrings.exampleDescription, maximumStimulusInterval: 10, minimumStimulusInterval: 4, thresholdAcceleration: 0.5, numberOfAttempts: 3, timeout: 3, successSound: successSound.soundID, timeoutSound: 0, failureSound: UInt32(kSystemSoundID_Vibrate), options: [])
    }
    
    private var normalizedReactionTimeTask: ORKTask {
        /// An example of a custom sound.
        let successSoundURL = Bundle.main.url(forResource: "tap", withExtension: "aif")!
        let successSound = SystemSound(soundURL: successSoundURL)!
        return ORKOrderedTask.normalizedReactionTime(withIdentifier: String(describing: Identifier.normalizedReactionTime), intendedUseDescription: TaskListRowStrings.exampleDescription, maximumStimulusInterval: 10, minimumStimulusInterval: 4, thresholdAcceleration: 0.5, numberOfAttempts: 3, timeout: 3, successSound: successSound.soundID, timeoutSound: 0, failureSound: UInt32(kSystemSoundID_Vibrate), options: [])
    }
    
    /// This task presents the Gait and Balance pre-defined active task.
    private var shortWalkTask: ORKTask {
        return ORKOrderedTask.shortWalk(withIdentifier: String(describing: Identifier.shortWalkTask), intendedUseDescription: TaskListRowStrings.exampleDescription, numberOfStepsPerLeg: 20, restDuration: 20, options: [])
    }
    
    /// This task presents the Spatial Span Memory pre-defined active task.
    private var spatialSpanMemoryTask: ORKTask {
        return ORKOrderedTask.spatialSpanMemoryTask(withIdentifier: String(describing: Identifier.spatialSpanMemoryTask), intendedUseDescription: TaskListRowStrings.exampleDescription, initialSpan: 3, minimumSpan: 2, maximumSpan: 15, playSpeed: 1.0, maximumTests: 5, maximumConsecutiveFailures: 3, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: [])
    }
    
    /// This task presents the Speech Recognition pre-defined active task.
    private var speechRecognitionTask: ORKTask {
        return ORKOrderedTask.speechRecognitionTask(withIdentifier: String(describing: Identifier.speechRecognitionTask), intendedUseDescription: TaskListRowStrings.exampleDescription, speechRecognizerLocale: .englishUS, speechRecognitionImage: nil, speechRecognitionText: NSLocalizedString("A quick brown fox jumps over the lazy dog.", comment: ""), shouldHideTranscript: false, allowsEdittingTranscript: true, options: [])
    }
    
    /// This task presents the Speech in Noise pre-defined active task.
    private var speechInNoiseTask: ORKTask {
        return ORKOrderedTask.speechInNoiseTask(withIdentifier: String(describing: Identifier.speechInNoiseTask), intendedUseDescription: TaskListRowStrings.exampleDescription, options: [])
    }
    
    /// This task presents the Stroop pre-defined active task.
    private var stroopTask: ORKTask {
        return ORKOrderedTask.stroopTask(withIdentifier: String(describing: Identifier.stroopTask), intendedUseDescription: TaskListRowStrings.exampleDescription, numberOfAttempts: 10, options: [])
    }

    /// This task presents the Timed Walk with turn around pre-defined active task.
    private var timedWalkWithTurnAroundTask: ORKTask {
        return ORKOrderedTask.timedWalk(withIdentifier: String(describing: Identifier.timedWalkWithTurnAroundTask), intendedUseDescription: TaskListRowStrings.exampleDescription, distanceInMeters: 100.0, timeLimit: 180.0, turnAroundTimeLimit: 60.0, includeAssistiveDeviceForm: true, options: [])
    }

    /// This task presents the Tone Audiometry pre-defined active task.
    private var toneAudiometryTask: ORKTask {
        return ORKOrderedTask.toneAudiometryTask(withIdentifier: String(describing: Identifier.toneAudiometryTask), intendedUseDescription: TaskListRowStrings.exampleDescription, speechInstruction: nil, shortSpeechInstruction: nil, toneDuration: 20, options: [])
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
        return ORKOrderedTask.towerOfHanoiTask(withIdentifier: String(describing: Identifier.towerOfHanoi), intendedUseDescription: TaskListRowStrings.exampleDescription, numberOfDisks: 5, options: [])
    }
    
    /// This task presents the Two Finger Tapping pre-defined active task.
    private var twoFingerTappingIntervalTask: ORKTask {
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: String(describing: Identifier.twoFingerTappingIntervalTask), intendedUseDescription: TaskListRowStrings.exampleDescription, duration: 10,
        handOptions: [.both], options: [])
    }
    
    /// This task presents a walk back-and-forth task
    private var walkBackAndForthTask: ORKTask {
        return ORKOrderedTask.walkBackAndForthTask(withIdentifier: String(describing: Identifier.walkBackAndForthTask), intendedUseDescription: TaskListRowStrings.exampleDescription, walkDuration: 30, restDuration: 30, options: [])
    }
    
    /// This task presents the Tremor Test pre-defined active task.
    private var tremorTestTask: ORKTask {
        return ORKOrderedTask.tremorTest(withIdentifier: String(describing: Identifier.tremorTestTask),
                                         intendedUseDescription: TaskListRowStrings.exampleDescription,
                                         activeStepDuration: 10,
                                         activeTaskOptions: [],
                                         handOptions: [.both],
                                         options: [])
    }
    
    /// This task presents a knee range of motion task
    private var kneeRangeOfMotion: ORKTask {
        return ORKOrderedTask.kneeRangeOfMotionTask(withIdentifier: String(describing: Identifier.kneeRangeOfMotion), limbOption: .right, intendedUseDescription: TaskListRowStrings.exampleDescription, options: [])
    }
    
    /// This task presents a shoulder range of motion task
    private var shoulderRangeOfMotion: ORKTask {
        return ORKOrderedTask.shoulderRangeOfMotionTask(withIdentifier: String(describing: Identifier.shoulderRangeOfMotion), limbOption: .left, intendedUseDescription: TaskListRowStrings.exampleDescription, options: [])
    }
    
    /// This task presents a trail making task
    private var trailMaking: ORKTask {
        let intendedUseDescription = "Tests visual attention and task switching"
        return ORKOrderedTask.trailmakingTask(withIdentifier: String(describing: Identifier.trailMaking), intendedUseDescription: intendedUseDescription, trailmakingInstruction: nil, trailType: .B, options: [])
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
        let webViewStep = TaskListRowSteps.webViewStepExample
        return ORKOrderedTask(identifier: String(describing: Identifier.webViewTask), steps: [webViewStep])
    }
    
    private var usdzModel: ORKTask {
        let usdzModelStep = TaskListRowSteps.usdzModelExample
        return ORKOrderedTask(identifier: String(describing: Identifier.usdzModelTask), steps: [usdzModelStep])
    }
    
    /// This task demonstrates a question asking for the user age.
    private var ageQuestionTask: ORKTask {
        let ageFormItemSectionHeader1 = ORKFormItem(sectionTitle: "What is your age?", detailText: "Age question with default values.", learnMoreItem: nil, showsProgress: true)
        
        
        // age picker example 1
        let answerFormat = ORKAgeAnswerFormat()
        answerFormat.shouldShowDontKnowButton = true
        answerFormat.customDontKnowButtonText = "Prefer not to answer"
        let ageFormItem = ORKFormItem(identifier: String(describing: Identifier.ageQuestionFormItem), text: nil, answerFormat: answerFormat)
        
        ageFormItem.isOptional = true
        
        let step = ORKFormStep(identifier: String(describing: Identifier.ageQuestionFormStep), title: "Title here", text: "Default age picker.")
        step.formItems = [ageFormItemSectionHeader1, ageFormItem]
        
        // age picker example 2
        let ageFormItemSectionHeader2 = ORKFormItem(sectionTitle: "What is your age?", detailText: "Age question with custom min/max values.", learnMoreItem: nil, showsProgress: true)
        
        let answerFormat2 = ORKAgeAnswerFormat(minimumAge: 18, maximumAge: 90)
        let ageFormItem2 = ORKFormItem(identifier: String(describing: Identifier.ageQuestionFormItem2), text: nil, answerFormat: answerFormat2)
        ageFormItem2.isOptional = false
        
        let step2 =  ORKFormStep(identifier: String(describing: Identifier.ageQuestionFormStep2), title: "Title here", text: "Age picker with modified min and max ages.")
        step2.formItems = [ageFormItemSectionHeader2, ageFormItem2]
        
        // age picker example 3
        let ageFormItemSectionHeader3 = ORKFormItem(sectionTitle: "What is your age?", detailText: "Age question that shows year in choices and passes back year for the result.", learnMoreItem: nil, showsProgress: true)
        
        let answerFormat3 = ORKAgeAnswerFormat(
            minimumAge: 18,
            maximumAge: 80,
            minimumAgeCustomText: "18 or younger",
            maximumAgeCustomText: "80 or older",
            showYear: true,
            useYearForResult: true,
            defaultValue: 40)
        
        let ageFormItem3 = ORKFormItem(identifier: String(describing: Identifier.ageQuestionFormItem3), text: nil, answerFormat: answerFormat3)
        ageFormItem3.isOptional = false
        
        let step3 =  ORKFormStep(identifier: String(describing: Identifier.ageQuestionFormStep3), title: "Title here", text: "Age picker with modified min and max ages.")
        step3.formItems = [ageFormItemSectionHeader3, ageFormItem3]
        
        
        // age picker example 4
        let ageFormItemSectionHeader4 = ORKFormItem(sectionTitle: "What was your age in the year 2000?", detailText: "Age question that passes back sentinel values for the result if the minimum (-1) or maximum (-2) values are selected.", learnMoreItem: nil, showsProgress: true)
        
        let answerFormat4 = ORKAgeAnswerFormat(
            minimumAge: 1,
            maximumAge: 60,
            minimumAgeCustomText: "Under a year old",
            maximumAgeCustomText: "60 or older",
            showYear: true,
            useYearForResult: false,
            treatMinAgeAsRange: true,
            treatMaxAgeAsRange: true,
            defaultValue: 30)
        
        answerFormat4.relativeYear = 2000
        
        let ageFormItem4 = ORKFormItem(identifier: String(describing: Identifier.ageQuestionFormItem4), text: nil, answerFormat: answerFormat4)
        ageFormItem4.isOptional = false
        
        let step4 =  ORKFormStep(identifier: String(describing: Identifier.ageQuestionFormStep4), title: "Title here", text: "Age picker with utilizing a updated relative year.")
        step4.formItems = [ageFormItemSectionHeader4, ageFormItem4]
        
        let completionStep = ORKCompletionStep(identifier: "completionStepIdentifier")
        completionStep.title = "Task complete"
        
        return ORKOrderedTask(identifier: String(describing: Identifier.ageQuestionTask), steps: [step, step2, step3, step4, completionStep])
    }
    
    private var colorChoiceQuestionTask: ORKTask {
        let colorChoiceOneText = NSLocalizedString("Choice 1", comment: "")
        let colorChoiceTwoText = NSLocalizedString("Choice 2", comment: "")
        let colorChoiceThreeText = NSLocalizedString("Choice 3", comment: "")
        let colorChoiceFourText = NSLocalizedString("Choice 4", comment: "")
        let colorChoiceFiveText = NSLocalizedString("Choice 5", comment: "")
        let colorChoiceSixText = NSLocalizedString("Choice 6", comment: "")
        let colorChoiceSevenText = NSLocalizedString("None of the above", comment: "")
        
        let colorOne = UIColor(red: 244/255, green: 208/255, blue: 176/255, alpha: 1.0)
        let colorTwo = UIColor(red: 232/255, green: 180/255, blue: 143/255, alpha: 1.0)
        let colorThree = UIColor(red: 211/255, green: 158/255, blue: 124/255, alpha: 1.0)
        let colorFour = UIColor(red: 187/255, green: 119/255, blue: 80/255, alpha: 1.0)
        let colorFive = UIColor(red: 165/255, green: 93/255, blue: 43/255, alpha: 1.0)
        let colorSix = UIColor(red: 60/255, green: 32/255, blue: 29/255, alpha: 1.0)
        
        let colorChoices = [
            ORKColorChoice(color: colorOne, text: colorChoiceOneText, detailText: nil, value: "choice_1" as NSString),
            ORKColorChoice(color: colorTwo, text: colorChoiceTwoText, detailText: nil, value: "choice_2" as NSString),
            ORKColorChoice(color: colorThree, text: colorChoiceThreeText, detailText: nil, value: "choice_3" as NSString),
            ORKColorChoice(color: colorFour, text: colorChoiceFourText, detailText: nil, value: "choice_4" as NSString),
            ORKColorChoice(color: colorFive, text: colorChoiceFiveText, detailText: nil, value: "choice_5" as NSString),
            ORKColorChoice(color: colorSix, text: colorChoiceSixText, detailText: nil, value: "choice_6" as NSString),
            ORKColorChoice(color: nil, text: colorChoiceSevenText, detailText: nil, value: "choice_7" as NSString)
        ]
        
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, colorChoices: colorChoices)
        let formItem = ORKFormItem(identifier: String(describing: Identifier.colorChoiceQuestionFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: answerFormat)
        formItem.detailText = "Select your favorite color from the offerings below"
        let formStep = ORKFormStep(identifier: String(describing: Identifier.colorChoiceQuestionStep), title: NSLocalizedString("Color Choice", comment: ""), text: TaskListRowStrings.exampleDetailText)
        
        formStep.formItems = [formItem]
        
        let colorChoicesSwatchOnly = [
            ORKColorChoice(color: colorOne, text: nil, detailText: nil, value: "choice_1" as NSString),
            ORKColorChoice(color: colorTwo, text: nil, detailText: nil, value: "choice_2" as NSString),
            ORKColorChoice(color: colorThree, text: nil, detailText: nil, value: "choice_3" as NSString),
            ORKColorChoice(color: colorFour, text: nil, detailText: nil, value: "choice_4" as NSString),
            ORKColorChoice(color: colorFive, text: nil, detailText: nil, value: "choice_5" as NSString),
            ORKColorChoice(color: colorSix, text: nil, detailText: nil, value: "choice_6" as NSString),
        ]
        
        let answerFormatSwatchOnly = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, colorChoices: colorChoicesSwatchOnly)
        let formItemSwatchOnly = ORKFormItem(identifier: String(describing: Identifier.colorChoiceQuestionFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: answerFormatSwatchOnly)
        
        let formStepSwatchOnly = ORKFormStep(identifier: String(describing: Identifier.colorChoiceQuestionStepSwatchOnly), title: NSLocalizedString("Color Choice No Text", comment: ""), text: TaskListRowStrings.exampleDetailText)
        
        formStepSwatchOnly.formItems = [formItemSwatchOnly]
        
        return ORKOrderedTask(identifier: String(describing: Identifier.colorChoiceQuestionTask), steps: [formStep, formStepSwatchOnly])
    }
    
    private var familyHistoryTask: ORKTask {
        
        let familyHistoryStep = TaskListRowSteps.familyHistoryStepExample
        
        let completionStep = ORKCompletionStep(identifier: "FamilyHistoryCompletionStep")
        completionStep.title = "All Done"
        
        return ORKOrderedTask(identifier: String(describing: Identifier.familyHistoryStep), steps: [familyHistoryStep, completionStep])
    }
    
}
