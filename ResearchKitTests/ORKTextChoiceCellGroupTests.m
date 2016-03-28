/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 
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

#import "ORKChoiceViewCell.h"
#import "ORKTextChoiceCellGroup.h"


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

- (NSArray *)textChoicesWithOneExclusive {
    static NSArray *choicesWithOneExclusive = nil;
    
    if (choicesWithOneExclusive == nil) {
        choicesWithOneExclusive = @[[ORKTextChoice choiceWithText:@"choice 01" value:@"c1"],
                                    [ORKTextChoice choiceWithText:@"choice 02" detailText:nil value:@"c2" exclusive:YES],
                                [ORKTextChoice choiceWithText:@"choice 03" value:@"c3"],
                                [ORKTextChoice choiceWithText:@"choice 04" value:@"c4"]];
    }
    
    return choicesWithOneExclusive;
}

- (NSArray *)textChoicesWithTwoExclusives {
    static NSArray *choicesWithTwoExclusives = nil;
    
    if (choicesWithTwoExclusives == nil) {
        choicesWithTwoExclusives = @[[ORKTextChoice choiceWithText:@"choice 01" value:@"c1"],
                                 [ORKTextChoice choiceWithText:@"choice 02" detailText:nil value:@"c2" exclusive:YES],
                                 [ORKTextChoice choiceWithText:@"choice 03" detailText:nil value:@"c3" exclusive:YES],
                                 [ORKTextChoice choiceWithText:@"choice 04" value:@"c4"]];
    }
    
    return choicesWithTwoExclusives;
}

- (NSArray *)textChoicesWithAllExclusives {
    static NSArray *choicesWithAllExclusives = nil;
    
    if (choicesWithAllExclusives == nil) {
        choicesWithAllExclusives = @[[ORKTextChoice choiceWithText:@"choice 01" detailText:nil value:@"c1" exclusive:YES],
                                 [ORKTextChoice choiceWithText:@"choice 02" detailText:nil value:@"c2" exclusive:YES],
                                 [ORKTextChoice choiceWithText:@"choice 03" detailText:nil value:@"c3" exclusive:YES],
                                 [ORKTextChoice choiceWithText:@"choice 04" detailText:nil value:@"c4" exclusive:YES]];
    }
    
    return choicesWithAllExclusives;
}

- (void)testSingleChoice {
    NSArray *choices = [self textChoices];
    ORKTextChoiceAnswerFormat *answerFormat = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choices];
    [self testSingleChoice:answerFormat choices:choices];
}

- (void)testSingleChoice: (ORKTextChoiceAnswerFormat *)answerFormat choices:(NSArray *)choices {
    
    ORKTextChoiceCellGroup *group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:answerFormat
                                                                                            answer:nil
                                                                                beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                               immediateNavigation:YES];
    
    // Basic check
    XCTAssertEqual(group.size, choices.count, @"");
    XCTAssertEqualObjects(group.answer, nil, @"");
    XCTAssertEqualObjects(group.answerForBoolean, nil, @"");
    
    // Test containsIndexPath
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], @"");
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:choices.count inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:choices.count-1 inSection:0]], @"");
    
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
    group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:answerFormat
                                                                    answer:nil
                                                        beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       immediateNavigation:YES];
    
    // Test cell selection
    for ( index = 0 ; index < group.size; index++) {
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        NSArray *answerArray = answer;
        XCTAssertEqual(answerArray.count, 1);

        ORKTextChoice *choice = choices[index];
        id value = choice.value;
        
        if (value == nil) {
            value = @(index);
        }
        
        XCTAssertEqualObjects(answerArray.firstObject, value, @"%@ vs %@", answerArray.firstObject, value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, YES);
    }
    
    // Test cell deselection (ORKChoiceAnswerStyleSingleChoice: selected cell should not deselect if chosen again)
    [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:group.size-1 inSection:0]];
    
    id answer = group.answer;
    XCTAssert([answer isKindOfClass:[NSArray class]]);
    NSArray *answerArray = answer;
    XCTAssertEqual(answerArray.count, 1);
    
    // Test set nil/null answer
    [group setAnswer:nil];
    answer = group.answer;
    XCTAssertNil(answer);
    answerArray = answer;
    XCTAssertEqual(answerArray.count, 0);
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(cell.selectedItem, NO);
    }
    [group setAnswer:ORKNullAnswerValue()];
    XCTAssertEqual(answerArray.count, 0);
    
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, NO);
    }
    
    // Test set answer
    for ( index = 0 ; index < group.size; index++) {
        ORKTextChoice *choice = choices[index];
        id value = choice.value;
        
        if (value == nil) {
            value = @(index);
        }
        
        [group setAnswer:@[value]];
        
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        NSArray *answerArray = answer;
        XCTAssertEqual(answerArray.count, 1);
       
        XCTAssertEqualObjects(answerArray.firstObject, value, @"%@ vs %@", answerArray.firstObject, value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertTrue( cell.selectedItem );
    }
}

