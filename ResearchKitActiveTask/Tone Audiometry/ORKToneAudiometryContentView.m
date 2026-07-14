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

#import "ORKRoundTappingButton.h"
#import "ORKUnitLabel.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


static const CGFloat TopToProgressViewMinPadding = 10.0;
static const CGFloat ProgressViewToCaptionMaxPadding = 20.0;
static const CGFloat ButtonToLabelPaddingStandard = 5.0;

@interface ORKToneAudiometryContentView ()

@property (nonatomic, strong, readwrite) UIStackView *contentView;
@property (nonatomic, strong) ORKUnitLabel *captionLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end


@implementation ORKToneAudiometryContentView {
    NSLayoutConstraint *_topToProgressViewConstraint;
    NSLayoutConstraint *_topToCaptionLabelConstraint;
    NSLayoutConstraint *_leftButtonToBottomConstraint;
    NSLayoutConstraint *_rightButtonToBottomConstraint;
    UILabel *_leftLabel;
    UILabel *_rightLabel;
}

@synthesize rightButton = _rightButton;
@synthesize leftButton = _leftButton;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(TopToProgressViewMinPadding, 0, 0, 0);
        [self addSubview:self.contentView];
        [NSLayoutConstraint activateConstraints:@[
            [self.layoutMarginsGuide.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [self.layoutMarginsGuide.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [self.layoutMarginsGuide.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [self.layoutMarginsGuide.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        ]];

        [self.contentView setCustomSpacing:ProgressViewToCaptionMaxPadding afterView:self.progressView];
    }
    return self;
}

- (UIStackView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIStackView alloc] initWithArrangedSubviews:[self arrangedContentViews]];
        _contentView.axis = UILayoutConstraintAxisVertical;
        _contentView.alignment = UIStackViewAlignmentFill;
        _contentView.distribution = UIStackViewDistributionFill;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return  _contentView;
}

- (UIView *)captionLabel {
    if (_captionLabel == nil) {
        _captionLabel = [ORKUnitLabel new];
        _captionLabel.textAlignment = NSTextAlignmentCenter;
        _captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _captionLabel.text = nil;
        [_captionLabel setHidden:YES];

    }
    return _captionLabel;
}

- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setAlpha:0];
    }
    return _progressView;
}

- (ORKRoundTappingButton *)leftButton {
    if (_leftButton == nil) {

        _leftButton = [[ORKRoundTappingButton alloc] init];
        _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftButton setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        _leftButton.accessibilityLabel = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_LEFT_EAR_LABEL", nil);
        _leftButton.accessibilityHint = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_LEFT_EAR_HINT", nil);

    }
    return _leftButton;
}

- (ORKRoundTappingButton *)rightButton {
    if (_rightButton == nil) {

        _rightButton = [[ORKRoundTappingButton alloc] init];
        _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_rightButton setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState: UIControlStateNormal];
        _rightButton.accessibilityLabel = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_RIGHT_EAR_LABEL", nil);
        _rightButton.accessibilityHint = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_RIGHT_EAR_HINT", nil);
    }
    return _rightButton;
}

- (UILabel *)rightLabel {
    if (_rightLabel == nil) {
        _rightLabel = [ORKUnitLabel new];
        _rightLabel.text = ORKLocalizedString(@"TONE_AUDIOMETRY_LABEL_RIGHT_EAR", nil);
        _rightLabel.textColor = [UIColor lightGrayColor];
        _rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rightLabel.isAccessibilityElement = NO;
        _rightLabel.numberOfLines = 0;
        _rightLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _rightLabel;
}

- (UILabel *)leftLabel {
    if (_leftLabel == nil) {
        _leftLabel = [ORKUnitLabel new];
        _leftLabel.text = ORKLocalizedString(@"TONE_AUDIOMETRY_LABEL_LEFT_EAR", nil);
        _leftLabel.textColor = [UIColor lightGrayColor];
        _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _leftLabel.isAccessibilityElement = NO;
        _leftLabel.numberOfLines = 0;
        _leftLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _leftLabel;
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
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
}

- (NSArray *)arrangedContentViews {
    UIStackView *leftButtonContainer = [[UIStackView alloc] initWithArrangedSubviews:@[self.leftButton, self.leftLabel]];
    leftButtonContainer.spacing = ButtonToLabelPaddingStandard;
    leftButtonContainer.axis = UILayoutConstraintAxisVertical;
    leftButtonContainer.alignment = UIStackViewAlignmentCenter;

    UIStackView *rightButtonContainer = [[UIStackView alloc] initWithArrangedSubviews:@[self.rightButton, self.rightLabel]];
    rightButtonContainer.spacing = ButtonToLabelPaddingStandard;
    rightButtonContainer.axis = UILayoutConstraintAxisVertical;
    rightButtonContainer.alignment = UIStackViewAlignmentCenter;

    UIStackView *buttonContainer = [[UIStackView alloc] initWithArrangedSubviews:@[
        [UIView new],
        leftButtonContainer,
        [UIView new],
        rightButtonContainer,
        [UIView new],
    ]];
    buttonContainer.axis = UILayoutConstraintAxisHorizontal;
    buttonContainer.alignment = UIStackViewAlignmentTop;
    buttonContainer.distribution = UIStackViewDistributionFillProportionally;

    [[leftButtonContainer.widthAnchor constraintEqualToAnchor:rightButtonContainer.widthAnchor] setActive:YES];

    return @[self.progressView, self.captionLabel, buttonContainer];
}

@end
