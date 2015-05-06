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


#import <XCTest/XCTest.h>
#import <ResearchKit/ResearchKit.h>
#import "ORKHelpers.h"
#import "ORKResult_Private.h"
#import "ORKStepNavigationRule_Private.h"


@interface ORKTaskTests : XCTestCase

@end


@implementation ORKTaskTests {
    NSArray *_orderedTaskStepIdentifiers;
    NSArray *_orderedTaskSteps;
    ORKOrderedTask *_orderedTask;

    NSArray *_navigableOrderedTaskStepIdentifiers;
    NSArray *_navigableOrderedTaskSteps;
    NSMutableDictionary *_stepNavigationRules;
    ORKNavigableOrderedTask *_navigableOrderedTask;
}

ORKDefineStringKey(ORKTHeadacheChoiceValue);
ORKDefineStringKey(ORKTDizinessChoiceValue);
ORKDefineStringKey(ORKTNauseaChoiceValue);

ORKDefineStringKey(ORKTSymptomStepIdentifier);
ORKDefineStringKey(ORKTSeverityStepIdentifier);
ORKDefineStringKey(ORKTBlankStepIdentifier);
ORKDefineStringKey(ORKTSevereHeadacheStepIdentifier);
ORKDefineStringKey(ORKTLightHeadacheStepIdentifier);
ORKDefineStringKey(ORKTOtherSymptomStepIdentifier);
ORKDefineStringKey(ORKTEndStepIdentifier);

ORKDefineStringKey(ORKTOrderedTaskIdentifier);
ORKDefineStringKey(ORKTNavigableOrderedTaskIdentifier);

- (void)getTaskSteps:(out NSArray **)outSteps stepIdentifiers:(out NSArray **)outStepIdentifiers {
    if (outSteps == NULL || outStepIdentifiers == NULL) {
        return;
    }
    
    NSMutableArray *stepIdentifiers = [NSMutableArray new];
    NSMutableArray *steps = [NSMutableArray new];
    
    ORKAnswerFormat *answerFormat = nil;
    NSString *stepIdentifier = nil;
    ORKStep *step = nil;
    
    NSArray *textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Headache" value:ORKTHeadacheChoiceValue],
      [ORKTextChoice choiceWithText:@"Dizziness" value:ORKTDizinessChoiceValue],
      [ORKTextChoice choiceWithText:@"Nausea" value:ORKTNauseaChoiceValue]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    stepIdentifier = ORKTSymptomStepIdentifier;
    step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier title:@"What is your symptom?" answer:answerFormat];
    step.optional = NO;
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    stepIdentifier = ORKTSeverityStepIdentifier;
    step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier title:@"Does your symptom interferes with your daily life?" answer:answerFormat];
    step.optional = NO;
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = ORKTBlankStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"This step is intentionally left blank (you should not see it)";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = ORKTSevereHeadacheStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have a severe headache";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = ORKTLightHeadacheStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have a light headache";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = ORKTOtherSymptomStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have other symptom";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = ORKTEndStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have finished the task";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    *outSteps = steps;
    *outStepIdentifiers = stepIdentifiers;
}

- (void)setUpOrderedTask {
    NSArray *orderedTaskSteps = nil;
    NSArray *orderedTaskStepIdentifiers = nil;
    [self getTaskSteps:&orderedTaskSteps stepIdentifiers:&orderedTaskStepIdentifiers];
    _orderedTaskSteps = orderedTaskSteps;
    _orderedTaskStepIdentifiers = orderedTaskStepIdentifiers;
    
    _orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:ORKTOrderedTaskIdentifier
                                                        steps:ORKArrayCopyObjects(_orderedTaskSteps)]; // deep copy to test step copying and equality
}

