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


#import <UIKit/UIKit.h>
#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKStepViewController.h>
#import <ResearchKit/ORKRecorder.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKStep;
@class ORKStepViewController;
@class ORKResult;
@class ORKTaskResult;
@class ORKTaskViewController;
@protocol ORKTaskResultSource;

/**
 The `ORKTaskViewControllerFinishReason` value indicates how the task view controller has finished
 the task.
 */
typedef NS_ENUM(NSInteger, ORKTaskViewControllerFinishReason) {
    
    /// The task was canceled by the participant or the developer, and the participant asked to save the current result.
    ORKTaskViewControllerFinishReasonSaved,
    
    /// The task was canceled by the participant or the developer, and the participant asked to discard the current result.
    ORKTaskViewControllerFinishReasonDiscarded,
    
    /// The task has completed successfully, because all steps have been completed.
    ORKTaskViewControllerFinishReasonCompleted,
    
    /// An error was detected during the current step.
    ORKTaskViewControllerFinishReasonFailed
};

/**
 The task view controller delegate is responsible for processing the results
 of the task, exerting some control over how the controller behaves, and providing
 auxiliary content as needed.
 */
@protocol ORKTaskViewControllerDelegate <NSObject>

/**
 Tells the delegate that the task has finished.
 
 The task view controller calls this method when an unrecoverable error occurs,
 when the user has canceled the task (with or without saving), or when the user
 completes the last step in the task.
 
 In most circumstances, the receiver should dismiss the task view controller
 in response to this method, and may also need to collect and process the results
 of the task.

 @param taskViewController  The `ORKTaskViewController `instance that is returning the result.
 @param reason              An `ORKTaskViewControllerFinishReason` value indicating how the user chose to complete the task.
 @param error               If failure occurred, an `NSError` object indicating the reason for the failure. The value of this parameter is `nil` if `result` does not indicate failure.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error;

@optional
/**
 Signals that an error has been detected by a recorder.
 
 Recorder errors can occur during active steps, typically because sensor data is unavailable or there isn't enough disk space to record the results.
 You can use this method as an opportunity to respond to the error by, for example, logging and ignoring it.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param recorder            The recorder that detected the error. `ORKStep` and `ORKRecorderConfiguration` objects can be found in the recorder instance.
 @param error               The error that was detected.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

/**
 Asks the delegate if the state of the current uncompleted task should be saved.
 
 The task view controller calls this method to determine whether to offer
 a save option when the user attempts to cancel a task that is in progress.
 
 If this method is not implemented, the task view controller assumes that save and restore are not supported.
 If this method returns `YES`, it's recommended that you copy the value of the `restorationData` property of the
task view controller and pass that data to `initWithTask:restorationData:` when it is time
 to create a new task view controller to continue from the point at which the user stopped.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 
 @return `YES` if save and restore should be supported; otherwise, `NO`.
 */
- (BOOL)taskViewControllerSupportsSaveAndRestore:(ORKTaskViewController *)taskViewController;

/**
 Asks the delegate if there is Learn More content for this step.
 
 The task view controller calls this method to determine whether a
 Learn More button should be displayed for the step.
 
 The standard templates in ResearchKit for all types of steps include a button
 labeled Learn More (or a variant). In consent steps, this is internal to
 the implementations of the step and step view controller, but in all other steps,
 the task view controller asks its delegate to determine if Learn More content is available,
 and to request that it be displayed.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param step                The step for which the task view controller needs to know if there is Learn More content.
 
 @return `NO` if there is no Learn More content to display.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step;

/**
 Tells the delegate that the user has tapped the Learn More button in the step.
 
 The standard templates in ResearchKit for all types of steps include a button
 labeled Learn More (or a variant). In consent steps this is internal to
 the implementations of the step and step view controller, but in all other steps,
 the task view controller asks its delegate to determine if Learn More content is available.
 
 This method is called only if the delegate returns `YES` to
 `taskViewController:hasLearnMoreForStep:` for the current step, and the user
 subsequently taps on the Learn More button.
 
 When this method is called, the app should respond to the Learn More action by
 presenting a dialog or other view (possibly modal) that contains the Learn More content.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param stepViewController  The `ORKStepViewController` that reported the Learn More event to the task view controller.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController;

/**
 Asks the delegate for a custom view controller for the specified step.
 
 If this method is implemented, the task view controller calls it to obtain a
 step view controller for the step.
 
 In most circumstances, the task view controller
 can determine which view controller to instantiate for a step. However, if
 you want to provide a specific view controller instance, you can call this method to do so.
 
 The delegate should provide a step view controller implementation for any custom step.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param step                The step for which a view controller is requested.
 
 @return A custom view controller, or `nil` to request the default step controller for this step.
 */
- (nullable ORKStepViewController *)taskViewController:(ORKTaskViewController *)taskViewController viewControllerForStep:(ORKStep *)step;

