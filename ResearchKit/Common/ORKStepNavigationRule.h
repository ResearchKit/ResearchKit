/*
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN


@interface ORKResultPredicate : NSObject

+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerValue:(CGFloat)minimumExpectedAnswerValue
                                    maximumExpectedAnswerValue:(CGFloat)maximumExpectedAnswerValue;

+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSString *)expectedAnswer;
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswers:(NSArray *)expectedAnswers;

+ (NSPredicate *)predicateForBooleanQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(BOOL)expectedAnswer;

+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSString *)expectedAnswer;

+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      minimumExpectedAnswerValue:(CGFloat)minimumExpectedAnswerValue
                                      maximumExpectedAnswerValue:(CGFloat)maximumExpectedAnswerValue;

+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                         minimumExpectedAnswerHour:(NSInteger)minimumExpectedAnswerHour
                                       minimumExpectedAnswerMinute:(NSInteger)minimumExpectedAnswerMinute
                                         maximumExpectedAnswerHour:(NSInteger)maximumExpectedAnswerHour
                                       maximumExpectedAnswerMinute:(NSInteger)maximumExpectedAnswerMinute;

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;

+ (NSPredicate *)predicateForDateQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerDate:(NSDate *)minimumExpectedAnswerDate
                                    maximumExpectedAnswerDate:(NSDate *)maximumExpectedAnswerDate;

@end


@class ORKResult;
@class ORKTaskResult;

ORK_CLASS_AVAILABLE
@interface ORKStepNavigationRule : NSObject <NSCopying, NSSecureCoding>

/**
 The `init` and `new` methods are unavailable.
 
 `ORKStepNavigationRule` classes should be initialized with custom designated
 initializers on each subclass.
 */
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns the target step identifier.
 
 Subclasses must implement this method to calculate the next step based on the passed task result.
 
 @param taskResult  Up to date task result, used for calculating the target step
 @return The identifier for the target step
 */
- (NSString *)identifierForDestinationStepWithTaskResult:(ORKTaskResult *)taskResult;

@end


ORK_CLASS_AVAILABLE
@interface ORKPredicateStepNavigationRule : ORKStepNavigationRule

- (instancetype)initWithResultPredicates:(NSArray *)resultPredicates
                 matchingStepIdentifiers:(NSArray *)matchingStepIdentifiers
                   defaultStepIdentifier:(NSString * __nullable)defaultStepIdentifier NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithResultPredicates:(NSArray *)resultPredicates
                 matchingStepIdentifiers:(NSArray *)matchingStepIdentifiers;

/**
 Returns a new step navigation rule initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the step navigation rule.
 @return A new step navigation rule.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


ORK_CLASS_AVAILABLE
@interface ORKDirectStepNavigationRule : ORKStepNavigationRule

- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new step navigation rule initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the step navigation rule.
 @return A new step navigation rule.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END