- (void)setUpNavigableOrderedTask {
    NSArray *navigableOrderedTaskSteps = nil;
    NSArray *navigableOrderedTaskStepIdentifiers = nil;
    [self getTaskSteps:&navigableOrderedTaskSteps stepIdentifiers:&navigableOrderedTaskStepIdentifiers];
    _navigableOrderedTaskSteps = navigableOrderedTaskSteps;
    _navigableOrderedTaskStepIdentifiers = navigableOrderedTaskStepIdentifiers;

    _navigableOrderedTask = [[ORKNavigableOrderedTask alloc] initWithIdentifier:ORKTNavigableOrderedTaskIdentifier
                                                                          steps:ORKArrayCopyObjects(_navigableOrderedTaskSteps)]; // deep copy to test step copying and equality
    
    // Build navigation rules
    _stepNavigationRules = [NSMutableDictionary new];
    // Individual predicates
    
    // User chose headache at the symptom step
    NSPredicate *predicateHeadache = [ORKResultPredicate predicateForChoiceQuestionResultWithIdentifier:ORKTSymptomStepIdentifier expectedAnswer:ORKTHeadacheChoiceValue];
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'symptom' \
    //                     AND SUBQUERY($x.answer, $y, $y like 'headache').@count > 0).@count > 0"];
    
    // User didn't chose headache at the symptom step
    NSPredicate *predicateNotHeadache = [NSCompoundPredicate notPredicateWithSubpredicate:predicateHeadache];
    
    // User chose YES at the severity step
    NSPredicate *predicateSevereYes = [ORKResultPredicate predicateForBooleanQuestionResultWithIdentifier:ORKTSeverityStepIdentifier expectedAnswer:YES];
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'severity' AND $x.answer == YES).@count > 0"];
    
    // User chose NO at the severity step
    NSPredicate *predicateSevereNo = [ORKResultPredicate predicateForBooleanQuestionResultWithIdentifier:ORKTSeverityStepIdentifier expectedAnswer:NO];
    
    
    // From the "symptom" step, go to "other_symptom" is user didn't chose headache.
    // Otherwise, default to going to next step (when the defaultStepIdentifier argument is omitted,
    // the regular ORKOrderedTask order applies).
    NSMutableArray *resultPredicates = [NSMutableArray new];
    NSMutableArray *matchingStepIdentifiers = [NSMutableArray new];
    
    [resultPredicates addObject:predicateNotHeadache];
    [matchingStepIdentifiers addObject:ORKTOtherSymptomStepIdentifier];
    
    ORKPredicateStepNavigationRule *predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                             matchingStepIdentifiers:matchingStepIdentifiers];
    
    [_navigableOrderedTask addNavigationRule:predicateRule forTriggerStepIdentifier:ORKTSymptomStepIdentifier];
    _stepNavigationRules[ORKTSymptomStepIdentifier] = [predicateRule copy];
    
    // From the "severity" step, go to "severe_headache" or "light_headache" depending on the user answer
    resultPredicates = [NSMutableArray new];
    matchingStepIdentifiers = [NSMutableArray new];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereYes]];
    [resultPredicates addObject:predicate];
    [matchingStepIdentifiers addObject:ORKTSevereHeadacheStepIdentifier];
    
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereNo]];
    [resultPredicates addObject:predicate];
    [matchingStepIdentifiers addObject:ORKTLightHeadacheStepIdentifier];
    
    predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                             matchingStepIdentifiers:matchingStepIdentifiers
                                               defaultStepIdentifier:ORKTOtherSymptomStepIdentifier];
    
    [_navigableOrderedTask addNavigationRule:predicateRule forTriggerStepIdentifier:ORKTSeverityStepIdentifier];
    _stepNavigationRules[ORKTSeverityStepIdentifier] = [predicateRule copy];

    
    // Add end direct rules to skip unneeded steps
    ORKDirectStepNavigationRule *directRule =
    [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKTEndStepIdentifier];
    
    [_navigableOrderedTask addNavigationRule:directRule forTriggerStepIdentifier:ORKTSevereHeadacheStepIdentifier];
    [_navigableOrderedTask addNavigationRule:directRule forTriggerStepIdentifier:ORKTLightHeadacheStepIdentifier];
    [_navigableOrderedTask addNavigationRule:directRule forTriggerStepIdentifier:ORKTOtherSymptomStepIdentifier];
    
    _stepNavigationRules[ORKTSevereHeadacheStepIdentifier] = [directRule copy];
    _stepNavigationRules[ORKTLightHeadacheStepIdentifier] = [directRule copy];
    _stepNavigationRules[ORKTOtherSymptomStepIdentifier] = [directRule copy];
}

