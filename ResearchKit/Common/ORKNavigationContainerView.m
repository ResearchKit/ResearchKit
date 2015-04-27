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
#import "ORKHelpers.h"


@implementation ORKNavigationContainerView {
    NSLayoutConstraint *_gapConstraint;
    NSMutableArray *_localConstraints;
    BOOL _continueButtonJustTapped;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        {
            _skipButton = [ORKTextButton new];
            _skipButton.contentEdgeInsets = (UIEdgeInsets){12,10,8,10}; // insets adjusted to get correct vertical height from bottom of screen when aligned to margin
            _skipButton.exclusiveTouch = YES;
            [_skipButton setTitle:nil forState:UIControlStateNormal];
            [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_skipButton];
        }
        {
            _continueButton = [[ORKContinueButton alloc] initWithTitle:@"" isDoneButton:NO];
            _continueButton.alpha = 0;
            _continueButton.exclusiveTouch = YES;
            _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:_continueButton];
            [_continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        self.preservesSuperviewLayoutMargins = NO;
        self.layoutMargins = (UIEdgeInsets){};
        
        [self updateContinueAndSkipEnabled];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setTopMargin:(CGFloat)topMargin {
    _topMargin = topMargin;
    [self updateContinueAndSkipEnabled];
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    [self updateContinueAndSkipEnabled];
}

- (void)skipButtonAction:(id)sender {
    [self skipAction:sender];
    
    // Disable button for 0.5s
    ((UIView *)sender).userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Re-enable skip button
        ((UIView *)sender).userInteractionEnabled = YES;
    });
}

- (void)continueButtonAction:(id)sender {
    if (_useNextForSkip && _skipButtonItem && ! _continueButtonItem) {
        [self skipAction:sender];
    } else {
        [self continueAction:sender];
    }
    
    // Disable button for 0.5s
    ((UIView *)sender).userInteractionEnabled = NO;
    _continueButtonJustTapped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _continueButtonJustTapped = NO;
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
                                      (void)[_skipButtonItem.target performSelector:_skipButtonItem.action withObject:self];
                                      );
}

- (void)setNeverHasContinueButton:(BOOL)neverHasContinueButton {
    _neverHasContinueButton = neverHasContinueButton;
    [self setNeedsUpdateConstraints];
}

- (BOOL)neverHasSkipButton {
    return ! self.optional;
}

- (BOOL)skipButtonHidden {
    return (! _skipButtonItem) || _useNextForSkip || ! self.optional;
}

- (CGFloat)skipButtonAlpha {
    return ( [self skipButtonHidden] ? 0.0 : 1.0);
}

- (BOOL)hasContinueOrSkip {
    return ! ([self neverHasContinueButton] && [self neverHasSkipButton]);
}

- (void)updateContinueAndSkipEnabled {
    [_skipButton setTitle:_skipButtonItem.title?:ORKLocalizedString(@"BUTTON_SKIP_QUESTION", nil) forState:UIControlStateNormal];
    if ([self neverHasSkipButton]) {
        [_skipButton setFrame:(CGRect){{0,0},{0,0}}];
    }
    UIEdgeInsets layoutMargins = (UIEdgeInsets){.top=_topMargin, .bottom=_bottomMargin};
    if ([self neverHasContinueButton]) {
        _continueButton.hidden = YES;
    }
    if ([self neverHasContinueButton] && [self neverHasSkipButton]) {
        layoutMargins = (UIEdgeInsets){};
    }
    self.layoutMargins = layoutMargins;
    if (_useNextForSkip && _skipButtonItem) {
        _continueButton.alpha = (_continueButtonItem == nil && _skipButtonItem == nil) ? 0 : 1;
        [_continueButton setTitle: _continueButtonItem.title ? : _skipButtonItem.title forState:UIControlStateNormal];
    } else {
        _continueButton.alpha = (_continueButtonItem == nil) ? 0 : 1;
        [_continueButton setTitle: _continueButtonItem.title forState:UIControlStateNormal];
    }
    
    _continueButton.enabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    
    // Do not modify _continueButton.userInteractionEnabled during continueButton disable period
    if (_continueButtonJustTapped == NO) {
        _continueButton.userInteractionEnabled = (_continueEnabled || (_useNextForSkip && _skipButtonItem));
    }
    
    _skipButton.alpha = [self skipButtonAlpha];
    [self updateConstraintConstants];
}

- (void)setContinueEnabled:(BOOL)continueEnabled {
    _continueEnabled = continueEnabled;
    [self updateContinueAndSkipEnabled];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    _skipButtonItem = skipButtonItem;
    [self updateContinueAndSkipEnabled];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    _continueButtonItem = continueButtonItem;
    [self updateContinueAndSkipEnabled];
}

- (void)updateConstraintConstants {
    const CGFloat ContinueBottomToSkipButtonBaseline = 30;
    
    if ([self neverHasSkipButton] || _neverHasContinueButton) {
        _gapConstraint.active = NO;
    } else {
        _gapConstraint.active = YES;
        _gapConstraint.constant = ContinueBottomToSkipButtonBaseline;
    }
}

- (void)updateConstraints {
    if (_localConstraints) {
        [NSLayoutConstraint deactivateConstraints:_localConstraints];
        _localConstraints = nil;
    }
    
    [super updateConstraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_skipButton, _continueButton);
    ORKEnableAutoLayoutForViews([views allValues]);
    
    _localConstraints = [NSMutableArray array];
    
    [_localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_continueButton]" options:0 metrics:nil views:views]];
    
    _gapConstraint =
    [NSLayoutConstraint constraintWithItem:_skipButton
                                 attribute:NSLayoutAttributeBaseline
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_continueButton
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1 constant:30];
    _gapConstraint.priority = UILayoutPriorityDefaultHigh+1;
    [_localConstraints addObject:_gapConstraint];
    
    for (UIView *v in [views allValues]) {
        [_localConstraints addObject:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [_localConstraints addObject:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
#ifdef LAYOUT_DEBUG
        v.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
        v.layer.borderColor = [UIColor cyanColor].CGColor;
        v.layer.borderWidth = 1.0;
#endif
    }
    {
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_continueButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeBottomMargin multiplier:1 constant:0];
        bottomConstraint.priority = UILayoutPriorityDefaultHigh+1;
        [_localConstraints addObject:bottomConstraint];
    }
    {
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_skipButton attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottomMargin multiplier:1 constant:0];
        bottomConstraint.priority = UILayoutPriorityDefaultHigh+1;
        [_localConstraints addObject:bottomConstraint];
    }
    {
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        heightConstraint.priority = UILayoutPriorityFittingSizeLevel;
        [_localConstraints addObject:heightConstraint];
    }
    
    if (_neverHasContinueButton && [self neverHasSkipButton]) {
        [_localConstraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1 constant:0]];
    } else if (_neverHasContinueButton) {
        [_localConstraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1 constant:0]];
    }
    [self addConstraints:_localConstraints];
    
    [self updateConstraintConstants];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isInside = [super pointInside:point withEvent:event];
    if (! isInside) {
        isInside = [self.continueButton pointInside:[self convertPoint:point toView:self.continueButton] withEvent:event];
    }
    return isInside;
}

@end
