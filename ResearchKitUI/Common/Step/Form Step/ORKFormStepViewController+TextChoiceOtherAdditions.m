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

#import "ORKFormStepViewController+TextChoiceOtherAdditions.h"

#import <ResearchKit/ORKAnswerFormat_Internal.h>
#import <ResearchKit/ORKFormStep.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ORKFormStepViewController (TextChoiceOtherAdditions)

- (NSArray *)updatedAnswersForFormItem:(ORKFormItem *)formItem
                               answers:(NSArray *)answers
                   otherTextChoiceText:(NSString *)text {
    ORKTextChoiceOther *textChoiceOther = [self textChoiceOtherForFormItem:formItem];
    if (textChoiceOther == nil) {
        return answers;
    }

    NSInteger indexToUpdate = [self indexForTextChoiceOther:textChoiceOther answers:answers];

    NSArray *updatedAnswers;
    if (indexToUpdate == NSNotFound) {
        updatedAnswers = answers;
    } else {
        NSMutableArray *answersCopy = [answers mutableCopy];
        answersCopy[indexToUpdate] = [self answerForTextChoiceOther:textChoiceOther
                                                        enteredText:text];
        updatedAnswers = answersCopy;
    }
    return updatedAnswers;
}

- (nullable ORKTextChoiceOther *)textChoiceOtherForFormItem:(ORKFormItem *)formItem {
    NSInteger otherTextChoiceIndex = [formItem.answerFormat.choices
        indexOfObjectPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          return [obj isKindOfClass:[ORKTextChoiceOther class]];
        }];

    if (otherTextChoiceIndex == NSNotFound) {
        return nil;
    }

    return formItem.answerFormat.choices[otherTextChoiceIndex];
}

- (NSInteger)indexForTextChoiceOther:(ORKTextChoiceOther *)textChoiceOther
                             answers:(NSArray *)answers {
    NSInteger indexForOtherAnswer = [answers indexOfObject:textChoiceOther.answer];

    if (indexForOtherAnswer == NSNotFound) {
        return NSNotFound;
    }

    return indexForOtherAnswer;
}

- (NSString *)answerForTextChoiceOther:(ORKTextChoiceOther *)textChoiceOther
                           enteredText:(NSString *)text {
    NSString *answer;
    if (text.length > 0) {
        answer = text;
    } else {
        answer = textChoiceOther.text;
    }
    return answer;
}

@end

NS_ASSUME_NONNULL_END
