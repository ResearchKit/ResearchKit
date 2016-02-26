/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.

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
    
    init?(soundURL: NSURL) {
        if AudioServicesCreateSystemSoundID(soundURL as CFURLRef, &soundID) != noErr {
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
    case Form = 0
    case Survey
    
    case BooleanQuestion
    case DateQuestion
    case DateTimeQuestion
    case ImageChoiceQuestion
    case LocationQuestion
    case NumericQuestion
    case ScaleQuestion
    case TextQuestion
    case TextChoiceQuestion
    case TimeIntervalQuestion
    case TimeOfDayQuestion
    case ValuePickerChoiceQuestion
    case ValidatedTextQuestion
    case ImageCapture
    case Wait
    
    case EligibilityTask
    case Consent
    case AccountCreation
    case Login
    case Passcode
    
    case Audio
    case Fitness
    case HolePegTest
    case PSAT
    case ReactionTime
    case ShortWalk
    case SpatialSpanMemory
    case TimedWalk
    case ToneAudiometry
    case TowerOfHanoi
    case TwoFingerTappingInterval
    
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
                    .Form,
                    .Survey,
                ]),
            TaskListRowSection(title: "Survey Questions", rows:
                [
                    .BooleanQuestion,
                    .DateQuestion,
                    .DateTimeQuestion,
                    .ImageChoiceQuestion,
                    .LocationQuestion,
                    .NumericQuestion,
                    .ScaleQuestion,
                    .TextQuestion,
                    .TextChoiceQuestion,
                    .TimeIntervalQuestion,
                    .TimeOfDayQuestion,
                    .ValuePickerChoiceQuestion,
                    .ValidatedTextQuestion,
                    .ImageCapture,
                    .Wait,
                ]),
            TaskListRowSection(title: "Onboarding", rows:
                [
                    .EligibilityTask,
                    .Consent,
                    .AccountCreation,
                    .Login,
                    .Passcode,
                ]),
            TaskListRowSection(title: "Active Tasks", rows:
                [
                    .Audio,
                    .Fitness,
                    .HolePegTest,
                    .PSAT,
                    .ReactionTime,
                    .ShortWalk,
                    .SpatialSpanMemory,
                    .TimedWalk,
                    .ToneAudiometry,
                    .TowerOfHanoi,
                    .TwoFingerTappingInterval,
                ]),
        ]}
    
    // MARK: CustomStringConvertible
    
    var description: String {
        switch self {
        case .Form:
            return NSLocalizedString("Form Survey Example", comment: "")
            
        case .Survey:
            return NSLocalizedString("Simple Survey Example", comment: "")
            
        case .BooleanQuestion:
            return NSLocalizedString("Boolean Question", comment: "")
            
        case .DateQuestion:
            return NSLocalizedString("Date Question", comment: "")
            
        case .DateTimeQuestion:
            return NSLocalizedString("Date and Time Question", comment: "")
            
        case .ImageChoiceQuestion:
            return NSLocalizedString("Image Choice Question", comment: "")
            
        case .LocationQuestion:
            return NSLocalizedString("Location Question", comment: "")
            
        case .NumericQuestion:
            return NSLocalizedString("Numeric Question", comment: "")
            
        case .ScaleQuestion:
            return NSLocalizedString("Scale Question", comment: "")
            
        case .TextQuestion:
            return NSLocalizedString("Text Question", comment: "")
            
        case .TextChoiceQuestion:
            return NSLocalizedString("Text Choice Question", comment: "")
            
        case .TimeIntervalQuestion:
            return NSLocalizedString("Time Interval Question", comment: "")
            
        case .TimeOfDayQuestion:
            return NSLocalizedString("Time of Day Question", comment: "")
            
        case .ValuePickerChoiceQuestion:
            return NSLocalizedString("Value Picker Choice Question", comment: "")
            
        case .ValidatedTextQuestion:
            return NSLocalizedString("Validated Text Question", comment: "")
            
        case .ImageCapture:
            return NSLocalizedString("Image Capture Step", comment: "")
            
        case .Wait:
            return NSLocalizedString("Wait Step", comment: "")

        case .EligibilityTask:
            return NSLocalizedString("Eligibility Task Example", comment: "")
            
        case .Consent:
            return NSLocalizedString("Consent-Obtaining Example", comment: "")

        case .AccountCreation:
            return NSLocalizedString("Account Creation", comment: "")
        
        case .Login:
            return NSLocalizedString("Login", comment: "")

        case .Passcode:
            return NSLocalizedString("Passcode Creation", comment: "")
            
        case .Audio:
            return NSLocalizedString("Audio", comment: "")
            
        case .Fitness:
            return NSLocalizedString("Fitness Check", comment: "")
        
        case .HolePegTest:
            return NSLocalizedString("Hole Peg Test", comment: "")
            
        case .PSAT:
            return NSLocalizedString("PSAT", comment: "")
            
        case .ReactionTime:
            return NSLocalizedString("Reaction Time", comment: "")
            
        case .ShortWalk:
            return NSLocalizedString("Short Walk", comment: "")
            
        case .SpatialSpanMemory:
            return NSLocalizedString("Spatial Span Memory", comment: "")
            
        case .TimedWalk:
            return NSLocalizedString("Timed Walk", comment: "")
            
        case .ToneAudiometry:
            return NSLocalizedString("Tone Audiometry", comment: "")
            
        case .TowerOfHanoi:
            return NSLocalizedString("Tower of Hanoi", comment: "")

        case .TwoFingerTappingInterval:
            return NSLocalizedString("Two Finger Tapping Interval", comment: "")
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
    private enum Identifier {
        // Task with a form, where multiple items appear on one page.
        case FormTask
        case FormStep
        case FormItem01
        case FormItem02
        case FormItem03

        // Survey task specific identifiers.
        case SurveyTask
        case IntroStep
        case QuestionStep
        case SummaryStep
        
        // Task with a Boolean question.
        case BooleanQuestionTask
        case BooleanQuestionStep

        // Task with an example of date entry.
        case DateQuestionTask
        case DateQuestionStep
        
        // Task with an example of date and time entry.
        case DateTimeQuestionTask
        case DateTimeQuestionStep

        // Task with an image choice question.
        case ImageChoiceQuestionTask
        case ImageChoiceQuestionStep
        
        // Task with a location entry.
        case LocationQuestionTask
        case LocationQuestionStep
        
        // Task with examples of numeric questions.
        case NumericQuestionTask
        case NumericQuestionStep
        case NumericNoUnitQuestionStep

        // Task with examples of questions with sliding scales.
        case ScaleQuestionTask
        case DiscreteScaleQuestionStep
        case ContinuousScaleQuestionStep
        case DiscreteVerticalScaleQuestionStep
        case ContinuousVerticalScaleQuestionStep
        case TextScaleQuestionStep
        case TextVerticalScaleQuestionStep

        // Task with an example of free text entry.
        case TextQuestionTask
        case TextQuestionStep
        
        // Task with an example of a multiple choice question.
        case TextChoiceQuestionTask
        case TextChoiceQuestionStep

        // Task with an example of time of day entry.
        case TimeOfDayQuestionTask
        case TimeOfDayQuestionStep

        // Task with an example of time interval entry.
        case TimeIntervalQuestionTask
        case TimeIntervalQuestionStep

        // Task with a value picker.
        case ValuePickerChoiceQuestionTask
        case ValuePickerChoiceQuestionStep
        
        // Task with an example of validated text entry.
        case ValidatedTextQuestionTask
        case ValidatedTextQuestionStepEmail
        case ValidatedTextQuestionStepDomain
        
        // Image capture task specific identifiers.
        case ImageCaptureTask
        case ImageCaptureStep
        
        // Task with an example of waiting.
        case WaitTask
        case WaitStepDeterminate
        case WaitStepIndeterminate
        
        // Eligibility task specific indentifiers.
        case EligibilityTask
        case EligibilityIntroStep
        case EligibilityFormStep
        case EligibilityFormItem01
        case EligibilityFormItem02
        case EligibilityFormItem03
        case EligibilityIneligibleStep
        case EligibilityEligibleStep
        
        // Consent task specific identifiers.
        case ConsentTask
        case VisualConsentStep
        case ConsentSharingStep
        case ConsentReviewStep
        case ConsentDocumentParticipantSignature
        case ConsentDocumentInvestigatorSignature
        
        // Account creation task specific identifiers.
        case AccountCreationTask
        case RegistrationStep
        case WaitStep
        case VerificationStep
        
        // Login task specific identifiers.
        case LoginTask
        case LoginStep
        case LoginWaitStep

        // Passcode task specific identifiers.
        case PasscodeTask
        case PasscodeStep

        // Active tasks.
        case AudioTask
        case FitnessTask
        case HolePegTestTask
        case PSATTask
        case ReactionTime
        case ShortWalkTask
        case SpatialSpanMemoryTask
        case TimedWalkTask
        case ToneAudiometryTask
        case TowerOfHanoi
        case TwoFingerTappingIntervalTask
    }
    
    // MARK: Properties
    
    /// Returns a new `ORKTask` that the `TaskListRow` enumeration represents.
    var representedTask: ORKTask {
        switch self {
        case .Form:
            return formTask
            
        case .Survey:
            return surveyTask
            
        case .BooleanQuestion:
            return booleanQuestionTask
            
        case .DateQuestion:
            return dateQuestionTask
            
        case .DateTimeQuestion:
            return dateTimeQuestionTask

        case .ImageChoiceQuestion:
            return imageChoiceQuestionTask
            
        case .LocationQuestion:
            return locationQuestionTask
            
        case .NumericQuestion:
            return numericQuestionTask
            
        case .ScaleQuestion:
            return scaleQuestionTask
            
        case .TextQuestion:
            return textQuestionTask
            
        case .TextChoiceQuestion:
            return textChoiceQuestionTask

        case .TimeIntervalQuestion:
            return timeIntervalQuestionTask

        case .TimeOfDayQuestion:
                return timeOfDayQuestionTask
        
        case .ValuePickerChoiceQuestion:
                return valuePickerChoiceQuestionTask
            
        case .ValidatedTextQuestion:
            return validatedTextQuestionTask
            
        case .ImageCapture:
            return imageCaptureTask
            
        case .Wait:
            return waitTask
        
        case .EligibilityTask:
            return eligibilityTask
            
        case .Consent:
            return consentTask
            
        case .AccountCreation:
            return accountCreationTask
            
        case .Login:
            return loginTask

        case .Passcode:
            return passcodeTask
            
        case .Audio:
            return audioTask

        case .Fitness:
            return fitnessTask
            
        case .HolePegTest:
            return holePegTestTask
            
        case .PSAT:
            return PSATTask
            
        case .ReactionTime:
            return reactionTimeTask
            
        case .ShortWalk:
            return shortWalkTask
            
        case .SpatialSpanMemory:
            return spatialSpanMemoryTask

        case .TimedWalk:
            return timedWalkTask
            
        case .ToneAudiometry:
            return toneAudiometryTask
            
        case .TowerOfHanoi:
            return towerOfHanoiTask
            
        case .TwoFingerTappingInterval:
            return twoFingerTappingIntervalTask
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
        let step = ORKFormStep(identifier: String(Identifier.FormStep), title: exampleQuestionText, text: exampleDetailText)
        
        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("Field01", comment: "")
        let formItem01 = ORKFormItem(identifier: String(Identifier.FormItem01), text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormatWithUnit(nil))
        formItem01.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString("Field02", comment: "")
        let formItem02 = ORKFormItem(identifier: String(Identifier.FormItem02), text: formItem02Text, answerFormat: ORKTimeIntervalAnswerFormat())
        formItem02.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        step.formItems = [
            formItem01,
            formItem02
        ]
        
        return ORKOrderedTask(identifier: String(Identifier.FormTask), steps: [step])
    }

    /**
    A task demonstrating how the ResearchKit framework can be used to present a simple
    survey with an introduction, a question, and a conclusion.
    */
    private var surveyTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(Identifier.IntroStep))
        
        instructionStep.title = NSLocalizedString("Sample Survey", comment: "")
        
        instructionStep.text = exampleDescription
        
        // Add a question step.
        let questionStepAnswerFormat = ORKBooleanAnswerFormat()
        
        let questionStepTitle = NSLocalizedString("Would you like to subscribe to our newsletter?", comment: "")
        let questionStep = ORKQuestionStep(identifier: String(Identifier.QuestionStep), title: questionStepTitle, answer: questionStepAnswerFormat)
        
        // Add a summary step.
        let summaryStep = ORKInstructionStep(identifier: String(Identifier.SummaryStep))
        summaryStep.title = NSLocalizedString("Thanks", comment: "")
        summaryStep.text = NSLocalizedString("Thank you for participating in this sample survey.", comment: "")
        
        return ORKOrderedTask(identifier: String(Identifier.SurveyTask), steps: [
            instructionStep,
            questionStep,
            summaryStep
            ])
    }

    /// This task presents just a single "Yes" / "No" question.
    private var booleanQuestionTask: ORKTask {
        let answerFormat = ORKBooleanAnswerFormat()
        
        // We attach an answer format to a question step to specify what controls the user sees.
        let questionStep = ORKQuestionStep(identifier: String(Identifier.BooleanQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        // The detail text is shown in a small font below the title.
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.BooleanQuestionTask), steps: [questionStep])
    }

    /// This task demonstrates a question which asks for a date.
    private var dateQuestionTask: ORKTask {
        /*
        The date answer format can also support minimum and maximum limits,
        a specific default value, and overriding the calendar to use.
        */
        let answerFormat = ORKAnswerFormat.dateAnswerFormat()
        
        let step = ORKQuestionStep(identifier: String(Identifier.DateQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.DateQuestionTask), steps: [step])
    }
    
    /// This task demonstrates a question asking for a date and time of an event.
    private var dateTimeQuestionTask: ORKTask {
        /*
        This uses the default calendar. Use a more detailed constructor to
        set minimum / maximum limits.
        */
        let answerFormat = ORKAnswerFormat.dateTimeAnswerFormat()
        
        let step = ORKQuestionStep(identifier: String(Identifier.DateTimeQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.DateTimeQuestionTask), steps: [step])
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
            ORKImageChoice(normalImage: roundShapeImage, selectedImage: nil, text: roundShapeText, value: roundShapeText),
            ORKImageChoice(normalImage: squareShapeImage, selectedImage: nil, text: squareShapeText, value: squareShapeText)
        ]
        
        let answerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(imageChoces)
        
        let questionStep = ORKQuestionStep(identifier: String(Identifier.ImageChoiceQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.ImageChoiceQuestionTask), steps: [questionStep])
    }
    
    /// This task presents just a single location question.
    private var locationQuestionTask: ORKTask {
        let answerFormat = ORKLocationAnswerFormat()
        
        // We attach an answer format to a question step to specify what controls the user sees.
        let questionStep = ORKQuestionStep(identifier: String(Identifier.LocationQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        // The detail text is shown in a small font below the title.
        questionStep.text = exampleDetailText
        questionStep.placeholder = NSLocalizedString("Address", comment: "");
        
        return ORKOrderedTask(identifier: String(Identifier.LocationQuestionTask), steps: [questionStep])
    }
    
    /**
        This task demonstrates use of numeric questions with and without units.
        Note that the unit is just a string, prompting the user to enter the value
        in the expected unit. The unit string propagates into the result object.
    */
    private var numericQuestionTask: ORKTask {
        // This answer format will display a unit in-line with the numeric entry field.
        let localizedQuestionStep1AnswerFormatUnit = NSLocalizedString("Your unit", comment: "")
        let questionStep1AnswerFormat = ORKAnswerFormat.decimalAnswerFormatWithUnit(localizedQuestionStep1AnswerFormatUnit)
        
        let questionStep1 = ORKQuestionStep(identifier: String(Identifier.NumericQuestionStep), title: exampleQuestionText, answer: questionStep1AnswerFormat)
        
        questionStep1.text = exampleDetailText
        questionStep1.placeholder = NSLocalizedString("Your placeholder.", comment: "")
                
        // This answer format is similar to the previous one, but this time without displaying a unit.
        let questionStep2 = ORKQuestionStep(identifier: String(Identifier.NumericNoUnitQuestionStep), title: exampleQuestionText, answer: ORKAnswerFormat.decimalAnswerFormatWithUnit(nil))
        
        questionStep2.text = exampleDetailText
        questionStep2.placeholder = NSLocalizedString("Placeholder without unit.", comment: "")
        
        return ORKOrderedTask(identifier: String(Identifier.NumericQuestionTask), steps: [
            questionStep1,
            questionStep2
        ])
    }
    
    /// This task presents two options for questions displaying a scale control.
    private var scaleQuestionTask: ORKTask {
        // The first step is a scale control with 10 discrete ticks.
        let step1AnswerFormat = ORKAnswerFormat.scaleAnswerFormatWithMaximumValue(10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: false, maximumValueDescription: exampleHighValueText, minimumValueDescription: exampleLowValueText)
        
        let questionStep1 = ORKQuestionStep(identifier: String(Identifier.DiscreteScaleQuestionStep), title: exampleQuestionText, answer: step1AnswerFormat)
        
        questionStep1.text = exampleDetailText
        
        // The second step is a scale control that allows continuous movement with a percent formatter.
        let step2AnswerFormat = ORKAnswerFormat.continuousScaleAnswerFormatWithMaximumValue(1.0, minimumValue: 0.0, defaultValue: 99.0, maximumFractionDigits: 0, vertical: false, maximumValueDescription: nil, minimumValueDescription: nil)
        step2AnswerFormat.numberStyle = .Percent
        
        let questionStep2 = ORKQuestionStep(identifier: String(Identifier.ContinuousScaleQuestionStep), title: exampleQuestionText, answer: step2AnswerFormat)
        
        questionStep2.text = exampleDetailText
        
        // The third step is a vertical scale control with 10 discrete ticks.
        let step3AnswerFormat = ORKAnswerFormat.scaleAnswerFormatWithMaximumValue(10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: true, maximumValueDescription: nil, minimumValueDescription: nil)
        
        let questionStep3 = ORKQuestionStep(identifier: String(Identifier.DiscreteVerticalScaleQuestionStep), title: exampleQuestionText, answer: step3AnswerFormat)
        
        questionStep3.text = exampleDetailText
        
        // The fourth step is a vertical scale control that allows continuous movement.
        let step4AnswerFormat = ORKAnswerFormat.continuousScaleAnswerFormatWithMaximumValue(5.0, minimumValue: 1.0, defaultValue: 99.0, maximumFractionDigits: 2, vertical: true, maximumValueDescription: exampleHighValueText, minimumValueDescription: exampleLowValueText)
        
        let questionStep4 = ORKQuestionStep(identifier: String(Identifier.ContinuousVerticalScaleQuestionStep), title: exampleQuestionText, answer: step4AnswerFormat)
        
        questionStep4.text = exampleDetailText
        
        // The fifth step is a scale control that allows text choices.
        let textChoices : [ORKTextChoice] = [ORKTextChoice(text: "Poor", value: 1), ORKTextChoice(text: "Fair", value: 2), ORKTextChoice(text: "Good", value: 3), ORKTextChoice(text: "Above Average", value: 10), ORKTextChoice(text: "Excellent", value: 5)]

        let step5AnswerFormat = ORKAnswerFormat.textScaleAnswerFormatWithTextChoices(textChoices, defaultIndex: NSIntegerMax, vertical: false)
        
        let questionStep5 = ORKQuestionStep(identifier: String(Identifier.TextScaleQuestionStep), title: exampleQuestionText, answer: step5AnswerFormat)
        
        questionStep5.text = exampleDetailText
        
        // The sixth step is a vertical scale control that allows text choices.
        let step6AnswerFormat = ORKAnswerFormat.textScaleAnswerFormatWithTextChoices(textChoices, defaultIndex: NSIntegerMax, vertical: true)
        
        let questionStep6 = ORKQuestionStep(identifier: String(Identifier.TextVerticalScaleQuestionStep), title: exampleQuestionText, answer: step6AnswerFormat)
        
        questionStep6.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.ScaleQuestionTask), steps: [
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
        
        let step = ORKQuestionStep(identifier: String(Identifier.TextQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.TextQuestionTask), steps: [step])
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
        
        // The text to display can be separate from the value coded for each choice:
        let textChoices = [
            ORKTextChoice(text: textChoiceOneText, value: "choice_1"),
            ORKTextChoice(text: textChoiceTwoText, value: "choice_2"),
            ORKTextChoice(text: textChoiceThreeText, value: "choice_3")
        ]
        
        let answerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices)
        
        let questionStep = ORKQuestionStep(identifier: String(Identifier.TextChoiceQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.TextChoiceQuestionTask), steps: [questionStep])
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
        
        let step = ORKQuestionStep(identifier: String(Identifier.TimeIntervalQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.TimeIntervalQuestionTask), steps: [step])
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
        
        let questionStep = ORKQuestionStep(identifier: String(Identifier.TimeOfDayQuestionStep), title: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.TimeOfDayQuestionTask), steps: [questionStep])
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
            ORKTextChoice(text: textChoiceOneText, value: "choice_1"),
            ORKTextChoice(text: textChoiceTwoText, value: "choice_2"),
            ORKTextChoice(text: textChoiceThreeText, value: "choice_3")
        ]
        
        let answerFormat = ORKAnswerFormat.valuePickerAnswerFormatWithTextChoices(textChoices)
        
        let questionStep = ORKQuestionStep(identifier: String(Identifier.ValuePickerChoiceQuestionStep), title: exampleQuestionText,
            answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.ValuePickerChoiceQuestionTask), steps: [questionStep])
    }

    /**
     This task demonstrates asking for text entry. Both single and multi-line
     text entry are supported, with appropriate parameters to the text answer
     format.
     */
    private var validatedTextQuestionTask: ORKTask {
        let answerFormatEmail = ORKAnswerFormat.emailAnswerFormat()
        let stepEmail = ORKQuestionStep(identifier: String(Identifier.ValidatedTextQuestionStepEmail), title: NSLocalizedString("Email", comment: ""), answer: answerFormatEmail)
        stepEmail.text = exampleDetailText
        
        let domainRegex = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        
        let answerFormatDomain = ORKAnswerFormat.textAnswerFormatWithValidationRegex(domainRegex, invalidMessage:"Invalid URL: %@")
        answerFormatDomain.multipleLines = false
        answerFormatDomain.keyboardType = UIKeyboardType.URL
        answerFormatDomain.autocapitalizationType = UITextAutocapitalizationType.None
        answerFormatDomain.autocorrectionType = UITextAutocorrectionType.No
        answerFormatDomain.spellCheckingType = UITextSpellCheckingType.No
        let stepDomain = ORKQuestionStep(identifier: String(Identifier.ValidatedTextQuestionStepDomain), title: NSLocalizedString("URL", comment: ""), answer: answerFormatDomain)
        stepDomain.text = exampleDetailText
        
        return ORKOrderedTask(identifier: String(Identifier.ValidatedTextQuestionTask), steps: [stepEmail, stepDomain])
    }
    
    /// This task presents the image capture step in an ordered task.
    private var imageCaptureTask: ORKTask {
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: String(Identifier.IntroStep))
        
        instructionStep.title = NSLocalizedString("Sample Survey", comment: "")
        
        instructionStep.text = exampleDescription
        
        let handSolidImage = UIImage(named: "hand_solid")!
        instructionStep.image = handSolidImage.imageWithRenderingMode(.AlwaysTemplate)
        
        let imageCaptureStep = ORKImageCaptureStep(identifier: String(Identifier.ImageCaptureStep))
        imageCaptureStep.optional = false
        imageCaptureStep.accessibilityInstructions = NSLocalizedString("Your instructions for capturing the image", comment: "")
        imageCaptureStep.accessibilityHint = NSLocalizedString("Captures the image visible in the preview", comment: "")
        
        imageCaptureStep.templateImage = UIImage(named: "hand_outline_big")!
        
        imageCaptureStep.templateImageInsets = UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05)
        
        return ORKOrderedTask(identifier: String(Identifier.ImageCaptureTask), steps: [
            instructionStep,
            imageCaptureStep
            ])
    }
    
    /// This task presents a wait task.
    private var waitTask: ORKTask {
        let waitStepIndeterminate = ORKWaitStep(identifier: String(Identifier.WaitStepIndeterminate))
        waitStepIndeterminate.title = exampleQuestionText
        waitStepIndeterminate.text = exampleDescription
        waitStepIndeterminate.indicatorType = ORKProgressIndicatorType.Indeterminate
        
        let waitStepDeterminate = ORKWaitStep(identifier: String(Identifier.WaitStepDeterminate))
        waitStepDeterminate.title = exampleQuestionText
        waitStepDeterminate.text = exampleDescription
        waitStepDeterminate.indicatorType = ORKProgressIndicatorType.ProgressBar
        
        return ORKOrderedTask(identifier: String(Identifier.WaitTask), steps: [waitStepIndeterminate, waitStepDeterminate])
    }
    
    /**
    A task demonstrating how the ResearchKit framework can be used to determine
    eligibility using a navigable ordered task.
    */
    private var eligibilityTask: ORKTask {
        // Intro step
        let introStep = ORKInstructionStep(identifier: String(Identifier.EligibilityIntroStep))
        introStep.title = NSLocalizedString("Eligibility Task Example", comment: "")
        
        // Form step
        let formStep = ORKFormStep(identifier: String(Identifier.EligibilityFormStep))
        formStep.title = NSLocalizedString("Eligibility", comment: "")
        formStep.text = exampleQuestionText
        formStep.optional = false
        
        // Form items
        let textChoices : [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes"), ORKTextChoice(text: "No", value: "No"), ORKTextChoice(text: "N/A", value: "N/A")]
        let answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.SingleChoice, textChoices: textChoices)
        
        let formItem01 = ORKFormItem(identifier: String(Identifier.EligibilityFormItem01), text: exampleQuestionText, answerFormat: answerFormat)
        formItem01.optional = false
        let formItem02 = ORKFormItem(identifier: String(Identifier.EligibilityFormItem02), text: exampleQuestionText, answerFormat: answerFormat)
        formItem02.optional = false
        let formItem03 = ORKFormItem(identifier: String(Identifier.EligibilityFormItem03), text: exampleQuestionText, answerFormat: answerFormat)
        formItem03.optional = false
        
        formStep.formItems = [
            formItem01,
            formItem02,
            formItem03
        ]
        
        // Ineligible step
        let ineligibleStep = ORKInstructionStep(identifier: String(Identifier.EligibilityIneligibleStep))
        ineligibleStep.title = NSLocalizedString("You are ineligible to join the study", comment: "")
        
        // Eligible step
        let eligibleStep = ORKCompletionStep(identifier: String(Identifier.EligibilityEligibleStep))
        eligibleStep.title = NSLocalizedString("You are eligible to join the study", comment: "")
        
        // Create the task
        let eligibilityTask = ORKNavigableOrderedTask(identifier: String(Identifier.EligibilityTask), steps: [
            introStep,
            formStep,
            ineligibleStep,
            eligibleStep
            ])
        
        // Build navigation rules.
        var resultSelector = ORKResultSelector(stepIdentifier: String(Identifier.EligibilityFormStep), resultIdentifier: String(Identifier.EligibilityFormItem01))
        let predicateFormItem01 = ORKResultPredicate.predicateForChoiceQuestionResultWithResultSelector(resultSelector, expectedAnswerValue: "Yes")
        
        resultSelector = ORKResultSelector(stepIdentifier: String(Identifier.EligibilityFormStep), resultIdentifier: String(Identifier.EligibilityFormItem02))
        let predicateFormItem02 = ORKResultPredicate.predicateForChoiceQuestionResultWithResultSelector(resultSelector, expectedAnswerValue: "Yes")
        
        resultSelector = ORKResultSelector(stepIdentifier: String(Identifier.EligibilityFormStep), resultIdentifier: String(Identifier.EligibilityFormItem03))
        let predicateFormItem03 = ORKResultPredicate.predicateForChoiceQuestionResultWithResultSelector(resultSelector, expectedAnswerValue: "No")
        
        let predicateEligible = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFormItem01, predicateFormItem02, predicateFormItem03])
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [ (predicateEligible, String(Identifier.EligibilityEligibleStep)) ])
        
        eligibilityTask.setNavigationRule(predicateRule, forTriggerStepIdentifier:String(Identifier.EligibilityFormStep))
        
        // Add end direct rules to skip unneeded steps
        let directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
        eligibilityTask.setNavigationRule(directRule, forTriggerStepIdentifier:String(Identifier.EligibilityIneligibleStep))
        
        return eligibilityTask
    }
    
    /// A task demonstrating how the ResearchKit framework can be used to obtain informed consent.
    private var consentTask: ORKTask {
        /*
        Informed consent starts by presenting an animated sequence conveying
        the main points of your consent document.
        */
        let visualConsentStep = ORKVisualConsentStep(identifier: String(Identifier.VisualConsentStep), document: consentDocument)
        
        let investigatorShortDescription = NSLocalizedString("Institution", comment: "")
        let investigatorLongDescription = NSLocalizedString("Institution and its partners", comment: "")
        let localizedLearnMoreHTMLContent = NSLocalizedString("Your sharing learn more content here.", comment: "")
        
        /*
        If you want to share the data you collect with other researchers for
        use in other studies beyond this one, it is best practice to get
        explicit permission from the participant. Use the consent sharing step
        for this.
        */
        let sharingConsentStep = ORKConsentSharingStep(identifier: String(Identifier.ConsentSharingStep), investigatorShortDescription: investigatorShortDescription, investigatorLongDescription: investigatorLongDescription, localizedLearnMoreHTMLContent: localizedLearnMoreHTMLContent)
        
        /*
        After the visual presentation, the consent review step displays
        your consent document and can obtain a signature from the participant.
        
        The first signature in the document is the participant's signature.
        This effectively tells the consent review step which signatory is
        reviewing the document.
        */
        let signature = consentDocument.signatures!.first
        
        let reviewConsentStep = ORKConsentReviewStep(identifier: String(Identifier.ConsentReviewStep), signature: signature, inDocument: consentDocument)
        
        // In a real application, you would supply your own localized text.
        reviewConsentStep.text = loremIpsumText
        reviewConsentStep.reasonForConsent = loremIpsumText

        return ORKOrderedTask(identifier: String(Identifier.ConsentTask), steps: [
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
        let passcodeValidationRegex = "^(?=.*\\d).{4,8}$"
        let passcodeInvalidMessage = NSLocalizedString("A valid password must be 4 and 8 digits long and include at least one numeric character.", comment: "")
        let registrationOptions: ORKRegistrationStepOption = [.IncludeGivenName, .IncludeFamilyName, .IncludeGender, .IncludeDOB]
        let registrationStep = ORKRegistrationStep(identifier: String(Identifier.RegistrationStep), title: registrationTitle, text: exampleDetailText, passcodeValidationRegex: passcodeValidationRegex, passcodeInvalidMessage: passcodeInvalidMessage, options: registrationOptions)
        
        /*
        A wait step allows you to upload the data from the user registration onto your server before presenting the verification step.
        */
        let waitTitle = NSLocalizedString("Creating account", comment: "")
        let waitText = NSLocalizedString("Please wait while we upload your data", comment: "")
        let waitStep = ORKWaitStep(identifier: String(Identifier.WaitStep))
        waitStep.title = waitTitle
        waitStep.text = waitText
        
        /*
        A verification step view controller subclass is required in order to use the verification step.
        The subclass provides the view controller button and UI behavior by overriding the following methods.
        */
        class VerificationViewController : ORKVerificationStepViewController {
            override func resendEmailButtonTapped() {
                let alertTitle = NSLocalizedString("Resend Verification Email", comment: "")
                let alertMessage = NSLocalizedString("Button tapped", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        let verificationStep = ORKVerificationStep(identifier: String(Identifier.VerificationStep), text: exampleDetailText, verificationViewControllerClass: VerificationViewController.self)
        
        return ORKOrderedTask(identifier: String(Identifier.AccountCreationTask), steps: [
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
        class LoginViewController : ORKLoginStepViewController {
            override func forgotPasswordButtonTapped() {
                let alertTitle = NSLocalizedString("Forgot password?", comment: "")
                let alertMessage = NSLocalizedString("Button tapped", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        /*
        A login step provides a form step that is populated with email and password fields,
        and a button for `Forgot password?`.
        */
        let loginTitle = NSLocalizedString("Login", comment: "")
        let loginStep = ORKLoginStep(identifier: String(Identifier.LoginStep), title: loginTitle, text: exampleDetailText, loginViewControllerClass: LoginViewController.self)
        
        /*
        A wait step allows you to validate the data from the user login against your server before proceeding.
        */
        let waitTitle = NSLocalizedString("Logging in", comment: "")
        let waitText = NSLocalizedString("Please wait while we validate your credentials", comment: "")
        let waitStep = ORKWaitStep(identifier: String(Identifier.LoginWaitStep))
        waitStep.title = waitTitle
        waitStep.text = waitText
        
        return ORKOrderedTask(identifier: String(Identifier.LoginTask), steps: [loginStep, waitStep])
    }
    
    /// This task demonstrates the Passcode creation process.
    private var passcodeTask: ORKTask {
        /*
        If you want to protect the app using a passcode. It is reccomended to
        ask user to create passcode as part of the consent process and use the
        authentication and editing view controllers to interact with the passcode.
        
        The passcode is stored in the keychain.
        */
        let passcodeConsentStep = ORKPasscodeStep(identifier: String(Identifier.PasscodeStep))

        return ORKOrderedTask(identifier: String(Identifier.PasscodeStep), steps: [passcodeConsentStep])
    }
    
    /// This task presents the Audio pre-defined active task.
    private var audioTask: ORKTask {
        return ORKOrderedTask.audioTaskWithIdentifier(String(Identifier.AudioTask), intendedUseDescription: exampleDescription, speechInstruction: exampleSpeechInstruction, shortSpeechInstruction: exampleSpeechInstruction, duration: 20, recordingSettings: nil, options: [])
    }

    /**
        This task presents the Fitness pre-defined active task. For this example,
        short walking and rest durations of 20 seconds each are used, whereas more
        realistic durations might be several minutes each.
    */
    private var fitnessTask: ORKTask {
        return ORKOrderedTask.fitnessCheckTaskWithIdentifier(String(Identifier.FitnessTask), intendedUseDescription: exampleDescription, walkDuration: 20, restDuration: 20, options: [])
    }
    
    /// This task presents the Hole Peg Test pre-defined active task.
    private var holePegTestTask: ORKTask {
        return ORKNavigableOrderedTask.holePegTestTaskWithIdentifier(String(Identifier.HolePegTestTask), intendedUseDescription: exampleDescription, dominantHand: .Right, numberOfPegs: 9, threshold: 0.2, rotated: false, timeLimit: 300, options: [])
    }
    
    /// This task presents the PSAT pre-defined active task.
    private var PSATTask: ORKTask {
        return ORKOrderedTask.PSATTaskWithIdentifier(String(Identifier.PSATTask), intendedUseDescription: exampleDescription, presentationMode: ORKPSATPresentationMode.Auditory.union(.Visual), interStimulusInterval: 3.0, stimulusDuration: 1.0, seriesLength: 60, options: [])
    }
    
    /// This task presents the Reaction Time pre-defined active task.
    private var reactionTimeTask: ORKTask {
        /// An example of a custom sound.
        let successSoundURL = NSBundle.mainBundle().URLForResource("tap", withExtension: "aif")!
        let successSound = SystemSound(soundURL: successSoundURL)!
        return ORKOrderedTask.reactionTimeTaskWithIdentifier(String(Identifier.ReactionTime), intendedUseDescription: exampleDescription, maximumStimulusInterval: 10, minimumStimulusInterval: 4, thresholdAcceleration: 0.5, numberOfAttempts: 3, timeout: 3, successSound: successSound.soundID, timeoutSound: 0, failureSound: UInt32(kSystemSoundID_Vibrate), options: [])
    }
    
    /// This task presents the Gait and Balance pre-defined active task.
    private var shortWalkTask: ORKTask {
        return ORKOrderedTask.shortWalkTaskWithIdentifier(String(Identifier.ShortWalkTask), intendedUseDescription: exampleDescription, numberOfStepsPerLeg: 20, restDuration: 20, options: [])
    }
    
    /// This task presents the Spatial Span Memory pre-defined active task.
    private var spatialSpanMemoryTask: ORKTask {
        return ORKOrderedTask.spatialSpanMemoryTaskWithIdentifier(String(Identifier.SpatialSpanMemoryTask), intendedUseDescription: exampleDescription, initialSpan: 3, minimumSpan: 2, maximumSpan: 15, playSpeed: 1.0, maxTests: 5, maxConsecutiveFailures: 3, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: [])
    }

    /// This task presents the Timed Walk pre-defined active task.
    private var timedWalkTask: ORKTask {
        return ORKOrderedTask.timedWalkTaskWithIdentifier(String(Identifier.TimedWalkTask), intendedUseDescription: exampleDescription, distanceInMeters: 100.0, timeLimit: 180.0, includeAssistiveDeviceForm: true, options: [])
    }
    
    /// This task presents the Tone Audiometry pre-defined active task.
    private var toneAudiometryTask: ORKTask {
        return ORKOrderedTask.toneAudiometryTaskWithIdentifier(String(Identifier.ToneAudiometryTask), intendedUseDescription: exampleDescription, speechInstruction: nil, shortSpeechInstruction: nil, toneDuration: 20, options: [])
    }

    private var towerOfHanoiTask: ORKTask {
        return ORKOrderedTask.towerOfHanoiTaskWithIdentifier(String(Identifier.TowerOfHanoi), intendedUseDescription: exampleDescription, numberOfDisks: 5, options: [])
    }
    
    /// This task presents the Two Finger Tapping pre-defined active task.
    private var twoFingerTappingIntervalTask: ORKTask {
        return ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier(String(Identifier.TwoFingerTappingIntervalTask), intendedUseDescription: exampleDescription, duration: 20, options: [])
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
        let participantSignature = ORKConsentSignature(forPersonWithTitle: participantSignatureTitle, dateFormatString: nil, identifier: String(Identifier.ConsentDocumentParticipantSignature))
        
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

        let investigatorSignature = ORKConsentSignature(forPersonWithTitle: investigatorSignatureTitle, dateFormatString: nil, identifier: String(Identifier.ConsentDocumentInvestigatorSignature), givenName: investigatorSignatureGivenName, familyName: investigatorSignatureFamilyName, signatureImage: signatureImage, dateString: investigatorSignatureDateString)
        
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
            .Overview,
            .DataGathering,
            .Privacy,
            .DataUse,
            .TimeCommitment,
            .StudySurvey,
            .StudyTasks,
            .Withdrawing
        ]
        
        /*
            For each consent section type in `consentSectionTypes`, create an
            `ORKConsentSection` that represents it.

            In a real app, you would set specific content for each section.
        */
        var consentSections: [ORKConsentSection] = consentSectionTypes.map { contentSectionType in
            let consentSection = ORKConsentSection(type: contentSectionType)
            
            consentSection.summary = loremIpsumShortText
            
            if contentSectionType == .Overview {
                consentSection.htmlContent = htmlContentString
            }
            else {
                consentSection.content = loremIpsumLongText
            }
            
            return consentSection
        }
        
        /*
            This is an example of a section that is only in the review document
            or only in the generated PDF, and is not displayed in `ORKVisualConsentStep`.
        */
        let consentSection = ORKConsentSection(type: .OnlyInDocument)
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
}
