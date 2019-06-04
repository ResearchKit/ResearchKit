/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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
@import ResearchKit;


static const NSString *LearnMoreStepIdentifierPrefix = @"ORKLearnMoreStepIdentifier";

@interface ORKStepContainerViewTests : XCTestCase

@end

@implementation ORKStepContainerViewTests {
    int identifierNumber;
    ORKLearnMoreItem *learnMoreItem;
}

- (NSString *)generateLearnMoreStepIdentifier {
    if (!identifierNumber) {
        identifierNumber = 0;
    }
    identifierNumber = identifierNumber + 1;
    return [LearnMoreStepIdentifierPrefix stringByAppendingString:[NSString stringWithFormat:@"%d",identifierNumber]];
}

- (NSArray<ORKBodyItem *> *)bodyItemsWithAllAttributes {
    learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:nil learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc] initWithIdentifier:[self generateLearnMoreStepIdentifier]]];
    
    return @[
             [[ORKBodyItem alloc] initWithText:@"Text1"
                                    detailText:@"DetailText1"
                                         image:[UIImage new]
                                 learnMoreItem:[ORKLearnMoreItem learnMoreItemWithText:@"LearnMore"
                                                                  learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc]
                                                                                            initWithIdentifier:[self generateLearnMoreStepIdentifier]]]
                                 bodyItemStyle:ORKBodyItemStyleText],
             [[ORKBodyItem alloc] initWithText:@"Text2"
                                    detailText:@"DetailText2"
                                         image:[UIImage new]
                                 learnMoreItem:learnMoreItem
                                 bodyItemStyle:ORKBodyItemStyleBulletPoint]
             ];
}

- (NSArray<ORKBodyItem *> *)bodyItemsWithoutText {
    learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:nil learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc] initWithIdentifier:[self generateLearnMoreStepIdentifier]]];
    return @[
             [[ORKBodyItem alloc] initWithText:nil
                                    detailText:@"DetailText1"
                                         image:[UIImage new]
                                 learnMoreItem:[ORKLearnMoreItem learnMoreItemWithText:@"LearnMore"
                                                                  learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc]
                                                                                            initWithIdentifier:[self generateLearnMoreStepIdentifier]]]
                                 bodyItemStyle:ORKBodyItemStyleBulletPoint],
             [[ORKBodyItem alloc] initWithText:nil
                                    detailText:@"DetailText2"
                                         image:[UIImage new]
                                 learnMoreItem:learnMoreItem
                                 bodyItemStyle:ORKBodyItemStyleImage]
             ];
}

- (NSArray<ORKBodyItem *> *)bodyItemsWithoutDetailText {
    learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:nil learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc] initWithIdentifier:[self generateLearnMoreStepIdentifier]]];
    return @[
             [[ORKBodyItem alloc] initWithText:@"Text1"
                                    detailText:nil
                                         image:[UIImage new]
                                 learnMoreItem:[ORKLearnMoreItem learnMoreItemWithText:@"LearnMore"
                                                                  learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc]
                                                                                            initWithIdentifier:[self generateLearnMoreStepIdentifier]]]
                                 bodyItemStyle:ORKBodyItemStyleImage],
             [[ORKBodyItem alloc] initWithText:@"Text2"
                                    detailText:nil
                                         image:[UIImage new]
                                 learnMoreItem:learnMoreItem
                                 bodyItemStyle:ORKBodyItemStyleText]
             ];
}

- (NSArray<ORKBodyItem *> *)bodyItemsWithoutImages {
    learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:nil learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc] initWithIdentifier:[self generateLearnMoreStepIdentifier]]];
    return @[
             [[ORKBodyItem alloc] initWithText:@"Text1"
                                    detailText:@"DetailText1"
                                         image:nil
                                 learnMoreItem:[ORKLearnMoreItem learnMoreItemWithText:@"LearnMore"
                                                                  learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc]
                                                                                            initWithIdentifier:[self generateLearnMoreStepIdentifier]]]
                                 bodyItemStyle:ORKBodyItemStyleImage],
             [[ORKBodyItem alloc] initWithText:@"Text2"
                                    detailText:@"DetailText2"
                                         image:nil
                                 learnMoreItem:learnMoreItem
                                 bodyItemStyle:ORKBodyItemStyleBulletPoint]
             ];
}

