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
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKEditableResult;
@class ORKRecorder;
@class ORKResult;
@class ORKReviewStep;
@class ORKStep;
@class ORKStepResult;
@class ORKStepViewController;
@class ORKTaskViewController;

/**
 An enumeration of values used in `ORKStepViewControllerDelegate` to indicate the direction of navigation
 requested by the participant.
 */
typedef NS_ENUM(NSInteger, ORKStepViewControllerNavigationDirection) {
    
    /// Forward navigation. Indicates that the user tapped the Continue or Next button.
    ORKStepViewControllerNavigationDirectionForward,
    
    /// Backward navigation. Indicates that the user tapped the Back button.
    ORKStepViewControllerNavigationDirectionReverse
} ORK_ENUM_AVAILABLE;


/**
 The primary implementer of the `ORKStepViewControllerDelegate` protocol is the
 task view controller (`ORKTaskViewController`). The task view controller observes the messages 
 of the protocol to correctly update its `result` property, and to control navigation
 through the task.
 
 If you present step view controllers outside of a task view controller, it
 can be helpful to implement this protocol to facilitate navigation and
 results collection.
 */
@protocol ORKStepViewControllerDelegate <NSObject>

@required
/**
 Tells the delegate when the user has done something that requires navigation, such as
 tap the Back or a Next button, or enter a response to a nonoptional
 survey question.
 
 @param stepViewController     The step view controller providing the callback.
 @param direction              Direction of navigation requested.
 */
- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction;

/**
 Tells the delegate when a substantial change has occurred to the result.
 
 The result is always available in the step view controller. Although the result is continuously changing
 while the step view controller is active (because the time stamp in the result property is different each time it's called), this method is called only when a substantive change
 to the result occurs, such as when the user enters a survey answer or completes
 an active step.
 
 In your implementation of this delegate method, you can collect the value of `result` from the step view controller.
 
 @param stepViewController     The step view controller providing the callback.
 */
- (void)stepViewControllerResultDidChange:(ORKStepViewController *)stepViewController;

/**
 Tells the delegate when a step fails due to an error.
 
 A step view controller can use this method to report its failure to the task view controller.
 The task view controller sends the error to its delegate indicating that the task has failed (using `ORKTaskViewControllerFinishReasonFailed`).
 Note that recorder errors are reported by calling the `ORKStepViewControllerDelegate` method `stepViewController:recorder:didFailWithError:`.
 
 @param stepViewController     The step view controller providing the callback.
 @param error                  The error detected.
 */
- (void)stepViewControllerDidFail:(ORKStepViewController *)stepViewController withError:(nullable NSError *)error;

/**
 Tells the delegate when a recorder error has been detected during the step.
 
 Recorder errors can occur during active steps, usually due to the
 unavailability of sensor data or disk space in which to record results.
 
 @param stepViewController     The step view controller providing the callback.
 @param recorder               The recorder that detected the error.
 @param error                  The error detected.
 */
- (void)stepViewController:(ORKStepViewController *)stepViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

@optional
/**
 Tells the delegate that the step view controller's view is about to appear.
 
 This method is called from the step view controller's `viewWillAppear:` method.
 You can use this method to customize the appearance of the step view
 controller without subclassing it.
 
 @param stepViewController          The step view controller providing the callback.
*/
- (void)stepViewControllerWillAppear:(ORKStepViewController *)stepViewController;

/**
 Asks the delegate whether there is a previous step.
 
 If there is a previous step, the step view controller adds a Back button to its
 navigation item; if not, no Back button is added to the navigation item.
 
 @param stepViewController     The step view controller providing the callback.
 
 @return `YES` if a Back button should be visible; otherwise, `NO`.
 */
- (BOOL)stepViewControllerHasPreviousStep:(ORKStepViewController *)stepViewController;

