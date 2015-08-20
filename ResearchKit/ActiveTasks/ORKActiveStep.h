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


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@class ORKRecorderConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKActiveStep` class is the base class for steps in active tasks, which
 are steps that collect sensor data in a semi-controlled environment, as opposed
 to the purely passive data collection enabled by HealthKit, or the more subjective data
 collected when users fill in surveys.
 
 In addition to the behaviors of `ORKStep`, active steps have the concept of
 life cycle, which includes a defined start and finish.
 
 The ResearchKit framework provides built-in behaviors that allow active steps to play voice prompts, speak a count down, and have a
 defined duration.
 
 To present an active step in your app, it's likely that you will subclass `ORKActiveStep` and
 `ORKActiveStepViewController` to present custom UI and custom
 prompts. For example subclasses, see `ORKSpatialSpanMemoryStep` or `ORKFitnessStep`.
 Active steps may also need `ORKResult` subclasses to record their results
 if these don't come purely from recorders.
 
 If you develop a new active step subclass, consider contributing your
 code to the ResearchKit project so that it's available for others to use in
 their studies.
 
 See also: `ORKActiveStepViewController`
 */
ORK_CLASS_AVAILABLE
@interface ORKActiveStep : ORKStep

/**
 The duration of the step in seconds.
 
 If the step duration is greater than zero, a built-in timer starts when the
 step starts. If `shouldStartTimerAutomatically` is set, the timer
 starts when the step's view appears. When the timer expires, a sound or
 vibration may be played. If `shouldContinueOnFinish` is set, the step
automatically navigates forward when the timer expires.
 
 The default value of this property is `0`, which disables the built-in timer.
 
 See also: `ORKActiveStepViewController`
 */
@property (nonatomic) NSTimeInterval stepDuration;

/**
 A Boolean value indicating whether to show a view with a default timer.
 
 The default timer UI is not used in any of the current predefined tasks,
 but it can be displayed in a simple active task that does not require custom
 UI and needs only a count down timer on screen during data collection.
 
 Note that this property is ignored if `stepDuration` is `0`.
 
 The default value of this property is `YES`.
 */
@property (nonatomic) BOOL shouldShowDefaultTimer;

/**
 A Boolean value indicating whether to speak the last few seconds in the count down of the
 duration of a timed step.
 
 When the value of this property is `YES`, `AVSpeechSynthesizer` is used to synthesize the countdown. Note that this property is ignored if VoiceOver is enabled.
 
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldSpeakCountDown;

/**
 A Boolean value indicating whether to start the count down timer automatically when the step starts, or
 require the user to take some explicit action to start the step, such as tapping a button.
 
 Usually the explicit action needs to come from custom UI in an
 `ORKActiveStepViewController` subclass.
 
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldStartTimerAutomatically;

/**
 A Boolean value indicating whether to play a default sound when the step starts.
 
The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldPlaySoundOnStart;

/**
 A Boolean value indicating whether to play a default sound when the step finishes.
 
The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldPlaySoundOnFinish;

/**
 A Boolean value indicating whether to vibrate when the step starts.
 
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldVibrateOnStart;

/**
 A Boolean value indicating whether to vibrate when the step finishes.
 
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldVibrateOnFinish;

/**
 A Boolean value indicating whether the Next button should double as a skip action before
 the step finishes.
 
 When the value of this property is `YES`, the ResearchKit framework hides the skip button and makes the Next button function as a skip button when the step has not yet finished.
 
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldUseNextAsSkipButton;

/**
 A Boolean value indicating whether to transition automatically when the step finishes.
 
 When the value of this property is `YES`, the active step view controller automatically performs the
 continue action when the `[ORKActiveStepViewController finish]` method
 is called.
 
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldContinueOnFinish;

/**
 Localized text that represents an instructional voice prompt.
 
 Instructional speech begins when the step starts. If VoiceOver is active,
 the instruction is spoken by VoiceOver.
 */
@property (nonatomic, copy, nullable) NSString *spokenInstruction;

/**
 An image to be displayed below the instructions for the step.
 
 The image can be stretched to fit the available space. When choosing a size
 for this asset, be sure to take into account the variations in device form factors.
 */
@property (nonatomic, strong, nullable) UIImage *image;

/**
 An array of recorder configurations that define the parameters for recorders to be
 run during a step to collect sensor or other data.
 
 If you want to collect data from sensors while the step is in progress,
 add one or more recorder configurations to the array. The active step view
 controller instantiates recorders and collates their results as children
 of the step result.
 
 The set of recorder configurations is scanned when populating the
 `requestedHealthKitTypesForReading` and `requestedPermissions` properties.
 
 See also: `ORKRecorderConfiguration` and `ORKRecorder`.
 */
@property (nonatomic, copy, nullable) NSArray<ORKRecorderConfiguration *> *recorderConfigurations;

/**
 The set of HealthKit types the step requests for reading. (read-only)
 
 The task view controller uses this set of types when constructing a list of
 all the HealthKit types required by all the steps in a task, so that it can
 present the HealthKit access dialog just once during that task.
 
 By default, the property scans the recorders and collates the HealthKit
 types the recorders require. Subclasses may override this implementation.
 */
@property (nonatomic, readonly, nullable) NSSet<HKObjectType *> *requestedHealthKitTypesForReading;

@end

NS_ASSUME_NONNULL_END
