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


#import <Foundation/Foundation.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKDefines.h>


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
@property (nonatomic, copy, nullable) NSDate *startDate;

/**
 The time when the task, step, or data collection stopped.
 
 The value of this property is set by the view controller or recorder that produces the result,
 to indicate when data collection stopped.
 
 Note that for instantaneous items, `startDate` and `endDate` can have the same value, and should
 generally correspond to the end of the instantaneous data collection period. 
 */
@property (nonatomic, copy, nullable) NSDate *endDate;

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
 Values that identify the button that was tapped in a tapping sample.
 */
typedef NS_ENUM(NSInteger, ORKTappingButtonIdentifier) {

    /// The touch landed outside of the two buttons.
    ORKTappingButtonIdentifierNone,
    
    /// The touch landed in the left button.
    ORKTappingButtonIdentifierLeft,
    
    /// The touch landed in the right button.
    ORKTappingButtonIdentifierRight
} ORK_ENUM_AVAILABLE;

/**
 The `ORKTappingSample` class represents a single tap on a button.
 
 The tapping sample object records the location of the tap, the
 button that was tapped, and the time at which the event occurred. A tapping sample is
 included in an `ORKTappingIntervalResult` object, and is recorded by the
 step view controller for the corresponding task when a tap is
 recognized.
 
 A tapping sample is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize the sample for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTappingSample : NSObject <NSCopying, NSSecureCoding>

/**
 A relative timestamp indicating the time of the tap event.
 
 The timestamp is relative to the value of `startDate` in the `ORKResult` object that includes this
 sample.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/** 
 An enumerated value that indicates which button was tapped, if any.
 
 If the value of this property is `ORKTappingButtonIdentifierNone`, it indicates that the tap
 was near, but not inside, one of the target buttons.
 */
@property (nonatomic, assign) ORKTappingButtonIdentifier buttonIdentifier;

/**
 The location of the tap within the step's view.
 
 The location coordinates are relative to a rectangle whose size corresponds to
 the `stepViewSize` in the enclosing `ORKTappingIntervalResult` object.
 */
@property (nonatomic, assign) CGPoint location;

@end

/**
 The `ORKTappingIntervalResult` class records the results of a tapping interval test.
 
 The tapping interval result object records an array of touch samples (one for each tap) and also the geometry of the
 task at the time it was displayed. You can use the information in the object for reference in interpreting the touch
 samples.
 
 A tapping interval sample is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTappingIntervalResult : ORKResult

/**
 An array of collected samples, in which each item is an `ORKTappingSample` object that represents a
 tapping event.
 */
@property (nonatomic, copy, nullable) NSArray *samples;

/**
 The size of the bounds of the step view containing the tap targets.
 */
@property (nonatomic) CGSize stepViewSize;

/**
 The frame of the left button, in points, relative to the step view bounds.
 */
@property (nonatomic) CGRect buttonRect1;

/**
 The frame of the right button, in points, relative to the step view bounds.
 */
@property (nonatomic) CGRect buttonRect2;

@end

/**
 The `ORKSpatialSpanMemoryGameTouchSample` class represents a tap during the
 spatial span memory game.
 
 A spatial span memory game touch sample is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */

ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryGameTouchSample : NSObject <NSCopying, NSSecureCoding>

/**
 A timestamp (in seconds) from the beginning of the game.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 The index of the target that was tapped.
 
 Usually, this index is a value that ranges between 0 and the number of targets,
 indicating which target was tapped.
 
 If the touch was outside all of the targets, the value of this property is -1.
 */
@property (nonatomic, assign) NSInteger targetIndex;

/**
 A point that records the touch location in the step's view.
 */
@property (nonatomic, assign) CGPoint location;

/**
 A Boolean value indicating whether the tapped target was the correct one.
 
 The value of this property is `YES` when the tapped target is the correct
 one, and `NO` otherwise.
 */
@property (nonatomic, assign, getter=isCorrect) BOOL correct;

@end

/// An enumeration of values that describe the status of a round of the spatial span memory game.
typedef NS_ENUM(NSInteger, ORKSpatialSpanMemoryGameStatus) {
    
    /// Unknown status. The game is still in progress or has not started.
    ORKSpatialSpanMemoryGameStatusUnknown,
    
    /// Success. The user has completed the sequence.
    ORKSpatialSpanMemoryGameStatusSuccess,
    
    /// Failure. The user has completed the sequence incorrectly.
    ORKSpatialSpanMemoryGameStatusFailure,
    
    /// Timeout. The game timed out during play.
    ORKSpatialSpanMemoryGameStatusTimeout
} ORK_ENUM_AVAILABLE;