/**
 Asks the delegate whether there is a next step.
 
 Depending on the result of the step, the step view controller can adjust the language for the
 Next button.
 
 @param stepViewController     The step view controller providing the callback.
 
 @return `YES` if there is a step following the current one; otherwise, `NO`.
 */
- (BOOL)stepViewControllerHasNextStep:(ORKStepViewController *)stepViewController;

@end


/**
 The `ORKStepViewController` class is a base class for view controllers that are
 presented by an `ORKTaskViewController` object for the steps in a task.
 
 In the ResearchKit framework, each step collects some information or data from the user. 
 Typically, the task view controller instantiates the step view controller 
 before presenting the next step (`ORKStep`) in the task.
 
 When you create a new type of step, you usually have to subclass
 `ORKStepViewController` to manage the step. For examples of subclasses, see 
 `ORKQuestionStepViewController` and `ORKFormStepViewController`. In contrast, the view
 controller for an active step is typically a subclass of `ORKActiveStepViewController`,
 because active steps include the concept of life cycle.
 
 If you are simply trying to change some of the runtime behaviors of `ORKStepViewController`,
 it's usually not necessary to subclass it. Instead, implement the
 `[ORKTaskViewControllerDelegate taskViewController:stepViewControllerWillAppear:]` method in
 the `ORKTaskViewControllerDelegate` protocol, and modify the appropriate properties
 of the step view controller. For example, to change the title of the Learn More
 or Next buttons, set the `learnMoreButtonTitle` or `continueButtonTitle`
 properties in your implementation of this delegate method.
 */
ORK_CLASS_AVAILABLE
@interface ORKStepViewController : UIViewController

/**
 Returns a new step view controller for the specified step.
 
 @param step    The step to be presented.
 
 @return A newly initialized step view controller.
 */
- (instancetype)initWithStep:(nullable ORKStep *)step;

/**
 Returns a new step view controller for the specified step.
 
 @param step    The step to be presented.
 @param result  The current step result for this step.
 
 @return A newly initialized step view controller.
 */
- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result;

/**
 The step presented by the step view controller.
 
 If you use a storyboard to initialize the step view controller, `initWithStep:` isn't called,
 so you need to set the `step` property directly before the step view controller is presented.
 
 Setting the value of `step` after the controller has been presented is an error that
 generates an exception.
 Modifying the value of `step` after the controller has been presented is an error that
 has undefined results.
 
 Subclasses that override the setter of this property must call super.
 */
@property (nonatomic, strong, nullable) ORKStep *step;

/**
 The delegate of the step view controller.
 
 The delegate is usually the `ORKTaskViewController` object that presents the step view
 controller. If you need to intercept the delegate methods, you can
 assign an intermediary object as the delegate and forward the messages
 to the task view controller.
 */
@property (nonatomic, weak, nullable) id<ORKStepViewControllerDelegate> delegate;

/**
 A localized string that represents the title of the Continue button.
 
 Most steps display a button that enables forward navigation. This button can have titles
 such as Next, Continue, or Done. Use this property to override the forward navigation
 button title for the step.
 */
@property (nonatomic, copy, nullable) NSString *continueButtonTitle;

/**
 A localized string that represents the title of the Learn More button.
 
 Many steps have a button that lets users view more information about the
 step than can fit on the screen. Use this property to override the title
 of the Learn More button for the step.
 */
@property (nonatomic, copy, nullable) NSString *learnMoreButtonTitle;

/**
 A localized string that represents the title of the "Skip" button.
 
 Many steps are optional and can be skipped. Set this property to override
 the title of the Skip button for the step. Note that setting this property
 has no effect if the Skip button is not visible, which is the case in a required question step.
 */
@property (nonatomic, copy, nullable) NSString *skipButtonTitle;