typedef NS_OPTIONS(NSUInteger, TestsTaskResultOptions) {
    TestsTaskResultOptionSymptomHeadache    = 1 << 0,
    TestsTaskResultOptionSymptomDiziness    = 2 << 0,
    TestsTaskResultOptionSymptomNausea      = 3 << 0,
    
    TestsTaskResultOptionSeverityYes        = 1 << 2,
    TestsTaskResultOptionSeverityNo         = 2 << 2
};

- (ORKTaskResult *)getResultTreeWithTaskIdentifier:(NSString *)taskIdentifier resultOptions:(TestsTaskResultOptions)resultOptions {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    ORKQuestionResult *questionResult = nil;
    ORKStepResult *stepResult = nil;
    NSString *stepIdentifier = nil;
    
    if (resultOptions & (TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSymptomDiziness | TestsTaskResultOptionSymptomNausea)) {
        stepIdentifier = ORKTSymptomStepIdentifier;
        questionResult = [[ORKChoiceQuestionResult alloc] init];
        questionResult.identifier = stepIdentifier;
        if (resultOptions & TestsTaskResultOptionSymptomHeadache) {
            questionResult.answer = @[ORKTHeadacheChoiceValue];
        } else if (resultOptions & TestsTaskResultOptionSymptomDiziness) {
            questionResult.answer = @[ORKTDizinessChoiceValue];
        } else if (resultOptions & TestsTaskResultOptionSymptomNausea) {
            questionResult.answer = @[ORKTNauseaChoiceValue];
        }
        questionResult.questionType = ORKQuestionTypeSingleChoice;
        
        stepResult = [[ORKStepResult alloc] initWithStepIdentifier:stepIdentifier results:@[questionResult]];
        [stepResults addObject:stepResult];
    }

    if (resultOptions & (TestsTaskResultOptionSeverityYes | TestsTaskResultOptionSeverityNo)) {
        stepIdentifier = ORKTSeverityStepIdentifier;
        questionResult = [[ORKBooleanQuestionResult alloc] init];
        questionResult.identifier = stepIdentifier;
        if (resultOptions & TestsTaskResultOptionSeverityYes) {
            questionResult.answer = @(YES);
        } else if (resultOptions & TestsTaskResultOptionSeverityNo) {
            questionResult.answer = @(NO);
        }
        questionResult.questionType = ORKQuestionTypeSingleChoice;
        
        stepResult = [[ORKStepResult alloc] initWithStepIdentifier:stepIdentifier results:@[questionResult]];
        [stepResults addObject:stepResult];
    }

    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:taskIdentifier
                                                                  taskRunUUID:[NSUUID UUID]
                                                              outputDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    taskResult.results = stepResults;
    
    return taskResult;
}

- (void)setUp {
    [super setUp];
    [self setUpOrderedTask];
    [self setUpNavigableOrderedTask];
}

