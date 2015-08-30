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


NSString *const ORKResultPredicateTaskIdentifierVariableName = @"ORK_TASK_IDENTIFIER";

@implementation ORKResultPredicate

+ (NSPredicate *)predicateMatchingTaskIdentifier:(NSString *)taskIdentifier
                                  stepIdentifier:(NSString *)stepIdentifier
                                resultIdentifier:(NSString *)resultIdentifier
                         subPredicateFormatArray:(NSArray *)subPredicateFormatArray
                 subPredicateFormatArgumentArray:(NSArray *)subPredicateFormatArgumentArray
                  areSubPredicateFormatsSubquery:(BOOL)areSubPredicateFormatsSubquery {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifier);

    if (!stepIdentifier) {
        stepIdentifier = resultIdentifier;
    }
    
    NSMutableString *format = [[NSMutableString alloc] init];
    NSMutableArray *formatArgumentArray = [[NSMutableArray alloc] init];
    
    // Match task identifier

    if (taskIdentifier) {
        [format appendString:@"SUBQUERY(SELF, $x, $x.identifier like %@"];
        [formatArgumentArray addObject:taskIdentifier];
    } else {
        // If taskIdentifier is nil, ORKPredicateStepNavigationRule will substitute the
        // ORKResultPredicateTaskIdentifierSubstitutionVariableName variable by the identifier of the ongoing task
        [format appendFormat:@"SUBQUERY(SELF, $x, $x.identifier like $%@", ORKResultPredicateTaskIdentifierVariableName];
    }
    
    {
        // Match question result identifier
        [format appendString:@" AND SUBQUERY($x.results, $y, $y.identifier like %@ AND SUBQUERY($y.results, $z, $z.identifier like %@"];
        [formatArgumentArray addObject:stepIdentifier];
        [formatArgumentArray addObject:resultIdentifier];
        {
            // Add question sub predicates. They can be normal predicates (for question results with only one answer)
            // or part of an additional subquery predicate (for question results with an array of answers, like ORKChoiceQuestionResult).
            for (NSString *subPredicateFormat in subPredicateFormatArray) {
                if (!areSubPredicateFormatsSubquery) {
                    [format appendString:@" AND $z."];
                    [format appendString:subPredicateFormat];
                } else {
                    [format appendString:@" AND SUBQUERY($z."];
                    [format appendString:subPredicateFormat];
                    [format appendString:@").@count > 0"];
                }
            }
            [formatArgumentArray addObjectsFromArray:subPredicateFormatArgumentArray];
        }
        [format appendString:@").@count > 0"];
        [format appendString:@").@count > 0"];
    }
    
    [format appendString:@").@count > 0"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArgumentArray];
    return predicate;
}

+ (NSPredicate *)predicateMatchingTaskIdentifier:(NSString *)taskIdentifier
                                  stepIdentifier:(NSString *)stepIdentifier
                                resultIdentifier:(NSString *)resultIdentifier
                         subPredicateFormatArray:(NSArray *)subPredicateFormatArray
                 subPredicateFormatArgumentArray:(NSArray *)subPredicateFormatArgumentArray {
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:subPredicateFormatArray
                 subPredicateFormatArgumentArray:subPredicateFormatArgumentArray
                  areSubPredicateFormatsSubquery:NO];
}

+ (NSPredicate *)predicateForNilQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                  stepIdentifier:(NSString *)stepIdentifier
                                                resultIdentifier:(NSString *)resultIdentifier {
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:@[ @"answer == nil" ]
                 subPredicateFormatArgumentArray:@[ ]];
}

+ (NSPredicate *)predicateForNilQuestionResultWithStepIdentifier:(NSString *)stepIdentifier
                                                resultIdentifier:(NSString *)resultIdentifier {
    return [self predicateForNilQuestionResultWithTaskIdentifier:nil
                                                  stepIdentifier:stepIdentifier
                                                resultIdentifier:resultIdentifier];
}

