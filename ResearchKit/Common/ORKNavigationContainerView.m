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

#import "ORKNavigationContainerView_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat standardSpacing = 5.0;
static const CGFloat skipButtonHeight = 50.0;
static const CGFloat topSpacing = 24.0;
static const CGFloat bottomSpacing = 34.0;
static const CGFloat activityIndicatorPadding = 24.0;

@implementation ORKNavigationContainerView {
    UIActivityIndicatorView *_activityIndicatorView;
    
    NSArray *_leftRightPaddingConstraints;
    UIVisualEffectView *effectView;
    UIColor *_appTintColor;
    
    BOOL _continueOrSkipButtonJustTapped;
    BOOL _removeVisualEffect;
    NSMutableArray *_regularConstraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:ORKColor(ORKNavigationContainerColorKey)];
        [self setupVisualEffectView];
        [self setupViews];
        [self setupFootnoteLabel];
        self.preservesSuperviewLayoutMargins = NO;
        _appTintColor = nil;
        self.skipButtonStyle = ORKNavigationContainerButtonStyleTextBold;
        [self updateContinueAndSkipEnabled];
    }
    return self;
}

- (void)removeStyling {
    _removeVisualEffect = YES;
    if (effectView) {
        [effectView removeFromSuperview];
        effectView = nil;
    }
}

- (void)flattenIfNeeded {
    if (![self hasContinueOrSkip] || (self.continueButtonItem == nil && [self neverHasSkipButton] && [self neverHasFootnote])) {
        [[self.heightAnchor constraintEqualToConstant:0] setActive:YES];
    }
}

- (void)setupVisualEffectView {
    if (!effectView && !_removeVisualEffect) {
        self.backgroundColor = [UIColor clearColor];
        UIVisualEffect *blurEffect;
        if (@available(iOS 13.0, *)) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
        } else {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }
        effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    effectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:effectView];
}

- (CGFloat)effectViewOpacity {
    return effectView.alpha;
}

- (void)setStylingOpactity:(CGFloat)opacity animated:(BOOL)animated {
    if (animated == YES) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            effectView.alpha = opacity;
        }];
    } else {
        effectView.alpha = opacity;
    }
}

- (void)setupContinueButton {
    if (!_continueButton) {
        _continueButton = [[ORKContinueButton alloc] initWithTitle:@"" isDoneButton:NO];
    }
    _continueButton.alpha = 0;
    _continueButton.exclusiveTouch = YES;
    _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_continueButton];
}

- (void)setupSkipButton {
    if (!_skipButton) {
        _skipButton = [ORKBorderedButton new];
    }
    _skipButton.exclusiveTouch = YES;
    [_skipButton setTitle:nil forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_skipButton];
}

- (void)setupFootnoteLabel {
    _footnoteLabel = [ORKFootnoteLabel new];
    _footnoteLabel.numberOfLines = 0;
    _footnoteLabel.textAlignment = NSTextAlignmentNatural;
    _footnoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_footnoteLabel];
}

- (void)setupViews {
    [self setupContinueButton];
    [self setupSkipButton];
    [self setUpConstraints];
}

- (void)didMoveToWindow {
    _appTintColor = self.window.tintColor ? : ORKColor(ORKBlueHighlightColorKey);
    _continueButton.normalTintColor = _appTintColor;
    _skipButton.normalTintColor = _appTintColor;
}

- (void)setSkipButtonStyle:(ORKNavigationContainerButtonStyle)skipButtonStyle {
    _skipButtonStyle = skipButtonStyle;
    switch (skipButtonStyle) {
        case ORKNavigationContainerButtonStyleTextStandard:
            [_skipButton setAppearanceAsTextButton];
            break;
        case ORKNavigationContainerButtonStyleTextBold:
            [_skipButton setAppearanceAsBoldTextButton];
            break;
        case ORKNavigationContainerButtonStyleRoundedRect:
            [_skipButton resetAppearanceAsBorderedButton];
            break;
        default:
            [_skipButton setAppearanceAsTextButton];
            break;
    }
}

- (void)setTopMargin:(CGFloat)topMargin {
    _topMargin = topMargin;
    [self updateContinueAndSkipEnabled];
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    [self updateContinueAndSkipEnabled];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
}

- (void)skipButtonAction:(id)sender {
    [self skipAction:sender];

    // Disable button for 0.5s
    ((UIView *)sender).userInteractionEnabled = NO;
    ((ORKTextButton *)sender).isInTransition = YES;
    _continueOrSkipButtonJustTapped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _continueOrSkipButtonJustTapped = NO;
        // Re-enable skip button
        ((UIView *)sender).userInteractionEnabled = YES;
        ((ORKTextButton *)sender).isInTransition = NO;
    });
}

- (void)continueButtonAction:(id)sender {
    if (_useNextForSkip && _skipButtonItem && !_continueButtonItem) {
        [self skipAction:sender];
    } else {
        [self continueAction:sender];
    }
    
    // Disable button for 0.5s
    ((UIView *)sender).userInteractionEnabled = NO;
    ((ORKTextButton *)sender).isInTransition = YES;
    _continueOrSkipButtonJustTapped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _continueOrSkipButtonJustTapped = NO;
        ((ORKTextButton *)sender).isInTransition = NO;
        [self updateContinueAndSkipEnabled];
    });
}

- (void)continueAction:(id)sender {
    ORKSuppressPerformSelectorWarning(
                                      (void)[_continueButtonItem.target performSelector:_continueButtonItem.action withObject:self];
                                      );
}

- (void)skipAction:(id)sender {
    ORKSuppressPerformSelectorWarning(
                                      (void)[_skipButtonItem.target performSelector:_skipButtonItem.action withObject:_skipButton];
                                      );
}

