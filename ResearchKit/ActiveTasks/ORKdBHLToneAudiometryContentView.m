/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
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


#import "ORKdBHLToneAudiometryContentView.h"

#import "ORKRoundTappingButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat TopToProgressViewMinPadding = 10.0;
static const CGFloat BottomToProgressLabelPadding = 30.0;

@implementation ORKdBHLToneAudiometryButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.borderWidth = 15.0;
        self.layer.borderColor = UIColor.whiteColor.CGColor;
        self.layer.shadowRadius = 10.0;
        self.layer.shadowOpacity = 0.2;
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (void)updateBackgroundColor {
    [super updateBackgroundColor];
    self.layer.borderColor = UIColor.whiteColor.CGColor;
}

@end

@implementation ORKdBHLToneAudiometryContentView {
    NSLayoutConstraint *_topToProgressViewConstraint;
    UILabel *_progressLabel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setAlpha:0];
        [_progressView setHidden:YES];
        [self addSubview:_progressView];
        _tapButton = [[ORKdBHLToneAudiometryButton alloc] init];
        [_tapButton setDiameter:150];
        _tapButton.translatesAutoresizingMaskIntoConstraints = NO;
        _tapButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitAllowsDirectInteraction;

        [self addSubview:_tapButton];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupProgressLabel];

        [self setUpConstraints];
    }
    
    return self;
}

- (void)setupProgressLabel {
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
    }
    _progressLabel.font = [self textFontBold];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    if (@available(iOS 13.0, *)) {
        _progressLabel.textColor = UIColor.secondaryLabelColor;
    } else {
        _progressLabel.textColor = UIColor.grayColor;
    }
    _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_progressLabel];
}

- (UIFont *)textFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold | UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)didMoveToWindow {
    if (self.window != nil && UIAccessibilityIsVoiceOverRunning()) {
        // Ensure that VoiceOver is aware of the direct touch area so that the first tap gets registered
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _tapButton);
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressView.progressTintColor = [self tintColor];
}

- (void)setProgress:(CGFloat)progress
           animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.progressView setAlpha:(progress == 0) ? 0 : 1];
    }];

    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.locale = [NSLocale currentLocale];

    NSString *percentageText = [formatter stringFromNumber:[NSNumber numberWithFloat:progress]];
    _progressLabel.text = [NSString stringWithFormat:ORKLocalizedString(@"dBHL_PROGRESS_COMPLETION_%@", nil), percentageText];
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
    self.tapButton.enabled = NO;
}

- (void)setUpConstraints {
    NSArray<NSLayoutConstraint *> *constraints = @[
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:TopToProgressViewMinPadding],
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_tapButton
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_tapButton
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_progressLabel
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_progressLabel
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:-BottomToProgressLabelPadding]

                                                   ];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
