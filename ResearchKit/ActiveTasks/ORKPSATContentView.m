/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKPSATContentView.h"
#import "ORKSkin.h"
#import "ORKPSATKeyboardView.h"
#import "ORKTapCountLabel.h"
#import "ORKBorderedButton.h"
#import "ORKVoiceEngine.h"
#import "ORKHelpers.h"


@interface ORKPSATContentView ()

@property (nonatomic, assign, getter = isAuditory) BOOL auditory;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKTapCountLabel *digitLabel;

@end


@implementation ORKPSATContentView

- (instancetype)initWithFrame:(CGRect)frame {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithPresentationMode:ORKPSATPresentationModeAuditory];
    return self;
}

- (instancetype)initWithPresentationMode:(ORKPSATPresentationMode)presentationMode {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        _digitLabel = [ORKTapCountLabel new];
        _digitLabel.textAlignment = NSTextAlignmentCenter;
        _digitLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_digitLabel];
        _auditory = (presentationMode & ORKPSATPresentationModeAuditory) ? YES : NO;
        if (!(presentationMode & ORKPSATPresentationModeVisual)) {
            _digitLabel.hidden = YES;
        }
        
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setAlpha:0];
        [self addSubview:_progressView];
        
        _keyboardView = [ORKPSATKeyboardView new];
        _keyboardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_keyboardView];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self setNeedsUpdateConstraints];
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    self.keyboardView.enabled = enabled;
}

- (void)setAddition:(NSUInteger)additionIndex forTotal:(NSUInteger)totalAddition withDigit:(NSNumber *)digit {
    if (digit.integerValue == -1) {
        self.digitLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        self.digitLabel.text = ORKLocalizedString(@"PSAT_NO_DIGIT", nil);
    } else {
        [self.keyboardView.selectedAnswerButton setSelected:NO];
        self.digitLabel.textColor = nil;
        self.digitLabel.text = [NSNumberFormatter localizedStringFromNumber:digit
                                                                numberStyle:NSNumberFormatterNoStyle];
        if (self.isAuditory) {
            [[ORKVoiceEngine sharedVoiceEngine] speakInt:digit.integerValue];
        }
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressView.progressTintColor = self.tintColor;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:self.constraints];
    
    const CGFloat ORKPSATKeyboardWidth = ORKGetMetricForWindow(ORKScreenMetricPSATKeyboardViewWidth, self.window);
    const CGFloat ORKPSATKeyboardHeight = ORKGetMetricForWindow(ORKScreenMetricPSATKeyboardViewHeight, self.window);
    
    NSMutableArray *constraints = [NSMutableArray array];

    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _digitLabel, _keyboardView);
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressView]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_keyboardView(==keyboardWidth)]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:@{ @"keyboardWidth": @(ORKPSATKeyboardWidth) }
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_keyboardView(==keyboardHeight)]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:@{ @"keyboardHeight": @(ORKPSATKeyboardHeight) }
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_progressView]-[_digitLabel]-(>=10)-[_keyboardView]-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

@end
