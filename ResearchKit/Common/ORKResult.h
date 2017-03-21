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


@import UIKit;
@import CoreLocation;
#import <ResearchKit/ORKTypes.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKRecorder;
@class ORKStep;
@class ORKQuestionStep;
@class ORKFormItem;
@class ORKFormStep;
@class ORKConsentReviewStep;
@class ORKQuestionResult;
@class ORKConsentSignature;
@class ORKConsentDocument;
@class ORKConsentSignatureResult;
@class ORKStepResult;
@class ORKToneAudiometrySample;


/**
 The `ORKResult` class defines the attributes of a result from one step or a group
 of steps. When you use the ResearchKit framework APIs, you typically get a result from the `result` property
 of either `ORKTaskViewController` or `ORKStepViewController`.
 Certain types of results can contain other results, which together express a hierarchy; examples of these types of results are `ORKCollectionResult` subclasses, such as `ORKStepResult` and `ORKTaskResult`.
 
 When you receive a result, you can store it temporarily by archiving it with
 `NSKeyedArchiver`, because all `ORKResult` objects implement `NSSecureCoding`. If you want to serialize the result object to other formats, you're responsible for implementing this.
 
 The result object hierarchy does not necessarily include all the data collected
 during a task. Some result objects, such as `ORKFileResult`, may refer to files
 in the filesystem that were generated during the task. These files are easy to find, because they are all
 located in the output directory of the task view controller.
 
 It's recommended that you use `NSFileProtectionComplete` (at a minimum) to protect these files, and that you similarly protect all serialization of `ORKResult` objects that you write to disk. It is also generally helpful to keep the results together with the referenced files as you submit them to a back-end server. For example, it can be convenient to zip all data corresponding to a particular task result into a single compressed archive.
 
 Every object in the result hierarchy has an identifier that should correspond
 to the identifier of an object in the original step hierarchy. Similarly, every
 object has a start date and an end date that correspond to the range of
 times during which the result was collected. In an `ORKStepResult` object, for example,
 the start and end dates cover the range of time during which the step view controller was visible on
 screen.
 
 When you implement a new type of step, it is usually helpful to create a new
 `ORKResult` subclass to hold the type of result data the step can generate, unless it makes sense to use an existing subclass. Return your custom result subclass as one of the results attached to the step's `ORKStepResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKResult : NSObject <NSCopying, NSSecureCoding>

/**
 Returns an initialized result using the specified identifier.
 
 Typically, objects such as `ORKStepViewController` and `ORKTaskViewController` instantiate result (and `ORKResult` subclass) objects; you seldom need to instantiate a result object in your code.
 
 @param identifier     The unique identifier of the result.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 A meaningful identifier for the result.
 
 The identifier can be used to identify the question
 that was asked or the task that was completed to produce the result. Typically, the identifier is copied from the originating object by the view controller or recorder that produces it.
 
 For example, a task result receives its identifier from a task,
 a step result receives its identifier from a step,
 and a question result receives its identifier from a step or a form item.
 Results that are generated by recorders also receive an identifier that corresponds to
 that recorder.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 The time when the task, step, or data collection began.
 
 The value of this property is set by the view controller or recorder that produces the result,
 to indicate when data collection started.
 
 Note that for instantaneous items, `startDate` and `endDate` can have the same value, and should
 generally correspond to the end of the instantaneous data collection period.
 */
@property (nonatomic, copy) NSDate *startDate;

/**
 The time when the task, step, or data collection stopped.
 
 The value of this property is set by the view controller or recorder that produces the result,
 to indicate when data collection stopped.
 
 Note that for instantaneous items, `startDate` and `endDate` can have the same value, and should
 generally correspond to the end of the instantaneous data collection period. 
 */
@property (nonatomic, copy) NSDate *endDate;

