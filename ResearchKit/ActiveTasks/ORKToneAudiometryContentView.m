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

#import "ORKToneAudiometryContentView.h"
#import "ORKSkin.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers.h"

@interface ORKToneAudiometryContentView ()

@property (nonatomic, strong) ORKUnitLabel *captionLabel;
@property (nonatomic, strong) UIProgressView *progressView;

- (void)setupConstraints;

@end


@implementation ORKToneAudiometryContentView {
    ORKScreenType _screenType;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        _screenType = ORKGetScreenTypeForWindow(self.window);
        _captionLabel = [ORKUnitLabel new];
        _captionLabel.textAlignment = NSTextAlignmentCenter;
        _captionLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setAlpha:0];

        _tapButton = [[ORKRoundTappingButton alloc] init];
        _tapButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_tapButton setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];

        [self addSubview:_captionLabel];
        [self addSubview:_progressView];
        [self addSubview:_tapButton];

        self.translatesAutoresizingMaskIntoConstraints = NO;

        _captionLabel.text = nil;

        [self setupConstraints];
        [self setNeedsUpdateConstraints];
    }

    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressView.progressTintColor = [self tintColor];
}

- (void)setProgress:(CGFloat)progress
            caption:(NSString *)caption
           animated:(BOOL)animated {
    self.captionLabel.text = caption;

    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
    self.tapButton.enabled = NO;
}

- (void)setupConstraints {
    ORKScreenType screenType = _screenType;
    const CGFloat HeaderBaselineToCaptionTop = ORKGetMetricForScreenType(ORKScreenMetricCaptionBaselineToTappingLabelTop, screenType);
    const CGFloat AssumedHeaderBaselineToStepViewTop = ORKGetMetricForScreenType(ORKScreenMetricLearnMoreBaselineToStepViewTop, screenType);
    CGFloat margin = ORKStandardHorizMarginForView(self);
    self.layoutMargins = (UIEdgeInsets) { .left=margin*2, .right=margin*2 };

    static const CGFloat TapButtonBottomToBottom = 36;

    NSMutableArray *constraints = [NSMutableArray array];

    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _captionLabel, _tapButton);
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_progressView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1 constant:(HeaderBaselineToCaptionTop/3) - AssumedHeaderBaselineToStepViewTop]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:_captionLabel
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1 constant:(HeaderBaselineToCaptionTop - AssumedHeaderBaselineToStepViewTop)]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_tapButton
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1 constant:TapButtonBottomToBottom]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_captionLabel]-(>=10)-[_tapButton]"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil views:views]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressView]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    NSLayoutConstraint *wideProgress = [NSLayoutConstraint constraintWithItem:_progressView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:2000];
    wideProgress.priority = UILayoutPriorityRequired-1;
    [constraints addObject:wideProgress];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_captionLabel]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:_tapButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1 constant:0]];

    [self addConstraints:constraints];

    [NSLayoutConstraint activateConstraints:constraints];
}

@end
