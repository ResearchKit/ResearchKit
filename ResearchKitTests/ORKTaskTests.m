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


@interface ORKTaskTests : XCTestCase

@end


ORKDefineStringKey(HeadacheChoice);
ORKDefineStringKey(DizinessChoice);
ORKDefineStringKey(NauseaChoice);

ORKDefineStringKey(SymptomStepIdentifier);
ORKDefineStringKey(SeverityStepIdentifier);
ORKDefineStringKey(BlankStepIdentifier);
ORKDefineStringKey(SevereHeadacheStepIdentifier);
ORKDefineStringKey(LightHeadacheStepIdentifier);
ORKDefineStringKey(OtherSymptomStepIdentifier);
ORKDefineStringKey(EndStepIdentifier);

ORKDefineStringKey(OrderedTaskIdentifier);
ORKDefineStringKey(NavigableOrderedTaskIdentifier);


@implementation ORKTaskTests {
    NSMutableArray *_orderedTaskStepIdentifiers;
    NSMutableArray *_orderedTaskSteps;
    ORKOrderedTask *_orderedTask;
    
    NSMutableDictionary *_stepNavigationRules;
    ORKNavigableOrderedTask *_navigableOrderedTask;
}

- (void)createOrderedTask {
    _orderedTaskStepIdentifiers = [NSMutableArray new];
    _orderedTaskSteps = [NSMutableArray new];
    
    ORKAnswerFormat *answerFormat = nil;
    NSString *stepIdentifier = nil;
    ORKStep *step = nil;
    
    NSArray *textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Headache" value:HeadacheChoice],
      [ORKTextChoice choiceWithText:@"Dizziness" value:DizinessChoice],
      [ORKTextChoice choiceWithText:@"Nausea" value:NauseaChoice]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    stepIdentifier = SymptomStepIdentifier;
    step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier title:@"What is your symptom?" answer:answerFormat];
    step.optional = NO;
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    stepIdentifier = SeverityStepIdentifier;
    step = [ORKQuestionStep questionStepWithIdentifier:stepIdentifier title:@"Does your symptom interferes with your daily life?" answer:answerFormat];
    step.optional = NO;
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    stepIdentifier = BlankStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"This step is intentionally left blank (you should not see it)";
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    stepIdentifier = SevereHeadacheStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have a severe headache";
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    stepIdentifier = LightHeadacheStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have a light headache";
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    stepIdentifier = OtherSymptomStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have other symptom";
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    stepIdentifier = EndStepIdentifier;
    step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
    step.title = @"You have finished the task";
    [_orderedTaskStepIdentifiers addObject:stepIdentifier];
    [_orderedTaskSteps addObject:step];
    
    _orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:OrderedTaskIdentifier
                                                        steps:ORKArrayCopyObjects(_orderedTaskSteps)]; // deep copy to test step copying and equality
    
}

