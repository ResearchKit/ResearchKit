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


#import "ORKTappingContentView.h"

#import "ORKActiveStepTimer.h"
#import "ORKRoundTappingButton.h"
#import "ORKSubheadlineLabel.h"
#import "ORKTapCountLabel.h"

#import "ORKResult.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


// #define LAYOUT_DEBUG 1

static const CGFloat ProgressViewTopPadding = 10.0;
static const CGFloat TapCaptionLabelTopPadding = 20.0;
static const CGFloat TapCountLabelTopPadding = 10.0;

@interface ORKTappingContentView ()

@property (nonatomic, strong) ORKSubheadlineLabel *tapCaptionLabel;
@property (nonatomic, strong) ORKTapCountLabel *tapCountLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end


@implementation ORKTappingContentView {
    UIView *_buttonContainer;
    NSNumberFormatter *_formatter;
    NSLayoutConstraint *_topToProgressViewConstraint;
    NSLayoutConstraint *_topToCaptionLabelConstraint;
    NSLayoutConstraint *_captionLabelToTapCountLabelConstraint;
    NSLayoutConstraint *_tapButtonToBottomConstraint;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tapCaptionLabel = [ORKSubheadlineLabel new];
        _tapCaptionLabel.textAlignment = NSTextAlignmentCenter;
        _tapCaptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tapCountLabel = [ORKTapCountLabel new];
        _tapCountLabel.textAlignment = NSTextAlignmentCenter;
        _tapCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _buttonContainer = [UIView new];
        _buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setIsAccessibilityElement:YES];
        [_progressView setAlpha:0];
        
        _tapButton1 = [[ORKRoundTappingButton alloc] init];
        _tapButton1.translatesAutoresizingMaskIntoConstraints = NO;
        [_tapButton1 setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        _tapButton1.accessibilityLabel = ORKLocalizedString(@"AX_TAP_BUTTON_1_LABEL", nil);
        _tapButton1.accessibilityHint = ORKLocalizedString(@"AX_TAP_BUTTON_HINT", nil);
        
        _tapButton2 = [[ORKRoundTappingButton alloc] init];
        _tapButton2.translatesAutoresizingMaskIntoConstraints = NO;
        [_tapButton2 setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        _tapButton2.accessibilityLabel = ORKLocalizedString(@"AX_TAP_BUTTON_2_LABEL", nil);
        _tapButton2.accessibilityHint = ORKLocalizedString(@"AX_TAP_BUTTON_HINT", nil);
        
        _lastTappedButton = -1;
        
        [self addSubview:_tapCaptionLabel];
        [self addSubview:_tapCountLabel];
        [self addSubview:_progressView];
        [self addSubview:_buttonContainer];
        
        [_buttonContainer addSubview:_tapButton1];
        [_buttonContainer addSubview:_tapButton2];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _tapCaptionLabel.text = ORKLocalizedString(@"TOTAL_TAPS_LABEL", nil);
        [self setTapCount:0];
        
        [self setUpConstraints];
        
        _tapCountLabel.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
        
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
        self.tapCaptionLabel.backgroundColor = [UIColor orangeColor];
        self.tapCountLabel.backgroundColor = [UIColor greenColor];
        _buttonContainer.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
#endif
    }
     return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    _progressView.progressTintColor = [self tintColor];
}

- (void)setTapCount:(NSUInteger)tapCount {
    if (_formatter == nil) {
        _formatter = [NSNumberFormatter new];
        _formatter.locale = [NSLocale currentLocale];
        _formatter.minimumIntegerDigits = 2;
    }
    _tapCountLabel.text = [_formatter stringFromNumber:@(tapCount)];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [_progressView setProgress:progress animated:animated];
    
    CGFloat previousAlpha = _progressView.alpha;
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [_progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
    
    if (UIAccessibilityIsVoiceOverRunning() && previousAlpha != _progressView.alpha) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
}

- (void)resetStep:(ORKActiveStepViewController *)viewController {
    [super resetStep:viewController];
    [self setTapCount:0];
    _tapButton1.enabled = YES;
    _tapButton2.enabled = YES;
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
    _tapButton1.enabled = NO;
    _tapButton2.enabled = NO;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_buttonContainer, _tapCaptionLabel, _tapCountLabel, _progressView, _tapButton1, _tapButton2);
    _topToProgressViewConstraint = [NSLayoutConstraint constraintWithItem:_progressView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:ProgressViewTopPadding];
    [constraints addObject:_topToProgressViewConstraint];
    
    _topToCaptionLabelConstraint = [NSLayoutConstraint constraintWithItem:_tapCaptionLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_progressView
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:TapCaptionLabelTopPadding];
    [constraints addObject:_topToCaptionLabelConstraint];
    
    _captionLabelToTapCountLabelConstraint = [NSLayoutConstraint constraintWithItem:_tapCountLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_tapCaptionLabel
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:TapCountLabelTopPadding];
    [constraints addObject:_captionLabelToTapCountLabelConstraint];
    
    _tapButtonToBottomConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainer
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:0.0];
    [constraints addObject:_tapButtonToBottomConstraint];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tapCountLabel]-(>=10)-[_buttonContainer]"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressView]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    NSLayoutConstraint *progressViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_progressView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                  multiplier:0.8
                                                                                    constant:0.0];
    progressViewWidthConstraint.priority = UILayoutPriorityRequired - 1;
    [constraints addObject:progressViewWidthConstraint];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_tapCaptionLabel]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_tapCountLabel]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tapButton1]-(==10)-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tapButton2]-(==10)-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tapButton1]-(>=24)-[_tapButton2(==_tapButton1)]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_tapButton1
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_tapButton2
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
