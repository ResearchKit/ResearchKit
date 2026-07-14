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
#import <ResearchKit/ResearchKit-Swift.h>


CGFloat navigationButtonHeight(void);

CGFloat navigationButtonHeight(void) {
    if (ORKLiquidGlassSupportEnabled()) {
        return 48;
    } else {
        return 50;
    }
}

static const CGFloat activityIndicatorPadding = 24;
static const CGFloat navigationContainerContentViewSpacing = 8;

@implementation ORKNavigationContainerView {
    UIActivityIndicatorView *_activityIndicatorView;
    UIColor *_appTintColor;
    UIStackView *_contentView;
    UIButton *_continueButton;
    UIButton *_skipButton;
    ORKFootnoteLabel *_footnoteLabel;
    ORKLabel *_detailTextLabel;

    BOOL _continueOrSkipButtonJustTapped;
    BOOL _removeVisualEffect;
    NSMutableArray *_regularConstraints;
    id<NSObject> _accessibilityObservationToken;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self setBackgroundColor:ORKColor(ORKNavigationContainerColorKey)];
    
    self.shouldAddFooterPadding = YES;
    
    [self setupViews];

    self.preservesSuperviewLayoutMargins = NO;
    _appTintColor = nil;
    [self updateContinueAndSkipEnabled];
}

- (void)flattenIfNeeded {
    if (![self hasContinueOrSkip] || (self.continueButtonItem == nil && [self hasSkipButton] && [self neverHasFootnote])) {
        for (UIView *subview in self.contentView.arrangedSubviews) {
            subview.hidden = YES;
        }
        [self setNeedsLayout];
    }
}

- (UIStackView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIStackView alloc] initWithArrangedSubviews:[self getContentViewArrangedViews]];
        _contentView.spacing = navigationContainerContentViewSpacing;
        _contentView.axis = UILayoutConstraintAxisVertical;
        _contentView.alignment = UIStackViewAlignmentFill;
        _contentView.distribution = UIStackViewDistributionFillProportionally;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

- (NSArray *)getContentViewArrangedViews {
    if (ORKLiquidGlassSupportEnabled()) {
        return @[
            self.detailTextLabel,
            self.footnoteLabel,
            self.continueButton,
            self.skipButton
        ];
    } else {
        return @[
            self.detailTextLabel,
            self.continueButton,
            self.skipButton,
            self.footnoteLabel
        ];
    }
}

- (UIButton *)continueButton {
    if (!_continueButton) {
        _continueButton = [[ORKContinueButton alloc] initWithTitle:@"" isDoneButton:NO];
        if (@available(iOS 26.0, *)) {
            if (ORKLiquidGlassSupportEnabled()) {
                UIButtonConfiguration *configuration = [UIButtonConfiguration prominentGlassButtonConfiguration];
                configuration.buttonSize = UIButtonConfigurationSizeLarge;
                configuration.cornerStyle = UIButtonConfigurationCornerStyleDynamic;
                _continueButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
            }
        }

        _continueButton.accessibilityIdentifier = @"ORKContinueButton.Next";
        _continueButton.exclusiveTouch = YES;
        _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _continueButton;
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [ORKBorderedButton new];
        if (@available(iOS 26.0, *)) {
            if (ORKLiquidGlassSupportEnabled()) {
                UIButtonConfiguration *configuration = [UIButtonConfiguration clearGlassButtonConfiguration];
                configuration.buttonSize = UIButtonConfigurationSizeLarge;
                configuration.cornerStyle = UIButtonConfigurationCornerStyleDynamic;
                configuration.titleLineBreakMode = NSLineBreakByClipping;
                _skipButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
            }
        }

        _skipButton.exclusiveTouch = YES;
        [_skipButton setTitle:nil forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _skipButton.titleLabel.adjustsFontSizeToFitWidth = YES;

        // Use UIButtonConfiguration for content insets on iOS 16+
        if (_skipButton.configuration == nil) {
            // Legacy path - create configuration with content insets
            UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
            config.contentInsets = NSDirectionalEdgeInsetsMake(6, 0, 6, 0);
            _skipButton.configuration = config;
        }

        _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        _skipButton.accessibilityIdentifier = @"ORKNavigationContainerView_skipButton";
        [self setSkipButtonStyle:[self __skipButtonStyle]];
    }
    return _skipButton;
}

- (ORKFootnoteLabel *)footnoteLabel {
    if (_footnoteLabel == nil) {
        _footnoteLabel = [ORKFootnoteLabel new];
        _footnoteLabel.numberOfLines = 0;
        _footnoteLabel.textAlignment = NSTextAlignmentCenter;
        _footnoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _footnoteLabel.textColor = UIColor.secondaryLabelColor;
    }
    return _footnoteLabel;
}

- (ORKLabel *)detailTextLabel {
    if (_detailTextLabel == nil) {
        _detailTextLabel = [[ORKLabel alloc] init];
        _detailTextLabel.numberOfLines = 0;
        _detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _detailTextLabel.textColor = [UIColor secondaryLabelColor];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _detailTextLabel;
}

- (void)setupViews {
    [self addSubview:self.contentView];
}

- (ORKNavigationContainerButtonStyle)__skipButtonStyle {
    if (ORKLiquidGlassSupportEnabled()) {
        return ORKNavigationContainerButtonStyleRoundedRect;
    } else {
        return ORKNavigationContainerButtonStyleTextBold;
    }
}

- (void)didMoveToWindow {
    _appTintColor = ORKViewTintColor(self);

    if ([_continueButton isKindOfClass:[ORKContinueButton class]]) {
        ORKContinueButton *continueButton = (ORKContinueButton *)_continueButton;
        continueButton.normalTintColor = _appTintColor;
    } else {
        [_continueButton setTintColor:_appTintColor];
    }

    if ([_skipButton isKindOfClass:[ORKBorderedButton class]]) {
        ORKBorderedButton *skipButton = (ORKBorderedButton *)_skipButton;
        skipButton.normalTintColor = _appTintColor;
    } else {
        [_skipButton setTintColor:_appTintColor];
    }

    CGFloat bottomMargin = ORKLargeContentLayoutMargins.leading + ORKSmallContentLayoutMargins.leading;
    if (self.shouldAddFooterPadding) {
        self.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0,
                                                                    ORKSmallContentLayoutMargins.leading,
                                                                    bottomMargin,
                                                                    ORKSmallContentLayoutMargins.trailing);
    } else {
        self.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0,
                                                                    0,
                                                                    bottomMargin,
                                                                    0);
    }
}