- (NSArray<ORKBodyItem *> *)bodyItemsWithoutLearnMoreItems {
    return @[
             [[ORKBodyItem alloc] initWithText:@"Text1"
                                    detailText:@"DetailText1"
                                         image:[UIImage new]
                                 learnMoreItem:nil
                                 bodyItemStyle:ORKBodyItemStyleText],
             [[ORKBodyItem alloc] initWithText:@"Text2"
                                    detailText:@"DetailText2"
                                         image:[UIImage new]
                                 learnMoreItem:nil
                                 bodyItemStyle:ORKBodyItemStyleText]
             ];
}

- (void)testBodyItems {

    NSArray<ORKBodyItem *> *bodyItems = [self bodyItemsWithoutText];
    for (ORKBodyItem *item in bodyItems) {
        XCTAssertNil(item.text);
        XCTAssertNotNil(item.detailText);
        XCTAssertNotNil(item.image);
        XCTAssertNotNil(item.learnMoreItem);
        
        XCTAssertLessThanOrEqual(item.bodyItemStyle, 2);

    }
    XCTAssertEqual(bodyItems[0].detailText, @"DetailText1");
    XCTAssertEqual(bodyItems[1].detailText, @"DetailText2");
    XCTAssertEqual(bodyItems[0].learnMoreItem.text, @"LearnMore");
    XCTAssertNil(bodyItems[1].learnMoreItem.text);

    
    bodyItems = [self bodyItemsWithoutDetailText];
    for (ORKBodyItem *item in bodyItems) {
        XCTAssertNotNil(item.text);
        XCTAssertNil(item.detailText);
        XCTAssertNotNil(item.image);
        XCTAssertNotNil(item.learnMoreItem);
        
        XCTAssertLessThanOrEqual(item.bodyItemStyle, 2);
    }
    XCTAssertEqual(bodyItems[0].text, @"Text1");
    XCTAssertEqual(bodyItems[1].text, @"Text2");
    XCTAssertEqual(bodyItems[0].learnMoreItem.text, @"LearnMore");
    XCTAssertNil(bodyItems[1].learnMoreItem.text);
    
    bodyItems = [self bodyItemsWithoutImages];
    for (ORKBodyItem *item in bodyItems) {
        XCTAssertNotNil(item.text);
        XCTAssertNotNil(item.detailText);
        XCTAssertNil(item.image);
        XCTAssertNotNil(item.learnMoreItem);
        
        XCTAssertLessThanOrEqual(item.bodyItemStyle, 2);
    }
    XCTAssertEqual(bodyItems[0].text, @"Text1");
    XCTAssertEqual(bodyItems[1].text, @"Text2");
    XCTAssertEqual(bodyItems[0].detailText, @"DetailText1");
    XCTAssertEqual(bodyItems[1].detailText, @"DetailText2");
    XCTAssertEqual(bodyItems[0].learnMoreItem.text, @"LearnMore");
    XCTAssertNil(bodyItems[1].learnMoreItem.text);
    
    bodyItems = [self bodyItemsWithoutLearnMoreItems];
    for (ORKBodyItem *item in bodyItems) {
        XCTAssertNotNil(item.text);
        XCTAssertNotNil(item.detailText);
        XCTAssertNotNil(item.image);
        XCTAssertNil(item.learnMoreItem);
    }
    
    bodyItems = [self bodyItemsWithAllAttributes];
    for (ORKBodyItem *item in bodyItems) {
        XCTAssertNotNil(item.text);
        XCTAssertNotNil(item.detailText);
        XCTAssertNotNil(item.image);
        XCTAssertNotNil(item.learnMoreItem);
        
        XCTAssertLessThanOrEqual(item.bodyItemStyle, 2);
    }
    XCTAssertEqual(bodyItems[0].text, @"Text1");
    XCTAssertEqual(bodyItems[1].text, @"Text2");
    XCTAssertEqual(bodyItems[0].detailText, @"DetailText1");
    XCTAssertEqual(bodyItems[1].detailText, @"DetailText2");
    XCTAssertEqual(bodyItems[0].learnMoreItem.text, @"LearnMore");
    XCTAssertNil(bodyItems[1].learnMoreItem.text);
}

@end
