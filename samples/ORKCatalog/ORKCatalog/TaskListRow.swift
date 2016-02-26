/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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
    An enum that corresponds to a row displayed in a `TaskListViewController`.

    Each of the tasks is composed of one or more steps giving examples of the
    types of functionality supported by the ResearchKit framework.
*/
enum TaskListRow: Int, Printable {
    case ScaleQuestion = 0
    case NumericQuestion
    case TimeOfDayQuestion
    case DateQuestion
    case DateTimeQuestion
    case TimeIntervalQuestion
    case TextQuestion
    case ValuePickerChoiceQuestion
    case TextChoiceQuestion
    case ImageChoiceQuestion
    case BooleanQuestion
    case TwoFingerTappingInterval
    case SpatialSpanMemory
    case Fitness
    case ShortWalk
    case Audio
    case ToneAudiometry
    case ReactionTime
    case TowerOfHanoi
    case PSAT
    case TimedWalk
    case HolePegTest
    case ImageCapture
    case Survey
    case Consent
    case Form
    
    /// Returns an array of all the task list row enum cases.
    static var allCases: [TaskListRow] {
        /*
            Create a generator that creates a `TaskListRow` at a specific index.
            When `TaskListRow`'s `rawValue` initializer returns `nil`, the generator
            will stop generating values. This will happen when the enum has no more
            cases represented by `caseIndex`.
        */
        var caseIndex = 0
        let caseGenerator = GeneratorOf { TaskListRow(rawValue: caseIndex++) }

        // Create a sequence that will consume the generator to create an array.
        let caseSequence = SequenceOf(caseGenerator)
        
        return Array(caseSequence)
    }
    
    // MARK: Printable
    
    var description: String {
        switch self {
            case .ScaleQuestion:
                return NSLocalizedString("Scale Question", comment: "")
                
            case .NumericQuestion:
                return NSLocalizedString("Numeric Question", comment: "")

            case .TimeOfDayQuestion:
                return NSLocalizedString("Time of Day Question", comment: "")
                
            case .DateQuestion:
                return NSLocalizedString("Date Question", comment: "")

            case .DateTimeQuestion:
                return NSLocalizedString("Date and Time Question", comment: "")
                
            case .TimeIntervalQuestion:
                return NSLocalizedString("Time Interval Question", comment: "")

            case .TextQuestion:
                return NSLocalizedString("Text Question", comment: "")
                
            case .ValuePickerChoiceQuestion:
                return NSLocalizedString("Value Picker Choice Question", comment: "")
                
            case .TextChoiceQuestion:
                return NSLocalizedString("Text Choice Question", comment: "")

            case .ImageChoiceQuestion:
                return NSLocalizedString("Image Choice Question", comment: "")

            case .BooleanQuestion:
                return NSLocalizedString("Boolean Question", comment: "")

            case .TwoFingerTappingInterval:
                return NSLocalizedString("Two Finger Tapping Interval Active Task", comment: "")

            case .SpatialSpanMemory:
                return NSLocalizedString("Spatial Span Memory Active Task", comment: "")

            case .Fitness:
                return NSLocalizedString("Fitness Check Active Task", comment: "")

            case .ShortWalk:
                return NSLocalizedString("Short Walk Active Task", comment: "")

            case .Audio:
                return NSLocalizedString("Audio Active Task", comment: "")

            case .ToneAudiometry:
                return NSLocalizedString("Tone Audiometry Active Task", comment: "")

            case .ReactionTime:
                return NSLocalizedString("Reaction Time Active Task", comment: "")
            
            case .TowerOfHanoi:
                return NSLocalizedString("Tower of Hanoi Active Task", comment: "")
            
            case .PSAT:
                return NSLocalizedString("PSAT Active Task", comment: "")
            
            case .TimedWalk:
                return NSLocalizedString("Timed Walk", comment: "")
            
            case .HolePegTest:
                return NSLocalizedString("Hole Peg Test Task", comment: "")
            
            case .ImageCapture:
                return NSLocalizedString("Image Capture Task", comment: "")

            case .Survey:
                return NSLocalizedString("Simple Survey", comment: "")

            case .Consent:
                return NSLocalizedString("Consent", comment: "")

            case .Form:
                return NSLocalizedString("Form", comment: "")
        }
    }
    