- (void)testOrderedTask {
    ORKTaskResult *mockTaskResult = [[ORKTaskResult alloc] init];
    
    XCTAssertEqualObjects(_orderedTask.identifier, ORKTOrderedTaskIdentifier);
    XCTAssertEqualObjects(_orderedTask.steps, _orderedTaskSteps);

    NSUInteger expectedTotalProgress = [_orderedTaskSteps count];
    
    for (NSUInteger stepIndex = 0; stepIndex < [_orderedTaskStepIdentifiers count]; stepIndex++) {
        ORKStep *currentStep = _orderedTaskSteps[stepIndex];
        XCTAssertEqualObjects(currentStep, [_orderedTask stepWithIdentifier:_orderedTaskStepIdentifiers[stepIndex]]);

        const NSUInteger expectedCurrentProgress = stepIndex;
        ORKTaskProgress currentProgress = [_orderedTask progressOfCurrentStep:currentStep withResult:mockTaskResult];
        XCTAssertTrue(currentProgress.total == expectedTotalProgress && currentProgress.current == expectedCurrentProgress);
        
        NSString *expectedPreviousStep = (stepIndex != 0) ? _orderedTaskSteps[stepIndex - 1] : nil;
        NSString *expectedNextStep = (stepIndex < [_orderedTaskStepIdentifiers count] - 1) ? _orderedTaskSteps[stepIndex + 1] : nil;
        XCTAssertEqualObjects(expectedPreviousStep, [_orderedTask stepBeforeStep:currentStep withResult:mockTaskResult]);
        XCTAssertEqualObjects(expectedNextStep, [_orderedTask stepAfterStep:currentStep withResult:mockTaskResult]);
    }
}

- (void)testNavigableOrderedTask {
    XCTAssertEqualObjects(_navigableOrderedTask.identifier, ORKTNavigableOrderedTaskIdentifier);
    XCTAssertEqualObjects(_navigableOrderedTask.steps, _navigableOrderedTaskSteps);
    XCTAssertEqualObjects(_navigableOrderedTask.stepNavigationRules, _stepNavigationRules);
    
    ORKStep *symptomStep = _navigableOrderedTaskSteps[0];
    ORKStep *severityStep = _navigableOrderedTaskSteps[1];
    ORKStep *blankStep = _navigableOrderedTaskSteps[2];
    ORKStep *severeHeadacheStep = _navigableOrderedTaskSteps[3];
    ORKStep *lightHeadacheStep = _navigableOrderedTaskSteps[4];
    ORKStep *otherSymptomStep = _navigableOrderedTaskSteps[5];
    ORKStep *endStep = _navigableOrderedTaskSteps[6];

    ORKTaskResult *taskResult = nil;

    BOOL (^testStepAfterStep)(ORKNavigableOrderedTask *, ORKTaskResult *, ORKStep *, ORKStep *) =  ^BOOL(ORKNavigableOrderedTask *task, ORKTaskResult *taskResult, ORKStep *fromStep, ORKStep *expectedStep) {
        ORKStep *testedStep = [task stepAfterStep:fromStep withResult:taskResult];
        return (testedStep == nil && expectedStep == nil) || [testedStep isEqual:expectedStep];
    };

    BOOL (^testStepBeforeStep)(ORKNavigableOrderedTask *, ORKTaskResult *, ORKStep *, ORKStep *) =  ^BOOL(ORKNavigableOrderedTask *task, ORKTaskResult *taskResult, ORKStep *fromStep, ORKStep *expectedStep) {
        ORKStep *testedStep = [task stepBeforeStep:fromStep withResult:taskResult];
        return (testedStep == nil && expectedStep == nil) || [testedStep isEqual:expectedStep];
    };

    //
    // Empty task result
    //
    taskResult = [self getResultTreeWithTaskIdentifier:ORKTNavigableOrderedTaskIdentifier resultOptions:0];
    
    // Test forward navigation
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, symptomStep, otherSymptomStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, otherSymptomStep, endStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, endStep, nil));

    // Test backward navigation
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, otherSymptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, otherSymptomStep, symptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, symptomStep, nil));
    
    // Test unreachable node (will reset navigation stack)
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, severityStep, otherSymptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, otherSymptomStep, severityStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, severityStep, nil));

    // Test unreachable node (will reset navigation stack)
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, blankStep, severeHeadacheStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, severeHeadacheStep, endStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, severeHeadacheStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, severeHeadacheStep, blankStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, blankStep, nil));

    // Test unreachable node (will reset navigation stack)
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, lightHeadacheStep, endStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, lightHeadacheStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, lightHeadacheStep, nil));

    //
    // Only headache symptom question step answered
    //
    taskResult = [self getResultTreeWithTaskIdentifier:ORKTNavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache];

    // Test forward navigation
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, symptomStep, severityStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, severityStep, otherSymptomStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, otherSymptomStep, endStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, endStep, nil));
    
    // Test backward navigation
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, otherSymptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, otherSymptomStep, severityStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, severityStep, symptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, symptomStep, nil));

    //
    // Only diziness symptom question answered
    //
    taskResult = [self getResultTreeWithTaskIdentifier:ORKTNavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomDiziness];
    
    // Test forward navigation
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, symptomStep, otherSymptomStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, otherSymptomStep, endStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, endStep, nil));
    
    // Test backward navigation
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, otherSymptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, otherSymptomStep, symptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, symptomStep, nil));

    //
    // Severe headache sequence
    //
    taskResult = [self getResultTreeWithTaskIdentifier:ORKTNavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSeverityYes];
    
    // Test forward navigation
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, symptomStep, severityStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, severityStep, severeHeadacheStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, severeHeadacheStep, endStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, endStep, nil));
    
    // Test backward navigation
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, severeHeadacheStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, severeHeadacheStep, severityStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, severityStep, symptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, symptomStep, nil));

    //
    // Light headache sequence
    //
    taskResult = [self getResultTreeWithTaskIdentifier:ORKTNavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSeverityNo];
    
    // Test forward navigation
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, symptomStep, severityStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, severityStep, lightHeadacheStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, lightHeadacheStep, endStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, endStep, nil));
    
    // Test backward navigation
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, lightHeadacheStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, lightHeadacheStep, severityStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, severityStep, symptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, symptomStep, nil));
}

