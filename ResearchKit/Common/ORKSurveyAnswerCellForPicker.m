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
#import "ORKDontKnowButton.h"

#import "ORKQuestionStep_Internal.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKHelpers_Internal.h"

static const CGFloat DividerViewTopPadding = 10.0;
static const CGFloat DontKnowButtonTopBottomPadding = 16.0;
static const CGFloat DontKnowButtonBottomPaddingOffset = 10.0;


@interface ORKSurveyAnswerCellForPicker () <ORKPickerDelegate, UIPickerViewDelegate> {
    BOOL _valueChangedDueUserAction;
}

@property (nonatomic, strong) id<ORKPicker> picker;

@end


@implementation ORKSurveyAnswerCellForPicker {
    ORKDontKnowButton *_dontKnowButton;
    UIView *_dividerView;
    BOOL _dontKnowButtonActive;
}

- (void)prepareView {
    [super prepareView];
    
    [self loadPicker];
    _valueChangedDueUserAction = NO;
}

- (void)loadPicker {
    if (_picker == nil) {
        _picker = [ORKPicker pickerWithAnswerFormat:[self.step impliedAnswerFormat] answer:self.answer delegate:self];

        if (@available(iOS 13.0, *)) {
            _picker.pickerView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        }
        
        [self.picker pickerWillAppear];
        
        [self addSubview:_picker.pickerView];
        
        if ([self.step.answerFormat shouldShowDontKnowButton] && !_dontKnowButton) {
            [self setupDontKnowButton];
        }
        
        [self setupConstraintsForView:_picker.pickerView];
    }
}

- (void)setupDontKnowButton {
    if (!_dontKnowButton) {
        _dontKnowButton = [ORKDontKnowButton new];
        _dontKnowButton.customDontKnowButtonText = self.step.answerFormat.customDontKnowButtonText;
        [_dontKnowButton addTarget:self action:@selector(dontKnowButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_dontKnowButton];
     }
     
     if (!_dividerView) {
         _dividerView = [UIView new];
         if (@available(iOS 13.0, *)) {
             [_dividerView setBackgroundColor:[UIColor separatorColor]];
         } else {
             [_dividerView setBackgroundColor:[UIColor lightGrayColor]];
         }
         [self addSubview:_dividerView];
     }
    
    _dontKnowButton.translatesAutoresizingMaskIntoConstraints = NO;
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.answer == [ORKDontKnowAnswer answer]) {
        [self dontKnowButtonWasPressed];
    }
}

- (void)dontKnowButtonWasPressed {
    if (![_dontKnowButton isDontKnowButtonActive]) {
        [_dontKnowButton setButtonActive];
        [self ork_setAnswer:[ORKDontKnowAnswer answer]];
        if (_picker) {
            [_picker setAnswer:nil];
        }
    }
}

- (void)setupConstraintsForView:(UIView *)view {
    if (view) {
        view.translatesAutoresizingMaskIntoConstraints = NO;

        [[view.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
        [[view.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
        
        if (_dontKnowButton) {
            CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
            [[_dividerView.topAnchor constraintEqualToAnchor:view.bottomAnchor constant:DividerViewTopPadding] setActive:YES];
            [[_dividerView.leftAnchor constraintEqualToAnchor:self.leftAnchor] setActive:YES];
            [[_dividerView.rightAnchor constraintEqualToAnchor:self.rightAnchor] setActive:YES];
            [[_dividerView.heightAnchor constraintGreaterThanOrEqualToConstant:separatorHeight] setActive:YES];
            
            [[_dontKnowButton.topAnchor constraintEqualToAnchor:_dividerView.bottomAnchor constant:DontKnowButtonTopBottomPadding] setActive:YES];
            [[_dontKnowButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
            [[_dontKnowButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-DontKnowButtonTopBottomPadding + DontKnowButtonBottomPaddingOffset] setActive:YES];
        } else {
            [[view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
        }
        
    }
}

- (void)answerDidChange {
    if (self.answer != [ORKDontKnowAnswer answer]) {
      [_picker setAnswer:self.answer];
    }
}

- (void)valueChangedDueUserAction:(BOOL)userAction {
    if (userAction) {
        _valueChangedDueUserAction = userAction;
        if (_dontKnowButton && [_dontKnowButton isDontKnowButtonActive]) {
            [_dontKnowButton setButtonInactive];
        }
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
    assert(pickerView == _picker.pickerView);
    return 32;
}

@end
