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
#import "ORKStepNavigationRule_Internal.h"


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

ORKDefineStringKey(HeadacheChoiceValue);
ORKDefineStringKey(DizzinessChoiceValue);
ORKDefineStringKey(NauseaChoiceValue);

ORKDefineStringKey(SymptomStepIdentifier);
ORKDefineStringKey(SeverityStepIdentifier);
ORKDefineStringKey(BlankStepIdentifier);
ORKDefineStringKey(SevereHeadacheStepIdentifier);
ORKDefineStringKey(LightHeadacheStepIdentifier);
ORKDefineStringKey(OtherSymptomStepIdentifier);
ORKDefineStringKey(EndStepIdentifier);
ORKDefineStringKey(BlankBStepIdentifier);

ORKDefineStringKey(OrderedTaskIdentifier);
ORKDefineStringKey(NavigableOrderedTaskIdentifier);

- (void)generateTaskSteps:(out NSArray **)outSteps stepIdentifiers:(out NSArray **)outStepIdentifiers {
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
      [ORKTextChoice choiceWithText:@"Headache" value:HeadacheChoiceValue],
      [ORKTextChoice choiceWithText:@"Dizziness" value:DizzinessChoiceValue],
      [ORKTextChoice choiceWithText:@"Nausea" value:NauseaChoiceValue]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    stepIdentifier = SymptomStepIdentifier;
    step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier title:@"What is your symptom?" answer:answerFormat];
    step.optional = NO;
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    stepIdentifier = SeverityStepIdentifier;
    step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier title:@"Does your symptom interferes with your daily life?" answer:answerFormat];
    step.optional = NO;
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = BlankStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"This step is intentionally left blank (you should not see it)";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = SevereHeadacheStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have a severe headache";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = LightHeadacheStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have a light headache";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = OtherSymptomStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have other symptom";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = EndStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have finished the task";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];
    
    stepIdentifier = BlankBStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"This step is intentionally left blank (you should not see it)";
    [stepIdentifiers addObject:stepIdentifier];
    [steps addObject:step];

    *outSteps = steps;
    *outStepIdentifiers = stepIdentifiers;
}

- (void)setUpOrderedTask {
    NSArray *orderedTaskSteps = nil;
    NSArray *orderedTaskStepIdentifiers = nil;
    [self generateTaskSteps:&orderedTaskSteps stepIdentifiers:&orderedTaskStepIdentifiers];
    _orderedTaskSteps = orderedTaskSteps;
    _orderedTaskStepIdentifiers = orderedTaskStepIdentifiers;
    
    _orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:OrderedTaskIdentifier
                                                        steps:ORKArrayCopyObjects(_orderedTaskSteps)]; // deep copy to test step copying and equality
}

- (void)setUpNavigableOrderedTask {
    NSArray *navigableOrderedTaskSteps = nil;
    NSArray *navigableOrderedTaskStepIdentifiers = nil;
    [self generateTaskSteps:&navigableOrderedTaskSteps stepIdentifiers:&navigableOrderedTaskStepIdentifiers];
    _navigableOrderedTaskSteps = navigableOrderedTaskSteps;
    _navigableOrderedTaskStepIdentifiers = navigableOrderedTaskStepIdentifiers;

    _navigableOrderedTask = [[ORKNavigableOrderedTask alloc] initWithIdentifier:NavigableOrderedTaskIdentifier
                                                                          steps:ORKArrayCopyObjects(_navigableOrderedTaskSteps)]; // deep copy to test step copying and equality
    
    // Build navigation rules
    _stepNavigationRules = [NSMutableDictionary new];
    // Individual predicates
    
    // User chose headache at the symptom step
    NSPredicate *predicateHeadache = [ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:SymptomStepIdentifier
                                                                                               expectedString:HeadacheChoiceValue];
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'symptom' \
    //                     AND SUBQUERY($x.answer, $y, $y like 'headache').@count > 0).@count > 0"];
    
    // User didn't chose headache at the symptom step
    NSPredicate *predicateNotHeadache = [NSCompoundPredicate notPredicateWithSubpredicate:predicateHeadache];
    
    // User chose YES at the severity step
    NSPredicate *predicateSevereYes = [ORKResultPredicate predicateForBooleanQuestionResultWithResultIdentifier:SeverityStepIdentifier
                                                                                                 expectedAnswer:YES];
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'severity' AND $x.answer == YES).@count > 0"];
    
    // User chose NO at the severity step
    NSPredicate *predicateSevereNo = [ORKResultPredicate predicateForBooleanQuestionResultWithResultIdentifier:SeverityStepIdentifier
                                                                                                expectedAnswer:NO];
    
    
    // From the "symptom" step, go to "other_symptom" is user didn't chose headache.
    // Otherwise, default to going to next step (when the defaultStepIdentifier argument is omitted,
    // the regular ORKOrderedTask order applies).
    NSMutableArray *resultPredicates = [NSMutableArray new];
    NSMutableArray *destinationStepIdentifiers = [NSMutableArray new];
    
    [resultPredicates addObject:predicateNotHeadache];
    [destinationStepIdentifiers addObject:OtherSymptomStepIdentifier];
    
    ORKPredicateStepNavigationRule *predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                          destinationStepIdentifiers:destinationStepIdentifiers];
    
    [_navigableOrderedTask setNavigationRule:predicateRule forTriggerStepIdentifier:SymptomStepIdentifier];
    _stepNavigationRules[SymptomStepIdentifier] = [predicateRule copy];
    
    // From the "severity" step, go to "severe_headache" or "light_headache" depending on the user answer
    resultPredicates = [NSMutableArray new];
    destinationStepIdentifiers = [NSMutableArray new];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereYes]];
    [resultPredicates addObject:predicate];
    [destinationStepIdentifiers addObject:SevereHeadacheStepIdentifier];
    
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereNo]];
    [resultPredicates addObject:predicate];
    [destinationStepIdentifiers addObject:LightHeadacheStepIdentifier];
    
    predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                          destinationStepIdentifiers:destinationStepIdentifiers
                                               defaultStepIdentifier:OtherSymptomStepIdentifier];
    
    [_navigableOrderedTask setNavigationRule:predicateRule forTriggerStepIdentifier:SeverityStepIdentifier];
    _stepNavigationRules[SeverityStepIdentifier] = [predicateRule copy];

    
    // Add end direct rules to skip unneeded steps
    ORKDirectStepNavigationRule *directRule = nil;
    
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:EndStepIdentifier];
    
    [_navigableOrderedTask setNavigationRule:directRule forTriggerStepIdentifier:SevereHeadacheStepIdentifier];
    [_navigableOrderedTask setNavigationRule:directRule forTriggerStepIdentifier:LightHeadacheStepIdentifier];
    [_navigableOrderedTask setNavigationRule:directRule forTriggerStepIdentifier:OtherSymptomStepIdentifier];
    
    _stepNavigationRules[SevereHeadacheStepIdentifier] = [directRule copy];
    _stepNavigationRules[LightHeadacheStepIdentifier] = [directRule copy];
    _stepNavigationRules[OtherSymptomStepIdentifier] = [directRule copy];
    
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
    [_navigableOrderedTask setNavigationRule:directRule forTriggerStepIdentifier:EndStepIdentifier];
    _stepNavigationRules[EndStepIdentifier] = [directRule copy];
}

