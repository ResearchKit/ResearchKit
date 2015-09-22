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
#import "ORKResult.h"
#import "ORKSkin.h"
#import "ORKSubheadlineLabel.h"
#import "ORKTapCountLabel.h"
#import "ORKHelpers.h"


// #define LAYOUT_DEBUG 1


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
        [_progressView setAlpha:0];
        
        _tapButton1 = [[ORKRoundTappingButton alloc] init];
        _tapButton1.translatesAutoresizingMaskIntoConstraints = NO;
        [_tapButton1 setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        
        _tapButton2 = [[ORKRoundTappingButton alloc] init];
        _tapButton2.translatesAutoresizingMaskIntoConstraints = NO;
        [_tapButton2 setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        
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
        [self updateConstraintConstantsForWindow:self.window];
        
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
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [_progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
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

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
}

- (void)updateLayoutMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin * 2, .right=margin * 2};
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateLayoutMargins];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateLayoutMargins];
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
                                                                 constant:0.0]; // constant set in updateConstraintConstantsForWindow:
    [constraints addObject:_topToProgressViewConstraint];
    
    _topToCaptionLabelConstraint = [NSLayoutConstraint constraintWithItem:_tapCaptionLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]; // constant set in updateConstraintConstantsForWindow:
    [constraints addObject:_topToCaptionLabelConstraint];
    
    _captionLabelToTapCountLabelConstraint = [NSLayoutConstraint constraintWithItem:_tapCountLabel
                                                                          attribute:NSLayoutAttributeFirstBaseline
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_tapCaptionLabel
                                                                          attribute:NSLayoutAttributeFirstBaseline
                                                                         multiplier:1.0
                                                                           constant:0.0]; // constant set in updateConstraintConstantsForWindow:
    [constraints addObject:_captionLabelToTapCountLabelConstraint];
    
    _tapButtonToBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_buttonContainer
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:0.0]; // constant set in updateConstraintConstantsForWindow:
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
                                                                                      toItem:nil
                                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                                  multiplier:1.0
                                                                                    constant:ORKScreenMetricMaxDimension];
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
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tapButton1]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tapButton2]|"
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

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    const CGFloat HeaderBaselineToCaptionTop = ORKGetMetricForWindow(ORKScreenMetricCaptionBaselineToTappingLabelTop, window);
    const CGFloat AssumedHeaderBaselineToStepViewTop = ORKGetMetricForWindow(ORKScreenMetricLearnMoreBaselineToStepViewTop, window);
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin * 2, .right = margin * 2};
    
    static const CGFloat CaptionBaselineToTapCountBaseline = 56;
    static const CGFloat TapButtonBottomToBottom = 36;
    
    // On the iPhone, _progressView is positioned outside the bounds of this view, to be in-between the header and this view.
    // On the iPad, we want to stretch this out a bit so it feels less compressed.
    CGFloat topToProgressViewOffset = 0.0;
    CGFloat topToCaptionLabelOffset = 0.0;
    ORKScreenType screenType = ORKGetVerticalScreenTypeForWindow(window);
    if (screenType == ORKScreenTypeiPad) {
        topToProgressViewOffset = 0;
        topToCaptionLabelOffset = AssumedHeaderBaselineToStepViewTop;
    } else {
        topToProgressViewOffset = (HeaderBaselineToCaptionTop / 3) - AssumedHeaderBaselineToStepViewTop;
        topToCaptionLabelOffset = HeaderBaselineToCaptionTop - AssumedHeaderBaselineToStepViewTop;
    }
    
    _topToProgressViewConstraint.constant = topToProgressViewOffset;
    _topToCaptionLabelConstraint.constant = topToCaptionLabelOffset;
    _captionLabelToTapCountLabelConstraint.constant = CaptionBaselineToTapCountBaseline;
    _tapButtonToBottomConstraint.constant = TapButtonBottomToBottom;
}

- (void)updateConstraints {
    [self updateConstraintConstantsForWindow:self.window];
    [super updateConstraints];
}

@end
