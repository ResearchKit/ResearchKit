/*
 Copyright (c) 2016, Sage Bionetworks
 
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

#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKOrderedTask.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKPageStep` class is a concrete subclass of `ORKStep`, used for presenting a subgrouping of
 `ORKStepViewController` views using a `UIPageViewController`.
 
 To use `ORKPageStep`, instantiate the object, fill in its properties, and include it in a task. 
 Next, create a task view controller for the task and present it.
 
 The base class implementation will instatiate a read-only `ORKPageStepViewController` to display
 a series of substeps. For each substep, the `ORKStepViewController` will be instantiated and added
 as a child of the `UIPageViewController` contained by the parent `ORKPageStepViewController`..
 
 Customization can be handled by overriding the base class implementations in either `ORKPageStep`
 or `ORKPageStepViewController`.
 */

ORK_CLASS_AVAILABLE
@interface ORKPageStep : ORKStep

/**
 Returns an initialized page step using the specified identifier and array of steps.
 
 @param identifier  The unique identifier for the step.
 @param steps       An array of `ORKStep` objects in the order in which they should be presented.
 
 @return An initialized page step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             steps:(nullable NSArray<ORKStep *> *)steps NS_DESIGNATED_INITIALIZER;

/**
 Returns a page step initialized from data in the given unarchiver.
 
 A page step can be serialized and deserialized with `NSKeyedArchiver`. Note
 that this serialization includes strings that might need to be localized.
 
 @param aDecoder    The coder from which to initialize the ordered task.
 
 @return An initialized page step.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 The array of steps in the page step. (read-only)
 
 Each element in the array must be a subclass of `ORKStep`.
 The associated page step view controller presents the steps in
 array order.
 */
@property (nonatomic, copy, readonly) NSArray<ORKStep *> *steps;

/**
 Returns the step after the specified step, if there is one.
 
 The page view controller calls this method to determine the step to display after the specified step. 
 The page view controller can also call this method every time the result updates, to determine if the 
 new result changes which steps are available.
 
 @param identifier      The reference step identifier. Pass `nil` to specify the first step.
 @param result          A snapshot of the current set of results.
 
 @return The step that comes after the specified step, or `nil` if there isn't one.
 */
- (nullable ORKStep *)stepAfterStepWithIdentifier:(nullable NSString *)identifier withResult:(ORKTaskResult *)result;

/**
 Returns the step that precedes the specified step, if there is one.
 
 The page view controller calls this method to determine the step to display before the specified step. 
 The page view controller can also call this method every time the result changes, to determine if the 
 new result changes which steps are available.
 
 @param identifier      The reference step identifier. 
 @param result          A snapshot of the current set of results.
 
 @return The step that precedes the reference step, or `nil` if there isn't one.
 */
- (nullable ORKStep *)stepBeforeStepWithIdentifier:(NSString *)identifier withResult:(ORKTaskResult *)result;


/**
 Returns the step that matches the specified identifier.
 
 @param identifier  The identifier of the step to restore.
 @return            The step that matches the specified identifier, or `nil` if there isn't one.
 */
- (nullable ORKStep *)stepWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END