- (void)setNeverHasContinueButton:(BOOL)neverHasContinueButton {
    _neverHasContinueButton = neverHasContinueButton;
    [self setNeedsUpdateConstraints];
}

- (BOOL)neverHasSkipButton {
    return !self.optional;
}

- (BOOL)neverHasFootnote {
    return _footnoteLabel.text.length == 0;
}

- (BOOL)skipButtonHidden {
    return (!_skipButtonItem) || _useNextForSkip || !self.optional;
}

- (CGFloat)skipButtonAlpha {
    return ([self skipButtonHidden] ? 0.0 : 1.0);
}

- (BOOL)hasContinueOrSkip {
    return !([self neverHasContinueButton] && [self neverHasSkipButton] && [self neverHasFootnote]);
}

- (BOOL)wasContinueOrSkipButtonJustPressed {
    return _continueOrSkipButtonJustTapped;
}

- (void)updateContinueAndSkipEnabled {
    [_skipButton setTitle:_skipButtonItem.title ? : ORKLocalizedString(@"BUTTON_SKIP", nil) forState:UIControlStateNormal];

    if ([self neverHasContinueButton]) {
        _continueButton.hidden = YES;
    }

    if (_useNextForSkip && _skipButtonItem) {
        _continueButton.alpha = (_continueButtonItem == nil && _skipButtonItem == nil) ? 0 : 1;
        [_continueButton setTitle: _continueButtonItem.title ? : _skipButtonItem.title forState:UIControlStateNormal];
        _continueButton.accessibilityHint = _continueButtonItem.accessibilityHint ? : _skipButtonItem.accessibilityHint;
    } else {
        _continueButton.alpha = (_continueButtonItem == nil) ? 0 : 1;
        [_continueButton setTitle: _continueButtonItem.title forState:UIControlStateNormal];
        _continueButton.accessibilityHint = _continueButtonItem.accessibilityHint;
    }
    
    _continueButton.enabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    _continueButton.disableTintColor = [[self tintColor] colorWithAlphaComponent:0.3];
    
    // Do not modify _continueButton.userInteractionEnabled during continueButton disable period
    // or when the activity indicator is present
    if (_continueOrSkipButtonJustTapped == NO && _activityIndicatorView == nil) {
        _continueButton.userInteractionEnabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    }
    
    _skipButton.alpha = [self skipButtonAlpha];
    [self setNeedsUpdateConstraints];
    [self setUpConstraints];
}

- (void)showActivityIndicator:(BOOL)showActivityIndicator {
    
    [_continueButton setUserInteractionEnabled:!showActivityIndicator];

    if (showActivityIndicator == YES) {
        if (_activityIndicatorView == nil) {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [_activityIndicatorView startAnimating];
            
            [_continueButton addSubview:_activityIndicatorView];
            CGPoint center = CGPointMake(_continueButton.titleLabel.frame.origin.x - activityIndicatorPadding, _continueButton.titleLabel.center.y);
            [_activityIndicatorView setCenter:center];
        } else {
            [_activityIndicatorView startAnimating];
        }
    } else {
        [_activityIndicatorView stopAnimating];
    }
}

- (void)setContinueEnabled:(BOOL)continueEnabled {
    _continueEnabled = continueEnabled;
    [self updateContinueAndSkipEnabled];
}

- (void)setSkipEnabled:(BOOL)skipEnabled {
    _skipEnabled = skipEnabled;
    self.skipButton.enabled = _skipEnabled;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    _skipButtonItem = skipButtonItem;
    [self updateContinueAndSkipEnabled];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    _continueButtonItem = continueButtonItem;
    [self updateContinueAndSkipEnabled];
}

- (void)setUpConstraints {
    
    CGFloat leftRightPadding = _useExtendedPadding ? ORKStepContainerExtendedLeftRightPaddingForWindow(self.window) : ORKStepContainerLeftRightPaddingForWindow(self.window);
    
    if (_regularConstraints) {
        [NSLayoutConstraint deactivateConstraints:_regularConstraints];
    }
    [_regularConstraints removeAllObjects];
    _regularConstraints = [NSMutableArray new];

    if (_continueButton) {
        [_regularConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_continueButton
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:topSpacing],
            [NSLayoutConstraint constraintWithItem:_continueButton
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.safeAreaLayoutGuide
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                          constant:leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_continueButton
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.safeAreaLayoutGuide
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:-leftRightPadding],
        ]];
    }
    
    if (_skipButton) {
        [_regularConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_skipButton
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_continueButton ? : self.safeAreaLayoutGuide
                                         attribute:_continueButton ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:_continueButton ? standardSpacing : topSpacing],
            [NSLayoutConstraint constraintWithItem:_skipButton
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:skipButtonHeight],
            [NSLayoutConstraint constraintWithItem:_skipButton
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.safeAreaLayoutGuide
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                          constant:leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_skipButton
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.safeAreaLayoutGuide
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:-leftRightPadding],
        ]];
    }
    
    UIView *lastView = _skipButton ? : _continueButton;
    
    if (lastView) {
        
        [_regularConstraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:lastView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:bottomSpacing]
         ];
    }
    else {
        [_regularConstraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:0.0]
        ];
    }
    if (effectView) {
        [_regularConstraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:effectView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:effectView
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:effectView
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:effectView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0]
                                           ]];

    }
    
    [NSLayoutConstraint activateConstraints:_regularConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setUpConstraints];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isInside = [super pointInside:point withEvent:event];
    if (!isInside) {
        isInside = [self.continueButton pointInside:[self convertPoint:point toView:self.continueButton] withEvent:event];
    }
    return isInside;
}

- (void)setUseExtendedPadding:(BOOL)useExtendedPadding {
    _useExtendedPadding = useExtendedPadding;
    [self setUpConstraints];
}

@end
