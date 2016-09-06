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


#import "ORKValuePicker.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKChoiceAnswerFormatHelper.h"
#import "ORKResult_Private.h"

#import "ORKAccessibilityFunctions.h"


@interface ORKValuePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) ORKChoiceAnswerFormatHelper *helper;

@end


@implementation ORKValuePicker {
    UIPickerView *_pickerView;
    id _answer;
    __weak id<ORKPickerDelegate> _pickerDelegate;
}

@synthesize pickerDelegate = _pickerDelegate;

- (instancetype)initWithAnswerFormat:(ORKValuePickerAnswerFormat *)answerFormat answer:(id)answer pickerDelegate:(id<ORKPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        NSAssert([answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]], @"answerFormat should be ORKValuePickerAnswerFormat");
        
        self.helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        self.answer = answer;
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
    
    NSNumber *indexNumber = [_helper selectedIndexForAnswer:answer];
    if (indexNumber) {
        [_pickerView selectRow:indexNumber.unsignedIntegerValue inComponent:0 animated:NO];
    } else {
        [_pickerView selectRow:0 inComponent:0 animated:NO];
    }
}

- (id)answer {
    return _answer;
}

- (NSString *)selectedLabelText {
    if ( _answer == ORKNullAnswerValue() || _answer == nil ) {
        return nil;
    }
   
    NSNumber *indexNumber = [_helper selectedIndexForAnswer:_answer];
    NSInteger row = indexNumber.integerValue;
    
    if (row == 0) {
        return nil;
    }
    
    return [self pickerView:_pickerView titleForRow:row forComponent:0];
}

- (void)pickerWillAppear {
    [self pickerView];
    [self valueDidChange];
    [self accessibilityFocusOnPickerElement];
}

- (void)valueDidChange {
    NSInteger row = [_pickerView selectedRowInComponent:0];
    _answer = [_helper answerForSelectedIndex:row];
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
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _helper.choiceCount;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_helper textChoiceAtIndex:row] text];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self valueDidChange];
}

@end
