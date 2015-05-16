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


#import "ORKResultPredicate.h"
#import "ORKHelpers.h"


@implementation ORKResultPredicate

+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                    maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier
                                      minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                      maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier
                                      minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier
                                      maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedString:(NSString *)expectedString {
    return [self predicateForChoiceQuestionResultWithIdentifier:resultIdentifier expectedAnswers:@[ expectedString ] usePatterns:NO];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedStrings:(NSArray *)expectedStrings {
    return [self predicateForChoiceQuestionResultWithIdentifier:resultIdentifier expectedAnswers:expectedStrings usePatterns:NO];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPattern:(NSString *)pattern {
    return [self predicateForChoiceQuestionResultWithIdentifier:resultIdentifier expectedAnswers:@[ pattern ] usePatterns:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPatterns:(NSArray *)patterns {
    return [self predicateForChoiceQuestionResultWithIdentifier:resultIdentifier expectedAnswers:patterns usePatterns:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswers:(NSArray *)expectedAnswers usePatterns:(BOOL)usePatterns {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    ORKThrowInvalidArgumentExceptionIfNil(expectedAnswers);
    if ([expectedAnswers count] == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"expectedAnswer can not be empty." userInfo:nil];
    }

    NSMutableString *format = [@"SUBQUERY(SELF, $x, $x.identifier like %@" mutableCopy];
    
    NSString *repeatingFormatInfix = usePatterns ?
    @" AND SUBQUERY($x.answer, $y, $y matches %@).@count > 0" :
    @" AND SUBQUERY($x.answer, $y, $y like %@).@count > 0";
    for (NSInteger i = 0; i < [expectedAnswers count]; i++) {
        [format appendString:repeatingFormatInfix];
    }
    
    NSString *formatSuffix = @").@count > 0";
    [format appendString:formatSuffix];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:resultIdentifier, nil];
    [arguments addObjectsFromArray:expectedAnswers];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:arguments];
    return predicate;
}

+ (NSPredicate *)predicateForBooleanQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(BOOL)expectedAnswer {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer == %@).@count > 0",
                              resultIdentifier, @(expectedAnswer)];
    return predicate;
}

+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedString:(NSString *)expectedString {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer like %@).@count > 0",
                              resultIdentifier, expectedString];
    return predicate;
}

+ (NSPredicate *)predicateForTextQuestionResultWithIdentifier:(NSString *)resultIdentifier matchingPattern:(NSString *)pattern {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer matches %@).@count > 0",
                              resultIdentifier, pattern];
    return predicate;
}

+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier expectedAnswer:(NSInteger)expectedAnswer {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer == %@).@count > 0",
                              resultIdentifier, @(expectedAnswer)];
    return predicate;
}

+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                      maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer >= %@ AND $x.answer <= %@).@count > 0",
                              resultIdentifier, @(minimumExpectedAnswerValue), @(maximumExpectedAnswerValue)];
    return predicate;
}

+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer >= %@).@count > 0",
                              resultIdentifier, @(minimumExpectedAnswerValue)];
    return predicate;
}

+ (NSPredicate *)predicateForNumericQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                      maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer <= %@).@count > 0",
                              resultIdentifier, @(maximumExpectedAnswerValue)];
    return predicate;
}

+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                         minimumExpectedAnswerHour:(NSInteger)minimumExpectedAnswerHour
                                       minimumExpectedAnswerMinute:(NSInteger)minimumExpectedAnswerMinute
                                         maximumExpectedAnswerHour:(NSInteger)maximumExpectedAnswerHour
                                       maximumExpectedAnswerMinute:(NSInteger)maximumExpectedAnswerMinute {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $x, $x.identifier like %@ AND $x.answer.hour >= %@ AND $x.answer.minute >= %@ AND $x.answer.hour <= %@ AND $x.answer.minute <= %@).@count > 0",
                              resultIdentifier, @(minimumExpectedAnswerHour), @(minimumExpectedAnswerMinute), @(maximumExpectedAnswerHour), @(maximumExpectedAnswerMinute)];
    return predicate;
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                           minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue
                                           maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier
                                      minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                      maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                           minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier
                                      minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                           maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithIdentifier:resultIdentifier
                                      maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForDateQuestionResultWithIdentifier:(NSString *)resultIdentifier
                                    minimumExpectedAnswerDate:(nullable NSDate *)minimumExpectedAnswerDate
                                    maximumExpectedAnswerDate:(nullable NSDate *)maximumExpectedAnswerDate {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:resultIdentifier, nil];
    NSMutableString *format = [@"SUBQUERY(SELF, $x, $x.identifier like %@" mutableCopy];
    if (minimumExpectedAnswerDate) {
        [format appendString:@" AND $x.answer >= %@"];
        [arguments addObject:minimumExpectedAnswerDate];
    }
    if (maximumExpectedAnswerDate) {
        [format appendString:@" AND $x.answer <= %@"];
        [arguments addObject:maximumExpectedAnswerDate];
    }
    [format appendString:@").@count > 0"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:arguments];
    return predicate;
}

@end