/**
 Metadata that describes the conditions under which the result was acquired.
 
 The `userInfo` dictionary can be set by the view controller or recorder
 that produces the result. However, it's often a better choice to use a new `ORKResult` subclass for passing additional information back to code that uses
 the framework, because using
 typed accessors is safer than using a dictionary.
 
 The user info dictionary must contain only keys and values that are suitable for property
 list or JSON serialization.
 */
@property (nonatomic, copy, nullable) NSDictionary *userInfo;

@end


/**
 The `ORKPasscodeResult` class records the results of a passcode step.
 
 The passcode result object contains a boolean indicating whether the passcode was saved or not.
 */
ORK_CLASS_AVAILABLE
@interface ORKPasscodeResult : ORKResult

/**
 A boolean indicating if a passcode was saved or not.
 */
@property (nonatomic, assign, getter=isPasscodeSaved) BOOL passcodeSaved;

/**
 A boolean that indicates if the user has enabled/disabled TouchID
 */
@property (nonatomic, assign, getter=isTouchIdEnabled) BOOL touchIdEnabled;

@end














/**
 The `ORKQuestionResult` class is the base class for leaf results from an item that uses an answer format (`ORKAnswerFormat`).
 
 A question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 See also: `ORKQuestionStep` and `ORKFormItem`.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionResult : ORKResult

/**
 A value that indicates the type of question the result came from.
 
 The value of `questionType` generally correlates closely with the class, but it can be
 easier to use this value in a switch statement in Objective-C.
 */
@property (nonatomic) ORKQuestionType questionType;

@end


/**
 The `ORKScaleQuestionResult` class represents the answer to a continuous or
 discrete-value scale answer format.
 
 A scale question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKScaleQuestionResult : ORKQuestionResult

/**
 The answer obtained from the scale question.
 
 The value of this property is `nil` when the user skipped the question or otherwise did not
 enter an answer.
 */
@property (nonatomic, copy, nullable) NSNumber *scaleAnswer;

@end


/**
 The `ORKChoiceQuestionResult` class represents the single or multiple choice
 answers from a choice-based answer format.
 
 For example, an `ORKTextChoiceAnswerFormat` or an `ORKImageChoiceAnswerFormat`
 format produces an `ORKChoiceQuestionResult` object.
 
 A choice question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKChoiceQuestionResult : ORKQuestionResult

/**
 An array of selected values, from the `value` property of an `ORKTextChoice` or `ORKImageChoice` object.
 In the case of a single choice, the array has exactly one entry.
 
 If the user skipped the question, the value of the corresponding array member is `nil`.
 */
@property (nonatomic, copy, nullable) NSArray *choiceAnswers;

@end

/**
 The `ORKMultipleComponentQuestionResult` class represents the choice
 answers from a multiple-component picker-style choice-based answer format.
 
 For example, an `ORKMultipleValuePickerAnswerFormat` produces an `ORKMultipleComponentQuestionResult` object.
 
 A multiple component question result is typically generated by the framework as the task proceeds. 
 When the task completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKMultipleComponentQuestionResult : ORKQuestionResult

/**
 An array of selected components, from the `value` property of an `ORKTextChoice` object.
 The array will have the same count as the number of components.
 
 If the user skipped the question, the value of the corresponding array member is `nil`.
 */
@property (nonatomic, copy, nullable) NSArray *componentsAnswer;

/**
 The string separator used to join the components (if applicable)
 */
@property (nonatomic, copy, nullable) NSString *separator;


@end


/**
 The `ORKBooleanQuestionResult` class represents the answer to a Yes/No question.
 
 A Boolean question result is produced by the task view controller when it presents a question or form
 item with a Boolean answer format (that is, `ORKBooleanAnswerFormat`).
 
 A Boolean question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKBooleanQuestionResult : ORKQuestionResult

/** The answer, or `nil` if the user skipped the question. */
@property (nonatomic, copy, nullable) NSNumber *booleanAnswer;

@end


