/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKAnswerFormat+FormStepViewControllerAdditions.h"

#import "ORKFormItemCell.h"

#import <ResearchKit/ORKAnswerFormat_Private.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ORKAnswerFormat (FormStepViewControllerAdditions)

- (nullable Class)formStepViewControllerCellClass {
    Class result = nil;
    
    ORKQuestionType type = self.questionType;
    
    if (result == nil) {
        BOOL matchesType = NO;
        matchesType = matchesType || (type == ORKQuestionTypeDateAndTime);
        matchesType = matchesType || (type == ORKQuestionTypeDate);
        matchesType = matchesType || (type == ORKQuestionTypeTimeOfDay);
        matchesType = matchesType || (type == ORKQuestionTypeTimeInterval);
        matchesType = matchesType || (type == ORKQuestionTypeMultiplePicker);
        matchesType = matchesType || (type == ORKQuestionTypeHeight);
        matchesType = matchesType || (type == ORKQuestionTypeWeight);
        matchesType = matchesType || (type == ORKQuestionTypeAge);
        matchesType = matchesType || (type == ORKQuestionTypeYear);
        result = matchesType ? [ORKFormItemPickerCell class] : result;
    }
    
    if (result == nil) {
        BOOL matchesType = NO;
        matchesType = matchesType || (type == ORKQuestionTypeDecimal);
        matchesType = matchesType || (type == ORKQuestionTypeInteger);
        result = matchesType ? [ORKFormItemNumericCell class] : result;
    }

    if (result == nil) {
        BOOL matchesType = NO;
        matchesType = matchesType || (type == ORKQuestionTypeScale);
        result = matchesType ? [ORKFormItemScaleCell class] : result;
    }

    if (result == nil) {
        BOOL matchesType = NO;
        matchesType = matchesType || (type == ORKQuestionTypeLocation);
        result = matchesType ? [ORKFormItemLocationCell class] : result;
    }

    if (result == nil) {
        BOOL matchesType = NO;
        matchesType = matchesType || (type == ORKQuestionTypeSES);
        result = matchesType ? [ORKFormItemSESCell class] : result;
    }

    return  result;
}

@end

@implementation ORKImageChoiceAnswerFormat (FormStepViewControllerAdditions)


- (nullable Class)formStepViewControllerCellClass {
    ORKQuestionType type = self.questionType;
    
    BOOL matchesType = NO;
    matchesType = matchesType || (type == ORKQuestionTypeSingleChoice);
    matchesType = matchesType || (type == ORKQuestionTypeMultipleChoice);
    
    Class result = matchesType ? [ORKFormItemImageSelectionCell class] : [super formStepViewControllerCellClass];
    return result;
}

@end

@implementation ORKValuePickerAnswerFormat (FormStepViewControllerAdditions)

- (nullable Class)formStepViewControllerCellClass {
    ORKQuestionType type = self.questionType;
    
    BOOL matchesType = NO;
    matchesType = matchesType || (type == ORKQuestionTypeSingleChoice);
    matchesType = matchesType || (type == ORKQuestionTypeMultipleChoice);
    
    Class result = matchesType ? [ORKFormItemPickerCell class] : [super formStepViewControllerCellClass];
    return result;
}

@end

@implementation ORKConfirmTextAnswerFormat (FormStepViewControllerAdditions)

- (nullable Class)formStepViewControllerCellClass {
    ORKQuestionType type = self.questionType;

    BOOL matchesType = NO;
    matchesType = matchesType || (type == ORKQuestionTypeText);
    
    Class result = matchesType ? [ORKFormItemConfirmTextCell class] : [super formStepViewControllerCellClass];
    return result;
}

@end

@implementation ORKTextAnswerFormat (FormStepViewControllerAdditions)

- (nullable Class)formStepViewControllerCellClass {
    Class result = nil;
    
    ORKQuestionType type = self.questionType;
    BOOL matchesType = NO;
    matchesType = matchesType || (type == ORKQuestionTypeText);

    if (matchesType == YES) {
        result = (self.multipleLines == YES) ? [ORKFormItemTextCell class] : [ORKFormItemTextFieldCell class];
    } else {
        result = [super formStepViewControllerCellClass];
    }
    
    return result;
}


@end

NS_ASSUME_NONNULL_END