- (void)createNavigableOrderedTask {
    _navigableOrderedTask = [[ORKNavigableOrderedTask alloc] initWithIdentifier:NavigableOrderedTaskIdentifier
                                                                          steps:ORKArrayCopyObjects(_orderedTaskSteps)]; // deep copy to test step copying and equality
    
    // Build navigation rules
    _stepNavigationRules = [NSMutableDictionary new];
    // Individual predicates
    
    // User chose headache at the symptom step
    NSPredicate *predicateHeadache = [ORKResultPredicate predicateForChoiceQuestionResultWithIdentifier:SymptomStepIdentifier expectedAnswer:HeadacheChoice];
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'symptom' \
    //                     AND SUBQUERY($x.answer, $y, $y like 'headache').@count > 0).@count > 0"];
    
    // User didn't chose headache at the symptom step
    NSPredicate *predicateNotHeadache = [NSCompoundPredicate notPredicateWithSubpredicate:predicateHeadache];
    
    // User chose YES at the severity step
    NSPredicate *predicateSevereYes = [ORKResultPredicate predicateForBooleanQuestionResultWithIdentifier:SeverityStepIdentifier expectedAnswer:YES];
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'severity' AND $x.answer == YES).@count > 0"];
    
    // User chose NO at the severity step
    NSPredicate *predicateSevereNo = [ORKResultPredicate predicateForBooleanQuestionResultWithIdentifier:SeverityStepIdentifier expectedAnswer:NO];
    
    
    // From the "symptom" step, go to "other_symptom" is user didn't chose headache.
    // Otherwise, default to going to next step (when the defaultStepIdentifier argument is omitted,
    // the regular ORKOrderedTask order applies).
    NSMutableArray *resultPredicates = [NSMutableArray new];
    NSMutableArray *matchingStepIdentifiers = [NSMutableArray new];
    
    [resultPredicates addObject:predicateNotHeadache];
    [matchingStepIdentifiers addObject:OtherSymptomStepIdentifier];
    
    ORKPredicateStepNavigationRule *predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                             matchingStepIdentifiers:matchingStepIdentifiers];
    
    [_navigableOrderedTask addNavigationRule:predicateRule forTriggerStepIdentifier:SymptomStepIdentifier];
    _stepNavigationRules[SymptomStepIdentifier] = [predicateRule copy];
    
    // From the "severity" step, go to "severe_headache" or "light_headache" depending on the user answer
    resultPredicates = [NSMutableArray new];
    matchingStepIdentifiers = [NSMutableArray new];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereYes]];
    [resultPredicates addObject:predicate];
    [matchingStepIdentifiers addObject:SevereHeadacheStepIdentifier];
    
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereNo]];
    [resultPredicates addObject:predicate];
    [matchingStepIdentifiers addObject:LightHeadacheStepIdentifier];
    
    predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:resultPredicates
                                             matchingStepIdentifiers:matchingStepIdentifiers
                                               defaultStepIdentifier:OtherSymptomStepIdentifier];
    
    [_navigableOrderedTask addNavigationRule:predicateRule forTriggerStepIdentifier:SeverityStepIdentifier];
    _stepNavigationRules[SeverityStepIdentifier] = [predicateRule copy];

    
    // Add end direct rules to skip unneeded steps
    ORKDirectStepNavigationRule *directRule =
    [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:EndStepIdentifier];
    
    [_navigableOrderedTask addNavigationRule:directRule forTriggerStepIdentifier:SevereHeadacheStepIdentifier];
    [_navigableOrderedTask addNavigationRule:directRule forTriggerStepIdentifier:LightHeadacheStepIdentifier];
    [_navigableOrderedTask addNavigationRule:directRule forTriggerStepIdentifier:OtherSymptomStepIdentifier];
    
    _stepNavigationRules[SevereHeadacheStepIdentifier] = [directRule copy];
    _stepNavigationRules[LightHeadacheStepIdentifier] = [directRule copy];
    _stepNavigationRules[OtherSymptomStepIdentifier] = [directRule copy];
}

typedef NS_ENUM(NSInteger, TestsTaskResultOptions) {
    TestsTaskResultOptionSymptomHeadache    = 1 << 0,
    TestsTaskResultOptionSymptomDiziness    = 2 << 0,
    TestsTaskResultOptionSymptomNausea      = 3 << 0,
    
    TestsTaskResultOptionSeverityYes        = 1 << 2,
    TestsTaskResultOptionSeverityNo         = 2 << 2
};

