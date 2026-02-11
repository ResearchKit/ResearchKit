/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.

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

import Foundation

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
    case formStep02
    case groupedFormStep
    case formStepWithMultipleSelection
    case formStepWithSingleSelection
    case formItem01
    case formItem02
    case formItem03
    case formItem04
    case formItem05
    case formItem06

    // Task with a form, with multiple don't know button
    case dontknowSurveyTask

    case textChoiceFormItem
    case textChoiceFormStep
    case appleFormItemIdentifier
    case imageChoiceItemSection
    case imageChoiceItem
    case freeTextSectionIdentifier
    case freeTextItemIdentifier
    case completionStep
    
    // Survey task specific identifiers.
    case surveyTask
    case introStep
    case surveyTaskWithMultipleSelection
    case questionStep
    case questionStepWithOtherItems
    case birthdayQuestion
    case birthdayQuestionFormItem
    case summaryStep
    case consentTask
    case consentDoc
    
    // Task with a Boolean question.
    case booleanQuestionTask
    case booleanQuestionStep
    case booleanFormStep
    case booleanFormItem

    // Task with an example of date entry.
    case dateQuestionTask
    case dateQuestionStep
    case dateQuestionFormItem
    case date3DayLimitQuestionTask

    // Task with an example of date and time entry.
    case dateTimeQuestionTask
    case dateTimeQuestionFormStep
    case dateTimeQuestionFormItem

    // Task with an example of height entry.
    case heightQuestionFormItem1
    case heightQuestionFormStep1
    case heightQuestionFormStep2
    case heightQuestionFormStep3
    case heightQuestionFormStep4
    case heightQuestionTask

    // Task with an example of weight entry.
    case weightQuestionTask
    case weightQuestionFormStep1
    case weightQuestionFormStep2
    case weightQuestionFormStep3
    case weightQuestionFormStep4
    case weightQuestionFormStep5
    case weightQuestionFormStep6
    case weightQuestionFormStep7

    // Task with an example of age entry.
    case ageQuestionTask
    case ageQuestionFormStep
    case ageQuestionFormStep2
    case ageQuestionFormStep3
    case ageQuestionFormStep4
    case ageQuestionFormItem
    case ageQuestionFormItem2
    case ageQuestionFormItem3
    case ageQuestionFormItem4
    
    // Task with an ORKHealthQuantity questions
    case healthQuantityFormItem
    case healthQuantityFormStep1
    case healthQuantityFormStep2
    case healthQuantityTask

    // Task with an image choice question.
    case imageChoiceFormItem
    case imageChoiceFormStep1
    case imageChoiceFormStep2
    case imageChoiceQuestionTask
    
    // Task with a location entry
    case locationQuestionFormItem
    case locationQuestionFormStep
    case locationQuestionTask
    
    // Task with examples of numeric questions.
    case numericDisplayUnitQuestionFormStep
    case numericFormItem
    case numericNoUnitQuestionFormStep
    case numericQuestionFormStep
    case numericQuestionTask

    // Task with examples of review Steps.
    case reviewTask
    case embeddedReviewStep
    case standAloneReviewStep
    
    // Task with examples of questions with sliding scales.
    case scaleQuestionTask
    case scaleFormItem
    case discreteScaleFormStep
    case continuousScaleFormStep
    case discreteVerticalScaleFormStep
    case continuousVerticalScaleFormStep
    case textScaleFormStep
    case textVerticalScaleFormStep

    // Task with an example of free text entry.
    case textQuestionFormItem
    case textQuestionFormStep
    case textQuestionStep
    case textQuestionTask

    // Task with an example of a multiple choice question.
    case textChoiceQuestionTask
    case textChoiceQuestionStep
    case textChoiceQuestionWithImageStep
    case textChoiceQuestionWithImageTask

    // Task with an example of time of day entry.
    case timeOfDayFormItem
    case timeOfDayQuestionFormStep
    case timeOfDayQuestionTask

    // Task with an example of time interval entry.
    case timeIntervalFormItem
    case timeIntervalFormStep
    case timeIntervalQuestionTask

    // Task with a value picker.
    case valuePickerChoiceFormItem
    case valuePickerChoiceFormStep
    case valuePickerChoiceQuestionTask
    
    // Task with an example of validated text entry.
    case validatedTextFormItem
    case validatedTextFormStepDomain
    case validatedTextFormStepEmail
    case validatedTextQuestionTask
    
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
    
    // Consent task specific identifiers
    case consentWelcomeInstructionStep
    case informedConsentInstructionStep
    
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
    case biometricPasscodeTask
    case biometricPasscodeStep

    // Active tasks.
    case audioTask
    case amslerGridTask
    case tecumsehCubeTestTask
    case sixMinuteWalkTask
    case fitnessTask
    case holePegTestTask
    case psatTask
    case reactionTime
    case normalizedReactionTime
    case shortWalkTask
    case spatialSpanMemoryTask
    case speechRecognitionTask
    case speechInNoiseTask
    case stroopTask

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
    
    // Video instruction tasks.
    case videoInstructionTask
    case videoInstructionStep
    
    // Web view tasks.
    case webViewTask
    case webViewStep
    
    // 3DModelStep tasks.
    case usdzModelStep
    case usdzModelTask
    
    // ORKColorChoice tasks.
    case colorChoiceQuestionTask
    case colorChoiceQuestionStep
    case colorChoiceQuestionStepSwatchOnly
    case colorChoiceQuestionFormItem
    
    // Family History tasks.
    case familyHistoryStep
    case familyHistoryTask
    
}


// `ORKTask` Reused Text Convenience

enum TaskListRowStrings {
    static var exampleDescription: String {
        return NSLocalizedString("Your description goes here.", comment: "")
    }
    
    static var exampleSpeechInstruction: String {
        return NSLocalizedString("Your more specific voice instruction goes here. For example, say 'Aaaah'.", comment: "")
    }
    
    static var exampleQuestionText: String {
        return NSLocalizedString("Your question goes here.", comment: "")
    }
    
    static var exampleHighValueText: String {
        return NSLocalizedString("High Value", comment: "")
    }
    
    static var exampleLowValueText: String {
        return NSLocalizedString("Low Value", comment: "")
    }
    
    static var exampleDetailText: String {
        return NSLocalizedString("Additional text can go here.", comment: "")
    }
    
    static var exampleEmailText: String {
        return NSLocalizedString("jappleseed@example.com", comment: "")
    }
    
    static var exampleTapHereText: String {
        return NSLocalizedString("Tap here", comment: "")
    }
    
    static var exampleDate3DayLimitQuestionTask: String {
        return NSLocalizedString("This date picker is restricted to 3 days before or after the current date.", comment: "")
    }
    
    static var exampleHeartRateQuestion: String {
        return NSLocalizedString("What is your Heart Rate?", comment: "")
    }
    
    static var exampleBloodTypeQuestion: String {
        return NSLocalizedString("What is your Blood Type?", comment: "")
    }
    
    static var loremIpsumText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    }
    
    static var loremIpsumShortText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    }
    
    static var loremIpsumMediumText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?"
    }
    
    static var loremIpsumLongText: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?"
    }
    

}
