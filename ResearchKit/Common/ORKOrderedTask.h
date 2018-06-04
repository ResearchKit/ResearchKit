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
#import <ResearchKit/ORKTask.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKOrderedTask` class implements all the methods in the `ORKTask` protocol and represents a 
 task that assumes a fixed order for its steps.
 
 In the ResearchKit framework, any simple sequential task, such as a survey or an active task, can
 be represented as an ordered task.
 
 If you want further custom conditional behaviors in a task, it can be easier to subclass
 `ORKOrderedTask` or `ORKNavigableOrderedTask` and override particular `ORKTask` methods than it is
 to implement the `ORKTask` protocol directly. Override the methods `stepAfterStep:withResult:` and
 `stepBeforeStep:withResult:`, and call super for all other methods.
 */
ORK_CLASS_AVAILABLE
@interface ORKOrderedTask : NSObject <ORKTask, NSSecureCoding, NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// @name Initializers

/**
 Returns an initialized ordered task using the specified identifier and array of steps.
 
 @param identifier  The unique identifier for the task.
 @param steps       An array of `ORKStep` objects in the order in which they should be presented.
 
 @return An initialized ordered task.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             steps:(nullable NSArray<ORKStep *> *)steps NS_DESIGNATED_INITIALIZER;

/**
 Returns an ordered task initialized from data in the given unarchiver.
 
 An ordered task can be serialized and deserialized with `NSKeyedArchiver`. Note
 that this serialization includes strings that might need to be
 localized.
 
 @param aDecoder    The coder from which to initialize the ordered task.
 
 @return An initialized ordered task.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/// @name Properties

/**
 The array of steps in the task. (read-only)
 
 Each element in the array must be a subclass of `ORKStep`.
 The associated task view controller presents the steps in
 array order.
 */
@property (nonatomic, copy, readonly) NSArray<ORKStep *> *steps;

/**
 Color property of the progress label.
 Default is black.
 */
@property (nonatomic) UIColor *progressLabelColor;

/**
 Return a mutated copy of self with the steps included in the given array.
 
 This method is intended to allow for mutating an ordered task (or subclass) while retaining
 the original class and properties that may not be publicly exposed, but with a mutated set
 of steps. An example of where this might be useful is if before performing an `ORKPredefinedActiveTask`, 
 the app needed to query the participant about medications, diet or sleep. The app
 would need to mutate the steps in order to insert their own steps. While an ORKOrderedTask could
 then be created with the same identifier and the new steps, subclass information such rules on an
 `ORKNavigableOrderedTask` would be lost.
 
 @param steps       An array of `ORKStep` objects in the order in which they should be presented.
 
 @return            An initialized ordered task.
 */
- (instancetype)copyWithSteps:(NSArray <ORKStep *> *)steps;

/**
 Find the index of a given step.
 
 @param step        The step to look for
 @return            The index position of the step (or NSNotFound if not found)
 */
- (NSUInteger)indexOfStep:(ORKStep *)step;

@end

NS_ASSUME_NONNULL_END
