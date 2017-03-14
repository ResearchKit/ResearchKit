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


@import XCTest;
@import ResearchKit.Private;


@interface ORKStepTests : XCTestCase

@end


@implementation ORKStepTests

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

- (void)testReactionTimeStep {
    ORKReactionTimeStep *validReactionTimeStep = [[ORKReactionTimeStep alloc] initWithIdentifier:@"ReactionTimeStep"];
    
    validReactionTimeStep.maximumStimulusInterval = 8;
    validReactionTimeStep.minimumStimulusInterval = 4;
    validReactionTimeStep.thresholdAcceleration = 0.5;
    validReactionTimeStep.numberOfAttempts = 3;
    validReactionTimeStep.timeout = 10;

    XCTAssertNoThrow([validReactionTimeStep validateParameters]);
    
    ORKReactionTimeStep *reactionTimeStep = [validReactionTimeStep copy];
    XCTAssertEqualObjects(reactionTimeStep, validReactionTimeStep);

    // minimumStimulusInterval cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.minimumStimulusInterval = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);

    // minimumStimulusInterval cannot be higher than maximumStimulusInterval
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.maximumStimulusInterval = 8;
    validReactionTimeStep.minimumStimulusInterval = 10;
    XCTAssertThrows([validReactionTimeStep validateParameters]);

    // thresholdAcceleration cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.thresholdAcceleration = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);

    // timeout cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.timeout = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);

    // numberOfAttempts cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.numberOfAttempts = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);
}

- (void)testPageResult {
    
    NSArray *steps = @[[[ORKStep alloc] initWithIdentifier:@"step1"],
                       [[ORKStep alloc] initWithIdentifier:@"step2"],
                       [[ORKStep alloc] initWithIdentifier:@"step3"],
                       ];
    ORKPageStep *pageStep = [[ORKPageStep alloc] initWithIdentifier:@"pageStep" steps:steps];
    
    ORKChoiceQuestionResult *step1Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result1"];
    step1Result1.choiceAnswers = @[@(1)];
    ORKChoiceQuestionResult *step1Result2 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result2"];
    step1Result2.choiceAnswers = @[@(2)];
    ORKChoiceQuestionResult *step2Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step2.result1"];
    step2Result1.choiceAnswers = @[@(3)];
    
    ORKStepResult *inputResult = [[ORKStepResult alloc] initWithStepIdentifier:@"pageStep"
                                                                       results:@[step1Result1, step1Result2, step2Result1]];
    
    ORKPageResult *pageResult = [[ORKPageResult alloc] initWithPageStep:pageStep stepResult:inputResult];
    
    // Check steps going forward
    ORKStep *step1 = [pageStep stepAfterStepWithIdentifier:nil withResult:pageResult];
    XCTAssertNotNil(step1);
    XCTAssertEqualObjects(step1.identifier, @"step1");
    
    ORKStep *step2 = [pageStep stepAfterStepWithIdentifier:@"step1" withResult:pageResult];
    XCTAssertNotNil(step2);
    XCTAssertEqualObjects(step2.identifier, @"step2");
    
    ORKStep *step3 = [pageStep stepAfterStepWithIdentifier:@"step2" withResult:pageResult];
    XCTAssertNotNil(step3);
    XCTAssertEqualObjects(step3.identifier, @"step3");
    
    ORKStep *step4 = [pageStep stepAfterStepWithIdentifier:@"step3" withResult:pageResult];
    XCTAssertNil(step4);
    
    // Check steps going backward
    ORKStep *backStep2 = [pageStep stepBeforeStepWithIdentifier:@"step3" withResult:pageResult];
    XCTAssertEqualObjects(backStep2, step2);
    
    ORKStep *backStep1 = [pageStep stepBeforeStepWithIdentifier:@"step2" withResult:pageResult];
    XCTAssertEqualObjects(backStep1, step1);
    
    ORKStep *backStepNil = [pageStep stepBeforeStepWithIdentifier:@"step1" withResult:pageResult];
    XCTAssertNil(backStepNil);
    
    // Check identifier
    XCTAssertEqualObjects([pageStep stepWithIdentifier:@"step1"], step1);
    XCTAssertEqualObjects([pageStep stepWithIdentifier:@"step2"], step2);
    XCTAssertEqualObjects([pageStep stepWithIdentifier:@"step3"], step3);
}

@end


