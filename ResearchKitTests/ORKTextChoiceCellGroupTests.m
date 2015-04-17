/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ORKTextChoiceCellGroup.h"
#import "ORKAnswerFormat_Internal.h"

@interface ORKTextChoiceCellGroupTests : XCTestCase

@end

@implementation ORKTextChoiceCellGroupTests

- (NSArray *)textChoices {
    
    static NSArray *choices = nil;
    
    if (choices == nil) {
        choices = @[[ORKTextChoice choiceWithText:@"choice 01" value:@"c1"],
                    [ORKTextChoice choiceWithText:@"choice 02" value:@"c2"],
                    [ORKTextChoice choiceWithText:@"choice 03" value:@"c3"],
                    [ORKTextChoice choiceWithText:@"choice 04" value:@"c4"]];
    }
    
    return choices;
}

- (void)testSingleChoice {
    
    ORKTextChoiceAnswerFormat *af = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:[self textChoices]];
    
    ORKTextChoiceCellGroup *group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:af
                                                                                            answer:nil
                                                                                beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                               immediateNavigation:YES];
    
    // Basic check
    XCTAssertEqual(group.size, [self textChoices].count, @"");
    XCTAssertEqualObjects(group.answer, nil, @"");
    XCTAssertEqualObjects(group.answerForBoolean, nil, @"");
    
    // Test containsIndexPath
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], @"");
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:[self textChoices].count inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:[self textChoices].count-1 inSection:0]], @"");
    
    
    // Test cell generation
    NSUInteger index = 0;
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertNotNil(cell, @"");
        XCTAssertEqualObjects(cell.reuseIdentifier, @"abc", @"");
        XCTAssertEqual(cell.immediateNavigation, YES, @"");
        XCTAssertEqual(cell.accessoryType, UITableViewCellAccessoryDisclosureIndicator, @"");
    }
    
    ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
    XCTAssertNil(cell, @"");
    
    // Regenerate cell group
    group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:af
                                                                    answer:nil
                                                        beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       immediateNavigation:YES];
    
    // Test cell selection
    for ( index = 0 ; index < group.size; index++) {
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        XCTAssertEqual([answer count], 1);

        ORKTextChoice *choice = [self textChoices][index];
        id value = [choice value];
        
        if (value == nil) {
            value = @(index);
        }
        
        XCTAssertEqualObjects([answer firstObject], value, @"%@ vs %@", [answer firstObject], value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, YES);
    }
    
    // Test cell deselection
    [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:group.size-1 inSection:0]];
    
    id answer = group.answer;
    XCTAssert([answer isKindOfClass:[NSArray class]]);
    XCTAssertEqual([answer count], 0);
    
    
    // Test set nil/null answer
    [group setAnswer:nil];
    XCTAssertEqual([answer count], 0);
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(cell.selectedItem, NO);
    }
    [group setAnswer:ORKNullAnswerValue()];
    XCTAssertEqual([answer count], 0);
    
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, NO);
    }
    
    // Test set answer
    for ( index = 0 ; index < group.size; index++) {
        
        ORKTextChoice *choice = [self textChoices][index];
        id value = [choice value];
        
        if (value == nil) {
            value = @(index);
        }
        
        [group setAnswer:@[value]];
        
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        XCTAssertEqual([answer count], 1);
        
       
        XCTAssertEqualObjects([answer firstObject], value, @"%@ vs %@", [answer firstObject], value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertTrue( cell.selectedItem );
        
    }
    
}

- (void)testMultiChoice {
    
    ORKTextChoiceAnswerFormat *af = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:[self textChoices]];
    
    ORKTextChoiceCellGroup *group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:af
                                                                                            answer:nil
                                                                                beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                               immediateNavigation:NO];
    
    // Test basics
    XCTAssertEqual(group.size, [self textChoices].count, @"");
    XCTAssertEqualObjects(group.answer, nil, @"");
    XCTAssertEqualObjects(group.answerForBoolean, nil, @"");
    
    // Test containsIndexPath
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], @"");
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:[self textChoices].count inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:[self textChoices].count-1 inSection:0]], @"");
    
    // Test cell generation
    NSUInteger index = 0;
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertNotNil(cell, @"");
        XCTAssertEqualObjects(cell.reuseIdentifier, @"abc", @"");
        XCTAssertEqual( cell.immediateNavigation, NO, @"");
    }
    
    // Test cell generation with invalid indexPath
    ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
    XCTAssertNil(cell, @"");
    
    // Regenerate cellGroup
    group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:af
                                                                    answer:nil
                                                        beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       immediateNavigation:NO];
    
    // Test cell selection
    for ( index = 0 ; index < group.size; index++) {
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        XCTAssertEqual([answer count], index+1);
        
        ORKTextChoice *choice = [self textChoices][index];
        id value = [choice value];
        
        if (value == nil) {
            value = @(index);
        }
        
        XCTAssertEqualObjects([answer lastObject], value, @"%@ vs %@", [answer firstObject], value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, YES);
    }
    
    // Test cell deselection
    for ( index = 0 ; index < group.size; index++) {
        
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        XCTAssertEqual([answer count], group.size - index -1);
        
        XCTAssertEqual( cell.selectedItem, NO);
    }
    
    id answer = group.answer;
    XCTAssert([answer isKindOfClass:[NSArray class]]);
    XCTAssertEqual([answer count], 0);
    
    
    // Test set nil/null answer
    [group setAnswer:nil];
    XCTAssertEqual([answer count], 0);
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssert( cell.selectedItem == NO);
    }
    [group setAnswer:ORKNullAnswerValue()];
    XCTAssertEqual([answer count], 0);

    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(cell.selectedItem, NO);
    }
    

    // Test set answers
    NSMutableArray *answers = [NSMutableArray new];
    for ( index = 0 ; index < group.size; index++) {
        
        ORKTextChoice *choice = [self textChoices][index];
        id value = [choice value];
        
        if (value == nil) {
            value = @(index);
        }
        
        [answers addObject:value];
        
        [group setAnswer:answers];
        
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        XCTAssertEqual([answer count], index + 1);
        
        
        XCTAssertEqualObjects([answer lastObject], value, @"%@ vs %@", [answer firstObject], value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertTrue( cell.selectedItem );
        
    }
    
}

@end
