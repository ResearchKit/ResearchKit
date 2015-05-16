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
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

extern const double ORKIgnoreDoubleValue;
extern const NSTimeInterval ORKIgnoreTimeIntervalValue;

/**
 The `ORKResultPredicate` class provides convenience class methods to build predicates for all the
 `ORKQuestionResult` subtypes.
 
 You use result predicates to create `ORKPredicateStepNavigationRule` objects. The result predicates
 are used to match specific `ORKQuestionResult` instances (created in response of the participant's
 answers) and navigate accordingly. You can match results both in an ongoing task or in previously
 completed tasks.
 */
ORK_CLASS_AVAILABLE
@interface ORKResultPredicate : NSObject

/*
 The `init` and `new` methods are unavailable. `ORKResultPredicate` only provides class methods and
 should not be instantiated.
 */
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns a predicate matching a result of type `ORKScaleQuestionResult` whose answer is the
 specified integer value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected integer value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKScaleQuestionResult` whose answer is within the
 specified double values.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected double value. Pass `ORKIgnoreDoubleValue`
                                        if you don't want to compare the answer against a maximum
                                        double value.
 @param maximumExpectedAnswerValue  The maximum expected double value. Pass `ORKIgnoreDoubleValue`
                                        if you don't want to compare the answer against a maximum
                                        double value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                    maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKScaleQuestionResult` whose answer is greater than
 or equal to the specified double value.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected double value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKScaleQuestionResult` whose answer is less than or
 equal to the specified double value.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param maximumExpectedAnswerValue  The maximum expected double value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answer is equal to
 the specified string.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected string answer.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedString:(NSString *)expectedString;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answers are equal to
 the specified strings.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedStrings      An array with all the expected string answers.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedStrings:(NSArray *)expectedStrings;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answer matches the
 specified regular expression pattern.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param pattern             An ICU-compliant regular expression pattern that matches the answer string.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPattern:(NSString *)pattern;

/**
 Returns a predicate matching a result of type `ORKChoiceQuestionResult` whose answers match the
 specified regular expression patterns.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param patterns            An array of ICU-compliant regular expression patterns that match the answer strings.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPatterns:(NSArray *)patterns;

/**
 Returns a predicate matching a result of type `ORKBooleanQuestionResult` whose answer is the
 specified boolean value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected boolean value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForBooleanQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(BOOL)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKTextQuestionResult` whose answer is equal to the
 specified string.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedString      The expected result string.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedString:(NSString *)expectedString;

/**
 Returns a predicate matching a result of type `ORKTextQuestionResult` whose answer matches the
 specified regular expression pattern.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param pattern             An ICU-compliant regular expression pattern that matches the answer string.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPattern:(NSString *)pattern;

/**
 Returns a predicate matching a result of type `ORKNumericQuestionResult` whose answer is the
 specified integer value.
 
 @param resultIdentifier    The identifier of the question result you want to match against.
 @param expectedAnswer      The expected integer value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer;

/**
 Returns a predicate matching a result of type `ORKNumericQuestionResult` whose answer is within the
 specified double values.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected double value. Pass `ORKIgnoreDoubleValue`
                                        if you don't want to compare the answer against a maximum
                                        double value.
 @param maximumExpectedAnswerValue  The maximum expected double value. Pass `ORKIgnoreDoubleValue`
                                        if you don't want to compare the answer against a minimum
                                        double value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                      maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKNumericQuestionResult` whose answer is greater
 than or equal to the specified double value.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected double value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKNumericQuestionResult` whose answer is less than
 or equal to the specified double value.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param maximumExpectedAnswerValue  The maximum expected double value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKTimeOfDayQuestionResult` whose answer is within
 the specified hour and minute values.
 
 Note that `ORKTimeOfDayQuestionResult` internally stores its answer as an `NSDateComponents` object.
 If you are interested in additional components, you will have to build the predicate manually.
 
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
 Returns a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is the
 is within the specified `NSTimeInterval` values.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected `NSTimeInterval` value. Pass
                                        `ORKIgnoreTimeIntervlValue` if you don't want to compare the
                                        answer against a maximum `NSTimeInterval` value.
 @param maximumExpectedAnswerValue  The maximum expected `NSTimeInterval` value. Pass
                                        `ORKIgnoreTimeIntervlValue` if you don't want to compare the
                                        answer against a minimum `NSTimeInterval` value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                           minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue
                                           maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is the
 specified integer value.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerValue  The minimum expected `NSTimeInterval` value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                           minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is the
 specified integer value.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param maximumExpectedAnswerValue  The maximum expected `NSTimeInterval` value.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                           maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue;

/**
 Returns a predicate matching a result of type `ORKDateQuestionResult` whose answer is a date within
 the specified dates.
 
 @param resultIdentifier            The identifier of the question result you want to match against.
 @param minimumExpectedAnswerDate   The minimum expected date. Pass `nil` if you don't want to
                                        compare the answer against a minimum date.
 @param maximumExpectedAnswerDate   The maximum expected date. Pass `nil` if you don't want to
                                        compare the answer against a maximum date.
 
 @return A result predicate.
 */
+ (NSPredicate *)predicateForDateQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerDate:(nullable NSDate *)minimumExpectedAnswerDate
                                    maximumExpectedAnswerDate:(nullable NSDate *)maximumExpectedAnswerDate;

@end

NS_ASSUME_NONNULL_END