- (void)testMultiChoice {
    ORKTextChoiceAnswerFormat *answerFormat = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:[self textChoices]];
    
    ORKTextChoiceCellGroup *group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:answerFormat
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
    group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:answerFormat
                                                                    answer:nil
                                                        beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       immediateNavigation:NO];
    
    // Test cell selection
    for ( index = 0 ; index < group.size; index++) {
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        NSArray *answerArray = answer;
        XCTAssertEqual(answerArray.count, index+1);
        
        ORKTextChoice *choice = [self textChoices][index];
        id value = choice.value;
        
        if (value == nil) {
            value = @(index);
        }
        
        XCTAssertEqualObjects(answerArray.lastObject, value, @"%@ vs %@", answerArray.lastObject, value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, YES);
    }
    
    // Test cell deselection
    for ( index = 0 ; index < group.size; index++) {
        
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        id answer = group.answer;
        if (index < group.size - 1) {
            XCTAssert([answer isKindOfClass:[NSArray class]]);
            NSArray *answerArray = answer;
            XCTAssertEqual(answerArray.count, group.size - index -1);
        } else {
            // Answer becomes NSNull when all cells are deselected
            XCTAssert(answer == ORKNullAnswerValue());
        }
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual( cell.selectedItem, NO);
    }
    
    XCTAssert(group.answer == ORKNullAnswerValue());

    // Select all cells again
    for ( index = 0 ; index < group.size; index++) {
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    
    NSArray *answerArray = group.answer;
    XCTAssertEqual(answerArray.count, group.size);
    
    // Test set nil/null answer
    [group setAnswer:nil];
    XCTAssertNil(group.answer);
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssert( cell.selectedItem == NO);
    }

    // Select all cells again
    for ( index = 0 ; index < group.size; index++) {
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    
    answerArray = group.answer;
    XCTAssertEqual(answerArray.count, group.size);

    [group setAnswer:ORKNullAnswerValue()];
    XCTAssert(group.answer == ORKNullAnswerValue());
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(cell.selectedItem, NO);
    }

    // Test set answers
    NSMutableArray *answers = [NSMutableArray new];
    for ( index = 0 ; index < group.size; index++) {
        ORKTextChoice *choice = [self textChoices][index];
        id value = choice.value;
        
        if (value == nil) {
            value = @(index);
        }
        
        [answers addObject:value];
        
        [group setAnswer:answers];
        
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        NSArray *answerArray = answer;
        XCTAssertEqual(answerArray.count, index + 1);
        
        XCTAssertEqualObjects(answerArray.lastObject, value, @"%@ vs %@", answerArray.lastObject, value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertTrue( cell.selectedItem );
    }
}

- (void)testMultiChoiceWithOneExclusive {
    [self testMultiChoiceWithExclusives:[self textChoicesWithOneExclusive]];
}

- (void)testMultiChoiceWithTwoExclusives {
    [self testMultiChoiceWithExclusives:[self textChoicesWithTwoExclusives]];
}