    // MARK: Types

    /**
        Every step and task in the ResearchKit framework has to have an identifier. Within a
        task, the step identifiers should be unique.

        Here we use an enum to ensure that the identifiers are kept unique. Since
        the enum has a raw underlying type of a `String`, the compiler can determine
        the uniqueness of the case values at compile time.

        In a real application, the identifiers for your tasks and steps might
        come from a database, or in a smaller application, might have some
        human-readable meaning.
    */
    private enum Identifier: String {
        // Task with examples of questions with sliding scales.
        case ScaleQuestionTask =                                    "ScaleQuestionTask"
        case DiscreteScaleQuestionStep =                            "DiscreteScaleQuestionStep"
        case ContinuousScaleQuestionStep =                          "ContinuousScaleQuestionStep"
        case DiscreteVerticalScaleQuestionStep =                    "DiscreteVerticalScaleQuestionStep"
        case ContinuousVerticalScaleQuestionStep =                  "ContinuousVerticalScaleQuestionStep"

        // Task with examples of numeric questions.
        case NumericQuestionTask =                                  "NumericQuestionTask"
        case NumericQuestionStep =                                  "NumericQuestionStep"
        case NumericNoUnitQuestionStep =                            "NumericNoUnitQuestionStep"
        
        // Task with an example of time of day entry.
        case TimeOfDayQuestionTask =                                "TimeOfDayQuestionTask"
        case TimeOfDayQuestionStep =                                "TimeOfDayQuestionStep"

        // Task with an example of date entry.
        case DateQuestionTask =                                     "DateQuestionTask"
        case DateQuestionStep =                                     "DateQuestionStep"

        // Task with an example of date and time entry.
        case DateTimeQuestionTask =                                 "DateTimeQuestionTask"
        case DateTimeQuestionStep =                                 "DateTimeQuestionStep"

        // Task with an example of time interval entry.
        case TimeIntervalQuestionTask =                             "TimeIntervalQuestionTask"
        case TimeIntervalQuestionStep =                             "TimeIntervalQuestionStep"

        // Task with an example of free text entry.
        case TextQuestionTask =                                     "TextQuestionTask"
        case TextQuestionStep =                                     "TextQuestionStep"

        // Task with a value picker.
        case ValuePickerChoiceQuestionTask =                        "ValuePickerChoiceQuestionTask"
        case ValuePickerChoiceQuestionStep =                        "ValuePickerChoiceQuestionStep"
        
        // Task with an example of a multiple choice question.
        case TextChoiceQuestionTask =                               "TextChoiceQuestionTask"
        case TextChoiceQuestionStep =                               "TextChoiceQuestionStep"
        
        // Task with an image choice question.
        case ImageChoiceQuestionTask =                              "ImageChoiceQuestionTask"
        case ImageChoiceQuestionStep =                              "ImageChoiceQuestionStep"

        // Survey example with a Boolean question.
        case BooleanQuestionTask =                                  "BooleanQuestionTask"
        case BooleanQuestionStep =                                  "BooleanQuestionStep"

        // Active tasks.
        case TwoFingerTappingIntervalTask =                         "TwoFingerTappingIntervalTask"
        case SpatialSpanMemoryTask =                                "SpatialSpanMemoryTask"
        case FitnessTask =                                          "FitnessTask"
        case ShortWalkTask =                                        "ShortWalkTask"
        case AudioTask =                                            "AudioTask"
        case ToneAudiometryTask =                                   "ToneAudiometry"
        case ReactionTime =                                         "ReactionTime"
        case TowerOfHanoi =                                         "TowerOfHanoi"
        case PSATTask =                                             "PSATTask"
        case TimedWalkTask =                                        "TimedWalkTask"
        case HolePegTestTask =                                      "HolePegTestTask"
        
        // Image capture task specific identifiers.
        case ImageCaptureTask =                                    "ImageCaptureTask"
        case ImageCaptureStep =                                    "ImageCaptureStep"

