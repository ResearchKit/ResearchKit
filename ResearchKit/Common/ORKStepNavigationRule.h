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

/**
 The `ORKResultPredicate` class provides convenience class methods to build predicates for all the `ORKQuestionResult` subtypes.
 */
ORK_CLASS_AVAILABLE
@interface ORKResultPredicate : NSObject

/**
 The `init` and `new` methods are unavailable. `ORKResultPredicate` only provides class methods and should not be instantiated.
 */
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns a predicate matching a result of type `ORKScaleQuestionResult` whose answer is the specified integer value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected integer value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKScaleQuestionResult` whose answer is within the specified float values.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue   The minimum expected float value.
 @param maximumExpectedAnswerValue   The maximum expected float value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerValue:(CGFloat)minimumExpectedAnswerValue
                                    maximumExpectedAnswerValue:(CGFloat)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answer is equal to the specified string.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected string answer.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedString:(NSString *)expectedString;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answers are equal to the specified strings.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedStrings      An array with all the expected string answers.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedStrings:(NSArray *)expectedStrings;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answer matches the specified regular expression pattern.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param pattern             An ICU-compliant regular expression pattern that matches the answer string.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPattern:(NSString *)pattern;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answers match the specified regular expression patterns.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param patterns            An array of ICU-compliant regular expression patterns that match the answer strings.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPatterns:(NSArray *)patterns;

/**
 Returns a predicate matching a result of type `ORKBooleanQuestionResult` whose answer is the specified boolean value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected boolean value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForBooleanQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(BOOL)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKTextQuestionResult` whose answer is equal to the specified string.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedString      The expected result string.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedString:(NSString *)expectedString;

/**
 Returns a predicate matching a result of type `ORKTextQuestionResult` whose answer matches the specified regular expression pattern.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param pattern             An ICU-compliant regular expression pattern that matches the answer string.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPattern:(NSString *)pattern;

/**
 Returns a predicate matching a result of type `ORKNumericQuestionResult` whose answer is the specified integer value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected integer value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKNumericQuestionResult` whose answer is within the specified float values.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected float value.
 @param maximumExpectedAnswerValue  The maximum expected float value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      minimumExpectedAnswerValue:(CGFloat)minimumExpectedAnswerValue
                                      maximumExpectedAnswerValue:(CGFloat)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKTimeOfDayQuestionResult` whose answer is within the specified hour and minute values.
 
 Note that `ORKTimeOfDayQuestionResult` internally stores its answer as an `NSDateComponents` object. If you are interested in additional components, you will have to build the predicate manually.
 
 @param resultIdentifier                The identifier of the question result you want to match against.
 @param minimumExpectedAnswerHour       The minimum expected hour component value.
 @param minimumExpectedAnswerMinute     The minimum expected minute component value.
 @param maximumExpectedAnswerHour       The maximum integer hour component value.
 @param maximumExpectedAnswerMinute     The maximum expected minute component value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                         minimumExpectedAnswerHour:(NSInteger)minimumExpectedAnswerHour
                                       minimumExpectedAnswerMinute:(NSInteger)minimumExpectedAnswerMinute
                                         maximumExpectedAnswerHour:(NSInteger)maximumExpectedAnswerHour
                                       maximumExpectedAnswerMinute:(NSInteger)maximumExpectedAnswerMinute;

/**
 Returns a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is the specified integer value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected integer value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKDateQuestionResult` whose answer is a date within the specified dates.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerDate   The minimum expected date.
 @param maximumExpectedAnswerDate   The maximum expected date.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForDateQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerDate:(NSDate *)minimumExpectedAnswerDate
                                    maximumExpectedAnswerDate:(NSDate *)maximumExpectedAnswerDate;

@end


@class ORKResult;
@class ORKTaskResult;

/**
 The `ORKStepNavigationRule` class is the abstract base class for concrete step navigation rules. Several navigation rules can be set on a navigable ordered task (`ORKNavigableOrderedTask`), for different trigger step identifiers.

 Subclasses must implement the `identifierForDestinationStepWithTaskResult:` method, which returns the identifier of the destination step for the rule.
 
 Two concrete subclasses are included: `ORKPredicateStepNavigationRule` can match any answer combination in the results of the ongoing task and jump accordingly; `ORKDirectStepNavigationRule` unconditionally navigates to the step specified by the destination step identifier.
 */
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
 
 @param taskResult      The up-to-date task result, used for calculating the destination step.
 
 @return The identifier of the destination step.
 */
- (NSString *)identifierForDestinationStepWithTaskResult:(ORKTaskResult *)taskResult;

@end


/**
 The `ORKPredicateStepNavigationRule` class is a concrete step navigation rule class.
 
 It can be used to match any answer combination in the results of the ongoing task and jump accordingly. You must provide one or more result predicates (each predicate can match one or more step result within the task).
 
 The `ORKResultPredicate` class provides convenience class methods to build predicates for all the `ORKQuestionResult` subtypes.
 */
ORK_CLASS_AVAILABLE
@interface ORKPredicateStepNavigationRule : ORKStepNavigationRule

/**
 Returns an initialized predicate step navigation rule using the specified result predicates, matching step identifiers, and an optional default step identifier.
 
 @param resultPredicates            An array of result predicates. Each result predicate can match one or more step results in the ongoing task.
 @param matchingStepIdentifiers     An array of possible destination step identifiers. This array must contain one step identifier for each of the predicates in `resultPredicates`.
 @param defaultStepIdentifier       The identifier of the step which will be used if none of the result predicates match. If this argument is `nil` and none of the predicates match, the default ordered task navigation behavior takes place (i.e, the task goes to the next step in order).
 
 @return An initialized predicate step navigation rule.
 */
- (instancetype)initWithResultPredicates:(NSArray *)resultPredicates
                 matchingStepIdentifiers:(NSArray *)matchingStepIdentifiers
                   defaultStepIdentifier:(nullable NSString *)defaultStepIdentifier NS_DESIGNATED_INITIALIZER;

/**
 Returns an initialized predicate step navigation rule using the specified result predicates and matching step identifiers.
 
 @param resultPredicates            An array of result predicates. Each result predicate can match one or more step results in the ongoing task.
 @param matchingStepIdentifiers     An array of possible destination step identifiers. This array must contain one step identifier for each of the predicates in resultPredicates.
 
 @return An initialized predicate step navigation rule.
 */
- (instancetype)initWithResultPredicates:(NSArray *)resultPredicates
                 matchingStepIdentifiers:(NSArray *)matchingStepIdentifiers;

/**
 Returns a new predicate step navigation rule initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the step navigation rule.
 @return A new predicate step navigation rule.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKDirectStepNavigationRule` class is a concrete step navigation rule class.
 
 It can be used to unconditionally jump to a destination step specified by its identifier.
 */
ORK_CLASS_AVAILABLE
@interface ORKDirectStepNavigationRule : ORKStepNavigationRule

/**
 Returns an initialized direct step navigation rule using the specified destination step identifier.
 
 @param destinationStepIdentifier   The identifier of the destination step.
 
 @return An direct step navigation rule.
 */
- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new direct step navigation rule initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the step navigation rule.
 @return A new direct step navigation rule.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END