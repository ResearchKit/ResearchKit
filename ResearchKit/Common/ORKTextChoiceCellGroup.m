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


#import "ORKTextChoiceCellGroup.h"
#import "ORKChoiceAnswerFormatHelper.h"
#import "ORKAnswerFormat_Internal.h"


@implementation ORKTextChoiceCellGroup {
    ORKChoiceAnswerFormatHelper *_helper;
    BOOL _singleChoice;
    BOOL _immediateNavigation;
    NSIndexPath *_beginningIndexPath;
    
    NSMutableDictionary *_cells;
}

- (instancetype)initWithTextChoiceAnswerFormat:(ORKTextChoiceAnswerFormat *)answerFormat
                                        answer:(id)answer
                            beginningIndexPath:(NSIndexPath *)indexPath
                           immediateNavigation:(BOOL)immediateNavigation {
    self = [super init];
    if (self) {
        _beginningIndexPath = indexPath;
        _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        _singleChoice = answerFormat.style == ORKChoiceAnswerStyleSingleChoice;
        _immediateNavigation = immediateNavigation;
        _cells = [NSMutableDictionary new];
        [self setAnswer:answer];
    }
    return self;
}

- (NSUInteger)size {
    return [_helper choiceCount];
}

- (void)setAnswer:(id)answer {
    _answer = answer;

    [self setSelectedIndexes:[_helper selectedIndexesForAnswer:answer]];
}

- (ORKChoiceViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)identifier {
    if ([self containsIndexPath:indexPath] == NO) {
        return nil;
    }
    
    return [self cellAtIndex:indexPath.row-_beginningIndexPath.row withReuseIdentifier:identifier];
}

- (ORKChoiceViewCell *)cellAtIndex:(NSUInteger)index withReuseIdentifier:(NSString *)identifier {
    ORKChoiceViewCell *cell = _cells[@(index)];
    
    if (cell == nil) {
        cell = [[ORKChoiceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.immediateNavigation = _immediateNavigation;
        ORKTextChoice *textChoice = [_helper textChoiceAtIndex:index];
        cell.shortLabel.text = textChoice.text;
        cell.longLabel.text = textChoice.detailText;
        
        _cells[@(index)] = cell;
        
        [self setSelectedIndexes:[_helper selectedIndexesForAnswer:_answer]];
    }
    
    return cell;
}

- (void)didSelectCellAtIndex:(NSUInteger)index {
    ORKChoiceViewCell *touchedCell = [self cellAtIndex:index withReuseIdentifier:nil];
        
    if (_singleChoice) {
        touchedCell.selectedItem = YES;
        for (ORKChoiceViewCell *cell in _cells.allValues) {
            if (cell != touchedCell) {
                cell.selectedItem = NO;
            }
        }
    } else {
        touchedCell.selectedItem = !touchedCell.selectedItem;
        if (touchedCell.selectedItem) {
            ORKTextChoice *touchedChoice = [_helper textChoiceAtIndex:index];
            for (NSNumber *num in _cells.allKeys) {
                ORKChoiceViewCell *cell = _cells[num];
                ORKTextChoice *choice = [_helper textChoiceAtIndex:num.unsignedIntegerValue];
                if (cell != touchedCell && (touchedChoice.exclusive || (cell.selectedItem && choice.exclusive))) {
                    cell.selectedItem = NO;
                }
            }
        }
    }
    
    _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    if ([self containsIndexPath:indexPath]== NO) {
        return;
    }
    return [self didSelectCellAtIndex:indexPath.row-_beginningIndexPath.row];
}

- (BOOL)containsIndexPath:(NSIndexPath *)indexPath {
    NSUInteger count = _helper.choiceCount;
    
    return (indexPath.section == _beginningIndexPath.section) &&
            (indexPath.row >= _beginningIndexPath.row) &&
            (indexPath.row < (_beginningIndexPath.row + count));
}

- (void)setSelectedIndexes:(NSArray *)indexes {
    for (NSUInteger index = 0; index < self.size; index++ ) {
        BOOL selected = [indexes containsObject:@(index)];
        
        if (selected) {
            // In case the cell has not been created, need to create cell
            ORKChoiceViewCell *cell = [self cellAtIndex:index withReuseIdentifier:nil];
            cell.selectedItem = YES;
        } else {
            // It is ok to not create the cell at here
            ORKChoiceViewCell *cell = _cells[@(index)];
            cell.selectedItem = NO;
        }
    }
}

- (NSArray *)selectedIndexes {
    NSMutableArray *indexes = [NSMutableArray new];
    
    for (NSUInteger index = 0; index < self.size; index++ ) {
        ORKChoiceViewCell *cell = _cells[@(index)];
        if (cell.selectedItem) {
            [indexes addObject:@(index)];
        }
    }
    
    return [indexes copy];
}

- (id)answerForBoolean {
    // Boolean type uses a different format
    if ([_answer isKindOfClass:[NSArray class]] ) {
        NSArray *answerArray = _answer;
        return (answerArray.count > 0)? answerArray.firstObject : nil;
    }
    return _answer;
}

@end
