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
#import <UIKit/UIKit.h>
#import <ResearchKit/ORKTypes.h>

@class HKObjectType;
@class ORKResult;
@protocol ORKTask;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ORKStep Common

ORK_EXTERN NSString *const ORKNullStepIdentifier ORK_AVAILABLE_DECL;
@class ORKEarlyTerminationConfiguration;

/**
 The base object for composing a task.
 
 ``ORKStep`` is the base class for the steps that can compose a task for presentation
 in an  ORKTaskViewController object. Each ``ORKStep`` object represents one logical piece of data
 entry or activity in a larger task.
 
 A step can be a question, an active test, or a simple instruction. Pair an ``ORKStep``
 subclass with an  ORKStepViewController subclass to display the step.
 
 To use a step, instantiate an ``ORKStep`` object and populate its properties. Add the step to a task,
 such as an ``ORKOrderedTask`` object, then present the task using ORKTaskViewController.
 
 To implement a new type of step, subclass ``ORKStep`` and add your additional
 properties.Then subclass  ORKStepViewController and implement
 your user interface. If your step is timed, or requires sensor data collection,
 subclass ``ORKActiveStep`` and  ORKActiveStepViewController.
 */

ORK_CLASS_AVAILABLE API_AVAILABLE(ios(11.0), watchos(6.0))
@interface ORKStep : NSObject <NSSecureCoding, NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a new step with the specified identifier.
 
 This method is the primary designated initializer.
 
 @param identifier   The unique identifier of the step.
 
 @return A new step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Creates a new step from data in the provided unarchiver.
 
 @param aDecoder   The coder that initializes the step.
 
 @return A new step.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 Creates a copy of this step with the specified identifier.
 
 @param identifier   The unique identifier for the copied step.
 
 @return A new step.
 */
- (instancetype)copyWithIdentifier:(NSString *)identifier;

/**
 A short string that uniquely identifies the step within the task.
 
 The identifier becomes part of the results of a step. Use it to link an ``ORKStepResult`` to the step that generated it. To accurately identify step results, ensure that step identifiers are unique within each task.
 
 In some cases, it can be useful to link the step identifier to a unique identifier in a
 database; in other cases, it can make sense to make the identifier human
 readable.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 A Boolean value that indicates whether a task can be restored to the step
 during state restoration.
 
 By default, the value of this read-only property is `YES`, but subclasses of `ORKStep` can use `NO`.
 
 If a task can't be restored to the step, it's typically restored to the
 last restorable step in the task, or to the first step if no restorable steps are available.
 */
@property (nonatomic, readonly, getter=isRestorable) BOOL restorable;

/**
 A Boolean value that indicates whether the user can skip the step without providing an answer.
 
 The default value of this property is `YES`. When the value is `NO`, the Skip button doesn't
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
 
 The additional text is displayed in a smaller font below ``title``. If you need to display a
 long question, it can work well to keep the title short and put the additional content in
 the ``text`` property.
 */

@property (nonatomic, copy, nullable) NSString *text;

/**
 Additional detailed explanation for the instruction.
 
 The detail text is displayed below the content of the ``text`` property.
 */
@property (nonatomic, copy, nullable) NSString *detailText;

/**
 A property that controls the text alignment the step's textual elements.
 */
@property (nonatomic) NSTextAlignment headerTextAlignment;


/**
 Additional text to display for the step in a localized string at the bottom of the view.
 
 The footnote is displayed in a smaller font below the continue button. It is intended to be used
 in order to include disclaimer, copyright, etc. that is important to display in the step but
 should not distract from the main purpose of the step.
 */

@property (nonatomic, copy, nullable) NSString *footnote;

/**
 An optional icon image to show above the title and text.
 */
@property (nonatomic, copy, nullable) UIImage *iconImage;

/**
 A property that gates automatic tint color image changes based on appearance changes.
 
 The default value for this property is  NO.
 */
@property (nonatomic) BOOL shouldAutomaticallyAdjustImageTintColor;

/**
 A property that determines whether  to show progress for this step when presented.
 
 The default is  YES.
 */
@property (nonatomic, assign) BOOL showsProgress;