typedef NS_OPTIONS(NSUInteger, TestsTaskResultOptions) {
    TestsTaskResultOptionSymptomHeadache    = 1 << 0,
    TestsTaskResultOptionSymptomDizziness   = 2 << 0,
    TestsTaskResultOptionSymptomNausea      = 3 << 0,
    
    TestsTaskResultOptionSeverityYes        = 1 << 2,
    TestsTaskResultOptionSeverityNo         = 2 << 2
};

- (ORKTaskResult *)getResultTreeWithTaskIdentifier:(NSString *)taskIdentifier resultOptions:(TestsTaskResultOptions)resultOptions {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    ORKQuestionResult *questionResult = nil;
    ORKStepResult *stepResult = nil;
    NSString *stepIdentifier = nil;
    
    if (resultOptions & (TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSymptomDizziness | TestsTaskResultOptionSymptomNausea)) {
        stepIdentifier = SymptomStepIdentifier;
        questionResult = [[ORKChoiceQuestionResult alloc] init];
        questionResult.identifier = stepIdentifier;
        if (resultOptions & TestsTaskResultOptionSymptomHeadache) {
            questionResult.answer = @[HeadacheChoiceValue];
        } else if (resultOptions & TestsTaskResultOptionSymptomDizziness) {
            questionResult.answer = @[DizzinessChoiceValue];
        } else if (resultOptions & TestsTaskResultOptionSymptomNausea) {
            questionResult.answer = @[NauseaChoiceValue];
        }
        questionResult.questionType = ORKQuestionTypeSingleChoice;
        
        stepResult = [[ORKStepResult alloc] initWithStepIdentifier:stepIdentifier results:@[questionResult]];
        [stepResults addObject:stepResult];
    }

    if (resultOptions & (TestsTaskResultOptionSeverityYes | TestsTaskResultOptionSeverityNo)) {
        stepIdentifier = SeverityStepIdentifier;
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
    
    XCTAssertEqualObjects(_orderedTask.identifier, OrderedTaskIdentifier);
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
    
    // Test duplicate step identifier validation
    XCTAssertNoThrow([_orderedTask validateParameters]);

    NSMutableArray *steps = [[NSMutableArray alloc] initWithArray:ORKArrayCopyObjects(_orderedTaskSteps)];
    ORKStep *step = [[ORKInstructionStep alloc] initWithIdentifier:BlankStepIdentifier];
    [steps addObject:step];
    
    ORKOrderedTask *orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:OrderedTaskIdentifier
                                                                       steps:steps];
    XCTAssertThrows([orderedTask validateParameters]);
}

#define getIndividualNavigableOrderedTaskSteps() \
    __unused ORKStep *symptomStep = _navigableOrderedTaskSteps[0];\
    __unused ORKStep *severityStep = _navigableOrderedTaskSteps[1];\
    __unused ORKStep *blankStep = _navigableOrderedTaskSteps[2];\
    __unused ORKStep *severeHeadacheStep = _navigableOrderedTaskSteps[3];\
    __unused ORKStep *lightHeadacheStep = _navigableOrderedTaskSteps[4];\
    __unused ORKStep *otherSymptomStep = _navigableOrderedTaskSteps[5];\
    __unused ORKStep *endStep = _navigableOrderedTaskSteps[6];

