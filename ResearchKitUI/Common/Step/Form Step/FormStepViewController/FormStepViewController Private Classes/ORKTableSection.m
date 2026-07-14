/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

#import "ORKTableSection.h"

#import "ORKColorChoiceCellGroup.h"
#import "ORKFormItem_Internal.h"
#import "ORKTableCellItem.h"

#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKFormStep.h>


@implementation ORKTableSection

- (instancetype)initWithSectionIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        self.title = @"";
        _index = index;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)addFormItem:(ORKFormItem *)item {
    if ([[item impliedAnswerFormat] isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        _hasChoiceRows = YES;
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)[item impliedAnswerFormat];
        
        _textChoiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:textChoiceAnswerFormat
                                                                                       answer:nil
                                                                           beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
                                                                          immediateNavigation:NO];
        
        [textChoiceAnswerFormat.textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item choiceIndex:idx];
            [(NSMutableArray *)self.items addObject:cellItem];
        }];
        
    } else {
        
        if ([[item impliedAnswerFormat] isKindOfClass:[ORKColorChoiceAnswerFormat class]]) {
            _hasChoiceRows = YES;
            ORKColorChoiceAnswerFormat *colorChoiceAnswerFormat = (ORKColorChoiceAnswerFormat *)[item impliedAnswerFormat];
            
            _colorChoiceCellGroup = [[ORKColorChoiceCellGroup alloc] initWithColorChoiceAnswerFormat:colorChoiceAnswerFormat
                                                                                              answer:nil
                                                                                  beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
                                                                                 immediateNavigation:NO];
            
            [colorChoiceAnswerFormat.colorChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item choiceIndex:idx];
                [(NSMutableArray *)self.items addObject:cellItem];
            }];
            
            return;
        }
        
        ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item];
        [(NSMutableArray *)self.items addObject:cellItem];
    }
}

- (BOOL)containsFormItem:(ORKFormItem *)formItem {
    for (ORKTableCellItem *cellItem in _items) {
        if (cellItem.formItem.identifier == formItem.identifier) {
            return YES;
        }
    }
    
    return NO;
}

- (CGFloat)maxLabelWidth {
    CGFloat max = 0;
    for (ORKTableCellItem *item in self.items) {
        if (item.labelWidth > max) {
            max = item.labelWidth;
        }
    }
    return max;
}

@end