/**
 Asks the delegate if the task view controller should proceed to the specified step.
 
 The task view controller calls this method before creating a step view
 controller for the next or previous step.
 
 Generally, when a step is available, the task view controller presents it when
 the user taps a forward or backward navigation button, but the results entered or other circumstances can make this action inappropriate. In these
 circumstances, you can implement this delegate method and return `NO`.
 
 If you return `NO`, it's often appropriate to present a dialog or take
 some other UI action to explain why navigation was denied.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param step                The step for which presentation is requested.
 
 @return `YES` if navigation should proceed to the specified step; `NO` if navigation should not proceed.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step;

/**
 Tells the delegate that a step view controller is about to be displayed.
 
 The task view controller calls this method before presenting the step
 view controller.
 
 This method gives you an opportunity to modify the step view controller before presentation.
 For example, you might want to modify the `learnMoreButtonTitle` or `continueButtonTitle`
 properties, or modify other button state. Another possible use case is when a particular
 step view controller requires additional setup before presentation.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param stepViewController  The `ORKStepViewController` that is about to be displayed.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController;

/**
 Tells the delegate that the result has substantively changed.
 
 The task view controller calls this method when steps start or finish, or if an answer has
 changed in the current step due to editing or other user interaction.
 
 @param taskViewController  The calling `ORKTaskViewController` instance.
 @param result              The current value of the result.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didChangeResult:(ORKTaskResult *)result;

@end


/**
 The `ORKTaskViewController` class is the primary entry point for the presentation of the
 ResearchKit framework UI. Note that a task view controller usually presents an `ORKOrderedTask` instance, but it can present any object that implements `ORKTask`.
 
 The task view controller is intended for modal presentation, which lets the user cancel participation in the task at any time. Typically, the task view
 controller displays a navigation bar and conducts right-to-left
 navigation for each step as the user progresses through the task.
 
 The task view controller supports UI state restoration, which allows users to continue a long task when they resume your app. To enable state restoration, set the restoration
 identifier and take the appropriate action to restore the task view controller when your app restarts or resumes.
 
 The task view controller also lets users save their progress in the middle of a task. To support
 this scenario in your app, implement `[ORKTaskViewControllerDelegate taskViewControllerSupportsSaveAndRestore:]` in your
 task view controller delegate, and return `YES`. If the task completes with the
 status `ORKTaskViewControllerFinishReasonSaved`, copy and store the value of the
 `restorationData` property. When the user resumes the task, create a
 new task view controller using the `initWithTask:restorationData:` initializer,
 and present it.
 
 It is possible to configure the task view controller to prefill surveys with
 data from another source, such as a previous run of the same task.
 Set the `defaultResultSource` property to use this feature.

 When conducting active tasks which may produce file results, always set the
 `outputDirectory` property. Files generated during active steps are written to
 the output directory that you specify, and references to these files are returned by `ORKFileResult`
 objects in the result hierarchy.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskViewController : UIViewController <ORKStepViewControllerDelegate, UIViewControllerRestoration>

/**
 Returns a newly initialized task view controller.
 
 This method is the primary designated initializer.

 @param task            The task to be presented.
 @param taskRunUUID     The UUID of this instance of the task. If `nil`, a new UUID is generated.
 
 @return A new task view controller.
 */
- (instancetype)initWithTask:(nullable id<ORKTask>)task taskRunUUID:(nullable NSUUID *)taskRunUUID NS_DESIGNATED_INITIALIZER;

/**
 Returns a new task view controller initialized from data in the given unarchiver.
 
 This method lets you instantiate a task view controller from a storyboard, although this is an atypical use case. This method is a designated initializer.
 
 @param aDecoder    The coder from which to initialize the task view controller.
 
 @return A new task view controller.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 Returns a newly initialized task view controller using the nib file in the specified bundle.
 
 This method is a designated initializer.
 
 @param nibNameOrNil    The name of the nib file from which to instantiate the task view controller.
 @param nibBundleOrNil  The name of the bundle in which to search for the nib file.
 
 @return A new task view controller.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 Creates a new task view controller from the specified restoration data.
 
 Call this method to restart a task when you have restoration data stored for a
 previous run of the task, in which the user canceled their current task and saved their progress.
 
 This method restores the presentation of the task to the point at which the user stopped.
 If the restoration data is not valid, an exception may be thrown.
 
 @param task        The task to be presented.
 @param data        Data obtained from the `restorationData` property of a previous
                    task view controller instance.
 @param delegate    The delegate for the task view controller.
 
 @return A new task view controller.
 */
- (instancetype)initWithTask:(nullable id<ORKTask>)task restorationData:(nullable NSData *)data delegate:(nullable id<ORKTaskViewControllerDelegate>)delegate;