/**
 The `ORKTextQuestionResult` class represents the answer to a question or
 form item that uses an `ORKTextAnswerFormat` format.
 
 A text question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextQuestionResult : ORKQuestionResult

/** 
 The answer that the user entered.
 
 If the user skipped the question, the value of this property is `nil`.
 */
@property (nonatomic, copy, nullable) NSString *textAnswer;

@end


/**
 The `ORKNumericQuestionResult` class represents a question or form item that uses an answer format that produces a numeric answer.
 
 Examples of this type of answer format include `ORKScaleAnswerFormat` and `ORKNumericAnswerFormat`.
 
 A numeric question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKNumericQuestionResult : ORKQuestionResult

/// The number collected, or `nil` if the user skipped the question.
@property (nonatomic, copy, nullable) NSNumber *numericAnswer;

/**
 The unit string displayed to the user when the value was entered, or `nil` if no unit string was displayed.
 */
@property (nonatomic, copy, nullable) NSString *unit;

@end


/**
 The `ORKTimeOfDayQuestionResult` class represents the result of a question that uses the `ORKTimeOfDayAnswerFormat` format.
 */

ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayQuestionResult : ORKQuestionResult

/**
 The date components picked by the user.
 
 Typically only hour, minute, and AM/PM data are of interest.
 */
@property (nonatomic, copy, nullable) NSDateComponents *dateComponentsAnswer;

@end


/**
 The `ORKTimeIntervalQuestionResult` class represents the result of a question
 that uses the `ORKTimeIntervalAnswerFormat` format.
 
 A time interval question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalQuestionResult : ORKQuestionResult

/**
 The selected interval, in seconds.
 
 The value of this property is `nil` if the user skipped the question.
 */
@property (nonatomic, copy, nullable) NSNumber *intervalAnswer;

@end


/**
 The `ORKDateQuestionResult` class represents the result of a question or form item that asks for a date (`ORKDateAnswerFormat`).
 
 The calendar and time zone are recorded in addition to the answer itself,
 to give the answer context. Usually, this data corresponds to the current calendar
 and time zone at the time of the activity, but it can be overridden by setting
 these properties explicitly in the `ORKDateAnswerFormat` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKDateQuestionResult : ORKQuestionResult

/**
 The date that the user entered, or `nil` if the user skipped the question.
 */
@property (nonatomic, copy, nullable) NSDate *dateAnswer;

/**
 The calendar used when selecting date and time.
 
 If the calendar in the `ORKDateAnswerFormat` object is `nil`, this calendar is the system
 calendar at the time of data entry.
 */
@property (nonatomic, copy, nullable) NSCalendar *calendar;

/**
 The time zone that was current when selecting the date and time.
 */
@property (nonatomic, copy, nullable) NSTimeZone *timeZone;

@end


/**
 The `ORKConsentSignatureResult` class represents a signature obtained during
 a consent review step (`ORKConsentReviewStep`). The consent signature result is usually found as a child result of the
 `ORKStepResult` object for the consent review step.
 
 You can apply the result to a document to facilitate the generation of a
 PDF including the signature, or for presentation in a follow-on
 consent review.
 
 A consent signature result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSignatureResult : ORKResult

/**
 A copy of the signature obtained.
 
 The signature is a copy of the `signature` property in the originating
 `ORKConsentReviewStep` object, but also includes any name or signature image collected during
 the consent review step.
 */
@property (nonatomic, copy, nullable) ORKConsentSignature *signature;

/**
 A boolean value indicating whether the participant consented.
 
 `YES` if the user confirmed consent to the contents of the consent review. Note
 that the signature could still be invalid if the name or signature image is
 empty; this indicates only that the user gave a positive acknowledgement of the
 document.
 */
@property (nonatomic, assign) BOOL consented;