- (ORKTaskResult *)createResultTreeWithTaskIdentifier:(NSString *)taskIdentifier resultOptions:(TestsTaskResultOptions)resultOptions {
    NSMutableArray *stepResults = [NSMutableArray new];
    
    ORKQuestionResult *questionResult = nil;
    ORKStepResult *stepResult = nil;
    NSString *stepIdentifier = nil;
    
    if (resultOptions & (TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSymptomDiziness | TestsTaskResultOptionSymptomNausea)) {
        stepIdentifier = SymptomStepIdentifier;
        questionResult = [[ORKChoiceQuestionResult alloc] init];
        questionResult.identifier = stepIdentifier;
        if (resultOptions & TestsTaskResultOptionSymptomHeadache) {
            questionResult.answer = @[HeadacheChoice];
        } else if (resultOptions & TestsTaskResultOptionSymptomDiziness) {
            questionResult.answer = @[DizinessChoice];
        } else if (resultOptions & TestsTaskResultOptionSymptomNausea) {
            questionResult.answer = @[NauseaChoice];
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
    [self createOrderedTask];
    [self createNavigableOrderedTask];
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
}

- (void)testNavigableOrderedTask {
    XCTAssertEqualObjects(_navigableOrderedTask.identifier, NavigableOrderedTaskIdentifier);
    XCTAssertEqualObjects(_navigableOrderedTask.steps, _orderedTaskSteps);
    XCTAssertEqualObjects(_navigableOrderedTask.stepNavigationRules, _stepNavigationRules);
    
    ORKStep *symptomStep = _orderedTaskSteps[0];
    ORKStep *severityStep = _orderedTaskSteps[1];
    ORKStep *blankStep = _orderedTaskSteps[2];
    ORKStep *severeHeadacheStep = _orderedTaskSteps[3];
    ORKStep *lightHeadacheStep = _orderedTaskSteps[4];
    ORKStep *otherSymptomStep = _orderedTaskSteps[5];
    ORKStep *endStep = _orderedTaskSteps[6];

    ORKTaskResult *taskResult = nil;
    ORKStep *testedStep = nil;

    
    //
    // Empty task result
    //
    taskResult = [self createResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:0];
    
    // Test forward navigation
    testedStep = [_navigableOrderedTask stepAfterStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);

    testedStep = [_navigableOrderedTask stepAfterStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);

    testedStep = [_navigableOrderedTask stepAfterStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    // Test backward navigation
    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, symptomStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);
    
    // Test unreachable node (will reset navigation stack)
    testedStep = [_navigableOrderedTask stepAfterStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    // Test unreachable node (will reset navigation stack)
    testedStep = [_navigableOrderedTask stepAfterStep:blankStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severeHeadacheStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:severeHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severeHeadacheStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:severeHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, blankStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:blankStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    // Test unreachable node (will reset navigation stack)
    testedStep = [_navigableOrderedTask stepAfterStep:lightHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, lightHeadacheStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:lightHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    //
    // Only headache symptom answered
    //
    taskResult = [self createResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache];

    // Test forward navigation
    testedStep = [_navigableOrderedTask stepAfterStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);

    testedStep = [_navigableOrderedTask stepAfterStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);

    testedStep = [_navigableOrderedTask stepAfterStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);
    
    // Test backward navigation
    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);

    testedStep = [_navigableOrderedTask stepBeforeStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, symptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    //
    // Only diziness symptom answered
    //
    taskResult = [self createResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomDiziness];
    
    // Test forward navigation
    testedStep = [_navigableOrderedTask stepAfterStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);
    
    // Test backward navigation
    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, otherSymptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:otherSymptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, symptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    //
    // Severe headache sequence
    //
    taskResult = [self createResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSeverityYes];
    
    // Test forward navigation
    testedStep = [_navigableOrderedTask stepAfterStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severeHeadacheStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:severeHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);
    
    // Test backward navigation
    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severeHeadacheStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:severeHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, symptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);

    //
    // Light headache sequence
    //
    taskResult = [self createResultTreeWithTaskIdentifier:NavigableOrderedTaskIdentifier resultOptions:TestsTaskResultOptionSymptomHeadache | TestsTaskResultOptionSeverityNo];
    
    // Test forward navigation
    testedStep = [_navigableOrderedTask stepAfterStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, lightHeadacheStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:lightHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, endStep);
    
    testedStep = [_navigableOrderedTask stepAfterStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);
    
    // Test backward navigation
    testedStep = [_navigableOrderedTask stepBeforeStep:endStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, lightHeadacheStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:lightHeadacheStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, severityStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:severityStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, symptomStep);
    
    testedStep = [_navigableOrderedTask stepBeforeStep:symptomStep withResult:taskResult];
    XCTAssertEqualObjects(testedStep, nil);
}

@end
