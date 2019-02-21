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
        [self updateConstraintConstantsForWindow:self.window];
    }
    
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
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

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    const CGFloat HeaderBaselineToCaptionTop = ORKGetMetricForWindow(ORKScreenMetricCaptionBaselineToTappingLabelTop, window);
    const CGFloat AssumedHeaderBaselineToStepViewTop = ORKGetMetricForWindow(ORKScreenMetricLearnMoreBaselineToStepViewTop, window);
    static const CGFloat buttonBottomToBottom = 36.0;
    
    _topToProgressViewConstraint.constant = (HeaderBaselineToCaptionTop / 3) - AssumedHeaderBaselineToStepViewTop;
    _topToCaptionLabelConstraint.constant = HeaderBaselineToCaptionTop - AssumedHeaderBaselineToStepViewTop;
    _leftButtonToBottomConstraint.constant = buttonBottomToBottom;
    _rightButtonToBottomConstraint.constant = buttonBottomToBottom;
    
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
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _captionLabel, _leftButton, _rightButton, _leftLabel, _rightLabel);
    
    
    _topToProgressViewConstraint = [NSLayoutConstraint constraintWithItem:_progressView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]; // constant will be set in updateConstraintConstantsForWindow:
    [constraints addObject:_topToProgressViewConstraint];
    
    _topToCaptionLabelConstraint = [NSLayoutConstraint constraintWithItem:_captionLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]; // constant will be set in updateConstraintConstantsForWindow:
    [constraints addObject:_topToCaptionLabelConstraint];
    
    _leftButtonToBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_leftButton
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0.0]; // constant will be set in updateConstraintConstantsForWindow:
    
    [constraints addObject:_leftButtonToBottomConstraint];
    
    _rightButtonToBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_rightButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [constraints addObject:_rightButtonToBottomConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_captionLabel
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_leftButton
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_captionLabel
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_rightButton
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_leftButton
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_rightButton
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_captionLabel]-(>=10)-[_leftButton]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_captionLabel]-(>=10)-[_rightButton]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftButton]-(>=10)-[_leftLabel]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightButton]-(>=10)-[_rightLabel]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressView]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    NSLayoutConstraint *progressWidthConstraint = [NSLayoutConstraint constraintWithItem:_progressView
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0
                                                                                constant:ORKScreenMetricMaxDimension];
    progressWidthConstraint.priority = UILayoutPriorityRequired - 1;
    [constraints addObject:progressWidthConstraint];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_captionLabel]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:constraints];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraints {
    [self updateConstraintConstantsForWindow:self.window];
    [super updateConstraints];
}

@end
