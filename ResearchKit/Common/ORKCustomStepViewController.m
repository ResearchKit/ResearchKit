 /*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKCustomStepViewController.h"
#import "ORKStepViewController_Internal.h"
#import "ORKCustomStep.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepContentView.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepView_Private.h"

@interface ORKCustomStepViewController ()

@end

@implementation ORKCustomStepViewController {
    ORKStepContainerView *_containerView;
    
    NSMutableArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)initWithStep:(ORKStep *)step {
    if (![step isKindOfClass:[ORKCustomStep class]]) {
        @throw NSInvalidArgumentException;
    }
    
    self = [super initWithStep:step];
    return self;
}

- (ORKCustomStep *)customStep {
    return (ORKCustomStep *)self.step;
}

- (void)stepDidChange {
    [_containerView removeFromSuperview];
    _containerView = nil;
    
    if (self.step && [self isViewLoaded]) {
        _containerView = [[ORKStepContainerView alloc] init];
        [self configureContainerView];
        [_containerView setPinNavigationContainer:self.customStep.pinNavigationContainer];
        [_containerView setCustomContentView:[self customStep].contentView withTopPadding:0.0 sidePadding:0.0];
        [_containerView setUseExtendedPadding:self.step.useExtendedPadding];
        [self.view addSubview:_containerView];
        [self setupConstraints];
    }
}

- (void)setupConstraints {
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    UIView *viewForiPad = [self viewForiPadLayoutConstraints];
    
    _constraints = nil;
    [self customStep].contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _constraints = [[NSMutableArray alloc] initWithArray:@[
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0]
    ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)configureContainerView {
    [_containerView setStepTitle:self.customStep.title];
    [_containerView setStepText:self.customStep.text];
    [_containerView setStepDetailText:self.customStep.detailText];
}

- (void)setStepHeaderTextAlignment:(NSTextAlignment)stepHeaderTextAlignment {
    [_containerView setStepHeaderTextAlignment:stepHeaderTextAlignment];
}

- (NSTextAlignment)stepHeaderTextAlignment {
    return [_containerView stepHeaderTextAlignment];
}

- (void)setBodyTextAlignment:(NSTextAlignment)bodyTextAlignment {
    [_containerView setBodyTextAlignment:bodyTextAlignment];
}

- (NSTextAlignment)bodyTextAlignment {
    return [_containerView bodyTextAlignment];
}

- (void)setupNavigationFooterView {
    _containerView.navigationFooterView.continueButtonItem = self.continueButtonItem;
    _containerView.navigationFooterView.continueEnabled = [self continueButtonEnabled];
    _containerView.navigationFooterView.skipButtonItem = [self skipButtonItem];
    [_containerView.navigationFooterView updateContinueAndSkipEnabled];
    [_containerView.navigationFooterView setUseExtendedPadding:[self.step useExtendedPadding]];
    [_containerView.navigationFooterView setOptional:self.step.isOptional];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _containerView.navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (BOOL)continueButtonEnabled {
    return YES;
}

- (void)updateButtonStates {
    _containerView.navigationFooterView.continueEnabled = [self continueButtonEnabled];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [_containerView setScrollEnabled:scrollEnabled];
}

- (BOOL)isScrollEnabled {
    return _containerView.scrollEnabled;
}

- (void)setShowScrollIndicator:(BOOL)showScrollIndicator {
    if (_containerView) {
        [_containerView setShowScrollIndicator:showScrollIndicator];
    }
}

- (BOOL)showScrollIndicator {
    return _containerView.showScrollIndicator;
}

- (void)setScrollViewInset:(UIEdgeInsets)contentInset {
    [_containerView setScrollViewInset:contentInset];
}

- (void)resetScrollViewInset {
    if (_containerView.pinNavigationContainer) {
        [_containerView setScrollViewInset:UIEdgeInsetsMake(0.0, 0.0, -(_containerView.navigationFooterView.frame.size.height + ORKContentBottomPadding), 0.0)];
    } else {
        [_containerView setScrollViewInset:UIEdgeInsetsZero];
    }
}

- (void)showActivityIndicatorInContinueButton:(BOOL)showActivityIndicator {
    [_containerView.navigationFooterView showActivityIndicator:showActivityIndicator];
}

- (void)scrollToPoint:(CGPoint)point {
    [_containerView scrollToPoint:point];
}

- (void)setSkipButtonTitle:(NSString *)skipButtonTitle {
    [super setSkipButtonTitle:skipButtonTitle];
    [self setupNavigationFooterView];
}

@end
