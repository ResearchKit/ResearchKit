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

#import "ORKTableCellItem.h"

#import "ORKCaption1Label.h"
#import "ORKFormItem_Internal.h"

#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKFormStep.h>

@implementation ORKTableCellItem

- (instancetype)initWithFormItem:(ORKFormItem *)formItem {
    self = [super init];
    if (self) {
        self.formItem = formItem;
         _answerFormat = [[formItem impliedAnswerFormat] copy];
    }
    return self;
}

- (instancetype)initWithFormItem:(ORKFormItem *)formItem choiceIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        self.formItem = formItem;
        _answerFormat = [[formItem impliedAnswerFormat] copy];
        
        if ([self textChoiceAnswerFormat] != nil) {
            _choice = [self.textChoiceAnswerFormat.textChoices[index] copy];
        }
    }
    return self;
}

- (ORKTextChoiceAnswerFormat *)textChoiceAnswerFormat {
    if ([self.answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        return (ORKTextChoiceAnswerFormat *)self.answerFormat;
    }
    return nil;
}

- (CGFloat)labelWidth {
    static ORKCaption1Label *sharedLabel;
    
    if (sharedLabel == nil) {
        sharedLabel = [ORKCaption1Label new];
    }
    
    sharedLabel.text = _formItem.text;
    
    return [sharedLabel textRectForBounds:CGRectInfinite limitedToNumberOfLines:1].size.width;
}

@end