        // Survey task specific identifiers.
        case SurveyTask =                                           "SurveyTask"
        case IntroStep =                                            "IntroStep"
        case QuestionStep =                                         "QuestionStep"
        case SummaryStep =                                          "SummaryStep"
        
        // Consent task specific identifiers.
        case ConsentTask =                                          "ConsentTask"
        case VisualConsentStep =                                    "VisualConsentStep"
        case ConsentSharingStep =                                   "ConsentSharingStep"
        case ConsentReviewStep =                                    "ConsentReviewStep"
        case ConsentDocumentParticipantSignature =                  "ConsentDocumentParticipantSignature"
        case ConsentDocumentInvestigatorSignature =                 "ConsentDocumentInvestigatorSignature"

        // Task with a form, where multiple items appear on one page.
        case FormTask =                                             "FormTask"
        case FormStep =                                             "FormStep"
        case FormItem01 =                                           "FormItem01"
        case FormItem02 =                                           "FormItem02"
    }
    
    // MARK: Properties
    
    /// Returns a new `ORKTask` that the `TaskListRow` enumeration represents.
    var representedTask: ORKTask {
        switch self {
            case .ScaleQuestion:
                return scaleQuestionTask

            case .NumericQuestion:
                return numericQuestionTask
            
            case .TimeOfDayQuestion:
                return timeOfDayQuestionTask

            case .DateQuestion:
                return dateQuestionTask
            
            case .DateTimeQuestion:
                return dateTimeQuestionTask
            
            case .TimeIntervalQuestion:
                return timeIntervalQuestionTask
            
            case .TextQuestion:
                return textQuestionTask
            
            case .ValuePickerChoiceQuestion:
                return valuePickerChoiceQuestionTask
            
            case .TextChoiceQuestion:
                return textChoiceQuestionTask
            
            case .ImageChoiceQuestion:
                return imageChoiceQuestionTask
            
            case .BooleanQuestion:
                return booleanQuestionTask
            
            case .TwoFingerTappingInterval:
                return twoFingerTappingIntervalTask
            
            case .SpatialSpanMemory:
                return spatialSpanMemoryTask
            
            case .Fitness:
                return fitnessTask
            
            case .ShortWalk:
                return shortWalkTask
            
            case .Audio:
                return audioTask
            
            case .ToneAudiometry:
                return toneAudiometryTask

            case .ReactionTime:
                return reactionTimeTask
            
            case .TowerOfHanoi:
                return towerOfHanoiTask
            
            case .PSAT:
                return PSATTask
            
            case .TimedWalk:
                return TimedWalkTask
            
            case .HolePegTest:
                return holePegTestTask
            
            case .ImageCapture:
                return imageCaptureTask
            
            case .Survey:
                return surveyTask
            
            case .Consent:
                return consentTask
            
            case .Form:
                return formTask
        }
    }

    // MARK: Task Creation Convenience
    
    /// This task presents two options for questions displaying a scale control.
    private var scaleQuestionTask: ORKTask {
        var steps = [ORKStep]()
        
        // The first step is a scale control with 10 discrete ticks.
        let step1AnswerFormat = ORKAnswerFormat.scaleAnswerFormatWithMaximumValue(10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: false, maximumValueDescription: exampleHighValueText, minimumValueDescription: exampleLowValueText)
        
        let questionStep1 = ORKQuestionStep(identifier: Identifier.DiscreteScaleQuestionStep.rawValue, title: exampleQuestionText, answer: step1AnswerFormat)
        
        questionStep1.text = exampleDetailText
        
        steps += [questionStep1]
        
        // The second step is a scale control that allows continuous movement with a percent formatter.
        let step2AnswerFormat = ORKAnswerFormat.continuousScaleAnswerFormatWithMaximumValue(1.0, minimumValue: 0.0, defaultValue: 99.0, maximumFractionDigits: 0, vertical: false, maximumValueDescription: nil, minimumValueDescription: nil)
        step2AnswerFormat.numberStyle = .Percent
        
        let questionStep2 = ORKQuestionStep(identifier: Identifier.ContinuousScaleQuestionStep.rawValue, title: exampleQuestionText, answer: step2AnswerFormat)
        
        questionStep2.text = exampleDetailText
        
        steps += [questionStep2]

        // The third step is a vertical scale control with 10 discrete ticks.
        let step3AnswerFormat = ORKAnswerFormat.scaleAnswerFormatWithMaximumValue(10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: true, maximumValueDescription: nil, minimumValueDescription: nil)
        
        let questionStep3 = ORKQuestionStep(identifier: Identifier.DiscreteVerticalScaleQuestionStep.rawValue, title: exampleQuestionText, answer: step3AnswerFormat)
        
        questionStep3.text = exampleDetailText
        
        steps += [questionStep3]

        // The fourth step is a vertical scale control that allows continuous movement.
        let step4AnswerFormat = ORKAnswerFormat.continuousScaleAnswerFormatWithMaximumValue(5.0, minimumValue: 1.0, defaultValue: 99.0, maximumFractionDigits: 2, vertical: true, maximumValueDescription: exampleHighValueText, minimumValueDescription: exampleLowValueText)
        
        let questionStep4 = ORKQuestionStep(identifier: Identifier.ContinuousVerticalScaleQuestionStep.rawValue, title: exampleQuestionText, answer: step4AnswerFormat)
        
        questionStep4.text = exampleDetailText
        
        steps += [questionStep4]
        
        return ORKOrderedTask(identifier: Identifier.ScaleQuestionTask.rawValue, steps: steps)
    }
    