BOOL (^testStepAfterStep)(ORKNavigableOrderedTask *, ORKTaskResult *, ORKStep *, ORKStep *) =  ^BOOL(ORKNavigableOrderedTask *task, ORKTaskResult *taskResult, ORKStep *fromStep, ORKStep *expectedStep) {
    ORKStep *testedStep = [task stepAfterStep:fromStep withResult:taskResult];
    return (testedStep == nil && expectedStep == nil) || [testedStep isEqual:expectedStep];
};

BOOL (^testStepBeforeStep)(ORKNavigableOrderedTask *, ORKTaskResult *, ORKStep *, ORKStep *) =  ^BOOL(ORKNavigableOrderedTask *task, ORKTaskResult *taskResult, ORKStep *fromStep, ORKStep *expectedStep) {
    ORKStep *testedStep = [task stepBeforeStep:fromStep withResult:taskResult];
    return (testedStep == nil && expectedStep == nil) || [testedStep isEqual:expectedStep];
};

- (void)testNavigableOrderedTask {
    XCTAssertEqualObjects(_navigableOrderedTask.identifier, NavigableOrderedTaskIdentifier);
    XCTAssertEqualObjects(_navigableOrderedTask.steps, _navigableOrderedTaskSteps);
    XCTAssertEqualObjects(_navigableOrderedTask.stepNavigationRules, _stepNavigationRules);

    for (NSString *triggerStepIdentifier in [_stepNavigationRules allKeys]) {
        XCTAssertEqualObjects(_stepNavigationRules[triggerStepIdentifier], [_navigableOrderedTask navigationRuleForTriggerStepIdentifier:triggerStepIdentifier]);
    }
    
    ORKDefineStringKey(MockTriggerStepIdentifier);
    ORKDefineStringKey(MockDestinationStepIdentifier);

    // Test adding and removing a step navigation rule
    XCTAssertNil([_navigableOrderedTask navigationRuleForTriggerStepIdentifier:MockTriggerStepIdentifier]);

    ORKDirectStepNavigationRule *mockNavigationRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:MockDestinationStepIdentifier];
    [_navigableOrderedTask setNavigationRule:mockNavigationRule forTriggerStepIdentifier:MockTriggerStepIdentifier];
 
    XCTAssertEqualObjects([_navigableOrderedTask navigationRuleForTriggerStepIdentifier:MockTriggerStepIdentifier], [mockNavigationRule copy]);
    
    [_navigableOrderedTask removeNavigationRuleForTriggerStepIdentifier:MockTriggerStepIdentifier];
    XCTAssertNil([_navigableOrderedTask navigationRuleForTriggerStepIdentifier:MockTriggerStepIdentifier]);
}

- (void)testNavigableOrderedTaskEmpty {
    getIndividualNavigableOrderedTaskSteps();

    //
    // Empty task result
    //
    ORKTaskResult *taskResult = [self getResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:0];
    
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
}

- (void)testNavigableOrderedTaskHeadache {
    getIndividualNavigableOrderedTaskSteps();

    //
    // Only headache symptom question step answered
    //
    ORKTaskResult *taskResult = [self getResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache];

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
}

- (void)testNavigableOrderedTaskDizziness {
    getIndividualNavigableOrderedTaskSteps();
    
    //
    // Only dizziness symptom question answered
    //
    ORKTaskResult *taskResult = [self getResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomDizziness];
    
    // Test forward navigation
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, symptomStep, otherSymptomStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, otherSymptomStep, endStep));
    XCTAssertTrue(testStepAfterStep(_navigableOrderedTask, taskResult, endStep, nil));
    
    // Test backward navigation
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, endStep, otherSymptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, otherSymptomStep, symptomStep));
    XCTAssertTrue(testStepBeforeStep(_navigableOrderedTask, taskResult, symptomStep, nil));
}

- (void)testNavigableOrderedTaskSevereHeadache {
    getIndividualNavigableOrderedTaskSteps();
    
    //
    // Severe headache sequence
    //
    ORKTaskResult *taskResult = [self getResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSeverityYes];
    
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
}

- (void)testNavigableOrderedTaskLightHeadache {
    getIndividualNavigableOrderedTaskSteps();
    
    //
    // Light headache sequence
    //
    ORKTaskResult *taskResult = [self getResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSeverityNo];
    
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

ORKDefineStringKey(ScaleStepIdentifier);
ORKDefineStringKey(ContinuousScaleStepIdentifier);
static const NSInteger IntegerValue = 6;
static const float FloatValue = 6.5;

ORKDefineStringKey(SingleChoiceStepIdentifier);
ORKDefineStringKey(MultipleChoiceStepIdentifier);
ORKDefineStringKey(SingleChoiceValue);
ORKDefineStringKey(MultipleChoiceValue1);
ORKDefineStringKey(MultipleChoiceValue2);

ORKDefineStringKey(BooleanStepIdentifier);
static const BOOL BooleanValue = YES;

ORKDefineStringKey(TextStepIdentifier);
ORKDefineStringKey(TextValue);
ORKDefineStringKey(OtherTextValue);

ORKDefineStringKey(IntegerNumericStepIdentifier);
ORKDefineStringKey(FloatNumericStepIdentifier);

ORKDefineStringKey(TimeOfDayStepIdentifier);
ORKDefineStringKey(TimeIntervalStepIdentifier);
ORKDefineStringKey(DateStepIdentifier);
static NSDate *(^Date)() = ^NSDate *{ return [NSDate dateWithTimeIntervalSince1970:60*60*24]; };
static NSDateComponents *(^DateComponents)() = ^NSDateComponents *{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.hour = 6;
    dateComponents.minute = 6;
    return dateComponents;
};

static ORKStepResult *(^getStepResult)(NSString *, Class, ORKQuestionType, id) = ^ORKStepResult *(NSString *stepIdentifier, Class choiceQuestionResultClass, ORKQuestionType questionType, id answer) {
    ORKQuestionResult *questionResult = [[choiceQuestionResultClass alloc] init];
    questionResult.identifier = stepIdentifier;
    questionResult.answer = answer;
    questionResult.questionType = questionType;
    
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:stepIdentifier results:@[questionResult]];
    return stepResult;
};

