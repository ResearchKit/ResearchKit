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


#import "ORKVerificationStepViewController.h"

#import "ORKStepHeaderView_Internal.h"
#import "ORKVerificationStepView.h"

#import "ORKStepViewController_Internal.h"

#import "ORKVerificationStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@implementation ORKVerificationStepViewController {
    ORKVerificationStepView *_verificationStepView;
    NSArray<NSLayoutConstraint *> *_constraints;
    UIView *_iPadContentView;
}

- (ORKVerificationStep *)verificationStep {
    return (ORKVerificationStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (self.step && [self isViewLoaded]) {
        self.navigationItem.title = ORKLocalizedString(@"VERIFICATION_NAV_TITLE", nil);
        
        _verificationStepView = [ORKVerificationStepView new];
        _verificationStepView.headerView.instructionLabel.text = [[self verificationStep].text stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", ORKLocalizedString(@"RESEND_EMAIL_LABEL_MESSAGE", nil)]];
        
        _iPadContentView = [self viewForiPadLayoutConstraints];
        if (_iPadContentView) {
            [_iPadContentView addSubview:_verificationStepView];
        }
        else {
            [self.view addSubview:_verificationStepView];
        }
        
        [_verificationStepView.resendEmailButton addTarget:self
                                                   action:@selector(resendEmailButtonHandler:)
                                         forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _verificationStepView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_verificationStepView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_iPadContentView ? : self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_verificationStepView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_iPadContentView ? : self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_verificationStepView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_iPadContentView ? : self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_verificationStepView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_iPadContentView ? : self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0],
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
    [self setupConstraints];
}

- (void)resendEmailButtonHandler:(id)sender {
    [self resendEmailButtonTapped];
}

#pragma mark Override methods

- (void)resendEmailButtonTapped {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

@end
