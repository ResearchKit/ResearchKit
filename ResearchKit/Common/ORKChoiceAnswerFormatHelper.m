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


#import "ORKChoiceAnswerFormatHelper.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionResult_Private.h"
#import "ORKResult_Private.h"

#import "ORKHelpers_Internal.h"


@implementation ORKChoiceAnswerFormatHelper {
    NSArray *_choices;
    BOOL _isValuePicker;
}

- (instancetype)initWithAnswerFormat:(ORKAnswerFormat *)answerFormat {
    self = [super init];
    if (self) {
        if ([answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]) {
            ORKValuePickerAnswerFormat *valuePickerAnswerFormat = (ORKValuePickerAnswerFormat *)answerFormat;
            ORKTextChoice *nullChoice = valuePickerAnswerFormat.nullTextChoice;
            _choices = [@[nullChoice] arrayByAddingObjectsFromArray:valuePickerAnswerFormat.textChoices];
            _isValuePicker = YES;
        } else if ([answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
            ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)answerFormat;
            _choices = textChoiceAnswerFormat.textChoices;
        } else if ([answerFormat isKindOfClass:[ORKImageChoiceAnswerFormat class]]) {
            ORKImageChoiceAnswerFormat *imageChoiceAnswerFormat = (ORKImageChoiceAnswerFormat *)answerFormat;
            _choices = imageChoiceAnswerFormat.imageChoices;
        } else if ([answerFormat isKindOfClass:[ORKTextScaleAnswerFormat class]]) {
            ORKTextScaleAnswerFormat *textScaleAnswerFormat = (ORKTextScaleAnswerFormat *)answerFormat;
            _choices = textScaleAnswerFormat.textChoices;
        } else {
            NSString *exceptionReason = [NSString stringWithFormat:@"%@ is not a currently supported answer format for the choice answer format helper.", NSStringFromClass([answerFormat class])];
            @throw [NSException exceptionWithName:NSGenericException reason:exceptionReason userInfo:nil];
        }
    }
    return self;
}

- (NSUInteger)choiceCount {
    return _choices.count;
}

- (id<ORKAnswerOption>)answerOptionAtIndex:(NSUInteger)index {
    if (index >= _choices.count) {
        return nil;
    }
    
    return _choices[index];
}

- (ORKImageChoice *)imageChoiceAtIndex:(NSUInteger)index {
    id<ORKAnswerOption> option = [self answerOptionAtIndex:index];
    return option && [option isKindOfClass:[ORKImageChoice class]] ? (ORKImageChoice *) option : nil;
}

- (ORKTextChoice *)textChoiceAtIndex:(NSUInteger)index {
    id<ORKAnswerOption> option = [self answerOptionAtIndex:index];
    return option && [option isKindOfClass:[ORKTextChoice class]] ? (ORKTextChoice *) option : nil;
}

- (id)answerForSelectedIndex:(NSUInteger)index {
    return [self answerForSelectedIndexes:@[ @(index) ]];
}

- (id)answerForSelectedIndexes:(NSArray *)indexes {
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSNumber *indexNumber in indexes) {
        
        NSUInteger index = indexNumber.unsignedIntegerValue;
        
        if (index >= _choices.count) {
            continue;
        }
        
        id<ORKAnswerOption> choice = _choices[index];
        id value = choice.value;
        
        if (value == nil) {
            value = _isValuePicker ? @(index - 1) : @(index);
        }
        
        if (_isValuePicker && index == 0) {
            // Don't add to answer array if this index is the 1st value of a value picker
        } else {
            [array addObject:value];
        }
    }
    return array.count > 0 ? [array copy] : ORKNullAnswerValue();
}

- (NSNumber *)selectedIndexForAnswer:(nullable id)answer {
    NSArray *indexes = [self selectedIndexesForAnswer:answer];
    return indexes.count > 0 ? indexes.firstObject : nil;
}

- (NSArray *)selectedIndexesForAnswer:(nullable id)answer {
    // Works with boolean result
    if ([answer isKindOfClass:[NSNumber class]]) {
        answer = @[answer];
    }
    
    NSMutableArray *indexArray = [NSMutableArray new];
    
    if (answer != nil && answer != ORKNullAnswerValue() ) {
        
        NSAssert([answer isKindOfClass:[ORKChoiceQuestionResult answerClass] ], @"Wrong answer type");
        
        for (id answerValue in (NSArray *)answer) {
            id<ORKAnswerOption> matchedChoice = nil;
            for ( id<ORKAnswerOption> choice in _choices) {
                if ([choice.value isEqual:answerValue]) {
                    matchedChoice = choice;
                    break;
                }
            }
            
            if (nil == matchedChoice) {
                NSAssert([answerValue isKindOfClass:[NSNumber class]], @"");
                if (_isValuePicker) {
                    matchedChoice = _choices[((NSNumber *)answerValue).unsignedIntegerValue + 1];
                } else {
                    matchedChoice = _choices[((NSNumber *)answerValue).unsignedIntegerValue];
                }
            }
            
            if (matchedChoice) {
                [indexArray addObject:@([_choices indexOfObject:matchedChoice])];
            }
        }
    }
    
    if (_isValuePicker && indexArray.count == 0) {
        // value picker should at least select the placeholder index
        [indexArray addObject:@(0)];
    }
    
    return [indexArray copy];
    
}

- (NSString *)stringForChoiceAnswer:(id)answer {
    NSMutableArray<NSString *> *answerStrings = [[NSMutableArray alloc] init];
    NSArray *indexes = [self selectedIndexesForAnswer:answer];
    for (NSNumber *index in indexes) {
        NSString *text = [[self answerOptionAtIndex:[index integerValue]] text];
        if (text != nil) {
            [answerStrings addObject:text];
        }
    }
    return [answerStrings componentsJoinedByString:@"\n"];
}

- (NSString *)labelForChoiceAnswer:(id)answer {
    NSMutableArray<NSString *> *answerStrings = [[NSMutableArray alloc] init];
    NSArray *indexes = [self selectedIndexesForAnswer:answer];
    for (NSNumber *index in indexes) {
        NSString *text = [[self answerOptionAtIndex:[index integerValue]] text];
        if (text != nil) {
            [answerStrings addObject:text];
        }
    }
    return [answerStrings componentsJoinedByString:@", "];
}

@end
