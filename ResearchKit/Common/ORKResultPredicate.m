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


@interface ORKResultIdentifier ()

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


@implementation ORKResultIdentifier

+ (instancetype)identifierWithTaskIdentifier:(NSString *)taskIdentifier
                              stepIdentifier:(NSString *)stepIdentifier
                            resultIdentifier:(NSString *)resultIdentifier {
    return [[[self class] alloc] initWithTaskIdentifier:taskIdentifier
                                         stepIdentifier:stepIdentifier
                                       resultIdentifier:resultIdentifier];
}

+ (instancetype)identifierWithStepIdentifier:(NSString *)stepIdentifier
                            resultIdentifier:(NSString *)resultIdentifier {
    return [[[self class] alloc] initWithStepIdentifier:stepIdentifier
                                       resultIdentifier:resultIdentifier];
}

+ (instancetype)identifierWithTaskIdentifier:(NSString *)taskIdentifier
                            resultIdentifier:(NSString *)resultIdentifier {
    return [[[self class] alloc] initWithTaskIdentifier:taskIdentifier
                                       resultIdentifier:resultIdentifier];
   
}

+ (instancetype)identifierWithResultIdentifier:(NSString *)resultIdentifier {
    return [[[self class] alloc] initWithResultIdentifier:resultIdentifier];
}

- (instancetype)initWithTaskIdentifier:(NSString *)taskIdentifier
                        stepIdentifier:(NSString *)stepIdentifier
                      resultIdentifier:(NSString *)resultIdentifier {
    if (self = [super init]) {
        _taskIdentifier = [taskIdentifier copy];
        _stepIdentifier = [stepIdentifier copy];
        _resultIdentifier = [resultIdentifier copy];
    }
    return self;
}

- (instancetype)initWithTaskIdentifier:(NSString *)taskIdentifier
                      resultIdentifier:(NSString *)resultIdentifier {
    return [self initWithTaskIdentifier:taskIdentifier
                         stepIdentifier:nil
                       resultIdentifier:resultIdentifier];

}

- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier
                      resultIdentifier:(NSString *)resultIdentifier {
    return [self initWithTaskIdentifier:nil
                         stepIdentifier:stepIdentifier
                       resultIdentifier:resultIdentifier];
}


- (instancetype)initWithResultIdentifier:(NSString *)resultIdentifier {
    return [self initWithTaskIdentifier:nil
                         stepIdentifier:nil
                       resultIdentifier:resultIdentifier];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    __typeof(self) resultIdentifier = [[[self class] allocWithZone:zone] initWithTaskIdentifier:_taskIdentifier
                                                                                 stepIdentifier:_stepIdentifier
                                                                               resultIdentifier:_resultIdentifier];
    return resultIdentifier;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(_taskIdentifier, castObject.taskIdentifier)
            && ORKEqualObjects(_stepIdentifier, castObject.stepIdentifier)
            && ORKEqualObjects(_resultIdentifier, castObject.resultIdentifier));
}

- (NSUInteger)hash {
    return [_taskIdentifier hash] ^ [_stepIdentifier hash] ^ [_resultIdentifier hash];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, taskIdentifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, stepIdentifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, resultIdentifier, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, taskIdentifier);
    ORK_ENCODE_OBJ(aCoder, stepIdentifier);
    ORK_ENCODE_OBJ(aCoder, resultIdentifier);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%@, %@, %@}",
            _taskIdentifier ? _taskIdentifier : @"<currentTask>",
            _stepIdentifier ? _stepIdentifier : _resultIdentifier,
            _resultIdentifier];
}

@end


@implementation ORKResultPredicate