/**
 Applies the signature to the consent document.
 
 This method uses the identifier to look up the matching signature placeholder
 in the consent document and replaces it with this signature. It may throw an exception if
 the document does not contain a signature with a matching identifier.
 
 @param document     The document to which to apply the signature.
 */
- (void)applyToDocument:(ORKConsentDocument *)document;

@end


/**
 The `ORKCollectionResult` class represents a result that contains an array of
 child results.
 
 `ORKCollectionResult` is the superclass of `ORKTaskResult` and `ORKStepResult`.
 
 Note that object of this class are not instantiated directly by the ResearchKit framework.
 */
ORK_CLASS_AVAILABLE
@interface ORKCollectionResult : ORKResult

/**
 An array of `ORKResult` objects that are the children of the result.
 
 For `ORKTaskResult`, the array contains `ORKStepResult` objects.
 For `ORKStepResult` the array contains concrete result objects such as `ORKFileResult`
 and `ORKQuestionResult`.
 */
@property (nonatomic, copy, nullable) NSArray<ORKResult *> *results;

/**
 Looks up the child result containing an identifier that matches the specified identifier.
 
 @param identifier The identifier of the step for which to search.
 
 @return The matching result, or `nil` if none was found.
 */
- (nullable ORKResult *)resultForIdentifier:(NSString *)identifier;

/**
 The first result.
 
 This is the first result, or `nil` if there are no results.
 */
@property (nonatomic, strong, readonly, nullable) ORKResult *firstResult;

@end


/**
 `ORKTaskResultSource` is the protocol for `[ORKTaskViewController defaultResultSource]`.
 */
@protocol ORKTaskResultSource <NSObject>

/**
 Returns a step result for the specified step identifier, if one exists.
 
 When it's about to present a step, the task view controller needs to look up a
 suitable default answer. The answer can be used to prepopulate a survey with
 the results obtained on a previous run of the same task, by passing an
 `ORKTaskResult` object (which itself implements this protocol).
 
 @param stepIdentifier The identifier for which to search.
 
 @return The result for the specified step, or `nil` for none.
 */
