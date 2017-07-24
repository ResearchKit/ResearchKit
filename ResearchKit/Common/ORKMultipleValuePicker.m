/*
 Copyright (c) 2017, Sage Bionetworks. All rights reserved.
 
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


#import "ORKMultipleValuePicker.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKChoiceAnswerFormatHelper.h"
#import "ORKResult_Private.h"

#import "ORKAccessibilityFunctions.h"


@interface ORKMultipleValuePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray <ORKChoiceAnswerFormatHelper *> *helpers;

@end


@implementation ORKMultipleValuePicker {
    UIPickerView *_pickerView;
    id _answer;
    NSString *_separator;
    BOOL _shouldShowSeparator;
    __weak id<ORKPickerDelegate> _pickerDelegate;
}

@synthesize pickerDelegate = _pickerDelegate;

- (instancetype)initWithAnswerFormat:(ORKMultipleValuePickerAnswerFormat *)answerFormat answer:(id)answer pickerDelegate:(id<ORKPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        NSAssert([answerFormat isKindOfClass:[ORKMultipleValuePickerAnswerFormat class]], @"answerFormat should be ORKMultipleValuePickerAnswerFormat");
    
        // setup the helpers
        NSMutableArray *helpers = [NSMutableArray new];
        for (ORKValuePickerAnswerFormat *valuePicker in answerFormat.valuePickers) {
            [helpers addObject:[[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:valuePicker]];
        }
        _helpers = [helpers copy];

        _separator = answerFormat.separator ?: @" ";
        _shouldShowSeparator = [[_separator stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
        _answer = answer;
        _pickerDelegate = delegate;
    }
    return self;
}

- (UIView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self setAnswer:_answer];
    }
    return _pickerView;
}

- (void)setAnswer:(id)answer {
    _answer = answer;
    
    NSArray *indexNumbers = [self indexNumbersForAnswer:answer];
    if (indexNumbers) {
        [indexNumbers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop __unused) {
            NSUInteger pickerIdx = [self convertToPickerViewComponent:idx];
            [_pickerView selectRow:[obj integerValue] inComponent:pickerIdx animated:NO];
            if (_shouldShowSeparator && idx > 0) {
                [_pickerView selectRow:0 inComponent:pickerIdx - 1 animated:NO];
            }
        }];
    }
    else {
        NSUInteger count = [self numberOfComponentsInPickerView:_pickerView];
        for (NSInteger ii = 0; ii < count; ii++) {
            [_pickerView selectRow:0 inComponent:ii animated:NO];
        }
    }
}

- (id)answer {
    return _answer;
}

- (NSUInteger)convertToPickerViewComponent:(NSUInteger)idx {
    if (_shouldShowSeparator) {
        return idx * 2;
    } else {
        return idx;
    }
}

- (NSUInteger)convertFromPickerViewComponent:(NSUInteger)component {
    if (_shouldShowSeparator) {
        if (component % 2 == 0) {
            return component / 2;
        } else {
            return NSNotFound;
        }
    } else {
        return component;
    }
}
         
- (NSArray <NSNumber *> *)indexNumbersForAnswer:(id)answer {
    if ([answer isKindOfClass:[NSArray class]] &&
        ([(NSArray*)answer count] == self.helpers.count)) {
        
        __block NSMutableArray *indexNumbers = [NSMutableArray new];
        [(NSArray*)answer enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop __unused) {
            NSNumber *indexNumber = [self.helpers[idx] selectedIndexForAnswer:@[obj]];
            if (indexNumber) {
                [indexNumbers addObject:indexNumber];
            } else {
                [indexNumbers addObject:@0];
            }
        }];
        return indexNumbers;
    }
    else {
        return nil;
    }
}

- (NSString *)selectedLabelText {
    if ( _answer == ORKNullAnswerValue() || _answer == nil ) {
        return nil;
    }
    
    NSArray *indexNumbers = [self indexNumbersForAnswer:_answer];
    if (indexNumbers == nil) {
        return nil;
    }
    
    __block NSMutableArray *strings = [NSMutableArray new];
    [indexNumbers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *title = [[self.helpers[idx] textChoiceAtIndex:[obj integerValue]] text];
        if (title) {
            [strings addObject:title];
        }
        else {
            *stop = YES;
        }
    }];
    
    if (strings.count == self.helpers.count) {
        return [strings componentsJoinedByString:_separator];
    } else {
        return nil;
    }
}

- (void)pickerWillAppear {
    [self pickerView];
    [self valueDidChange];
    [self accessibilityFocusOnPickerElement];
}

- (void)valueDidChange {
    
    __block NSMutableArray *answers = [NSMutableArray new];
    [self.helpers enumerateObjectsUsingBlock:^(ORKChoiceAnswerFormatHelper * _Nonnull helper, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger pickerIdx = [self convertToPickerViewComponent:idx];
        NSInteger row = [_pickerView selectedRowInComponent:pickerIdx];
        id answer = [helper answerForSelectedIndex:row];
        if ([answer isKindOfClass:[NSArray class]]) {
            id obj = [(NSArray*)answer firstObject];
            if ((obj != nil) && (obj != ORKNullAnswerValue())) {
                [answers addObject: obj];
            }
        } else {
            *stop = YES;
        }
    }];

    _answer = (answers.count == self.helpers.count) ? answers : ORKNullAnswerValue();
    if ([self.pickerDelegate respondsToSelector:@selector(picker:answerDidChangeTo:)]) {
        [self.pickerDelegate picker:self answerDidChangeTo:_answer];
    }
}


#pragma mark - Accessibility

- (void)accessibilityFocusOnPickerElement {
    if (UIAccessibilityIsVoiceOverRunning()) {
        ORKAccessibilityPerformBlockAfterDelay(0.75, ^{
            NSArray *axElements = [self.pickerView accessibilityElements];
            if ([axElements count] > 0) {
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, [axElements objectAtIndex:0]);
            }
        });
    }
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (_shouldShowSeparator) {
        return self.helpers.count*2 - 1;
    } else {
        return self.helpers.count;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger idx = [self convertFromPickerViewComponent:component];
    if (idx == NSNotFound) {
        return 1;
    } else {
        return self.helpers[idx].choiceCount;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSUInteger idx = [self convertFromPickerViewComponent:component];
    if (idx == NSNotFound) {
        return _separator;
    } else {
        return [[self.helpers[idx] textChoiceAtIndex:row] text] ?: @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self valueDidChange];
}

@end