- (void)testMultiChoiceWithExclusives:(NSArray *)choices {
    ORKTextChoiceAnswerFormat *answerFormat = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:choices];
    
    ORKTextChoiceCellGroup *group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:answerFormat
                                                                                            answer:nil
                                                                                beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                               immediateNavigation:NO];
    
    // Test basics
    XCTAssertEqual(group.size, choices.count, @"");
    XCTAssertEqualObjects(group.answer, nil, @"");
    XCTAssertEqualObjects(group.answerForBoolean, nil, @"");
    
    // Test containsIndexPath
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], @"");
    XCTAssertFalse([group containsIndexPath:[NSIndexPath indexPathForRow:choices.count inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], @"");
    XCTAssertTrue([group containsIndexPath:[NSIndexPath indexPathForRow:choices.count-1 inSection:0]], @"");
    
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
    group = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:answerFormat
                                                                    answer:nil
                                                        beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       immediateNavigation:NO];
    
    // Get the indexes of the exclusive and non-exclusive choices
    NSMutableArray *exclusiveIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *nonExclusiveIndexes = [[NSMutableArray alloc] init];
    for (index = 0 ; index < group.size; index++) {
        ORKTextChoice *choice = choices[index];
        if (choice.exclusive) {
            [exclusiveIndexes addObject:@(index)];
        } else {
            [nonExclusiveIndexes addObject:@(index)];
        }
    }
    
    // Test cell selection.  First select all the non-exclusive choices, then do one exclusive
    NSUInteger exclusiveIndexI = 0;
    for (exclusiveIndexI = 0 ; exclusiveIndexI < exclusiveIndexes.count; exclusiveIndexI++) {
        NSUInteger exclusiveIndex = ((NSNumber *)exclusiveIndexes[exclusiveIndexI]).unsignedIntegerValue;
        
        // Select all the non-exclusive choices, confirming the answer is including them all
        NSUInteger nonExclusiveIndexI = 0;
        for ( nonExclusiveIndexI = 0 ; nonExclusiveIndexI < nonExclusiveIndexes.count; nonExclusiveIndexI++) {
            NSUInteger index = ((NSNumber *)nonExclusiveIndexes[nonExclusiveIndexI]).unsignedIntegerValue;
            ORKTextChoice *choice = choices[index];
            [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            id answer = group.answer;
            XCTAssert([answer isKindOfClass:[NSArray class]]);
            NSArray *answerArray = answer;
            XCTAssertEqual(answerArray.count, nonExclusiveIndexI+1);
            
            id value = choice.value;
            
            if (value == nil) {
                value = @(index);
            }
            
            XCTAssertEqualObjects(answerArray.lastObject, value, @"%@ vs %@", answerArray.lastObject, value );
            
            ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
            XCTAssertEqual( cell.selectedItem, YES);
        }
        // Now, Select the exclusive choice, which should unselect all the non-exclusive choices chosen
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0]];
        id exclusiveAnswer = group.answer;
        XCTAssert([exclusiveAnswer isKindOfClass:[NSArray class]]);
        NSArray *exclusiveAnswerArray = exclusiveAnswer;
        XCTAssertEqual(exclusiveAnswerArray.count, 1);
        ORKChoiceViewCell *exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(exclusiveCell.selectedItem, YES);
    
        // Test cell deselection.  First deselect the exclusive, and confirm no choices are selected
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0]];
        exclusiveAnswer = group.answer;
        XCTAssert(exclusiveAnswer == ORKNullAnswerValue());
        exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(exclusiveCell.selectedItem, NO);
        
        // Now, select the exclusive choice again, and then select a non-exclusive choice, which
        // should deselect the exclusive choice
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0]];
        exclusiveAnswer = group.answer;
        XCTAssert([exclusiveAnswer isKindOfClass:[NSArray class]]);
        exclusiveAnswerArray = exclusiveAnswer;
        XCTAssertEqual(exclusiveAnswerArray.count, 1);
        exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(exclusiveCell.selectedItem, YES);
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:((NSNumber *)nonExclusiveIndexes[0]).unsignedIntegerValue inSection:0]];
        exclusiveAnswer = group.answer;
        XCTAssert([exclusiveAnswer isKindOfClass:[NSArray class]]);
        exclusiveAnswerArray = exclusiveAnswer;
        XCTAssertEqual(exclusiveAnswerArray.count, 1);
        ORKChoiceViewCell *nonExclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:((NSNumber *)nonExclusiveIndexes[0]).unsignedIntegerValue inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(nonExclusiveCell.selectedItem, YES);
        exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(exclusiveCell.selectedItem, NO);

        // Deselect the non-exclusive to reset for the next test
        [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:((NSNumber *)nonExclusiveIndexes[0]).unsignedIntegerValue inSection:0]];
        
        // If there are more than one exclusive choice, try selecting the current exclusive choice, and then
        // selecting another exclusive choice, which should deselect the first
        if (exclusiveIndexes.count > 1) {
            NSUInteger otherExclusiveIndex = ((NSNumber *)exclusiveIndexes[(exclusiveIndexI+1)%exclusiveIndexes.count]).unsignedIntegerValue;
            
            // Select the current exclusive choice and confirm its selected
            [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0]];
            exclusiveAnswer = group.answer;
            XCTAssert([exclusiveAnswer isKindOfClass:[NSArray class]]);
            exclusiveAnswerArray = exclusiveAnswer;
            XCTAssertEqual(exclusiveAnswerArray.count, 1);
            exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
            XCTAssertEqual(exclusiveCell.selectedItem, YES);

            // Select the other exclusive choice and confirm its selected, and the previously selected exclusive
            // choice is no longer selected
            [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:otherExclusiveIndex inSection:0]];
            exclusiveAnswer = group.answer;
            XCTAssert([exclusiveAnswer isKindOfClass:[NSArray class]]);
            exclusiveAnswerArray = exclusiveAnswer;
            XCTAssertEqual(exclusiveAnswerArray.count, 1);
            exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:otherExclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
            XCTAssertEqual(exclusiveCell.selectedItem, YES);
            exclusiveCell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:exclusiveIndex inSection:0] withReuseIdentifier:@"abc"];
            XCTAssertEqual(exclusiveCell.selectedItem, NO);

            // Deselect the other exclusive choice to reset for the next test
            [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:otherExclusiveIndex inSection:0]];
        }
        
        // Now select all the non-exclusive choices
        for (nonExclusiveIndexI = 0 ; nonExclusiveIndexI < nonExclusiveIndexes.count; nonExclusiveIndexI++) {
            NSUInteger index = ((NSNumber *)nonExclusiveIndexes[nonExclusiveIndexI]).unsignedIntegerValue;
            [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
            XCTAssertEqual( cell.selectedItem, YES);
        }
        XCTAssertEqual(((NSArray *)group.answer).count, nonExclusiveIndexes.count);
        
        // Now, deselect all the non-exclusive choices one at a time
        for (nonExclusiveIndexI = 0 ; nonExclusiveIndexI < nonExclusiveIndexes.count; nonExclusiveIndexI++) {
            NSUInteger index = ((NSNumber *)nonExclusiveIndexes[nonExclusiveIndexI]).unsignedIntegerValue;
            [group didSelectCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            id answer = group.answer;
            if (nonExclusiveIndexI < nonExclusiveIndexes.count - 1) {
                XCTAssert([answer isKindOfClass:[NSArray class]]);
                NSArray *answerArray = answer;
                XCTAssertEqual(answerArray.count, nonExclusiveIndexes.count - nonExclusiveIndexI - 1);
            } else {
                // Answer becomes NSNull when there are no selected cells
                XCTAssert(answer == ORKNullAnswerValue());
            }
            
            ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
            XCTAssertEqual( cell.selectedItem, NO);
        }
        
        id answer = group.answer;
        XCTAssert(answer == ORKNullAnswerValue());
    }
    
    // Test set nil/null answer
    [group setAnswer:nil];
    id answer = group.answer;
    XCTAssertNil(answer);
    NSArray *answerArray = answer;
    XCTAssertEqual(answerArray.count, 0);
    for ( index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssert(cell.selectedItem == NO);
    }
    [group setAnswer:ORKNullAnswerValue()];
    XCTAssertEqual(answerArray.count, 0);

    for (index = 0 ; index < group.size; index++) {
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertEqual(cell.selectedItem, NO);
    }

    // Test set answers
    NSMutableArray *answers = [NSMutableArray new];
    for (index = 0 ; index < group.size; index++) {
        ORKTextChoice *choice = choices[index];
        id value = choice.value;
        
        if (value == nil) {
            value = @(index);
        }
        
        [answers addObject:value];
        
        [group setAnswer:answers];
        
        id answer = group.answer;
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        NSArray *answerArray = answer;
        XCTAssertEqual(answerArray.count, index + 1);
        
        
        XCTAssertEqualObjects(answerArray.lastObject, value, @"%@ vs %@", answerArray.lastObject, value );
        
        ORKChoiceViewCell *cell = [group cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] withReuseIdentifier:@"abc"];
        XCTAssertTrue(cell.selectedItem );
    }
}

- (void)testMultiChoiceWithAllExclusives {
    // All exclusives should behave exactly like single choice mode, so use that test method
    NSArray *choices = [self textChoicesWithAllExclusives];
    ORKTextChoiceAnswerFormat *answerFormat = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choices];
    [self testSingleChoice:answerFormat choices:choices];
}

@end
