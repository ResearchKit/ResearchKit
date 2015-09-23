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


#import "ORKTimeIntervalPicker.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKHelpers.h"


@interface ORKDatePicker : UIDatePicker

@end


@implementation ORKDatePicker

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    // Work around for UIDatePicker UIControlEventValueChanged only fired on second selection
    dispatch_async(dispatch_get_main_queue(), ^{
        self.countDownDuration = self.countDownDuration;
    });
}

@end


@interface ORKTimeIntervalPicker ()

@property (nonatomic, strong) ORKTimeIntervalAnswerFormat *answerFormat;

@end


@implementation ORKTimeIntervalPicker {
    id _answer;
    __weak id<ORKPickerDelegate> _pickerDelegate;
    ORKDatePicker *_pickerView;
}

@synthesize pickerDelegate = _pickerDelegate;
@synthesize answer = _answer;

- (instancetype)initWithAnswerFormat:(ORKTimeIntervalAnswerFormat *)answerFormat
                              answer:(id)answer
                      pickerDelegate:(id<ORKPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.answerFormat = answerFormat;
        self.answer = answer;
        self.pickerDelegate = delegate;
    }
    return self;
}

- (UIView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[ORKDatePicker alloc] init];
        _pickerView.datePickerMode = UIDatePickerModeCountDownTimer;
        [_pickerView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self setAnswerFormat:_answerFormat];
        [self setAnswer:_answer];
    }
    return _pickerView;
}

- (void)setAnswer:(id)answer {
    _answer = answer;
    
    NSTimeInterval value;
    if (answer != nil && answer != ORKNullAnswerValue()  && [answer isKindOfClass:[NSNumber class]]) {
        value = ((NSNumber *)answer).doubleValue;
    } else {
        value = [_answerFormat pickerDefaultDuration];
    }
    
    _pickerView.countDownDuration = value;
}

- (void)setAnswerFormat:(ORKTimeIntervalAnswerFormat *)answerFormat {
    _answerFormat = answerFormat;
    NSAssert([answerFormat isKindOfClass:[ORKTimeIntervalAnswerFormat class]], @"");
    
    _pickerView.minuteInterval = [answerFormat step];
}

- (NSString *)selectedLabelText {
    return  (_answer == nil || _answer == ORKNullAnswerValue()) ? nil : [ORKTimeIntervalLabelFormatter() stringFromTimeInterval:((NSNumber *)self.answer).floatValue];
}

- (void)pickerWillAppear {
    [self pickerView];
    [self valueChanged:nil];
}

- (void)valueChanged:(id)sender {
    NSTimeInterval interval = _pickerView.countDownDuration;
    _answer = @(interval);
    
    if ([self.pickerDelegate respondsToSelector:@selector(picker:answerDidChangeTo:)]) {
        [self.pickerDelegate picker:self answerDidChangeTo:self.answer];
    }
}

@end