ORKDefineStringKey(ORKTScaleStepIdentifier);
ORKDefineStringKey(ORKTContinuousScaleStepIdentifier);
static const NSInteger ORKTIntegerValue = 6;
static const NSInteger ORKTFloatValue = 6.5;

ORKDefineStringKey(ORKTSingleChoiceStepIdentifier);
ORKDefineStringKey(ORKTMultipleChoiceStepIdentifier);
ORKDefineStringKey(ORKTSingleChoiceValue);
ORKDefineStringKey(ORKTMultipleChoiceValue1);
ORKDefineStringKey(ORKTMultipleChoiceValue2);

ORKDefineStringKey(ORKTBooleanStepIdentifier);
static const BOOL ORKTBooleanValue = YES;

ORKDefineStringKey(ORKTTextStepIdentifier);
ORKDefineStringKey(ORKTTextValue);
ORKDefineStringKey(ORKTOtherTextValue);

ORKDefineStringKey(ORKTIntegerNumericStepIdentifier);
ORKDefineStringKey(ORKTFloatNumericStepIdentifier);

ORKDefineStringKey(ORKTTimeOfDayStepIdentifier);
ORKDefineStringKey(ORKTTimeIntervalStepIdentifier);
ORKDefineStringKey(ORKTDateStepIdentifier);
static NSDate *(^ORKTDate)() = ^NSDate *{ return [NSDate dateWithTimeIntervalSince1970:60*60*24]; };
static NSDateComponents *(^ORKTDateComponents)() = ^NSDateComponents *{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.hour = 6;
    dateComponents.minute = 6;
    return dateComponents;
};

