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
#import <ResearchKit/ORKStepViewController.h>
#import <ResearchKit/ORKRecorder.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKActiveStepViewController` class is the base class for displaying `ORKActiveStep`
 subclasses. The predefined active tasks defined in `ORKOrderedTask` all make use
 of subclasses of `ORKActiveStep`, paired with `ORKActiveStepViewController`
 subclasses.
 
 An active step view controller is typically instantiated by a task view controller
 when it encounters an active step in a task. Active steps generally include some form of sensor-driven data collection, or involve some highly interactive content, such as a cognitive task or game.
 
 Examples of active step view controller subclasses include `ORKWalkingTaskStepViewController`,
 `ORKCountdownStepViewController`, `ORKSpatialSpanMemoryStepViewController`,
 `ORKFitnessStepViewController`, and `ORKAudioStepViewController`.
 
 The primary feature that active step view controllers enable is life cycle. After an active step is presented, it can be started to start a timer. When the timer expires, the
 step is  considered finished. Some steps may have the concept of suspend and resume, such as when
 the app is put in the background, and during which data recording is temporarily paused.
 These life cycle methods generally apply to any recorders being used to record
 data from the device's sensors, but they should also be applied to any UI
 being displayed to clearly indicate when data is being collected
 for the task.
 
 When you develop a new active step, you should subclass `ORKActiveStepViewController`
 and define your specific UI. When subclassing, pay special attention to the life cycle
 methods, `start`, `finish`, `suspend`, and `resume`. Also, be sure to test for
 the expected behavior when the user suspends and resumes the app, during task
 save and restore, and during UIKit's UI state restoration.
 
 See also: `ORKActiveStep`.
 */
ORK_CLASS_AVAILABLE
@interface ORKActiveStepViewController : ORKStepViewController <ORKRecorderDelegate>

/// @name UI Customization

/**
 The custom view for the active step.
 
 Attach a custom view here, and implement `sizeThatFits:` or
 use `intrinsicContentSize` or provide constraints that request the size needed for
 the custom view within the active step's layout.
 
 Custom views can be used for visual instructions with animation,
 or for getting interactive input.
 */
@property (nonatomic, strong, nullable) UIView *customView;

/**
 The image view for the active step. (read-only)
 
 The image view is created on demand when this property is accessed, and is a
 shortcut to display an image in the custom area of an active task (that is, instead of
 using `customView`).
 */
@property (nonatomic, strong, readonly, nullable) UIImageView *imageView;

/// @name Data collection

/**
 The array of recorders currently in use by the active step. (read-only)
 
 Recorders are generated when the step starts, based on the recorder
 configurations of the step. Each recorder is an instance of `ORKRecorder`, and
 is created by the active step view controller using the array of recorder
 configurations in the step.
 
 See also: `ORKRecorderConfiguration` and `ORKActiveStep`.
 */
@property (nonatomic, strong, readonly, nullable) NSArray *recorders;

/// @name Active step life cycle

/**
 A Boolean value that indicates whether the step has finished. (read-only)
 
 If the step is considered finished, the Continue button is enabled and the Skip
 button is hidden. When the step is not finished, the Continue button is disabled and the Skip
 button is visible.
 
 In addition, when a step is finished, all recorders are stopped.
 */
@property (nonatomic, assign, readonly, getter=isFinished) BOOL finished;

/**
 A Boolean value that indicates whether the step has started. (read-only)
 
 If the step has not yet started, recorders are not yet running, and time
 is not counted against the `duration` of the step.
 */
@property (nonatomic, assign, readonly, getter=isStarted) BOOL started;

/**
 Tells the view controller that the active step has finished.
 
 This method is an override point for subclasses, called by the base class when
 the step has just finished.
 
 The default implementation does nothing except in the case of steps that have countdown
 enabled. When countdown is enabled in a step, the view controller attempts to navigate automatically to the next step, if so configured.
 */
- (void)stepDidFinish;

/**
 A Boolean value that indicates whether to suspend the step if the app is not
 active or the screen is off.
 
 Active steps that require the screen in order to work should suspend
 recording when the app goes into the background. Other active steps require
 the step to continue while the app is in the background. For example, the fitness check
 active step continues to collect data while the screen is off, and continues
 to give voice prompts.
 */
@property (nonatomic, assign) BOOL suspendIfInactive;

/**
 Starts the active step.
 
 Call this method to start the timer on the active step, if there is one, and
 to start any data recording.
 
 When you start the step, recorders are instantiated based on their configurations and then started. All
 timers should start, and the UI should show users that the step is in progress.
 
 This method does nothing if the step has already started.
 
 Subclasses should super when overriding this method.
 */
- (void)start;

/**
 Suspends the active step.
 
 Call this method to suspend data recording and the step's timer.
 
 This method may called automatically when the app is suspended.
 The view controller can be configured not to suspend even if the app
 goes into the background (for more information, see `suspendIfInactive`).
 
 Subclasses should call super when overriding this method.
 */
- (void)suspend;

/**
 Resumes the active step.
 
 Call this method when the step should be resumed. Calls to this method should
 be paired with previous calls to `suspend`.
 
 This method may be called automatically when the app is resumed. The view
 controller can be configured not to suspend even if the app
 goes into the background (for more information, see `suspendIfInactive`).
 
 When the step is resumed, the UI should resume at the point where the user left off,
 or, if that does not make sense for the particular step, to the most recent
 suitable point.
 
 Subclasses should call super when overriding this method.
 */
- (void)resume;

/**
 Finishes the active step.
 
 Call this method to finish the active step. If the active step is configured with
 a timer, this method is called automatically when the timer expires.
 
 Finishing the active step stops all data recording and stops any timers. In steps that have the
 `shouldContinueOnFinish` property set, forward navigation to the next step
 may ensue.
 
 This method does nothing if the step has already finished.
 
 Subclasses should call super when overriding this method.
 */
- (void)finish;

/// @name Recorder life cycle

/**
 Tells the view controller that the set of recorders changed.
 
 This method is usually called by the active step view controller in response
 to `start` or `resume`.
 
 Subclasses may override this method.
 */
- (void)recordersDidChange;

/**
 Tells the view controller that the recorders are about to start.
 
 This method is called by the active step view controller after instantiating
 the recorders, but before starting them.
 
 Subclasses may override this method.
 */
- (void)recordersWillStart;

/**
 Tells the view controller that the recorders are about to stop.
 
 This method is called by the active step view controller before
 stopping the recorders.
 
 Subclasses may override this method.
 */
- (void)recordersWillStop;

/**
 Tells the view controller that the step has been loaded and is about to start.
 
 This method is called by the active step view controller just after the step
 has been set. The base implementation instantiates the recorders and timer but
 does not start them.
 
 Subclasses may override this method, but must also call super.
 */
- (void)prepareStep;

@end

NS_ASSUME_NONNULL_END
