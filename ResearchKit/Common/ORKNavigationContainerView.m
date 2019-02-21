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

static const CGFloat ORKStackViewSpacing = 10.0;
static const CGFloat shadowHeight = 0.75;

@implementation ORKNavigationContainerView {
    
    UIStackView *_parentStackView;
    UIStackView *_subStackView1;
    UIStackView *_subStackView2;
    UIView *_skipButtonView;
    UIView *_cancelButtonView;
    
    NSMutableArray *_variableConstraints;
    NSMutableArray *_skipButtonConstraints;
    NSMutableArray *_cancelButtonConstraints;
    
    UIVisualEffectView *effectView;
    UIColor *_appTintColor;
    
    BOOL _continueButtonJustTapped;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:ORKColor(ORKNavigationContainerColorKey)];
        [self setupVisualEffectView];
        [self setupViews];
        [self setupFootnoteLabel];
        self.preservesSuperviewLayoutMargins = NO;
        _appTintColor = nil;
        self.skipButtonStyle = ORKNavigationContainerButtonStyleTextBold;
        self.cancelButtonStyle = ORKNavigationContainerButtonStyleTextBold;
        [self setUpConstraints];
        [self updateContinueAndSkipEnabled];
    }
    return self;
}

- (void)setupVisualEffectView {
    if (!effectView) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        
        effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    effectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:effectView];
}

- (void)setupContinueButton {
    if (!_continueButton) {
        _continueButton = [[ORKContinueButton alloc] initWithTitle:@"" isDoneButton:NO];
    }
    _continueButton.alpha = 0;
    _continueButton.exclusiveTouch = YES;
    _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if (_appTintColor) {
        _continueButton.normalTintColor = _appTintColor;
    }
    
}

- (void)setupCancelButton {
    if (!_cancelButton) {
        _cancelButton = [ORKBorderedButton new];
        _cancelButtonView = [UIView new];
    }
    [_cancelButton setTitle:nil forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelButtonView.translatesAutoresizingMaskIntoConstraints = NO;

    [_cancelButtonView addSubview:_cancelButton];
    if (_appTintColor) {
        _cancelButton.normalTintColor = _appTintColor;
    }
    [self setCancelButtonConstraints];
}

- (void)setCancelButtonConstraints {
    if (_cancelButtonConstraints) {
        [NSLayoutConstraint deactivateConstraints:_cancelButtonConstraints];
    }
    _cancelButtonConstraints = nil;
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] initWithObjects:
                                                         [NSLayoutConstraint constraintWithItem:_cancelButton
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:_cancelButtonView
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1.0
                                                                                       constant:0.0],
                                                         
                                                         [NSLayoutConstraint constraintWithItem:_cancelButton
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:_cancelButtonView
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                     multiplier:1.0
                                                                                       constant:0.0], nil];
    if (_cancelButtonStyle == ORKNavigationContainerButtonStyleRoundedRect) {
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:_cancelButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_cancelButtonView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0]
                                           ]];
    }
    else {
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:_cancelButtonView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:_cancelButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0]
                                           ]];
    }
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cancelButtonView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_cancelButton
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:0.0]];
    _cancelButtonConstraints = constraints;
    [NSLayoutConstraint activateConstraints:_cancelButtonConstraints];
}

- (void)setupSkipButton {
    if (!_skipButton) {
        _skipButton = [ORKBorderedButton new];
        _skipButtonView = [UIView new];
    }
    _skipButton.exclusiveTouch = YES;
    [_skipButton setTitle:nil forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    _skipButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_skipButtonView addSubview:_skipButton];
    if (_appTintColor) {
        _skipButton.normalTintColor = _appTintColor;
    }
    [self setSkipButtonConstraints];
}