- (ORKTaskResult *)getGeneralTaskResultTree {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    [stepResults addObject:getStepResult(ScaleStepIdentifier, [ORKScaleQuestionResult class], ORKQuestionTypeScale, @(IntegerValue))];
    [stepResults addObject:getStepResult(ContinuousScaleStepIdentifier, [ORKScaleQuestionResult class], ORKQuestionTypeScale, @(FloatValue))];

    [stepResults addObject:getStepResult(SingleChoiceStepIdentifier, [ORKChoiceQuestionResult class], ORKQuestionTypeSingleChoice, @[SingleChoiceValue])];
    [stepResults addObject:getStepResult(MultipleChoiceStepIdentifier, [ORKChoiceQuestionResult class], ORKQuestionTypeMultipleChoice, @[MultipleChoiceValue1, MultipleChoiceValue2])];

    [stepResults addObject:getStepResult(BooleanStepIdentifier, [ORKBooleanQuestionResult class], ORKQuestionTypeBoolean, @(BooleanValue))];

    [stepResults addObject:getStepResult(TextStepIdentifier, [ORKTextQuestionResult class], ORKQuestionTypeText, TextValue)];

    [stepResults addObject:getStepResult(IntegerNumericStepIdentifier, [ORKNumericQuestionResult class], ORKQuestionTypeInteger, @(IntegerValue))];
    [stepResults addObject:getStepResult(FloatNumericStepIdentifier, [ORKNumericQuestionResult class], ORKQuestionTypeDecimal, @(FloatValue))];

    [stepResults addObject:getStepResult(DateStepIdentifier, [ORKDateQuestionResult class], ORKQuestionTypeDate, Date())];

    [stepResults addObject:getStepResult(TimeIntervalStepIdentifier, [ORKTimeIntervalQuestionResult class], ORKQuestionTypeTimeInterval, @(IntegerValue))];

    [stepResults addObject:getStepResult(TimeOfDayStepIdentifier, [ORKTimeOfDayQuestionResult class], ORKQuestionTypeTimeOfDay, DateComponents())];

    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:OrderedTaskIdentifier
                                                                  taskRunUUID:[NSUUID UUID]
                                                              outputDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    taskResult.results = stepResults;
    
    return taskResult;
}

ORKDefineStringKey(MatchedDestinationStepIdentifier);
ORKDefineStringKey(DefaultDestinationStepIdentifier);

ORKDefineStringKey(AdditionalTaskIdentifier);

ORKDefineStringKey(AdditionalTextStepIdentifier);
ORKDefineStringKey(AdditionalTextValue);

- (ORKTaskResult *)getSmallTaskResultTreeWithAdditionalOption:(BOOL)isAdditional {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    if (!isAdditional) {
        [stepResults addObject:getStepResult(TextStepIdentifier, [ORKTextQuestionResult class], ORKQuestionTypeText, TextValue)];
    } else {
        [stepResults addObject:getStepResult(AdditionalTextStepIdentifier, [ORKTextQuestionResult class], ORKQuestionTypeText, AdditionalTextValue)];
    }
    
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:!isAdditional ? OrderedTaskIdentifier : AdditionalTaskIdentifier
                                                                  taskRunUUID:[NSUUID UUID]
                                                              outputDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    taskResult.results = stepResults;
    
    return taskResult;
}

- (ORKTaskResult *)getSmallTaskResultTreeWithDuplicateStepIdentifiers {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    [stepResults addObject:getStepResult(TextStepIdentifier, [ORKTextQuestionResult class], ORKQuestionTypeText, TextValue)];
    [stepResults addObject:getStepResult(TextStepIdentifier, [ORKTextQuestionResult class], ORKQuestionTypeText, TextValue)];
    
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:OrderedTaskIdentifier
                                                                  taskRunUUID:[NSUUID UUID]
                                                              outputDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    taskResult.results = stepResults;
    
    return taskResult;
}

