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


#import "ORKSurveyAnswerCellForPicker.h"

#import "ORKPicker.h"

#import "ORKQuestionStep_Internal.h"


@interface ORKSurveyAnswerCellForPicker () <ORKPickerDelegate, UIPickerViewDelegate> {
    UIPickerView *_tempPicker;
    BOOL _valueChangedDueUserAction;
}

@property (nonatomic, strong) id<ORKPicker> picker;

@end


@implementation ORKSurveyAnswerCellForPicker

- (void)prepareView {
    [super prepareView];
    
    // Add a temporary picker view to show the lines the date picker will have
    if (!_tempPicker && !self.picker) {
        _tempPicker = [UIPickerView new];
        _tempPicker.delegate = self;
        [self addSubview:_tempPicker];
        
        [self addHorizontalHuggingConstraintForView:_tempPicker];
    }
    
    _valueChangedDueUserAction = NO;
}

- (void)loadPicker {
    if (_picker == nil) {
        _picker = [ORKPicker pickerWithAnswerFormat:[self.step impliedAnswerFormat] answer:self.answer delegate:self];
        
        [self.picker pickerWillAppear];
        
        [self addSubview:_picker.pickerView];
        
        // Removing _tempPicker automatically removes its constraints
        [_tempPicker removeFromSuperview];
        _tempPicker = nil;
        
        [self addHorizontalHuggingConstraintForView:_picker.pickerView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_picker) {
        CGSize pickerSize = [_picker.pickerView sizeThatFits:(CGSize){self.bounds.size.width,CGFLOAT_MAX}];
        pickerSize.width = MIN(pickerSize.width, self.bounds.size.width);
        _picker.pickerView.frame = (CGRect){{0,0}, pickerSize};
    }
    
    if (_tempPicker) {
        CGSize pickerSize = [_tempPicker sizeThatFits:(CGSize){self.bounds.size.width,CGFLOAT_MAX}];
        pickerSize.width = MIN(pickerSize.width, self.bounds.size.width);
        _tempPicker.frame = (CGRect){{0,0}, pickerSize};
    }
}

- (void)addHorizontalHuggingConstraintForView:(UIView *)view {
    if (view) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                                                       metrics:nil
                                                                         views:@{ @"view": view }];
        [NSLayoutConstraint activateConstraints:constraints];
    }
}

- (void)answerDidChange {
    [_picker setAnswer:self.answer];
}

- (void)valueChangedDueUserAction:(BOOL)userAction {
    if (userAction) {
        _valueChangedDueUserAction = userAction;
    }
    
    [self ork_setAnswer:_picker.answer];
}

- (void)ork_setAnswer:(id)answer {
    // Override
    _answer = [answer copy];
    [self.delegate answerCell:self answerDidChangeTo:answer dueUserAction:_valueChangedDueUserAction];
}

- (void)picker:(id)picker answerDidChangeTo:(id)answer {
    [self valueChangedDueUserAction:YES];
}


+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return 162.0 + 30.0;
}

#pragma mark UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    assert(pickerView == _tempPicker);
    return 32;
}

@end