- (void)setSkipButtonConstraints {
    if (_skipButtonConstraints) {
        [NSLayoutConstraint deactivateConstraints:_skipButtonConstraints];
    }
    _skipButtonConstraints = nil;
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] initWithObjects:
                                                         [NSLayoutConstraint constraintWithItem:_skipButton
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:_skipButtonView
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1.0
                                                                                       constant:0.0],
                                                         
                                                         [NSLayoutConstraint constraintWithItem:_skipButton
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:_skipButtonView
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                     multiplier:1.0
                                                                                       constant:0.0], nil];
    if (_skipButtonStyle == ORKNavigationContainerButtonStyleRoundedRect) {
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:_skipButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_skipButtonView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0]
                                           ]];
    }
    else {
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:_skipButtonView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:_skipButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0]
                                           ]];
    }
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_skipButtonView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_skipButton
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:0.0]];
    _skipButtonConstraints = constraints;
    [NSLayoutConstraint activateConstraints:_skipButtonConstraints];
}

- (void)setupFootnoteLabel {
    _footnoteLabel = [ORKFootnoteLabel new];
    _footnoteLabel.numberOfLines = 0;
    _footnoteLabel.textAlignment = NSTextAlignmentNatural;
    _footnoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_footnoteLabel];
}

- (void)setupViews {
    [self setupParentStackView];
    [self setupSubStackViews];
    [self arrangeSubStacks];
}

- (void)setupParentStackView {
    if (!_parentStackView) {
        _parentStackView = [[UIStackView alloc] init];
    }
    _parentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _parentStackView.spacing = ORKStackViewSpacing;
    _parentStackView.distribution = UIStackViewDistributionFill;
    
    [self addSubview:_parentStackView];
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
    [self setSkipButtonConstraints];
}

- (void)setCancelButtonStyle:(ORKNavigationContainerButtonStyle)cancelButtonStyle {
    _cancelButtonStyle = cancelButtonStyle;
    switch (cancelButtonStyle) {
        case ORKNavigationContainerButtonStyleTextStandard:
            [_cancelButton setAppearanceAsTextButton];
            break;
        case ORKNavigationContainerButtonStyleTextBold:
            [_cancelButton setAppearanceAsBoldTextButton];
            break;
        case ORKNavigationContainerButtonStyleRoundedRect:
            [_cancelButton resetAppearanceAsBorderedButton];
            break;
        default:
            [_cancelButton setAppearanceAsTextButton];
            break;
    }
    [self setCancelButtonConstraints];
}

- (void)setupSubStackViews {
    if (!_subStackView1) {
        _subStackView1 = [[UIStackView alloc] init];
    }
    if (!_subStackView2) {
        _subStackView2 = [[UIStackView alloc] init];
    }
    for (UIStackView *subStack in @[_subStackView1, _subStackView2]) {
        subStack.translatesAutoresizingMaskIntoConstraints = NO;
        subStack.spacing = ORKStackViewSpacing;
        subStack.distribution = UIStackViewDistributionFillEqually;
        subStack.axis = UILayoutConstraintAxisHorizontal;
        if (_parentStackView) {
            [_parentStackView addArrangedSubview:subStack];
        }
    }
    _appTintColor = [[UIApplication sharedApplication].delegate window].tintColor;
    [self setupContinueButton];
    [self setupCancelButton];
    [self setupSkipButton];
}

- (void)arrangeSubStacks {
    if (_parentStackView && _subStackView1 && _subStackView2) {
        [_continueButton removeFromSuperview];
        [_cancelButtonView removeFromSuperview];
        [_skipButtonView removeFromSuperview];
        [_subStackView1 removeFromSuperview];
        [_subStackView2 removeFromSuperview];
        
        
        if (![_continueButton isHidden] && _continueButton.alpha > 0) {
            [_subStackView1 addArrangedSubview:_continueButton];
        }
        
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
           
            [_subStackView1 insertArrangedSubview:_cancelButtonView atIndex:[[_subStackView1 arrangedSubviews] count]];
            [_subStackView1 insertArrangedSubview:_skipButtonView atIndex:[[_subStackView1 arrangedSubviews] count] - 1];
            _parentStackView.axis = UILayoutConstraintAxisHorizontal;
        } else {
            [_subStackView2 insertArrangedSubview:_skipButtonView atIndex:0];
            [_subStackView2 insertArrangedSubview:_cancelButtonView atIndex:[[_subStackView2 arrangedSubviews] count]];
            _parentStackView.axis = UILayoutConstraintAxisVertical;
        }
        if ([_subStackView1.subviews count] > 0) {
            [_parentStackView addArrangedSubview:_subStackView1];
        }
        if ([_subStackView2.subviews count] > 0) {
            [_parentStackView addArrangedSubview:_subStackView2];
        }
        [_skipButtonView setHidden:(!_skipButton || _skipButton.isHidden || _skipButton.alpha == 0)];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y - shadowHeight, self.bounds.size.width, shadowHeight)];
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowColor = ORKColor(ORKNavigationContainerShadowColorKey).CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 1.0;
    self.layer.masksToBounds = NO;
    [self arrangeSubStacks];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Re-enable skip button
        ((UIView *)sender).userInteractionEnabled = YES;
        ((ORKTextButton *)sender).isInTransition = NO;
    });
}