/**
 The `ORKSpatialSpanMemoryGameRecord` class records the results of a
 single playable instance of the spatial span memory game.
 
 A spatial span memory game record is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 These records are found in the `records` property of an `ORKSpatialSpanMemoryResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryGameRecord : NSObject <NSCopying, NSSecureCoding>

/**
 An integer used as the seed for the sequence.
 
 If you pass a specific seed value to another game, you get the same sequence.
 */
@property (nonatomic, assign) uint32_t seed;

/**
 An array of `NSNumber` objects that represent the sequence that was presented to the user.
 
 The sequence is an array of length `sequenceLength` that contains a random permutation of integers (0..`gameSize`-1)
 */
@property (nonatomic, copy, nullable) NSArray *sequence;

/**
 The size of the game.
 
 The game size is the number of targets, such as flowers, in the game.
 */
@property (nonatomic, assign) NSInteger gameSize;

/**
 An array of `NSValue` objects wrapped in `CGRect` that record the frames of the target
 tiles as displayed, relative to the step view.
 */
@property (nonatomic, copy, nullable) NSArray *targetRects;

/**
 An array of `ORKSpatialSpanMemoryGameTouchSample` objects that record the onscreen locations
the user tapped during the game.
 */
@property (nonatomic, copy, nullable) NSArray *touchSamples;

/**
 A value indicating whether the user completed the sequence and, if the game was not completed, why not.
 */
@property (nonatomic, assign) ORKSpatialSpanMemoryGameStatus gameStatus;

/**
 An integer that records the number of points obtained during this game toward
 the total score.
 */
@property (nonatomic, assign) NSInteger score;

@end


/**
 The `ORKSpatialSpanMemoryResult` class represents the result of a spatial span memory step (`ORKSpatialSpanMemoryStep`).
 
 A spatial span memory result records the score displayed to the user, the number of games, the
 objects recording the actual game, and the user's taps in response
 to the game.
 
 A spatial span memory result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryResult : ORKResult

/**
 The score in the game.
 
 The score is an integer value that monotonically increases during the game, across multiple rounds.
 */
@property (nonatomic, assign) NSInteger score;

/**
 The number of games.
 
 The number of rounds that the user participated in, including successful,
 failed, and timed out rounds.
 */
@property (nonatomic, assign) NSInteger numberOfGames;

/**
 The number of failures.
 
 The number of rounds in which the user participated, but did not correctly
 complete the sequence.
 */
@property (nonatomic, assign) NSInteger numberOfFailures;

/**
 An array that contains the results of the games played.
 
 Each item in the array is an `ORKSpatialSpanMemoryGameRecord` object.
 */
@property (nonatomic, copy, nullable) NSArray *gameRecords;

@end

/**
 The `ORKFileResult` class is a result that references the location of a file produced
 during a task.
 
 A file result is typically generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize the linked file for transmission
 to the server.
 
 Active steps typically produce file results when CoreMotion or HealthKit are
 serialized to disk using a data logger (`ORKDataLogger`). Audio recording also produces a file
 result.
 
 When you write a custom step, use files to report results only when the data
 is likely to be too big to hold in memory for the duration of the task. For
 example, fitness tasks that use sensors can be quite long and can generate
 a large number of samples. To compensate for the length of the task, you can stream the samples to disk during
 the task, and return an `ORKFileResult` object in the result hierarchy, usually as a
 child of an `ORKStepResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKFileResult : ORKResult

/**
 The MIME content type of the result.
 
 For example, `@"application/json"`.
 */
@property (nonatomic, copy, nullable) NSString *contentType;

/**
 The URL of the file produced.
 
 It is the responsibility of the receiver of the result object to delete
 the file when it is no longer needed.
 
 The file is typically written to the output directory of the
 task view controller, so it is common to manage the archiving or cleanup
 of these files by archiving or deleting the entire output directory.
 */
@property (nonatomic, copy, nullable) NSURL *fileURL;

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
 An array of selected values, from the `value` property of an `ORKAnswerOption` object.
 In the case of a single choice, the array has exactly one entry.
 
 If the user skipped the question, the value of the corresponding array member is `nil`.
 */
@property (nonatomic, copy, nullable) NSArray *choiceAnswers;

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
 completes, it may be appropriate to serialize it for transmission to a server,
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
 Applies the signature to the consent document.
 
 This method uses the identifier to look up the matching signature placeholder in the consent document and replaces it with this signature. It may throw an exception if
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
@property (nonatomic, copy, nullable) NSArray /* <ORKResult> */ *results;

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
- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(nullable NSArray *)results;

@end


NS_ASSUME_NONNULL_END