+ (NSPredicate *)predicateForNilQuestionResultWithResultIdentifier:(NSString *)resultIdentifier {
    return [self predicateForNilQuestionResultWithStepIdentifier:nil
                                                resultIdentifier:resultIdentifier];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    stepIdentifier:(NSString *)stepIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                                    expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                                      expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                                    expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                    stepIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                                    expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                      expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                                    expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    stepIdentifier:(NSString *)stepIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                        minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                        maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                        minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                        maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                    stepIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                        minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                        maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                        minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                        maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    stepIdentifier:(NSString *)stepIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                        minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                        minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                    stepIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                        minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                        minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    stepIdentifier:(NSString *)stepIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                        maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                  resultIdentifier:(NSString *)resultIdentifier
                                        maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                    stepIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                        maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                        maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForScaleQuestionResultWithTaskIdentifier:nil
                                                  resultIdentifier:resultIdentifier
                                        maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                     stepIdentifier:(NSString *)stepIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                    expectedAnswers:(NSArray *)expectedAnswers
                                                        usePatterns:(BOOL)usePatterns {
    ORKThrowInvalidArgumentExceptionIfNil(expectedAnswers);
    if ([expectedAnswers count] == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"expectedAnswer can not be empty." userInfo:nil];
    }
    
    NSMutableArray *subPredicateFormatArray = [NSMutableArray new];
    
    NSString *repeatingSubPredicateFormat =
    usePatterns ?
    @"answer, $w, $w matches %@" :
    @"answer, $w, $w like %@";
    
    for (NSInteger i = 0; i < [expectedAnswers count]; i++) {
        [subPredicateFormatArray addObject:repeatingSubPredicateFormat];
    }
    
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:subPredicateFormatArray
                 subPredicateFormatArgumentArray:expectedAnswers
                  areSubPredicateFormatsSubquery:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                     stepIdentifier:(NSString *)stepIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                     expectedString:(NSString *)expectedString {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:stepIdentifier
                                                   resultIdentifier:resultIdentifier
                                                    expectedAnswers:@[ expectedString ]
                                                        usePatterns:NO];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                     expectedString:(NSString *)expectedString {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                     expectedString:expectedString];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                       expectedString:(NSString *)expectedString {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:nil
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                     expectedString:(NSString *)expectedString];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                     stepIdentifier:(NSString *)stepIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                    expectedStrings:(NSArray<NSString *> *)expectedStrings {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:(NSString *)stepIdentifier
                                                         resultIdentifier:resultIdentifier
                                                    expectedAnswers:expectedStrings
                                                        usePatterns:NO];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                    expectedStrings:(NSArray<NSString *> *)expectedStrings {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                    expectedStrings:expectedStrings];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                      expectedStrings:(NSArray *)expectedStrings {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                    expectedStrings:expectedStrings];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                     stepIdentifier:(NSString *)stepIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                    matchingPattern:(NSString *)pattern {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:stepIdentifier
                                                   resultIdentifier:resultIdentifier
                                                    expectedAnswers:@[ pattern ]
                                                        usePatterns:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                    matchingPattern:(NSString *)pattern {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                    matchingPattern:pattern];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                      matchingPattern:(NSString *)pattern {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                    matchingPattern:pattern];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                     stepIdentifier:(NSString *)stepIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                   matchingPatterns:(NSArray<NSString *> *)patterns {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:stepIdentifier
                                                   resultIdentifier:resultIdentifier
                                                    expectedAnswers:patterns
                                                        usePatterns:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   resultIdentifier:(NSString *)resultIdentifier
                                                   matchingPatterns:(NSArray<NSString *> *)patterns {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                     stepIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                   matchingPatterns:patterns];

}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                     matchingPatterns:(NSArray<NSString *> *)patterns {
    return [self predicateForChoiceQuestionResultWithTaskIdentifier:nil
                                                   resultIdentifier:resultIdentifier
                                                   matchingPatterns:patterns];
}

+ (NSPredicate *)predicateForBooleanQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                      stepIdentifier:(NSString *)stepIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                                      expectedAnswer:(BOOL)expectedAnswer {
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:@[ @"answer == %@" ]
                 subPredicateFormatArgumentArray:@[ @(expectedAnswer) ]];
}

+ (NSPredicate *)predicateForBooleanQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                                      expectedAnswer:(BOOL)expectedAnswer {
    return [self predicateForBooleanQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                                      expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForBooleanQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                        expectedAnswer:(BOOL)expectedAnswer {
    return [self predicateForBooleanQuestionResultWithTaskIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                                      expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForTextQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   stepIdentifier:(NSString *)stepIdentifier
                                                 resultIdentifier:(NSString *)resultIdentifier
                                                   expectedString:(NSString *)expectedString {
    ORKThrowInvalidArgumentExceptionIfNil(expectedString);
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:@[ @"answer like %@" ]
                 subPredicateFormatArgumentArray:@[ expectedString ]];
}

+ (NSPredicate *)predicateForTextQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                 resultIdentifier:(NSString *)resultIdentifier
                                                   expectedString:(NSString *)expectedString {
    return [self predicateForTextQuestionResultWithTaskIdentifier:taskIdentifier
                                                   stepIdentifier:nil
                                                 resultIdentifier:resultIdentifier
                                                   expectedString:expectedString];
}

+ (NSPredicate *)predicateForTextQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                     expectedString:(NSString *)expectedString {
    return [self predicateForTextQuestionResultWithTaskIdentifier:nil
                                                 resultIdentifier:resultIdentifier
                                                   expectedString:expectedString];
}

+ (NSPredicate *)predicateForTextQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   stepIdentifier:(NSString *)stepIdentifier
                                                 resultIdentifier:(NSString *)resultIdentifier
                                                  matchingPattern:(NSString *)pattern {
    ORKThrowInvalidArgumentExceptionIfNil(pattern);
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:@[ @"answer matches %@" ]
                 subPredicateFormatArgumentArray:@[ pattern ]];
}

+ (NSPredicate *)predicateForTextQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                 resultIdentifier:(NSString *)resultIdentifier
                                                  matchingPattern:(NSString *)pattern {
    return [self predicateForTextQuestionResultWithTaskIdentifier:taskIdentifier
                                                   stepIdentifier:nil
                                                 resultIdentifier:resultIdentifier
                                                  matchingPattern:pattern];
}

+ (NSPredicate *)predicateForTextQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                    matchingPattern:(NSString *)pattern {
    return [self predicateForTextQuestionResultWithTaskIdentifier:nil
                                                 resultIdentifier:resultIdentifier
                                                  matchingPattern:pattern];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                      stepIdentifier:(NSString *)stepIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                                      expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:@[ @"answer == %@" ]
                 subPredicateFormatArgumentArray:@[ @(expectedAnswer) ]];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                                      expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                                      expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                        expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                                      expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                      stepIdentifier:(NSString *)stepIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    NSMutableArray *subPredicateFormatArray = [NSMutableArray new];
    NSMutableArray *subPredicateFormatArgumentArray = [NSMutableArray new];
    
    if (!isnan(minimumExpectedAnswerValue)) {
        [subPredicateFormatArray addObject:@"answer >= %@"];
        [subPredicateFormatArgumentArray addObject:@(minimumExpectedAnswerValue)];
    }
    if (!isnan(maximumExpectedAnswerValue)) {
        [subPredicateFormatArray addObject:@"answer <= %@"];
        [subPredicateFormatArgumentArray addObject:@(maximumExpectedAnswerValue)];
    }
    
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:subPredicateFormatArray
                 subPredicateFormatArgumentArray:subPredicateFormatArgumentArray];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                            minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                            maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                      stepIdentifier:(NSString *)stepIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:ORKIgnoreDoubleValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                            minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                      stepIdentifier:(NSString *)stepIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:ORKIgnoreDoubleValue
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                    resultIdentifier:(NSString *)resultIdentifier
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                            maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:nil
                                                    resultIdentifier:resultIdentifier
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                        stepIdentifier:(NSString *)stepIdentifier
                                                      resultIdentifier:(NSString *)resultIdentifier
                                                   minimumExpectedHour:(NSInteger)minimumExpectedHour
                                                 minimumExpectedMinute:(NSInteger)minimumExpectedMinute
                                                   maximumExpectedHour:(NSInteger)maximumExpectedHour
                                                 maximumExpectedMinute:(NSInteger)maximumExpectedMinute {
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:@[ @"answer.hour >= %@",
                                                    @"answer.minute >= %@",
                                                    @"answer.hour <= %@",
                                                    @"answer.minute <= %@" ]
                 subPredicateFormatArgumentArray:@[ @(minimumExpectedHour),
                                                    @(minimumExpectedMinute),
                                                    @(maximumExpectedHour),
                                                    @(maximumExpectedMinute) ]];
}

+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                      resultIdentifier:(NSString *)resultIdentifier
                                                   minimumExpectedHour:(NSInteger)minimumExpectedHour
                                                 minimumExpectedMinute:(NSInteger)minimumExpectedMinute
                                                   maximumExpectedHour:(NSInteger)maximumExpectedHour
                                                 maximumExpectedMinute:(NSInteger)maximumExpectedMinute {
    return [self predicateForTimeOfDayQuestionResultWithTaskIdentifier:taskIdentifier
                                                        stepIdentifier:nil
                                                      resultIdentifier:resultIdentifier
                                                   minimumExpectedHour:minimumExpectedHour
                                                 minimumExpectedMinute:minimumExpectedMinute
                                                   maximumExpectedHour:maximumExpectedHour
                                                 maximumExpectedMinute:maximumExpectedMinute];
}

+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                     minimumExpectedHour:(NSInteger)minimumExpectedHour
                                                   minimumExpectedMinute:(NSInteger)minimumExpectedMinute
                                                     maximumExpectedHour:(NSInteger)maximumExpectedHour
                                                   maximumExpectedMinute:(NSInteger)maximumExpectedMinute {
    return [self predicateForTimeOfDayQuestionResultWithTaskIdentifier:nil
                                                      resultIdentifier:resultIdentifier
                                                   minimumExpectedHour:minimumExpectedHour
                                                 minimumExpectedMinute:minimumExpectedMinute
                                                   maximumExpectedHour:maximumExpectedHour
                                                 maximumExpectedMinute:maximumExpectedMinute];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                           stepIdentifier:(NSString *)stepIdentifier
                                                         resultIdentifier:(NSString *)resultIdentifier
                                               minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue
                                               maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                         resultIdentifier:(NSString *)resultIdentifier
                                               minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue
                                               maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                           stepIdentifier:nil
                                                         resultIdentifier:resultIdentifier
                                               minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                               maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                 minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue
                                                 maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForTimeIntervalQuestionResultWithTaskIdentifier:nil
                                                         resultIdentifier:resultIdentifier
                                               minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                               maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                           stepIdentifier:(NSString *)stepIdentifier
                                                         resultIdentifier:(NSString *)resultIdentifier
                                               minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                         resultIdentifier:(NSString *)resultIdentifier
                                               minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue {
    return [self predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                           stepIdentifier:nil
                                                         resultIdentifier:resultIdentifier
                                               minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                 minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue {
    return [self predicateForTimeIntervalQuestionResultWithTaskIdentifier:nil
                                                         resultIdentifier:resultIdentifier
                                               minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                           stepIdentifier:(NSString *)stepIdentifier
                                                         resultIdentifier:(NSString *)resultIdentifier
                                               maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                      stepIdentifier:stepIdentifier
                                                    resultIdentifier:resultIdentifier
                                          maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                         resultIdentifier:(NSString *)resultIdentifier
                                               maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                           stepIdentifier:nil
                                                         resultIdentifier:resultIdentifier
                                               maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                                 maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForTimeIntervalQuestionResultWithTaskIdentifier:nil
                                                         resultIdentifier:resultIdentifier
                                               maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForDateQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                   stepIdentifier:(NSString *)stepIdentifier
                                                 resultIdentifier:(NSString *)resultIdentifier
                                        minimumExpectedAnswerDate:(nullable NSDate *)minimumExpectedAnswerDate
                                        maximumExpectedAnswerDate:(nullable NSDate *)maximumExpectedAnswerDate {
    NSMutableArray *subPredicateFormatArray = [NSMutableArray new];
    NSMutableArray *subPredicateFormatArgumentArray = [NSMutableArray new];
    
    if (minimumExpectedAnswerDate) {
        [subPredicateFormatArray addObject:@"answer >= %@"];
        [subPredicateFormatArgumentArray addObject:minimumExpectedAnswerDate];
    }
    if (maximumExpectedAnswerDate) {
        [subPredicateFormatArray addObject:@"answer <= %@"];
        [subPredicateFormatArgumentArray addObject:maximumExpectedAnswerDate];
    }
    
    return [self predicateMatchingTaskIdentifier:taskIdentifier
                                  stepIdentifier:stepIdentifier
                                resultIdentifier:resultIdentifier
                         subPredicateFormatArray:subPredicateFormatArray
                 subPredicateFormatArgumentArray:subPredicateFormatArgumentArray];
}

+ (NSPredicate *)predicateForDateQuestionResultWithTaskIdentifier:(NSString *)taskIdentifier
                                                 resultIdentifier:(NSString *)resultIdentifier
                                        minimumExpectedAnswerDate:(nullable NSDate *)minimumExpectedAnswerDate
                                        maximumExpectedAnswerDate:(nullable NSDate *)maximumExpectedAnswerDate {
    return [self predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                   stepIdentifier:nil
                                                 resultIdentifier:resultIdentifier
                                        minimumExpectedAnswerDate:minimumExpectedAnswerDate
                                        maximumExpectedAnswerDate:maximumExpectedAnswerDate];
}

+ (NSPredicate *)predicateForDateQuestionResultWithResultIdentifier:(NSString *)resultIdentifier
                                          minimumExpectedAnswerDate:(nullable NSDate *)minimumExpectedAnswerDate
                                          maximumExpectedAnswerDate:(nullable NSDate *)maximumExpectedAnswerDate {
    return [self predicateForDateQuestionResultWithTaskIdentifier:nil
                                                 resultIdentifier:resultIdentifier
                                        minimumExpectedAnswerDate:minimumExpectedAnswerDate
                                        maximumExpectedAnswerDate:maximumExpectedAnswerDate];
}

@end