/**
 The back button item.
 
 The back button item controls the Back button displayed in the navigation bar when
 the step view controller is current.
 This property lets you control the appearance and target of the
 Back button at runtime.
 
 When the value of the property is `nil`, the Back button is not displayed; otherwise, the title, target,
 and action associated with the Back button item are used (other properties of `UIBarButtonItem`
 are ignored).
 
 The back button item is updated during view loading and when the value of the `step` property
 is changed, but they are safe to set in the `taskViewController:stepViewControllerWillAppear:` delegate callback.
 
 Subclasses can safely modify this property any time after calling `viewWillAppear:` on super.
 */
@property (nonatomic, strong, nullable) UIBarButtonItem *backButtonItem;

/**
 The cancel button item.
 
 The cancel button item controls the Cancel button displayed in the navigation bar
 when the step view controller is current.
 This property lets you control the appearance and target of the
 Cancel button at runtime.
 
 When the value of the property is `nil`, the Cancel button is not displayed; otherwise, the title, target,
 and action associated with the Cancel button item are used (other properties of `UIBarButtonItem`
 are ignored).
 
 The cancel button item is updated during view loading and when the value of the `step` property
 is changed, but is safe to
 set in the `taskViewController:stepViewControllerWillAppear:` delegate callback.
 
 Subclasses can safely modify this property any time after calling `viewWillAppear:` on super.
 */
@property (nonatomic, strong, nullable) UIBarButtonItem *cancelButtonItem;

/**
 The current state of the result. (read-only)
 
 The task view controller uses this property to get the results for the
 step, and to collate them into the task result.
 
 The current step result and any subsidiary results representing data collected
 so far are available in this property. You can detect significant changes to the result,
 such as when the user enters a new answer, using the
 `stepViewControllerResultDidChange:` delegate callback.
 
 Subclasses *must* use this property to return the current results.
 Subclasses *may* call super to obtain
 a clean, empty result object appropriate for the step, to which they can
 attach appropriate child results.
 
 The implementations of this method in the ResearchKit framework currently create a new
 result object on every call, so do not call this method unless it is
 actually necessary.
 */
@property (nonatomic, copy, readonly, nullable) ORKStepResult *result;

/**
 Add a result to the step view controller's `ORKStepResult`. By default, the property for
 the step view controller's result will instantiate a copy of the result each time it is 
 called. Therefore, the result cannot be mutated by adding a result to its result array.
 
 This method can be called by a delegate to add a result to a given step in a way that will
 be retained by the step.
 
 @param result     The result to add to the step results.
 */
- (void)addResult:(ORKResult*)result;

/**
 Returns a Boolean value indicating whether there is a previous step.
 
 This method is a convenience accessor that subclasses can call to make a delegate callback to
 determine whether a previous step exists. Subclasses can also override this method if the step 
 view controller should always behave as if backward navigation is disabled.
 
 See also: `stepViewControllerHasPreviousStep:`
 
 @return `YES` if there is a previous step; otherwise, `NO`.
 */
- (BOOL)hasPreviousStep;

/**
 Returns a Boolean value indicating whether there is a next step.
 
 This method is a convenience method that subclasses can call to make a delegate callback to
 determine whether a next step exists.
 
 See also: `stepViewControllerHasNextStep:`
 
 @return `YES` if there is a next step; otherwise, `NO`.
 */
- (BOOL)hasNextStep;

/**
 The presenting task view controller. (read-only)
 */
@property (nonatomic, weak, readonly, nullable) ORKTaskViewController *taskViewController;

/**
 Navigates forward to the next step.
 
 When a user taps a Next button, the information passes through this method. You can use this method as an override
 point or a target action for a subclass.
 */
- (void)goForward;

/**
 Navigates backward to the previous step.
 
 When a user taps the Back button, the information passes through this method. You can use this method as an override
 point or a target action for a subclass.
 */
- (void)goBackward;

/**
 This method is called when the user taps the skip button. By default, it calls `-goForward`.
 */
- (void)skipForward;

/**
 A Boolean value indicating whether the view controller has been presented before.
 */
@property (nonatomic, readonly) BOOL hasBeenPresented;

@end

NS_ASSUME_NONNULL_END