- (ORKTaskResult *)getGeneralTaskResultTree {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    ORKStepResult *(^getStepResult)(NSString *, Class, ORKQuestionType, id) = ^ORKStepResult *(NSString *stepIdentifier, Class choiceQuestionResultClass, ORKQuestionType questionType, id answer) {
        ORKQuestionResult *questionResult = [[choiceQuestionResultClass alloc] init];
        questionResult.identifier = stepIdentifier;
        questionResult.answer = answer;
        questionResult.questionType = questionType;
        
        ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:stepIdentifier results:@[questionResult]];
        return stepResult;
    };

    [stepResults addObject:getStepResult(ORKTScaleStepIdentifier, [ORKScaleQuestionResult class], ORKQuestionTypeScale, @(ORKTIntegerValue))];
    [stepResults addObject:getStepResult(ORKTContinuousScaleStepIdentifier, [ORKScaleQuestionResult class], ORKQuestionTypeScale, @(ORKTFloatValue))];

    [stepResults addObject:getStepResult(ORKTSingleChoiceStepIdentifier, [ORKChoiceQuestionResult class], ORKQuestionTypeSingleChoice, @[ORKTSingleChoiceValue])];
    [stepResults addObject:getStepResult(ORKTMultipleChoiceStepIdentifier, [ORKChoiceQuestionResult class], ORKQuestionTypeMultipleChoice, @[ORKTMultipleChoiceValue1, ORKTMultipleChoiceValue2])];

    [stepResults addObject:getStepResult(ORKTBooleanStepIdentifier, [ORKBooleanQuestionResult class], ORKQuestionTypeBoolean, @(ORKTBooleanValue))];

    [stepResults addObject:getStepResult(ORKTTextStepIdentifier, [ORKTextQuestionResult class], ORKQuestionTypeText, ORKTTextValue)];

    [stepResults addObject:getStepResult(ORKTIntegerNumericStepIdentifier, [ORKNumericQuestionResult class], ORKQuestionTypeInteger, @(ORKTIntegerValue))];
    [stepResults addObject:getStepResult(ORKTFloatNumericStepIdentifier, [ORKNumericQuestionResult class], ORKQuestionTypeDecimal, @(ORKTFloatValue))];

    [stepResults addObject:getStepResult(ORKTDateStepIdentifier, [ORKDateQuestionResult class], ORKQuestionTypeDate, ORKTDate())];

    [stepResults addObject:getStepResult(ORKTTimeIntervalStepIdentifier, [ORKTimeIntervalQuestionResult class], ORKQuestionTypeTimeInterval, @(ORKTIntegerValue))];

    [stepResults addObject:getStepResult(ORKTTimeOfDayStepIdentifier, [ORKTimeOfDayQuestionResult class], ORKQuestionTypeTimeOfDay, ORKTDateComponents())];

    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:ORKTOrderedTaskIdentifier
                                                                  taskRunUUID:[NSUUID UUID]
                                                              outputDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    taskResult.results = stepResults;
    
    return taskResult;
}