- (void)testPredicateStepNavigationRule {
    NSPredicate *predicate = nil;
    ORKPredicateStepNavigationRule *predicateRule = nil;
    ORKTaskResult *taskResult = nil;
    ORKTaskResult *additionalTaskResult = nil;
    
    NSArray *resultPredicates = nil;
    NSArray *destinationStepIdentifiers = nil;
    NSString *defaultStepIdentifier = nil;
    
    // Test predicate step navigation rule initializers
    predicate = [ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                        expectedString:TextValue];
    resultPredicates = @[ predicate ];
    destinationStepIdentifiers = @[ MatchedDestinationStepIdentifier ];
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                                          destinationStepIdentifiers:destinationStepIdentifiers];

    XCTAssertEqualObjects(predicateRule.resultPredicates, ORKArrayCopyObjects(resultPredicates));
    XCTAssertEqualObjects(predicateRule.destinationStepIdentifiers, ORKArrayCopyObjects(destinationStepIdentifiers));
    XCTAssertNil(predicateRule.defaultStepIdentifier);

    defaultStepIdentifier = DefaultDestinationStepIdentifier;
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                                          destinationStepIdentifiers:destinationStepIdentifiers
                                                               defaultStepIdentifier:defaultStepIdentifier];

    XCTAssertEqualObjects(predicateRule.resultPredicates, ORKArrayCopyObjects(resultPredicates));
    XCTAssertEqualObjects(predicateRule.destinationStepIdentifiers, ORKArrayCopyObjects(destinationStepIdentifiers));
    XCTAssertEqualObjects(predicateRule.defaultStepIdentifier, defaultStepIdentifier);

    // Predicate matching, no additional task results, matching
    taskResult = [ORKTaskResult new];
    taskResult.identifier = OrderedTaskIdentifier;

    predicate = [ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                        expectedString:TextValue];
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicate ]
                                                          destinationStepIdentifiers:@[ MatchedDestinationStepIdentifier ]
                                                               defaultStepIdentifier:DefaultDestinationStepIdentifier];

    XCTAssertEqualObjects([predicateRule identifierForDestinationStepWithTaskResult:taskResult], DefaultDestinationStepIdentifier);

    taskResult = [self getSmallTaskResultTreeWithAdditionalOption:NO];
    XCTAssertEqualObjects([predicateRule identifierForDestinationStepWithTaskResult:taskResult], MatchedDestinationStepIdentifier);

    // Predicate matching, no additional task results, non matching
    predicate = [ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                        expectedString:OtherTextValue];
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicate ]
                                                          destinationStepIdentifiers:@[ MatchedDestinationStepIdentifier ]
                                                               defaultStepIdentifier:DefaultDestinationStepIdentifier];
    taskResult = [self getSmallTaskResultTreeWithAdditionalOption:NO];
    XCTAssertEqualObjects([predicateRule identifierForDestinationStepWithTaskResult:taskResult], DefaultDestinationStepIdentifier);

    
    // Predicate matching, additional task results
    NSPredicate *currentPredicate = [ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                                            expectedString:TextValue];
    NSPredicate *additionalPredicate = [ORKResultPredicate predicateForTextQuestionResultWithTaskIdentifier:AdditionalTaskIdentifier
                                                                                           resultIdentifier:AdditionalTextStepIdentifier
                                                                                         expectedString:AdditionalTextValue];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[currentPredicate, additionalPredicate]];
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicate ]
                                                          destinationStepIdentifiers:@[ MatchedDestinationStepIdentifier ]
                                                               defaultStepIdentifier:DefaultDestinationStepIdentifier];
    
    taskResult = [ORKTaskResult new];
    taskResult.identifier = OrderedTaskIdentifier;
    XCTAssertEqualObjects([predicateRule identifierForDestinationStepWithTaskResult:taskResult], DefaultDestinationStepIdentifier);
    
    taskResult = [self getSmallTaskResultTreeWithAdditionalOption:NO];
    XCTAssertEqualObjects([predicateRule identifierForDestinationStepWithTaskResult:taskResult], DefaultDestinationStepIdentifier);

    additionalTaskResult = [self getSmallTaskResultTreeWithAdditionalOption:YES];
    predicateRule.additionalTaskResults = @[ additionalTaskResult ];
    XCTAssertEqualObjects([predicateRule identifierForDestinationStepWithTaskResult:taskResult], MatchedDestinationStepIdentifier);

    // Test duplicate task identifiers check
    predicateRule.additionalTaskResults = @[ taskResult ];
    XCTAssertThrows([predicateRule identifierForDestinationStepWithTaskResult:taskResult]);

    // Test duplicate question result identifiers check
    XCTAssertThrows(predicateRule.additionalTaskResults = @[ [self getSmallTaskResultTreeWithDuplicateStepIdentifiers] ]);
}

- (void)testDirectStepNavigationRule {
    ORKDirectStepNavigationRule *directRule = nil;
    ORKTaskResult *mockTaskResult = [ORKTaskResult new];
    
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:MatchedDestinationStepIdentifier];
    XCTAssertEqualObjects(directRule.destinationStepIdentifier, [MatchedDestinationStepIdentifier copy] );
    XCTAssertEqualObjects([directRule identifierForDestinationStepWithTaskResult:mockTaskResult], [MatchedDestinationStepIdentifier copy]);

    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
    XCTAssertEqualObjects(directRule.destinationStepIdentifier, [ORKNullStepIdentifier copy]);
    XCTAssertEqualObjects([directRule identifierForDestinationStepWithTaskResult:mockTaskResult], [ORKNullStepIdentifier copy]);
}