    /**
        This task demonstrates use of numeric questions with and without units.
        Note that the unit is just a string, prompting the user to enter the value
        in the expected unit. The unit string propagates into the result object.
    */
    private var numericQuestionTask: ORKTask {
        var steps = [ORKStep]()
        
        // This answer format will display a unit in-line with the numeric entry field.
        let localizedQuestionStep1AnswerFormatUnit = NSLocalizedString("Your unit", comment: "")
        let questionStep1AnswerFormat = ORKAnswerFormat.decimalAnswerFormatWithUnit(localizedQuestionStep1AnswerFormatUnit)
        
        let questionStep1 = ORKQuestionStep(identifier: Identifier.NumericQuestionStep.rawValue, title: exampleQuestionText, answer: questionStep1AnswerFormat)
        
        questionStep1.text = exampleDetailText
        questionStep1.placeholder = NSLocalizedString("Your placeholder.", comment: "")
        
        steps += [questionStep1]
        
        // This answer format is similar to the previous one, but this time without displaying a unit.
        let questionStep2 = ORKQuestionStep(identifier: Identifier.NumericNoUnitQuestionStep.rawValue, title: exampleQuestionText, answer: ORKAnswerFormat.decimalAnswerFormatWithUnit(nil))
        
        questionStep2.text = exampleDetailText
        questionStep2.placeholder = NSLocalizedString("Placeholder without unit.", comment: "")
        
        steps += [questionStep2]
        
        return ORKOrderedTask(identifier: Identifier.NumericQuestionTask.rawValue, steps: steps)
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
        
        let questionStep = ORKQuestionStep(identifier: Identifier.TimeOfDayQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.TimeOfDayQuestionTask.rawValue, steps: [questionStep])
    }
    
    /// This task demonstrates a question which asks for a date.
    private var dateQuestionTask: ORKTask {
        /*
            The date answer format can also support minimum and maximum limits,
            a specific default value, and overriding the calendar to use.
        */
        let answerFormat = ORKAnswerFormat.dateAnswerFormat()
        
        let step = ORKQuestionStep(identifier: Identifier.DateQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.DateQuestionTask.rawValue, steps: [step])
    }
    
    /// This task demonstrates a question asking for a date and time of an event.
    private var dateTimeQuestionTask: ORKTask {
        /*
            This uses the default calendar. Use a more detailed constructor to
            set minimum / maximum limits.
         */
        let answerFormat = ORKAnswerFormat.dateTimeAnswerFormat()
        
        let step = ORKQuestionStep(identifier: Identifier.DateTimeQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.DateTimeQuestionTask.rawValue, steps: [step])
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
        
        let step = ORKQuestionStep(identifier: Identifier.TimeIntervalQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.TimeIntervalQuestionTask.rawValue, steps: [step])
    }

