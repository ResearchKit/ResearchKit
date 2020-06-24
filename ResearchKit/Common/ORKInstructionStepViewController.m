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


#import "ORKInstructionStepViewController.h"
#import "ORKLearnMoreStepViewController.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKInstructionStepContainerView.h"
#import "ORKStepView_Private.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKInstructionStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#import "ORKBodyContainerView.h"
#import "ORKStepContentView.h"
#import "ORKStepContentView_Private.h"

@class ORKBodyContainerView;

@interface ORKInstructionStepViewController()<ORKStepViewLearnMoreItemDelegate, ORKBodyItemContainerViewDelegate>

@end

@implementation ORKInstructionStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (ORKInstructionStep *)instructionStep {
    return (ORKInstructionStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [self.stepView removeFromSuperview];
    self.stepView = nil;
    
    if (self.step && [self isViewLoaded]) {
        self.stepView = [[ORKInstructionStepContainerView alloc] initWithInstructionStep:[self instructionStep]];
        _stepView.delegate = self;
        _stepView.stepContentView.bodyContainerView.bodyItemDelegate = self;
        [self.view addSubview:self.stepView];
        [self setNavigationFooterView];
        [self setupConstraints];
    }
}

- (void)setNavigationFooterView {
    if (_stepView) {
        _navigationFooterView = _stepView.navigationFooterView;
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.continueEnabled = YES;
        _navigationFooterView.hidden = self.isBeingReviewed;
        _navigationFooterView.optional = [self instructionStep].isOptional;
        _navigationFooterView.footnoteLabel.text = [self instructionStep].footnote;
        [_navigationFooterView updateContinueAndSkipEnabled];
    }
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    self.stepView.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;
    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:self.stepView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:self.stepView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:self.stepView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:self.stepView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([self.taskViewController isStepLastBeginningInstructionStep:self.step]) {
        [self useAppropriateButtonTitleAsLastBeginningInstructionStep];
    }
    
    [super viewWillAppear:animated];
    [self.taskViewController.navigationBar setBarTintColor:self.view.backgroundColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stepDidChange];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_stepView setNeedsUpdateConstraints];
    
    if (self.step.buildInBodyItems == YES) {
        UIView *lastVisibleBodyItem = [_stepView.stepContentView.bodyContainerView lastVisibleBodyItem];
        [_stepView updateEffectViewStylingAndAnimate:NO checkCurrentValue:NO customView:lastVisibleBodyItem];
    } else {
        [_stepView updateEffectViewStylingAndAnimate:NO checkCurrentValue:NO];
    }
}

- (void)useAppropriateButtonTitleAsLastBeginningInstructionStep {
    if (self.continueButtonTitle ==  nil) {
        self.internalContinueButtonItem.title = ORKLocalizedString(@"BUTTON_GET_STARTED", nil);
    }
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];

    _navigationFooterView.skipButtonItem = self.skipButtonItem;
    _navigationFooterView.skipEnabled = self.skipButtonItem ? YES : NO;
}

- (void)buildInNextBodyItem {
    [_stepView.stepContentView.bodyContainerView updateBodyItemViews];
    
    UIView *lastView = [_stepView.stepContentView.bodyContainerView lastVisibleBodyItem];
    [_stepView scrollToBodyItem:lastView];
    [_stepView updateEffectViewStylingAndAnimate:NO checkCurrentValue:NO customView:lastView];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - ORKStepContainerLearnMoreItemDelegate

- (void)stepViewLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    /*
     In some cases we want to allow the parent application to intercept the learn more callback in learn more instruction steps. These
     should get handled the same way as other learn more callbacks at the task level. If the app responds to this delegate, it get's
     higher prioriy and it becomes the responsibility of the developer to handle all cases.
     
     If not implemented, default to showing the learnMore view controller for the the step.
     */
    if ([self.taskViewController.delegate respondsToSelector:@selector(taskViewController:learnMoreButtonPressedWithStep:forStepViewController:)]) {
        [self.taskViewController.delegate taskViewController:self.taskViewController learnMoreButtonPressedWithStep:learnMoreStep forStepViewController:self];
    } else {
        UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController: [self.taskViewController learnMoreViewControllerForStep:learnMoreStep]];
        [navigationViewController.navigationBar setPrefersLargeTitles:NO];
        [self presentViewController:navigationViewController
                           animated:YES
                         completion:nil];
    }
}

- (void)goForward {
    if (([self instructionStep].buildInBodyItems == YES) && ([_stepView.stepContentView.bodyContainerView hasShownAllBodyItem] == NO)) {
        [self buildInNextBodyItem];
    } else {
        [super goForward];
    }
}

- (void)bodyContainerViewDidLoadBodyItems {
    if ([self.stepView buildInBodyItems] == YES) {
        UIView *lastVisibleBodyItem = [_stepView.stepContentView.bodyContainerView lastVisibleBodyItem];
        [_stepView updateEffectViewStylingAndAnimate:NO checkCurrentValue:NO customView:lastVisibleBodyItem];
    }
}

@end
