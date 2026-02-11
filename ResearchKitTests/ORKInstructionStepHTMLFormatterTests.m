/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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
@import ResearchKit;

#import "ORKInstructionStepHTMLFormatter.h"

@interface ORKInstructionStepHTMLFormatterTests : XCTestCase

@property (nonatomic, strong) ORKInstructionStep *instructionStep;
@property (nonatomic, strong) ORKInstructionStepHTMLFormatter *formatter;

@end

@implementation ORKInstructionStepHTMLFormatterTests

- (void)setUp {
    [super setUp];
    
    _instructionStep = [[ORKInstructionStep alloc] initWithIdentifier:@"InstructionStepIdentifier"];
    _formatter = [ORKInstructionStepHTMLFormatter new];
}

- (void)testInstructionStepTitle {
    NSString *instructionStepTitle = @"Welcome to our study!";
    _instructionStep.title = instructionStepTitle;
    NSString *html = [_formatter HTMLForInstructionSteps:@[_instructionStep]];
    
    XCTAssert([html containsString:instructionStepTitle]);
}

- (void)testInstructionStepDetailText {
    NSString *instructionStepDetailText = @"Learn more by clicking viewing the information below.";
    _instructionStep.detailText = instructionStepDetailText;
    NSString *html = [_formatter HTMLForInstructionSteps:@[_instructionStep]];
    
    XCTAssert([html containsString:instructionStepDetailText]);
}

- (void)testInstructionStepIconImage {
    _instructionStep.iconImage = [UIImage systemImageNamed:@"hand.wave"];
    NSString *html = [_formatter HTMLForInstructionSteps:@[_instructionStep]];
    
    XCTAssert([html containsString:@"<div class='iconImageContainer'>"]);
}

- (void)testInstructionStepImage {
    _instructionStep.image = [UIImage systemImageNamed:@"hand.wave"];
    NSString *html = [_formatter HTMLForInstructionSteps:@[_instructionStep]];
    
    XCTAssert([html containsString:@"<img width='100%'"]);
}

- (void)testInstructionStepBulletItems {
    NSString *sharingHealthDataText = @"The study will ask you to share some of your Health data.";
    ORKBodyItem *sharingHealthDataBodyItem = [[ORKBodyItem alloc] initWithText:sharingHealthDataText detailText:nil image:nil learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleBulletPoint];
    
    NSString *completingTasksText = @"You will be asked to complete various tasks over the duration of the study.";
    ORKBodyItem *completingTasksBodyItem = [[ORKBodyItem alloc] initWithText:completingTasksText detailText:nil image:nil learnMoreItem:nil bodyItemStyle:ORKBodyItemStyleBulletPoint];

    _instructionStep.bodyItems = @[sharingHealthDataBodyItem, completingTasksBodyItem];
    
    NSString *html = [_formatter HTMLForInstructionSteps:@[_instructionStep]];
    
    XCTAssert([html containsString:sharingHealthDataText]);
    XCTAssert([html containsString:completingTasksText]);
}

- (void)testInstructionStepHTMLCopiesAreEqual {
    NSString *instructionStepTitle = @"Welcome to our study!";
    _instructionStep.title = instructionStepTitle;
    
    ORKInstructionStep *instructionStepCopy = [_instructionStep copy];
    
    NSString *html = [_formatter HTMLForInstructionSteps:@[_instructionStep]];
    NSString *htmlFromCopy = [_formatter HTMLForInstructionSteps:@[instructionStepCopy]];
    
    XCTAssert([html isEqualToString:htmlFromCopy]);
}

@end
