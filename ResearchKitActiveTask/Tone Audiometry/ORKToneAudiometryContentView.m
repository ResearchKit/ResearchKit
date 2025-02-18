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
static const CGFloat CaptionLabelToButtonMinPadding = 5.0;

@interface ORKToneAudiometryContentView ()

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

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _captionLabel = [ORKUnitLabel new];
        _captionLabel.textAlignment = NSTextAlignmentCenter;
        _captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _progressView = [UIProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progressTintColor = [self tintColor];
        [_progressView setAlpha:0];
        
        _leftButton = [[ORKRoundTappingButton alloc] init];
        _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftButton setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        
        _rightButton = [[ORKRoundTappingButton alloc] init];
        _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_rightButton setTitle:ORKLocalizedString(@"TAP_BUTTON_TITLE", nil) forState: UIControlStateNormal];
        
        _leftLabel = [ORKUnitLabel new];
        _rightLabel = [ORKUnitLabel new];
        
        _leftLabel.text = ORKLocalizedString(@"TONE_AUDIOMETRY_LABEL_LEFT_EAR", nil);
        _rightLabel.text = ORKLocalizedString(@"TONE_AUDIOMETRY_LABEL_RIGHT_EAR", nil);
        
        _leftLabel.textColor = [UIColor lightGrayColor];
        _rightLabel.textColor = [UIColor lightGrayColor];
        
        _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _leftButton.accessibilityLabel = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_LEFT_EAR_LABEL", nil);
        _leftButton.accessibilityHint = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_LEFT_EAR_HINT", nil);
        _rightButton.accessibilityLabel = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_RIGHT_EAR_LABEL", nil);
        _rightButton.accessibilityHint = ORKLocalizedString(@"AX_TONE_AUDIOMETRY_BUTTON_RIGHT_EAR_HINT", nil);
        // The labels will be included in the button accessibility label, so we should not expose them additionally here.
        _leftLabel.isAccessibilityElement = NO;
        _rightLabel.isAccessibilityElement = NO;
        
        [self addSubview:_captionLabel];
        [self addSubview:_progressView];
        [self addSubview:_leftButton];
        [self addSubview:_rightButton];
        [self addSubview:_leftLabel];
        [self addSubview:_rightLabel];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _captionLabel.text = nil;
        [_captionLabel setHidden:YES];
        
        [self setUpConstraints];
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
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
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
                                                 [NSLayoutConstraint constraintWithItem:_captionLabel
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                 toItem:_progressView
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:ProgressViewToCaptionMaxPadding],
                                                 [NSLayoutConstraint constraintWithItem:_captionLabel
                                                                              attribute:NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeCenterX
                                                                             multiplier:1.0
                                                                               constant:0.0],
                                                 
                                                 [NSLayoutConstraint constraintWithItem:_leftButton
                                                                              attribute:NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeCenterX
                                                                             multiplier:0.5
                                                                               constant:0.0],
                                                 [NSLayoutConstraint constraintWithItem:_rightButton
                                                                              attribute:NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeCenterX
                                                                             multiplier:1.5
                                                                               constant:0.0],
                                                 
                                                 [NSLayoutConstraint constraintWithItem:_leftLabel
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:0.0],
                                                 [NSLayoutConstraint constraintWithItem:_rightLabel
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:0.0],
                                                 
                                                 [NSLayoutConstraint constraintWithItem:_leftLabel
                                                                              attribute:NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:_leftButton
                                                                              attribute:NSLayoutAttributeCenterX
                                                                             multiplier:1.0
                                                                               constant:0.0],
                                                 [NSLayoutConstraint constraintWithItem:_rightLabel
                                                                              attribute:NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:_rightButton
                                                                              attribute:NSLayoutAttributeCenterX
                                                                             multiplier:1.0
                                                                               constant:0.0],
                                                 
                                                 [NSLayoutConstraint constraintWithItem:_leftButton
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:_leftLabel
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:-ButtonToLabelPaddingStandard],
                                                 [NSLayoutConstraint constraintWithItem:_rightButton
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:_rightLabel
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:-ButtonToLabelPaddingStandard],
                                                 
                                                 [NSLayoutConstraint constraintWithItem:_leftButton
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                 toItem:_captionLabel
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:CaptionLabelToButtonMinPadding],
                                                 [NSLayoutConstraint constraintWithItem:_rightButton
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                 toItem:_captionLabel
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:CaptionLabelToButtonMinPadding],
                                                 ];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