- (void)setSkipButtonStyle:(ORKNavigationContainerButtonStyle)skipButtonStyle {
    _skipButtonStyle = skipButtonStyle;
    switch (skipButtonStyle) {
        case ORKNavigationContainerButtonStyleTextStandard:
            [_skipButton performIfRespondsToSelector:@selector(setAppearanceAsTextButton)];
            break;
        case ORKNavigationContainerButtonStyleTextBold:
            [_skipButton performIfRespondsToSelector:@selector(setAppearanceAsBoldTextButton)];
            break;
        case ORKNavigationContainerButtonStyleRoundedRect:
            [_skipButton performIfRespondsToSelector:@selector(resetAppearanceAsBorderedButton)];
            break;
        default:
            [_skipButton performIfRespondsToSelector:@selector(setAppearanceAsTextButton)];
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

- (void)setNavigationDetailText:(NSString *)navigationDetailText {
    _navigationDetailText = navigationDetailText;
    self.detailTextLabel.text = _navigationDetailText;
    self.detailTextLabel.hidden = [self isDetailTextEmpty];
}

- (void)setContinueButtonDisabledStyle:(ORKBorderedButtonDisabledStyle)continueButtonDisabledStyle {
    _continueButtonDisabledStyle = continueButtonDisabledStyle;
    [_continueButton performIfRespondsToSelector:@selector(setDisabledButtonStyle:)
                                      withObject:[NSNumber numberWithBool: continueButtonDisabledStyle]];
}

- (void)skipButtonAction:(id)sender {
    [self skipAction:sender];

    // Disable button for 0.5s
    ((UIView *)sender).userInteractionEnabled = NO;
    [sender performIfRespondsToSelector:@selector(setIsInTransition:) withObject:[NSNumber numberWithBool:YES]];

    _continueOrSkipButtonJustTapped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _continueOrSkipButtonJustTapped = NO;
        // Re-enable skip button
        ((UIView *)sender).userInteractionEnabled = YES;
        [sender performIfRespondsToSelector:@selector(setIsInTransition:) withObject:[NSNumber numberWithBool:NO]];
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
    [sender performIfRespondsToSelector:@selector(setIsInTransition:) withObject:[NSNumber numberWithBool:YES]];
    _continueOrSkipButtonJustTapped = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _continueOrSkipButtonJustTapped = NO;
        [sender performIfRespondsToSelector:@selector(setIsInTransition:) withObject:[NSNumber numberWithBool:NO]];
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

- (BOOL)hasSkipButton {
    return !self.optional;
}

- (BOOL)isDetailTextEmpty {
    return _detailTextLabel.text.length == 0;
}

- (BOOL)neverHasFootnote {
    return _footnoteLabel.text.length == 0;
}

- (BOOL)skipButtonHidden {
    return (!_skipButtonItem) || _useNextForSkip || !self.optional || _skipButtonItem.title == nil;
}

- (BOOL)hasContinueOrSkip {
    return !([self neverHasContinueButton] && [self hasSkipButton] && [self neverHasFootnote]);
}

- (BOOL)wasContinueOrSkipButtonJustPressed {
    return _continueOrSkipButtonJustTapped;
}

- (void)updateContinueAndSkipEnabled {
    [_skipButton setTitle:_skipButtonItem.title ? : ORKLocalizedString(@"BUTTON_SKIP", nil) forState:UIControlStateNormal];
    
    if (_skipButtonItem.accessibilityIdentifier) {
        _skipButton.accessibilityIdentifier = _skipButtonItem.accessibilityIdentifier;
    }

    if ([self neverHasContinueButton]) {
        _continueButton.hidden = YES;
    }

    if (_useNextForSkip && _skipButtonItem) {
        if (![self neverHasContinueButton]) {
            _continueButton.hidden = (_continueButtonItem == nil && _skipButtonItem == nil);
        }
        [_continueButton setTitle: _continueButtonItem.title ? : _skipButtonItem.title forState:UIControlStateNormal];
        _continueButton.accessibilityHint = _continueButtonItem.accessibilityHint ? : _skipButtonItem.accessibilityHint;
        
        NSString *accessibilityId = _continueButtonItem.accessibilityIdentifier ? : _skipButtonItem.accessibilityIdentifier;
        if (accessibilityId) {
            _continueButton.accessibilityIdentifier = accessibilityId;
        }
    } else {
        if (![self neverHasContinueButton]) {
            _continueButton.hidden = (_continueButtonItem == nil);
        }
        [_continueButton setTitle: _continueButtonItem.title forState:UIControlStateNormal];
        _continueButton.accessibilityHint = _continueButtonItem.accessibilityHint;
        
        if (_continueButtonItem.accessibilityIdentifier) {
            _continueButton.accessibilityIdentifier = _continueButtonItem.accessibilityIdentifier;
        }
    }
    
    _continueButton.enabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    if ([_continueButton isKindOfClass:[ORKContinueButton class]]) {
        ORKContinueButton *continueButton = (ORKContinueButton *)_continueButton;
        continueButton.disableTintColor = [[self tintColor] colorWithAlphaComponent:0.5];
        continueButton.disabledButtonStyle = self.continueButtonDisabledStyle;
    }
    else if (@available(iOS 26.0, *)) {
        if (ORKLiquidGlassSupportEnabled()) {
            UIButtonConfiguration *configuration = [_continueButton configuration];
            UIColor *tintColor = [UIColor tintColor];
            if (!_continueButton.enabled) {
                configuration.baseBackgroundColor = [tintColor colorWithAlphaComponent:0.5];
            } else {
                configuration.baseBackgroundColor = tintColor;
            }
            [_continueButton setConfiguration:configuration];
        }
    }

    // Do not modify _continueButton.userInteractionEnabled during continueButton disable period
    // or when the activity indicator is present
    if (_continueOrSkipButtonJustTapped == NO && _activityIndicatorView == nil) {
        _continueButton.userInteractionEnabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    }

    self.detailTextLabel.hidden = [self isDetailTextEmpty];
    self.footnoteLabel.hidden = [self neverHasFootnote];
    _skipButton.hidden = [self skipButtonHidden];
    [self setNeedsUpdateConstraints];
    [self setUpConstraints];
}

- (void)showActivityIndicator:(BOOL)showActivityIndicator {
    [_continueButton setUserInteractionEnabled:!showActivityIndicator];
    [self updateContinueAndSkipEnabled];

    if (showActivityIndicator == YES) {
        if (_activityIndicatorView == nil) {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
            [self updateActivityIndicator:_activityIndicatorView for:[[UIApplication sharedApplication] preferredContentSizeCategory]];

            [_continueButton addSubview:_activityIndicatorView];
            _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[
                [_activityIndicatorView.centerXAnchor constraintEqualToAnchor:_continueButton.readableContentGuide.leadingAnchor constant:activityIndicatorPadding],
                [_activityIndicatorView.centerYAnchor constraintEqualToAnchor:_continueButton.centerYAnchor]
            ]];

        }
        [_activityIndicatorView startAnimating];
        _accessibilityObservationToken = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
            NSString *sizeCategory = [[notification userInfo] valueForKey:UIContentSizeCategoryNewValueKey];
            [self updateActivityIndicator:_activityIndicatorView for:sizeCategory];
        }];
    } else {
        [_activityIndicatorView stopAnimating];
        _accessibilityObservationToken = nil;
    }
}

- (void) updateActivityIndicator:(UIActivityIndicatorView *)activityIndicatorView for:(NSString *)sizeCategory {
    NSArray *largeSizesSupported = @[UIContentSizeCategoryExtraLarge, UIContentSizeCategoryExtraExtraLarge, UIContentSizeCategoryExtraExtraExtraLarge, UIContentSizeCategoryAccessibilityExtraLarge, UIContentSizeCategoryAccessibilityExtraExtraLarge, UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
    if ([largeSizesSupported containsObject:sizeCategory]) {
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
    } else {
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
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
    if (_regularConstraints) {
        [NSLayoutConstraint deactivateConstraints:_regularConstraints];
    }
    _regularConstraints = [NSMutableArray new];

    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints: @[
        [self.contentView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.safeAreaLayoutGuide.topAnchor multiplier:3],
        [self.layoutMarginsGuide.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [self.layoutMarginsGuide.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.layoutMarginsGuide.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
    ]];
    
    [NSLayoutConstraint activateConstraints:_regularConstraints];
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

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self didMoveToWindow];
}

@end