- (nullable ORKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier;

/**
 Should the default result store be used even if there is a previous result? (due to 
 reverse navigation or looping)
 
 By default, the `[ORKTaskViewController defaultResultSource]` is only queried for a 
 result if the previous result is nil. This allows the result source to override that
 default behavior.
 
 @return `YES` if the default result should be given priority over the previous result.
 */
@optional
- (BOOL)alwaysCheckForDefaultResult;

@end


/**
 An `ORKTaskResult` object is a collection result that contains all the step results
 generated from one run of a task or ordered task (that is, `ORKTask` or `ORKOrderedTask`) in a task view controller.
 
 A task result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 The `results` property of the `ORKCollectionResult` object contains the step results
 for the task.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskResult : ORKCollectionResult <ORKTaskResultSource>

/**
 Returns an intialized task result using the specified identifiers and directory.
 
 @param identifier      The identifier of the task that produced this result.
 @param taskRunUUID     The UUID of the run of the task that produced this result.
 @param outputDirectory The directory in which any files referenced by results can be found.
 
 @return An initialized task result.
 */
- (instancetype)initWithTaskIdentifier:(NSString *)identifier
                           taskRunUUID:(NSUUID *)taskRunUUID
                       outputDirectory:(nullable NSURL *)outputDirectory;

/**
 A unique identifier (UUID) for the presentation of the task that generated
 the result.
 
 The unique identifier for a run of the task typically comes directly
 from the task view controller that was used to run the task.
 */
@property (nonatomic, copy, readonly) NSUUID *taskRunUUID;

/**
 The directory in which the generated data files were stored while the task was run.
 
 The directory comes directly from the task view controller that was used to run this
 task. Generally, when archiving the results of a task, it is useful to archive
 all the files found in the output directory.
 
 The file URL also prefixes the file URLs referenced in any child
 `ORKFileResult` objects.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *outputDirectory;

@end


/**
 The `ORKStepResult` class represents a collection result produced by a step view controller to
 hold all child results produced by the step.
 
 A step result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 For example, an `ORKQuestionStep` object produces an `ORKQuestionResult` object that becomes
 a child of the `ORKStepResult` object. Similarly, an `ORKActiveStep` object may produce individual
 child result objects for each of the recorder configurations that was active
 during that step.
 
 The `results` property of the `ORKCollectionResult` object contains the step results
 for the task.
 */
ORK_CLASS_AVAILABLE
@interface ORKStepResult : ORKCollectionResult


/**
 Returns an initialized step result using the specified identifier.
 
 @param stepIdentifier      The identifier of the step.
 @param results             The array of child results. The value of this parameter can be `nil` or empty
            if no results were collected.
 
 @return An initialized step result.
 */
- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(nullable NSArray<ORKResult *> *)results;

/**
 This property indicates whether the Voice Over or Switch Control assistive technologies were active
 while performing the corresponding step.
 
 This information can be used, for example, to take into consideration the extra time needed by
 handicapped participants to complete some tasks, such as the Tower of Hanoi activity.
 
 The property can have the following values:
 - `UIAccessibilityNotificationVoiceOverIdentifier` if Voice Over was active
 - `UIAccessibilityNotificationSwitchControlIdentifier` if Switch Control was active
 
 Note that the Voice Over and Switch Control assistive technologies are mutually exclusive.
 
 If the property is `nil`, none of these assistive technologies was used.
 */
@property (nonatomic, copy, readonly, nullable) NSString *enabledAssistiveTechnology;

@end


/**
 The `ORKLocation` class represents the location addess obtained from a locaton question.
 */
ORK_CLASS_AVAILABLE
@interface ORKLocation : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 The geographical coordinate information.
 */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 The region describes the size of the placemark of the location.
 */
@property (nonatomic, copy, readonly) CLCircularRegion *region;

/**
 The human readable address typed in by user.
 */
@property (nonatomic, copy, readonly) NSString *userInput;

/**
 The address dicitonary for this coordinate from MapKit.
 */
@property (nonatomic, copy, readonly) NSDictionary *addressDictionary;

@end


/**
 The `ORKLocationQuestionResult` class represents the result of a question or form item that asks for a location (`ORKLocationAnswerFormat`).
 
 A Location question result is produced by the task view controller when it presents a question or form
 item with a Location answer format (that is, `ORKLocationAnswerFormat`).
 
 A Location question result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKLocationQuestionResult : ORKQuestionResult

/**
 The answer representing the coordinate and the address of a specific location.
 */
@property (nonatomic, copy, nullable) ORKLocation *locationAnswer;

@end

/**
 The `ORKSignatureResult` class represents the result of a signature step (`ORKSignatureStep`).
 
 A signature result is produced by the task view controller when it presents a signature step.

 */
ORK_CLASS_AVAILABLE
@interface ORKSignatureResult : ORKResult

/**
 The signature image generated by this step.
 */
@property (nonatomic, nullable) UIImage *signatureImage;

/**
 The bezier path components used to create the signature image.
 */
@property (nonatomic, copy, nullable) NSArray <UIBezierPath *> *signaturePath;

@end


/**
 The `ORKVideoInstructionStepResult` class represents the result of a video insruction step (`ORKVideoInstructionStep`).
 
 A video instruction result is produced by the task view controller when it presents a video instruction step.
 
 */
ORK_CLASS_AVAILABLE
@interface ORKVideoInstructionStepResult : ORKResult

/**
 The time (in seconds) after video playback stopped, or NaN if the video was never played.
 */
@property (nonatomic) Float64 playbackStoppedTime;

/**
 Returns 'YES' if the video was watched until the end, or 'NO' if video playback was stopped half way.
 */
@property (nonatomic) BOOL playbackCompleted;

@end

NS_ASSUME_NONNULL_END