/**
 A property that determines whether to use extended outer padding for views.
 */
@property (nonatomic, assign) BOOL useExtendedPadding;

/**
 A configuration for supporting early termination from a step.
 */
@property (nonatomic, copy, nullable) ORKEarlyTerminationConfiguration *earlyTerminationConfiguration;

/**
 The task that contains the step.
 
 The value of `task` is usually set when a step is added to the `ORKOrderedTask` object.
 Although it's a good idea to set this property when you implement a custom task, it's important
 to note that the use of this property is a convenience, and should not be relied
 upon within the ResearchKit framework.
 */
@property (nonatomic, weak, nullable) id<ORKTask> task;

/**
 The set of access permissions required for the step.
 
 This is a ready-only property. The task view controller uses the permission mask to determine the types of
 access to request from users when they complete the initial instruction steps
 in a task. If your step requires access to APIs that limit access, include
 the permissions you require in this mask.
 
 By default, the property scans the recorders and collates the permissions
 required by the recorders. Subclasses may override this implementation.
 */
@property (nonatomic, readonly) ORKPermissionMask requestedPermissions;

/**
 The set of HealthKit types the step requests for reading.
 
 This is a read-only property. The task view controller uses this set of types when constructing a list of
 all the HealthKit types required by all the steps in a task, so that it can
 present the HealthKit access dialog just once during that task.
 
 By default, the property scans the recorders and collates the HealthKit
 types the recorders require. Subclasses may override this implementation.
 */
@property (nonatomic, readonly, nullable) NSSet<HKObjectType *> *requestedHealthKitTypesForReading;

/**
 Checks the parameters of the step and throws exceptions on invalid parameters.
 
 This method is called when there is a need to validate the step's parameters, which is typically
 the case when adding a step to an  ORKStepViewController object, and when presenting the
 step view controller.
 
 Subclasses should override this method to provide validation of their additional
 properties, and must call super.
 */
- (void)validateParameters;

@end

#pragma mark - iOS

#if TARGET_OS_IOS || TARGET_OS_VISION

@class ORKBodyItem;

API_AVAILABLE(ios(11))
@interface ORKStep ()

/**
 An array of body items to display textual information.
 */
@property (nonatomic, nullable) NSArray<ORKBodyItem *> *bodyItems API_AVAILABLE(ios(11)) API_UNAVAILABLE(watchos);

/**
 An property that controls the text alignment for text body items.
 */
@property (nonatomic) NSTextAlignment bodyItemTextAlignment API_AVAILABLE(ios(11)) API_UNAVAILABLE(watchos);

/**
 A Boolean value indicating if the body items of the step should build in.
 
 Default value is NO resulting in all body items being displayed. Set to YES to
 only show the first item and subsequent items will build in on continue.
 */
@property (nonatomic, assign) BOOL buildInBodyItems API_AVAILABLE(ios(11)) API_UNAVAILABLE(watchos);

/**
 An image that provides visual context for the instruction.
 
 The image is displayed with aspect fit. Depending on the device, the screen area
 available for this image can vary.
 */

@property (nonatomic, copy, nullable) UIImage *image API_AVAILABLE(ios(11)) API_UNAVAILABLE(watchos);


/**
 An image that provides visual context for the instruction that allows for showing
 a two-part composite.
 
 The image is tinted and ``auxiliaryImage`` appears with light grey.
 
 The image displays with the same frame as ``image``, so it and ``auxiliaryImage``
 should have transparency to allow for overlay.
 */

@property (nonatomic, copy, nullable) UIImage *auxiliaryImage API_AVAILABLE(ios(11)) API_UNAVAILABLE(watchos);


/**
 A view controller that positions an image inside an image view that the step uses.
 
 Depending on the subclass of the step,  ORKStepView uses a specific UIImageView, and
 ``imageContentMode`` sets the content mode of used image view.
 */

@property (nonatomic) UIViewContentMode imageContentMode API_AVAILABLE(ios(11)) API_UNAVAILABLE(watchos);

@end
#endif


#pragma mark - watchOS / VisionOS


NS_ASSUME_NONNULL_END