/**
 The delegate for the task view controller.
 
 There are many optional methods in the task view controller protocol, but the delegate must support
 completion. When the task view controller completes its task, it is the delegate's
 responsibility to dismiss it.
 
 See also: `[ORKTaskViewControllerDelegate taskViewController:didFinishWithReason:error:]`.
 */
@property (nonatomic, weak, nullable) id<ORKTaskViewControllerDelegate> delegate;

/**
 The task for this task view controller.
 
 The task functions as the data source for an `ORKTaskViewController` object, providing
 the steps that the user must complete in order to complete the task.
 It is an error to change the task after presenting the task view controller.
 */
@property (nonatomic, strong, nullable) id<ORKTask> task;

/**
 A source that the task view controller can consult to obtain default answers
 for questions provided in question steps and form steps.
 
 The source can provide default answers, perhaps based on previous runs of
 the same task, which will be used to prefill question and form items.
 For example, an `ORKTaskResult` object from a previous run of the task can function as
 an `ORKTaskResultSource` object, because `ORKTaskResult` implements the protocol.
 */
@property (nonatomic, strong, nullable) id<ORKTaskResultSource> defaultResultSource;

/**
 A unique identifier (UUID) for this presentation of the task.
 
 The task run UUID is a unique identifier for this run of the task view controller.
 All results produced by this instance are tagged with this UUID.
 
 The task run UUID is preserved across UI state restoration, or across task
 save and restore.
 
 @note It is an error to set the value of `taskRunUUID` after the first time the task view controller
 is presented.
 */
@property (nonatomic, copy) NSUUID *taskRunUUID;

/**
 The current state of the task result. (read-only)
 
 Use this property to obtain or inspect the results of the task. The results
 are hierarchical; the children of `result` are `ORKStepResult` instances,
 one for each step that the user visited during the task.
 
 If the user uses the Back button to go back through the steps, the
 results of steps that are ahead of the currently visible step are not included
 in the result.
 */
@property (nonatomic, copy, readonly) ORKTaskResult *result;

/**
 Snapshot data that can be used for future restoration.
 
 When the user taps Cancel during a task and selects the Save option,
 the `[ORKTaskViewControllerDelegate taskViewController:didFinishWithReason:error:]`
 method is called with `ORKTaskViewControllerFinishReasonSaved`. When that happens,
 use `restorationData` to obtain restoration data that can be used to restore
 the task at a later date.
 
 Use `initWithTask:restorationData:` to create a new task view controller that
 restores the current state.
 */
@property (nonatomic, copy, readonly, nullable) NSData *restorationData;

/**
 File URL for the directory in which to store generated data files.
 
 Active steps with recorders (and potentially other steps) can save data
 to files during the progress of the task. This property specifies where such
 data should be written. If no output directory is specified, active steps
 that require writing data to disk, such as those with recorders, will typically
 fail at runtime.
 
 In general, set this property after instantiating the task view
 controller and before presenting it.
 
 Before presenting the view controller, set the `outputDirectory` property to specify a
 path where files should be written when an `ORKFileResult` object must be returned for
 a step.
 */
@property (nonatomic, copy, nullable) NSURL *outputDirectory;

/**
 A Boolean value indicating whether progress is shown in the navigation bar.
 
 Setting this property to `YES` does not display progress if you don't also implement the `progress`
 method of `ORKTask`.
 
 The default value of this property is `YES`. To disable the display of progress in the navigation bar, set the value to `NO`.
 */
@property (nonatomic, assign) BOOL showsProgressInNavigationBar;

/**
 The current step view controller.
 
 The task view controller instantiates and presents a series of step view
 controllers. The current step view controller is the one that is currently
 visible on screen.
 
 The value of this property may be `nil` if the task view controller has not yet been presented.
 */
@property (nonatomic, strong, readonly, nullable) ORKStepViewController *currentStepViewController;

/**
 Forces navigation to the next step.
 
 Call this method to force forward navigation. This method is called by the framework
 if the user takes an action that requires navigation, or if the step is timed
 and the timer completes.
 */
- (void)goForward;

/**
 Forces navigation to the previous step.
 
 Call this method to force backward navigation. This method is called by the framework
 if the user takes an action that requires backward navigation.
 */
- (void)goBackward;

/**
 A Boolean value indicating whether the navigation bar is hidden.
 
 By default, the task view controller includes a visible navigation bar. To disable the display of the navigation bar, set this property to `NO`.
 */
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;

/**
 Shows or hides the navigation bar, with optional animation.
 
 @param hidden     `YES` to hide the navigation bar; otherwise, `NO`.
 @param animated   `YES` to animate the show or hide operation; otherwise, `NO`.
 */
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 The navigation bar for the task view controller. (read-only)
 
 You can use this method to customize the appearance of the task view controller's navigation bar.
 */
@property (nonatomic, readonly) UINavigationBar *navigationBar;

@end

NS_ASSUME_NONNULL_END