+ (NSPredicate *)predicateMatchingResultIdentifier:(ORKResultIdentifier *)resultIdentifierObject
                           subPredicateFormatArray:(NSArray *)subPredicateFormatArray
                   subPredicateFormatArgumentArray:(NSArray *)subPredicateFormatArgumentArray
                    areSubPredicateFormatsSubquery:(BOOL)areSubPredicateFormatsSubquery {
    ORKThrowInvalidArgumentExceptionIfNil(resultIdentifierObject);

    NSString *taskIdentifier = resultIdentifierObject.taskIdentifier;
    NSString *stepIdentifier = resultIdentifierObject.stepIdentifier;
    NSString *resultIdentifier = resultIdentifierObject.resultIdentifier;
    
    if (!stepIdentifier) {
        stepIdentifier = resultIdentifier;
    }
    
    NSMutableString *format = [[NSMutableString alloc] init];
    NSMutableArray *formatArgumentArray = [[NSMutableArray alloc] init];
    
    // Match task identifier

    if (taskIdentifier) {
        [format appendString:@"SUBQUERY(SELF, $x, $x.identifier == %@"];
        [formatArgumentArray addObject:taskIdentifier];
    } else {
        // If taskIdentifier is nil, ORKPredicateStepNavigationRule will substitute the
        // ORKResultPredicateTaskIdentifierSubstitutionVariableName variable by the identifier of the ongoing task
        [format appendFormat:@"SUBQUERY(SELF, $x, $x.identifier == $%@", ORKResultPredicateTaskIdentifierVariableName];
    }
    
    {
        // Match question result identifier
        [format appendString:@" AND SUBQUERY($x.results, $y, $y.identifier == %@ AND SUBQUERY($y.results, $z, $z.identifier == %@"];
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

+ (NSPredicate *)predicateMatchingResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                           subPredicateFormatArray:(NSArray *)subPredicateFormatArray
                   subPredicateFormatArgumentArray:(NSArray *)subPredicateFormatArgumentArray {
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:subPredicateFormatArray
                   subPredicateFormatArgumentArray:subPredicateFormatArgumentArray
                    areSubPredicateFormatsSubquery:NO];
}

+ (NSPredicate *)predicateForNilQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier {
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:@[ @"answer == nil" ]
                   subPredicateFormatArgumentArray:@[ ]];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                      expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                                        expectedAnswer:expectedAnswer];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                            maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                          minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForScaleQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                          maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
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
    @"answer, $w, $w == %@";
    
    for (NSInteger i = 0; i < [expectedAnswers count]; i++) {
        [subPredicateFormatArray addObject:repeatingSubPredicateFormat];
    }
    
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:subPredicateFormatArray
                   subPredicateFormatArgumentArray:expectedAnswers
                    areSubPredicateFormatsSubquery:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                  expectedAnswerValue:(id<NSCopying, NSCoding, NSObject>)expectedAnswerValue {
    return [self predicateForChoiceQuestionResultWithResultIdentifier:resultIdentifier
                                                      expectedAnswers:@[ expectedAnswerValue ]
                                                          usePatterns:NO];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                 expectedAnswerValues:(NSArray<id<NSCopying, NSCoding, NSObject>> *)expectedAnswerValues {
    return [self predicateForChoiceQuestionResultWithResultIdentifier:resultIdentifier
                                                      expectedAnswers:expectedAnswerValues
                                                          usePatterns:NO];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                      matchingPattern:(NSString *)pattern {
    return [self predicateForChoiceQuestionResultWithResultIdentifier:resultIdentifier
                                                      expectedAnswers:@[ pattern ]
                                                          usePatterns:YES];
}

+ (NSPredicate *)predicateForChoiceQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                     matchingPatterns:(NSArray<NSString *> *)patterns {
    return [self predicateForChoiceQuestionResultWithResultIdentifier:resultIdentifier
                                                      expectedAnswers:patterns
                                                          usePatterns:YES];
}

+ (NSPredicate *)predicateForBooleanQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                        expectedAnswer:(BOOL)expectedAnswer {
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:@[ @"answer == %@" ]
                   subPredicateFormatArgumentArray:@[ @(expectedAnswer) ]];
}

+ (NSPredicate *)predicateForTextQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                     expectedString:(NSString *)expectedString {
    ORKThrowInvalidArgumentExceptionIfNil(expectedString);
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:@[ @"answer == %@" ]
                   subPredicateFormatArgumentArray:@[ expectedString ]];
}

+ (NSPredicate *)predicateForTextQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                    matchingPattern:(NSString *)pattern {
    ORKThrowInvalidArgumentExceptionIfNil(pattern);
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:@[ @"answer matches %@" ]
                   subPredicateFormatArgumentArray:@[ pattern ]];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                        expectedAnswer:(NSInteger)expectedAnswer {
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:@[ @"answer == %@" ]
                   subPredicateFormatArgumentArray:@[ @(expectedAnswer) ]];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
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
    
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:subPredicateFormatArray
                   subPredicateFormatArgumentArray:subPredicateFormatArgumentArray];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                            minimumExpectedAnswerValue:(double)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                            maximumExpectedAnswerValue:ORKIgnoreDoubleValue];
}

+ (NSPredicate *)predicateForNumericQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                            maximumExpectedAnswerValue:(double)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            minimumExpectedAnswerValue:ORKIgnoreDoubleValue
                                            maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeOfDayQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                     minimumExpectedHour:(NSInteger)minimumExpectedHour
                                                   minimumExpectedMinute:(NSInteger)minimumExpectedMinute
                                                     maximumExpectedHour:(NSInteger)maximumExpectedHour
                                                   maximumExpectedMinute:(NSInteger)maximumExpectedMinute {
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:@[ @"answer.hour >= %@",
                                                      @"answer.minute >= %@",
                                                      @"answer.hour <= %@",
                                                      @"answer.minute <= %@" ]
                   subPredicateFormatArgumentArray:@[ @(minimumExpectedHour),
                                                      @(minimumExpectedMinute),
                                                      @(maximumExpectedHour),
                                                      @(maximumExpectedMinute) ]];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                 minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue
                                                 maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            minimumExpectedAnswerValue:minimumExpectedAnswerValue
                                            maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                 minimumExpectedAnswerValue:(NSTimeInterval)minimumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            minimumExpectedAnswerValue:minimumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForTimeIntervalQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
                                                 maximumExpectedAnswerValue:(NSTimeInterval)maximumExpectedAnswerValue {
    return [self predicateForNumericQuestionResultWithResultIdentifier:resultIdentifier
                                            maximumExpectedAnswerValue:maximumExpectedAnswerValue];
}

+ (NSPredicate *)predicateForDateQuestionResultWithResultIdentifier:(ORKResultIdentifier *)resultIdentifier
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
    
    return [self predicateMatchingResultIdentifier:resultIdentifier
                           subPredicateFormatArray:subPredicateFormatArray
                   subPredicateFormatArgumentArray:subPredicateFormatArgumentArray];
}

@end