- (void)testResultPredicatesWithTaskIdentifier:(NSString *)taskIdentifier
                         substitutionVariables:(NSDictionary *)substitutionVariables
                                   taskResults:(NSArray *)taskResults {
    // ORKScaleQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:ScaleStepIdentifier
                                                                          expectedAnswer:IntegerValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:ScaleStepIdentifier
                                                                           expectedAnswer:IntegerValue + 1] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:ContinuousScaleStepIdentifier
                                                              minimumExpectedAnswerValue:FloatValue - 0.01
                                                              maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:ContinuousScaleStepIdentifier
                                                               minimumExpectedAnswerValue:FloatValue + 0.05
                                                               maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:ContinuousScaleStepIdentifier
                                                              minimumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:ContinuousScaleStepIdentifier
                                                               minimumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:ContinuousScaleStepIdentifier
                                                              maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:ContinuousScaleStepIdentifier
                                                               maximumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKChoiceQuestionResult (strings)
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:SingleChoiceStepIdentifier
                                                                           expectedString:SingleChoiceValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:SingleChoiceStepIdentifier
                                                                            expectedString:OtherTextValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    NSArray *expectedAnswers = nil;
    expectedAnswers = @[MultipleChoiceValue1, MultipleChoiceValue2];
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:MultipleChoiceStepIdentifier
                                                                          expectedStrings:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    expectedAnswers = @[MultipleChoiceValue1, MultipleChoiceValue2, OtherTextValue];
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:MultipleChoiceStepIdentifier
                                                                           expectedStrings:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKChoiceQuestionResult (regular expressions)
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:SingleChoiceStepIdentifier
                                                                          matchingPattern:@"...gleChoiceValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:SingleChoiceStepIdentifier
                                                                            expectedString:@"...SingleChoiceValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    expectedAnswers = @[@"...tipleChoiceValue1", @"...tipleChoiceValue2"];
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                         resultIdentifier:MultipleChoiceStepIdentifier
                                                                         matchingPatterns:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    expectedAnswers = @[@"...MultipleChoiceValue1", @"...MultipleChoiceValue2", @"...OtherTextValue"];
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:MultipleChoiceStepIdentifier
                                                                          matchingPatterns:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKBooleanQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForBooleanQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:BooleanStepIdentifier
                                                                            expectedAnswer:BooleanValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForBooleanQuestionResultWithTaskIdentifier:taskIdentifier
                                                                           resultIdentifier:BooleanStepIdentifier
                                                                             expectedAnswer:!BooleanValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTextQuestionResult (strings)
    XCTAssertTrue([[ORKResultPredicate predicateForTextQuestionResultWithTaskIdentifier:taskIdentifier
                                                                       resultIdentifier:TextStepIdentifier
                                                                         expectedString:TextValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTextQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:TextStepIdentifier
                                                                          expectedString:OtherTextValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTextQuestionResult (regular expressions)
    XCTAssertTrue([[ORKResultPredicate predicateForTextQuestionResultWithTaskIdentifier:taskIdentifier
                                                                       resultIdentifier:TextStepIdentifier
                                                                        matchingPattern:@"...tValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTextQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:TextStepIdentifier
                                                                         matchingPattern:@"...TextValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKNumericQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:IntegerNumericStepIdentifier
                                                                            expectedAnswer:IntegerValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                           resultIdentifier:IntegerNumericStepIdentifier
                                                                             expectedAnswer:IntegerValue + 1] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:FloatNumericStepIdentifier
                                                                minimumExpectedAnswerValue:ORKIgnoreDoubleValue
                                                                maximumExpectedAnswerValue:ORKIgnoreDoubleValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:FloatNumericStepIdentifier
                                                                minimumExpectedAnswerValue:FloatValue - 0.01
                                                                maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                           resultIdentifier:FloatNumericStepIdentifier
                                                                 minimumExpectedAnswerValue:FloatValue + 0.05
                                                                 maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:FloatNumericStepIdentifier
                                                                minimumExpectedAnswerValue:FloatValue - 0.01
                                                                maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                           resultIdentifier:FloatNumericStepIdentifier
                                                                 minimumExpectedAnswerValue:FloatValue + 0.05
                                                                 maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:FloatNumericStepIdentifier
                                                                minimumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                           resultIdentifier:FloatNumericStepIdentifier
                                                                 minimumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                          resultIdentifier:FloatNumericStepIdentifier
                                                                maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithTaskIdentifier:taskIdentifier
                                                                           resultIdentifier:FloatNumericStepIdentifier
                                                                 maximumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTimeOfDayQuestionResult
    NSDateComponents *expectedDateComponentsMinimum = DateComponents();
    NSDateComponents *expectedDateComponentsMaximum = DateComponents();
    XCTAssertTrue([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithTaskIdentifier:taskIdentifier
                                                                            resultIdentifier:TimeOfDayStepIdentifier
                                                                   minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                 minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                   maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                 maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    expectedDateComponentsMinimum.minute -= 2;
    expectedDateComponentsMaximum.minute += 2;
    XCTAssertTrue([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithTaskIdentifier:taskIdentifier
                                                                            resultIdentifier:TimeOfDayStepIdentifier
                                                                   minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                 minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                   maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                 maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    expectedDateComponentsMinimum.minute += 3;
    XCTAssertFalse([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithTaskIdentifier:taskIdentifier
                                                                             resultIdentifier:TimeOfDayStepIdentifier
                                                                    minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                  minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                    maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                  maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    expectedDateComponentsMinimum.minute -= 3;
    expectedDateComponentsMinimum.hour += 1;
    expectedDateComponentsMaximum.hour += 2;
    XCTAssertFalse([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithTaskIdentifier:taskIdentifier
                                                                             resultIdentifier:TimeOfDayStepIdentifier
                                                                    minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                  minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                    maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                  maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTimeIntervalQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                               resultIdentifier:FloatNumericStepIdentifier
                                                                     minimumExpectedAnswerValue:ORKIgnoreTimeIntervalValue
                                                                     maximumExpectedAnswerValue:ORKIgnoreTimeIntervalValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                               resultIdentifier:FloatNumericStepIdentifier
                                                                     minimumExpectedAnswerValue:FloatValue - 0.01
                                                                     maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                                resultIdentifier:FloatNumericStepIdentifier
                                                                      minimumExpectedAnswerValue:FloatValue + 0.05
                                                                      maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                               resultIdentifier:FloatNumericStepIdentifier
                                                                     minimumExpectedAnswerValue:FloatValue - 0.01
                                                                     maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                                resultIdentifier:FloatNumericStepIdentifier
                                                                      minimumExpectedAnswerValue:FloatValue + 0.05
                                                                      maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                               resultIdentifier:FloatNumericStepIdentifier
                                                                     minimumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                                resultIdentifier:FloatNumericStepIdentifier
                                                                      minimumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                               resultIdentifier:FloatNumericStepIdentifier
                                                                     maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithTaskIdentifier:taskIdentifier
                                                                                resultIdentifier:FloatNumericStepIdentifier
                                                                      maximumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKDateQuestionResult
    NSDate *expectedDate = Date();
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                       resultIdentifier:DateStepIdentifier
                                                              minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-60]
                                                              maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:DateStepIdentifier
                                                               minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]
                                                               maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+120]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                       resultIdentifier:DateStepIdentifier
                                                              minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-60]
                                                              maximumExpectedAnswerDate:nil] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:DateStepIdentifier
                                                               minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+1]
                                                               maximumExpectedAnswerDate:nil] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                       resultIdentifier:DateStepIdentifier
                                                              minimumExpectedAnswerDate:nil
                                                              maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                        resultIdentifier:DateStepIdentifier
                                                               minimumExpectedAnswerDate:nil
                                                               maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-1]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithTaskIdentifier:taskIdentifier
                                                                       resultIdentifier:DateStepIdentifier
                                                              minimumExpectedAnswerDate:nil
                                                              maximumExpectedAnswerDate:nil] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
}

- (void)testResultPredicatesWithSubstitutionVariables:(NSDictionary *)substitutionVariables
                                          taskResults:(NSArray *)taskResults {
    // ORKScaleQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ScaleStepIdentifier
                                                                            expectedAnswer:IntegerValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ScaleStepIdentifier
                                                                             expectedAnswer:IntegerValue + 1] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ContinuousScaleStepIdentifier
                                                                minimumExpectedAnswerValue:FloatValue - 0.01
                                                                maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ContinuousScaleStepIdentifier
                                                                 minimumExpectedAnswerValue:FloatValue + 0.05
                                                                 maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ContinuousScaleStepIdentifier
                                                                minimumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ContinuousScaleStepIdentifier
                                                                 minimumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ContinuousScaleStepIdentifier
                                                                maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForScaleQuestionResultWithResultIdentifier:ContinuousScaleStepIdentifier
                                                                 maximumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKChoiceQuestionResult (strings)
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:SingleChoiceStepIdentifier
                                                                             expectedString:SingleChoiceValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:SingleChoiceStepIdentifier
                                                                              expectedString:OtherTextValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    NSArray *expectedAnswers = nil;
    expectedAnswers = @[MultipleChoiceValue1, MultipleChoiceValue2];
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:MultipleChoiceStepIdentifier
                                                                            expectedStrings:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    expectedAnswers = @[MultipleChoiceValue1, MultipleChoiceValue2, OtherTextValue];
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:MultipleChoiceStepIdentifier
                                                                             expectedStrings:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKChoiceQuestionResult (regular expressions)
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:SingleChoiceStepIdentifier
                                                                            matchingPattern:@"...gleChoiceValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:SingleChoiceStepIdentifier
                                                                              expectedString:@"...SingleChoiceValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    expectedAnswers = @[@"...tipleChoiceValue1", @"...tipleChoiceValue2"];
    XCTAssertTrue([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:MultipleChoiceStepIdentifier
                                                                           matchingPatterns:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    expectedAnswers = @[@"...MultipleChoiceValue1", @"...MultipleChoiceValue2", @"...OtherTextValue"];
    XCTAssertFalse([[ORKResultPredicate predicateForChoiceQuestionResultWithResultIdentifier:MultipleChoiceStepIdentifier
                                                                            matchingPatterns:expectedAnswers] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKBooleanQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForBooleanQuestionResultWithResultIdentifier:BooleanStepIdentifier
                                                                              expectedAnswer:BooleanValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForBooleanQuestionResultWithResultIdentifier:BooleanStepIdentifier
                                                                               expectedAnswer:!BooleanValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTextQuestionResult (strings)
    XCTAssertTrue([[ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                           expectedString:TextValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                            expectedString:OtherTextValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTextQuestionResult (regular expressions)
    XCTAssertTrue([[ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                          matchingPattern:@"...tValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTextQuestionResultWithResultIdentifier:TextStepIdentifier
                                                                           matchingPattern:@"...TextValue"] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKNumericQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:IntegerNumericStepIdentifier
                                                                              expectedAnswer:IntegerValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:IntegerNumericStepIdentifier
                                                                               expectedAnswer:IntegerValue + 1] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                  minimumExpectedAnswerValue:ORKIgnoreDoubleValue
                                                                  maximumExpectedAnswerValue:ORKIgnoreDoubleValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                  minimumExpectedAnswerValue:FloatValue - 0.01
                                                                  maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                   minimumExpectedAnswerValue:FloatValue + 0.05
                                                                   maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                  minimumExpectedAnswerValue:FloatValue - 0.01
                                                                  maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                   minimumExpectedAnswerValue:FloatValue + 0.05
                                                                   maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                  minimumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                   minimumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                  maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForNumericQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                   maximumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTimeOfDayQuestionResult
    NSDateComponents *expectedDateComponentsMinimum = DateComponents();
    NSDateComponents *expectedDateComponentsMaximum = DateComponents();
    XCTAssertTrue([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithResultIdentifier:TimeOfDayStepIdentifier
                                                                     minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                   minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                     maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                   maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    expectedDateComponentsMinimum.minute -= 2;
    expectedDateComponentsMaximum.minute += 2;
    XCTAssertTrue([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithResultIdentifier:TimeOfDayStepIdentifier
                                                                     minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                   minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                     maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                   maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    expectedDateComponentsMinimum.minute += 3;
    XCTAssertFalse([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithResultIdentifier:TimeOfDayStepIdentifier
                                                                      minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                    minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                      maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                    maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    expectedDateComponentsMinimum.minute -= 3;
    expectedDateComponentsMinimum.hour += 1;
    expectedDateComponentsMaximum.hour += 2;
    XCTAssertFalse([[ORKResultPredicate predicateForTimeOfDayQuestionResultWithResultIdentifier:TimeOfDayStepIdentifier
                                                                      minimumExpectedAnswerHour:expectedDateComponentsMinimum.hour
                                                                    minimumExpectedAnswerMinute:expectedDateComponentsMinimum.minute
                                                                      maximumExpectedAnswerHour:expectedDateComponentsMaximum.hour
                                                                    maximumExpectedAnswerMinute:expectedDateComponentsMaximum.minute] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKTimeIntervalQuestionResult
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                       minimumExpectedAnswerValue:ORKIgnoreTimeIntervalValue
                                                                       maximumExpectedAnswerValue:ORKIgnoreTimeIntervalValue] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                       minimumExpectedAnswerValue:FloatValue - 0.01
                                                                       maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                        minimumExpectedAnswerValue:FloatValue + 0.05
                                                                        maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                       minimumExpectedAnswerValue:FloatValue - 0.01
                                                                       maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                        minimumExpectedAnswerValue:FloatValue + 0.05
                                                                        maximumExpectedAnswerValue:FloatValue + 0.06] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                       minimumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                        minimumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                       maximumExpectedAnswerValue:FloatValue + 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForTimeIntervalQuestionResultWithResultIdentifier:FloatNumericStepIdentifier
                                                                        maximumExpectedAnswerValue:FloatValue - 0.01] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    // ORKDateQuestionResult
    NSDate *expectedDate = Date();
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-60]
                                                                maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                 minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]
                                                                 maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+120]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-60]
                                                                maximumExpectedAnswerDate:nil] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                 minimumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+1]
                                                                 maximumExpectedAnswerDate:nil] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                minimumExpectedAnswerDate:nil
                                                                maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:+60]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    XCTAssertFalse([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                 minimumExpectedAnswerDate:nil
                                                                 maximumExpectedAnswerDate:[expectedDate dateByAddingTimeInterval:-1]] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
    
    XCTAssertTrue([[ORKResultPredicate predicateForDateQuestionResultWithResultIdentifier:DateStepIdentifier
                                                                minimumExpectedAnswerDate:nil
                                                                maximumExpectedAnswerDate:nil] evaluateWithObject:taskResults substitutionVariables:substitutionVariables]);
}

- (void)testResultPredicates {
    ORKTaskResult *taskResult = [self getGeneralTaskResultTree];
    NSArray *taskResults = @[ taskResult ];

    // The following two calls are equivalent since 'substitutionVariables' are ignored when you provide a non-nil task identifier
    [self testResultPredicatesWithTaskIdentifier:OrderedTaskIdentifier
                           substitutionVariables:nil
                                     taskResults:taskResults];
    [self testResultPredicatesWithTaskIdentifier:OrderedTaskIdentifier
                           substitutionVariables:@{ORKResultPredicateTaskIdentifierVariableName: OrderedTaskIdentifier}
                                     taskResults:taskResults];
    // Test nil task identifier variable substitution
    [self testResultPredicatesWithTaskIdentifier:nil
                           substitutionVariables:@{ORKResultPredicateTaskIdentifierVariableName: OrderedTaskIdentifier}
                                     taskResults:taskResults];
    // Test nil task identifier convenience methods
    [self testResultPredicatesWithSubstitutionVariables:@{ORKResultPredicateTaskIdentifierVariableName: OrderedTaskIdentifier}
                                            taskResults:taskResults];
}

@end
