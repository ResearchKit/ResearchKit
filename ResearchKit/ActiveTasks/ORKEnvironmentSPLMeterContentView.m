/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKEnvironmentSPLMeterContentView.h"

#import "ORKRoundTappingButton.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKRingView.h"
#import "ORKProgressView.h"

static const CGFloat DBLabelFontSize = 35.0;


@implementation ORKEnvironmentSPLMeterContentView {
    NSLayoutConstraint *_topToProgressViewConstraint;
    UIStackView *stackView;
    UIStackView *miniStackView;
    UILabel *_dBValueLabel;
    UILabel *_unitLabel;
    UILabel *_thresholdLabel;
    CGFloat preValue;
    CGFloat currentValue;
    CAShapeLayer *circle;
    ORKProgressView *_loadingView;
    UIProgressView *_progressView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        preValue = -M_PI_2;
        currentValue = 0.0;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _ringView = [ORKRingView new];
        _ringView.animationDuration = 0.8;
        [self addSubview: _ringView];
        
        [self setupThresholdLabel];
        [self setupDBValueLabel];
        [self setupUnitLabel];
        [_ringView addSubview:_dBValueLabel];
        [_ringView addSubview:_unitLabel];
        [self addSubview:_thresholdLabel];

        _loadingView = [ORKProgressView new];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [_ringView addSubview:_loadingView];
        
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setAlpha:0];
        [self addSubview:_progressView];
        
        [self setUpConstraints];
    }

    return self;
}

- (void) setupDBValueLabel {
    if (!_dBValueLabel) {
        _dBValueLabel = [UILabel new];
    }
    _dBValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dBValueLabel.numberOfLines = 0;
    _dBValueLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    _dBValueLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _dBValueLabel.textAlignment = NSTextAlignmentCenter;
    [_dBValueLabel setText:ORKLocalizedString(@"ENVIRONMENTSPL_CALCULATING", nil)];
    [_dBValueLabel setFont:[UIFont systemFontOfSize:DBLabelFontSize weight:UIFontWeightThin]];
}

- (void) setupUnitLabel {
    if (!_unitLabel) {
        _unitLabel = [UILabel new];
    }
    _unitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _unitLabel.numberOfLines = 0;
    _unitLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:1.0];
    _unitLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _unitLabel.textAlignment = NSTextAlignmentCenter;
    [_unitLabel setText:ORKLocalizedString(@"ENVIRONMENTSPL_UNIT", nil)];
    [_unitLabel setHidden:YES];
    [_unitLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
}

- (void)setupThresholdLabel {
    if (!_thresholdLabel) {
        _thresholdLabel = [UILabel new];
    }
    _thresholdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _thresholdLabel.numberOfLines = 0;
    _thresholdLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:1.0];
    _thresholdLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _thresholdLabel.textAlignment = NSTextAlignmentCenter;
    [_thresholdLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightThin]];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    _progressView.progressTintColor = [self tintColor];
}

- (void)setProgress:(CGFloat)progress
           animated:(BOOL)animated {
    
    [_progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [_progressView setAlpha:(progress == 0) ? 0 : 1];
    }];

}

- (void)setProgressCircle:(CGFloat)progress {
    [_ringView setValue:progress WithColor:progress < 1.0 ? [[UIColor greenColor] colorWithAlphaComponent:0.5] : [[UIColor redColor] colorWithAlphaComponent:0.5]];
}

- (void)setThreshold:(double)threshold {
    if (_thresholdLabel) {
        [_thresholdLabel setText:[NSString stringWithFormat:ORKLocalizedString(@"ENVIRONMENTSPL_THRESHOLD", nil), @(threshold)]];
    }
}

- (void)setDBText:(NSString *)text {
    if (_loadingView) {
        [_loadingView setHidden:YES];
        [_loadingView removeFromSuperview];
        _loadingView = nil;

    }
    if (_dBValueLabel) {
        [_dBValueLabel setText:[NSString stringWithFormat:@"%@", text]];
        [_unitLabel setHidden:NO];
    }
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
}

- (void)updateLayoutMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin * 2, .right = margin * 2};
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

    NSArray *constraints = @[
                             
                             [NSLayoutConstraint constraintWithItem:_ringView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0 constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_ringView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:-80.0],
                             [NSLayoutConstraint constraintWithItem:_dBValueLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_ringView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_dBValueLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_ringView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_unitLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_ringView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_unitLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_dBValueLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0],
                             [NSLayoutConstraint constraintWithItem:_thresholdLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_ringView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_thresholdLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_ringView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-20.0],
                             [NSLayoutConstraint constraintWithItem:_loadingView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_dBValueLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_loadingView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_dBValueLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:5.0],
                             [NSLayoutConstraint constraintWithItem:_progressView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_ringView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:80.0],
                             [NSLayoutConstraint constraintWithItem:_progressView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:5.0],
                             [NSLayoutConstraint constraintWithItem:_progressView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-5.0],
                             
                             ];
    
    [self addConstraints:constraints];
    
    [NSLayoutConstraint activateConstraints:constraints];
}


@end