- (void)cancelButtonAction:(id)sender {
    [self cancelAction:sender];
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
    _continueButtonJustTapped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _continueButtonJustTapped = NO;
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

- (void)cancelAction:(id)sender {
    ORKSuppressPerformSelectorWarning((void)[_cancelButtonItem.target performSelector:_cancelButtonItem.action withObject:_cancelButton];
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

- (void)updateContinueAndSkipEnabled {
    [_skipButton setTitle:_skipButtonItem.title ? : ORKLocalizedString(@"BUTTON_SKIP", nil) forState:UIControlStateNormal];
    if ([self neverHasSkipButton]) {
        [_skipButton setFrame:(CGRect){{0,0},{0,0}}];
    }
    UIEdgeInsets layoutMargins = (UIEdgeInsets){.top=_topMargin, .bottom=_bottomMargin};
    if ([self neverHasContinueButton]) {
        _continueButton.hidden = YES;
    }
    if ([self neverHasContinueButton] && [self neverHasSkipButton] && [self neverHasFootnote]) {
        layoutMargins = (UIEdgeInsets){};
    }
    self.layoutMargins = layoutMargins;
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
    
    // Do not modify _continueButton.userInteractionEnabled during continueButton disable period
    if (_continueButtonJustTapped == NO) {
        _continueButton.userInteractionEnabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    }
    
    _skipButton.alpha = [self skipButtonAlpha];
    
    [self setNeedsUpdateConstraints];
    [self arrangeSubStacks];
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

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    _cancelButtonItem = cancelButtonItem;
    [_cancelButton setTitle:cancelButtonItem.title ? cancelButtonItem.title : ORKLocalizedString(@"BUTTON_CANCEL", nil) forState:UIControlStateNormal];
    [_cancelButtonItem addObserver:self
                  forKeyPath:@"title"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"title"]) {
        UIBarButtonItem *cancelButtonItemObject = object;
        NSString *title = cancelButtonItemObject.title;
        [_cancelButton setTitle:title forState:UIControlStateNormal];
    }
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];

    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:_parentStackView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:ORKStackViewSpacing],
                                       [NSLayoutConstraint constraintWithItem:_footnoteLabel
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_parentStackView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:ORKStackViewSpacing],
                                       [NSLayoutConstraint constraintWithItem:self.safeAreaLayoutGuide
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_footnoteLabel
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0.0]
                                       ]];

    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:_parentStackView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.safeAreaLayoutGuide
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:ORKStackViewSpacing],
                                       [NSLayoutConstraint constraintWithItem:_parentStackView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.safeAreaLayoutGuide
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:-ORKStackViewSpacing],
                                       [NSLayoutConstraint constraintWithItem:_footnoteLabel
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.safeAreaLayoutGuide
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:ORKStackViewSpacing],
                                       [NSLayoutConstraint constraintWithItem:_footnoteLabel
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.safeAreaLayoutGuide
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:-ORKStackViewSpacing]
                                       ]];
    [constraints addObjectsFromArray:@[
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
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isInside = [super pointInside:point withEvent:event];
    if (!isInside) {
        isInside = [self.continueButton pointInside:[self convertPoint:point toView:self.continueButton] withEvent:event];
    }
    return isInside;
}

@end