- (void)testResultPredicates {
    // Get leaf results
    ORKTaskResult *taskResult = [self getGeneralTaskResultTree];
    NSArray *leafResults = [ORKPredicateStepNavigationRule getLeafResultsWithTaskResult:taskResult];

    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithIdentifier:ORKTScaleStepIdentifier
                                                                      expectedAnswer:ORKTIntegerValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithIdentifier:ORKTScaleStepIdentifier
                                                                       expectedAnswer:ORKTIntegerValue + 1] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithIdentifier:ORKTContinuousScaleStepIdentifier
                                                          minimumExpectedAnswerValue:ORKTFloatValue - 0.01
                                                          maximumExpectedAnswerValue:ORKTFloatValue + 0.01] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithIdentifier:ORKTContinuousScaleStepIdentifier
                                                           minimumExpectedAnswerValue:ORKTFloatValue + 0.05
                                                           maximumExpectedAnswerValue:ORKTFloatValue + 0.06] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithIdentifier:ORKTSingleChoiceStepIdentifier
                                                                       expectedAnswer:ORKTSingleChoiceValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithIdentifier:ORKTSingleChoiceStepIdentifier
                                                                        expectedAnswer:ORKTOtherTextValue] evaluateWithObject:leafResults]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithIdentifier:ORKTScaleStepIdentifier
                                                                      expectedAnswer:ORKTIntegerValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithIdentifier:ORKTScaleStepIdentifier
                                                                       expectedAnswer:ORKTIntegerValue + 1] evaluateWithObject:leafResults]);

    NSArray *expectedAnswers = nil;
    expectedAnswers = @[ORKTMultipleChoiceValue1, ORKTMultipleChoiceValue2];
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithIdentifier:ORKTMultipleChoiceStepIdentifier
                                                                      expectedAnswers:expectedAnswers] evaluateWithObject:leafResults]);
    expectedAnswers = @[ORKTMultipleChoiceValue1, ORKTMultipleChoiceValue2, ORKTOtherTextValue];
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithIdentifier:ORKTMultipleChoiceStepIdentifier
                                                                       expectedAnswers:expectedAnswers] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForBooleanQuestionResultWithIdentifier:ORKTBooleanStepIdentifier
                                                                        expectedAnswer:ORKTBooleanValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForBooleanQuestionResultWithIdentifier:ORKTBooleanStepIdentifier
                                                                         expectedAnswer:!ORKTBooleanValue] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForTextQuestionResultWithIdentifier:ORKTTextStepIdentifier
                                                                     expectedAnswer:ORKTTextValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForTextQuestionResultWithIdentifier:ORKTTextStepIdentifier
                                                                      expectedAnswer:ORKTOtherTextValue] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithIdentifier:ORKTIntegerNumericStepIdentifier
                                                                        expectedAnswer:ORKTIntegerValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithIdentifier:ORKTIntegerNumericStepIdentifier
                                                                         expectedAnswer:ORKTIntegerValue + 1] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithIdentifier:ORKTFloatNumericStepIdentifier
                                                            minimumExpectedAnswerValue:ORKTFloatValue - 0.01
                                                            maximumExpectedAnswerValue:ORKTFloatValue + 0.01] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithIdentifier:ORKTFloatNumericStepIdentifier
                                                             minimumExpectedAnswerValue:ORKTFloatValue + 0.05
                                                             maximumExpectedAnswerValue:ORKTFloatValue + 0.06] evaluateWithObject:leafResults]);

    NSDateComponents *expectedDateComponentsMinimum = ORKTDateComponents();
    NSDateComponents *expectedDateComponentsMaximum = ORKTDateComponents();
    XCTAssertTrue([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithIdentifier:ORKTTimeOfDayStepIdentifier
                                                               minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                             minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                               maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                             maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:leafResults]);
    expectedDateComponentsMinimum.minute -= 2;
    expectedDateComponentsMaximum.minute += 2;
    XCTAssertTrue([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithIdentifier:ORKTTimeOfDayStepIdentifier
                                                               minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                             minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                               maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                             maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:leafResults]);
    
    expectedDateComponentsMinimum.minute += 3;
    XCTAssertFalse([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithIdentifier:ORKTTimeOfDayStepIdentifier
                                                                minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                              minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                              maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:leafResults]);

    expectedDateComponentsMinimum.minute -= 3;
    expectedDateComponentsMinimum.hour += 1;
    expectedDateComponentsMaximum.hour += 2;
    XCTAssertFalse([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithIdentifier:ORKTTimeOfDayStepIdentifier
                                                                minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                              minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                              maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:leafResults]);

    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithIdentifier:ORKTTimeIntervalStepIdentifier
                                                                             expectedAnswer:ORKTIntegerValue] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithIdentifier:ORKTTimeIntervalStepIdentifier
                                                                              expectedAnswer:ORKTIntegerValue + 1] evaluateWithObject:leafResults]);

    NSDate *expectedDate = ORKTDate();
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithIdentifier:ORKTDateStepIdentifier
                                                          minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-60]
                                                          maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:60]] evaluateWithObject:leafResults]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithIdentifier:ORKTDateStepIdentifier
                                                           minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]
                                                           maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+120]] evaluateWithObject:leafResults]);
}

@end