    /**
        This task demonstrates asking for text entry. Both single and multi-line
        text entry are supported, with appropriate parameters to the text answer
        format.
    */
    private var textQuestionTask: ORKTask {
        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        
        let step = ORKQuestionStep(identifier: Identifier.TextQuestionStep.rawValue, title: exampleQuestionText, answer: ORKAnswerFormat.textAnswerFormat())
        
        step.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.TextQuestionTask.rawValue, steps: [step])
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
        
        let questionStep = ORKQuestionStep(identifier: Identifier.ValuePickerChoiceQuestionStep.rawValue, title: exampleQuestionText,
            answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.ValuePickerChoiceQuestionTask.rawValue, steps: [questionStep])
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
        
        let questionStep = ORKQuestionStep(identifier: Identifier.TextChoiceQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.TextChoiceQuestionTask.rawValue, steps: [questionStep])
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
        
        let questionStep = ORKQuestionStep(identifier: Identifier.ImageChoiceQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.ImageChoiceQuestionTask.rawValue, steps: [questionStep])
    }

    /// This task presents just a single "Yes" / "No" question.
    private var booleanQuestionTask: ORKTask {
        let answerFormat = ORKBooleanAnswerFormat()

        // We attach an answer format to a question step to specify what controls the user sees.
        let questionStep = ORKQuestionStep(identifier: Identifier.BooleanQuestionStep.rawValue, title: exampleQuestionText, answer: answerFormat)
        
        // The detail text is shown in a small font below the title.
        questionStep.text = exampleDetailText
        
        return ORKOrderedTask(identifier: Identifier.BooleanQuestionTask.rawValue, steps: [questionStep])
    }

    /// This task presents the Two Finger Tapping pre-defined active task.
    private var twoFingerTappingIntervalTask: ORKTask {
        return ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier(Identifier.TwoFingerTappingIntervalTask.rawValue, intendedUseDescription: exampleDescription, duration: 20, options: nil)
    }

    /// This task presents the Spatial Span Memory pre-defined active task.
    private var spatialSpanMemoryTask: ORKTask {
        return ORKOrderedTask.spatialSpanMemoryTaskWithIdentifier(Identifier.SpatialSpanMemoryTask.rawValue, intendedUseDescription: exampleDescription, initialSpan: 3, minimumSpan: 2, maximumSpan: 15, playSpeed: 1.0, maxTests: 5, maxConsecutiveFailures: 3, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: nil)
    }
    
    /**
        This task presents the Fitness pre-defined active task. For this example,
        short walking and rest durations of 20 seconds each are used, whereas more
        realistic durations might be several minutes each.
    */
    private var fitnessTask: ORKTask {
        return ORKOrderedTask.fitnessCheckTaskWithIdentifier(Identifier.FitnessTask.rawValue, intendedUseDescription: exampleDescription, walkDuration: 20, restDuration: 20, options: nil)
    }

    /// This task presents the Gait and Balance pre-defined active task.
    private var shortWalkTask: ORKTask {
        return ORKOrderedTask.shortWalkTaskWithIdentifier(Identifier.ShortWalkTask.rawValue, intendedUseDescription: exampleDescription, numberOfStepsPerLeg: 20, restDuration: 20, options: nil)
    }

    /// This task presents the Audio pre-defined active task.
    private var audioTask: ORKTask {
        return ORKOrderedTask.audioTaskWithIdentifier(Identifier.AudioTask.rawValue, intendedUseDescription: exampleDescription, speechInstruction: exampleSpeechInstruction, shortSpeechInstruction: exampleSpeechInstruction, duration: 20, recordingSettings: nil, options: nil)
    }
    
    private var reactionTimeTask: ORKTask {
        return ORKOrderedTask.reactionTimeTaskWithIdentifier(Identifier.ReactionTime.rawValue, intendedUseDescription: exampleDescription, maximumStimulusInterval: 10, minimumStimulusInterval: 4, thresholdAcceleration: 0.5, numberOfAttempts: 3, timeout: 3, successSound: exampleSuccessSound, timeoutSound: 0, failureSound: UInt32(kSystemSoundID_Vibrate), options: nil)
    }
    
    private var towerOfHanoiTask: ORKTask {
        return ORKOrderedTask.towerOfHanoiTaskWithIdentifier(Identifier.TowerOfHanoi.rawValue, intendedUseDescription: exampleDescription, numberOfDisks: 5, options: nil)
    }
    
    /// This task presents the PSAT pre-defined active task.
    private var PSATTask: ORKTask {
        return ORKOrderedTask.PSATTaskWithIdentifier(Identifier.PSATTask.rawValue, intendedUseDescription: exampleDescription, presentationMode: (.Auditory | .Visual), interStimulusInterval: 3.0, stimulusDuration: 1.0, seriesLength: 60, options: nil)
    }
    
    /// This task presents the Timed Walk pre-defined active task.
    private var timedWalkTask: ORKTask {
        return ORKOrderedTask.timedWalkTaskWithIdentifier(String(Identifier.TimedWalkTask), intendedUseDescription: exampleDescription, distanceInMeters: 100.0, timeLimit: 180.0, includeAssistiveDeviceForm: true, options: [])
    }
    
    /// This task presents the Hole Peg Test pre-defined active task.
    private var holePegTestTask: ORKTask {
        return ORKNavigableOrderedTask.holePegTestTaskWithIdentifier(Identifier.HolePegTestTask.rawValue, intendedUseDescription: exampleDescription, dominantHand: .Right, numberOfPegs: 9, threshold: 0.2, rotated: false, timeLimit: 300, options: nil)
    }
    
    private var exampleSuccessSound: UInt32 {
        var successSoundPath: CFURLRef! = NSURL(fileURLWithPath: "///System/Library/Audio/UISounds/Modern/sms_alert_complete.caf") as CFURLRef!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(successSoundPath, &soundID)
        return soundID
    }

    /// This task presents the Tone Audiometry pre-defined active task.
    private var toneAudiometryTask: ORKTask {
        return ORKOrderedTask.toneAudiometryTaskWithIdentifier(Identifier.ToneAudiometryTask.rawValue, intendedUseDescription: exampleDescription, speechInstruction: nil, shortSpeechInstruction: nil, toneDuration: 20, options: nil)
    }
    
    /// This task presents the image capture step in an ordered task.
    private var imageCaptureTask: ORKTask {
        var steps = [ORKStep]()
        
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: Identifier.IntroStep.rawValue)
        
        instructionStep.title = NSLocalizedString("Sample Survey", comment: "")
        
        instructionStep.text = exampleDescription
        
        instructionStep.image = UIImage(named: "hand_solid")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        steps += [instructionStep]
        
        let imageCaptureStep = ORKImageCaptureStep(identifier: Identifier.ImageCaptureStep.rawValue)
        imageCaptureStep.optional = false
        imageCaptureStep.accessibilityInstructions = NSLocalizedString("Your instructions for capturing the image", comment: "")
        imageCaptureStep.accessibilityHint = NSLocalizedString("Captures the image visible in the preview", comment: "")
        
        imageCaptureStep.templateImage = UIImage(named: "hand_outline_big")!
        
        imageCaptureStep.templateImageInsets = UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05)
        
        steps += [imageCaptureStep]
        
        return ORKOrderedTask(identifier: Identifier.ImageCaptureTask.rawValue, steps: steps)
    }

    /**
        A task demonstrating how the ResearchKit framework can be used to present a simple
        survey with an introduction, a question, and a conclusion.
    */
    private var surveyTask: ORKTask {
        var steps = [ORKStep]()
        
        // Create the intro step.
        let instructionStep = ORKInstructionStep(identifier: Identifier.IntroStep.rawValue)
        
        instructionStep.title = NSLocalizedString("Sample Survey", comment: "")
        
        instructionStep.text = exampleDescription
        
        steps += [instructionStep]
        
        // Add a question step.
        let questionStepAnswerFormat = ORKBooleanAnswerFormat()
        
        let questionStepTitle = NSLocalizedString("Would you like to subscribe to our newsletter?", comment: "")
        let questionStep = ORKQuestionStep(identifier: Identifier.QuestionStep.rawValue, title: questionStepTitle, answer: questionStepAnswerFormat)
        
        steps += [questionStep]
        
        // Add a summary step.
        let summaryStep = ORKInstructionStep(identifier: Identifier.SummaryStep.rawValue)
        summaryStep.title = NSLocalizedString("Thanks", comment: "")
        summaryStep.text = NSLocalizedString("Thank you for participating in this sample survey.", comment: "")
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: Identifier.SurveyTask.rawValue, steps: steps)
    }

    /// A task demonstrating how the ResearchKit framework can be used to obtain informed consent.
    private var consentTask: ORKTask {
        var steps = [ORKStep]()
        
        /*
            Informed consent starts by presenting an animated sequence conveying
            the main points of your consent document.
        */
        let visualConsentStep = ORKVisualConsentStep(identifier: Identifier.VisualConsentStep.rawValue, document: consentDocument)
        
        steps += [visualConsentStep]
        
        let investigatorShortDescription = NSLocalizedString("Institution", comment: "")
        let investigatorLongDescription = NSLocalizedString("Institution and its partners", comment: "")
        let localizedLearnMoreHTMLContent = NSLocalizedString("Your sharing learn more content here.", comment: "")
        
        /*
            If you want to share the data you collect with other researchers for
            use in other studies beyond this one, it is best practice to get
            explicit permission from the participant. Use the consent sharing step
            for this.
        */
        let sharingConsentStep = ORKConsentSharingStep(identifier: Identifier.ConsentSharingStep.rawValue, investigatorShortDescription: investigatorShortDescription, investigatorLongDescription: investigatorLongDescription, localizedLearnMoreHTMLContent: localizedLearnMoreHTMLContent)
        
        steps += [sharingConsentStep]
        
        /*
            After the visual presentation, the consent review step displays
            your consent document and can obtain a signature from the participant.
        
            The first signature in the document is the participant's signature.
            This effectively tells the consent review step which signatory is
            reviewing the document.
        */
        let signature = consentDocument.signatures!.first as! ORKConsentSignature

        let reviewConsentStep = ORKConsentReviewStep(identifier: Identifier.ConsentReviewStep.rawValue, signature: signature, inDocument: consentDocument)

        // In a real application, you would supply your own localized text.
        reviewConsentStep.text = loremIpsumText
        reviewConsentStep.reasonForConsent = loremIpsumText
        
        steps += [reviewConsentStep]
        
        return ORKOrderedTask(identifier: Identifier.ConsentTask.rawValue, steps: steps)
    }
    
    /**
        This task demonstrates a form step, in which multiple items are presented
        in a single scrollable form. This might be used for entering multi-value
        data, like taking a blood pressure reading with separate systolic and
        diastolic values.
    */
    private var formTask: ORKTask {
        let step = ORKFormStep(identifier: Identifier.FormTask.rawValue, title: exampleQuestionText, text: exampleDetailText)
        
        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("Field01", comment: "")
        let formItem01 = ORKFormItem(identifier: Identifier.FormItem01.rawValue, text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormatWithUnit(nil))
        formItem01.placeholder = NSLocalizedString("Your placeholder here", comment: "")

        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString("Field02", comment: "")
        let formItem02 = ORKFormItem(identifier: Identifier.FormItem02.rawValue, text: formItem02Text, answerFormat: ORKTimeIntervalAnswerFormat())
        formItem02.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        step.formItems = [formItem01, formItem02]

        return ORKOrderedTask(identifier: Identifier.FormTask.rawValue, steps: [step])
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
        let participantSignature = ORKConsentSignature(forPersonWithTitle: participantSignatureTitle, dateFormatString: nil, identifier: Identifier.ConsentDocumentParticipantSignature.rawValue)
        
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

        let investigatorSignature = ORKConsentSignature(forPersonWithTitle: investigatorSignatureTitle, dateFormatString: nil, identifier: Identifier.ConsentDocumentInvestigatorSignature.rawValue, givenName: investigatorSignatureGivenName, familyName: investigatorSignatureFamilyName, signatureImage: signatureImage, dateString: investigatorSignatureDateString)
        
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
            
            consentSection.summary = self.loremIpsumShortText
            
            if contentSectionType == .Overview {
                consentSection.htmlContent = htmlContentString
            }
            else {
                consentSection.content = self.loremIpsumLongText
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
    
