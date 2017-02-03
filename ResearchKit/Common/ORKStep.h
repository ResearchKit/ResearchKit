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


@import Foundation;
@import HealthKit;
#import <ResearchKit/ORKTypes.h>


NS_ASSUME_NONNULL_BEGIN

ORK_EXTERN NSString *const ORKNullStepIdentifier ORK_AVAILABLE_DECL;

@class ORKStepViewController;
@class ORKResult;

@protocol ORKTask;

/**
 `ORKStep` is the base class for the steps that can compose a task for presentation
 in an `ORKTaskViewController` object. Each `ORKStep` object represents one logical piece of data
 entry or activity in a larger task.
 
 A step can be a question, an active test, or a simple instruction. An `ORKStep`
 subclass is usually paired with an `ORKStepViewController` subclass that displays the step.
 
 To use a step, instantiate an `ORKStep` object and populate its properties. Add the step to a task,
 such as an `ORKOrderedTask` object, and then present the task using a task view controller (an
 `ORKTaskViewController` object).
 
 To implement a new type of step, subclass `ORKStep` and add your additional
 properties. Separately, subclass `ORKStepViewController` and implement
 your user interface. Note that if your step is timed or requires sensor data collection,
 you should consider subclassing `ORKActiveStep` and `ORKActiveStepViewController`
 instead.
 */
ORK_CLASS_AVAILABLE
@interface ORKStep : NSObject <NSSecureCoding, NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns a new step initialized with the specified identifier.
 
 This method is the primary designated initializer.
 
 @param identifier   The unique identifier of the step.
 
 @return A new step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new step initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the step.
 
 @return A new step.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 Returns a copy of this step initialized with the specified identifier.
 
 @param identifier   The unique identifier for the new step to be returned.
 
 @return A new step.
 */
- (instancetype)copyWithIdentifier:(NSString *)identifier;

/**
 A short string that uniquely identifies the step within the task.
 
 The identifier is reproduced in the results of a step. In fact, the only way to link a result
 (an `ORKStepResult` object) to the step that generated it is to look at the value of
 `identifier`. To accurately identify step results, you need to ensure that step identifiers 
 are unique within each task.
 
 In some cases, it can be useful to link the step identifier to a unique identifier in a
 database; in other cases, it can make sense to make the identifier human
 readable.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 A Boolean value indicating whether a task can be restored to the step
 during state restoration. (read-only)
 
 By default, the value of this property is `YES`, but subclasses of `ORKStep` might use `NO`.
 
 If a task cannot be restored to the step, the task is typically restored to the
 last restorable step in the task, or to the first step, if
 no restorable steps are available.
 */
@property (nonatomic, readonly, getter=isRestorable) BOOL restorable;

/**
 A Boolean value indicating whether the user can skip the step
 without providing an answer.
 
 The default value of this property is `YES`. When the value is `NO`, the Skip button does not
 appear on this step.
 
 This property may not be meaningful for all steps; for example, an active step
 might not provide a way to skip, because it requires a timer to finish.
 */
@property (nonatomic, getter=isOptional) BOOL optional;

/**
 The primary text to display for the step in a localized string.
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 Additional text to display for the step in a localized string.
 
 The additional text is displayed in a smaller font below `title`. If you need to display a
 long question, it can work well to keep the title short and put the additional content in
 the `text` property.
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 The task that contains the step.
 
 The value of `task` is usually set when a step is added to the `ORKOrderedTask` object.
 Although it's a good idea to set this property when you implement a custom task, it's important
 to note that the use of this property is a convenience, and should not be relied
 upon within the ResearchKit framework.
 */
@property (nonatomic, weak, nullable) id<ORKTask> task;

/**
 The set of access permissions required for the step. (read-only)
 
 The permission mask is used by the task view controller to determine the types of
 access to request from users when they complete the initial instruction steps
 in a task. If your step requires access to APIs that limit access, include
 the permissions you require in this mask.
 
 By default, the property scans the recorders and collates the permissions
 required by the recorders. Subclasses may override this implementation.
 */
@property (nonatomic, readonly) ORKPermissionMask requestedPermissions;

/**
 The set of HealthKit types the step requests for reading. (read-only)
 
 The task view controller uses this set of types when constructing a list of
 all the HealthKit types required by all the steps in a task, so that it can
 present the HealthKit access dialog just once during that task.
 
 By default, the property scans the recorders and collates the HealthKit
 types the recorders require. Subclasses may override this implementation.
 */
@property (nonatomic, readonly, nullable) NSSet<HKObjectType *> *requestedHealthKitTypesForReading;

/**
 Checks the parameters of the step and throws exceptions on invalid parameters.
 
 This method is called when there is a need to validate the step's parameters, which is typically
 the case when adding a step to an `ORKStepViewController` object, and when presenting the
 step view controller.
 
 Subclasses should override this method to provide validation of their additional
 properties, and must call super.
 */
- (void)validateParameters;

/**
 Returns the class that the task view controller should instantiate to display
 this step.
 */
- (Class)stepViewControllerClass;

/**
 Instantiates a step view controller for this class.
 
 This method is called when a step is about to be presented. The default implementation returns
 a view controller that is appropriate to this step by allocating an instance of `ORKStepViewController`
 using the `-stepViewControllerClass` method and initializing that instance by calling `initWithIdentifier:result:`
 on the provided `ORKStepViewController` class instance.
 
 Override this method if you need to customize the behavior before presenting the step or if 
 the view controller is presented using a nib or storyboard.
 
 @param result    The result associated with this step
 
 @return A newly initialized step view controller.
 */
- (ORKStepViewController *)instantiateStepViewControllerWithResult:(ORKResult *)result;

@end

NS_ASSUME_NONNULL_END
