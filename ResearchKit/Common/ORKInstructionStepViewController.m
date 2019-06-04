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


@interface ORKInstructionStepViewController()<ORKStepViewLearnMoreItemDelegate>

@end

@implementation ORKInstructionStepViewController {
    ORKNavigationContainerView *_navigationFooterView;
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
        _navigationFooterView.cancelButtonItem = self.cancelButtonItem;
        _navigationFooterView.hidden = self.isBeingReviewed;
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
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stepDidChange];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_stepView setNeedsUpdateConstraints];
}


- (void)useAppropriateButtonTitleAsLastBeginningInstructionStep {
    self.internalContinueButtonItem.title = ORKLocalizedString(@"BUTTON_GET_STARTED", nil);
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    [super setCancelButtonItem:cancelButtonItem];
    _navigationFooterView.cancelButtonItem = cancelButtonItem;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - ORKStepContainerLearnMoreItemDelegate

- (void)stepViewLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [self presentViewController:[[ORKLearnMoreStepViewController alloc] initWithStep:learnMoreStep] animated:YES completion:nil];
}

@end
