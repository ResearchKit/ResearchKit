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


@implementation ORKTaskTests {
    NSArray *_orderedTaskStepIdentifiers;
    NSArray *_orderedTaskSteps;
    ORKOrderedTask *_orderedTask;
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
    [self generateTaskSteps:&orderedTaskSteps stepIdentifiers:&orderedTaskStepIdentifiers];
    _orderedTaskSteps = orderedTaskSteps;
    _orderedTaskStepIdentifiers = orderedTaskStepIdentifiers;
    
    _orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:ORKTOrderedTaskIdentifier
                                                        steps:ORKArrayCopyObjects(_orderedTaskSteps)]; // deep copy to test step copying and equality
}

- (void)setUp {
    [super setUp];
    [self setUpOrderedTask];
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
    
    // Test duplicate step identifier validation
    XCTAssertNoThrow([_orderedTask validateParameters]);

    NSMutableArray *steps = [[NSMutableArray alloc] initWithArray:ORKArrayCopyObjects(_orderedTaskSteps)];
    ORKStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKTBlankStepIdentifier];
    [steps addObject:step];
    
    ORKOrderedTask *orderedTask = [[ORKOrderedTask alloc] initWithIdentifier:ORKTOrderedTaskIdentifier
                                                                       steps:steps];
    XCTAssertThrows([orderedTask validateParameters]);
}

- (void)testFormStep {
    // Test duplicate form step identifier validation
    ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:@"form" title:@"Form" text:@"Form test"];
    NSMutableArray *items = [NSMutableArray new];
    
    ORKFormItem *item = nil;
    item = [[ORKFormItem alloc] initWithIdentifier:@"formItem1"
                                              text:@"formItem1"
                                      answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
    [items addObject:item];

    item = [[ORKFormItem alloc] initWithIdentifier:@"formItem2"
                                              text:@"formItem2"
                                      answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
    [items addObject:item];

    [formStep setFormItems:items];
    XCTAssertNoThrow([formStep validateParameters]);

    item = [[ORKFormItem alloc] initWithIdentifier:@"formItem2"
                                              text:@"formItem2"
                                      answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
    [items addObject:item];

    [formStep setFormItems:items];
    XCTAssertThrows([formStep validateParameters]);
}

@end
