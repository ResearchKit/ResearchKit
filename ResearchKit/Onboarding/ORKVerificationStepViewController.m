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
#import "ORKStepViewController_Internal.h"
#import "ORKVerificationStep.h"
#import "ORKVerificationStepView.h"


@implementation ORKVerificationStepViewController

- (ORKVerificationStep *)verificationStep {
    return (ORKVerificationStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (self.step && [self isViewLoaded]) {
        ORKVerificationStepView *verificationStepView = [[ORKVerificationStepView alloc] initWithFrame:self.view.bounds];
        verificationStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        verificationStepView.headerView.captionLabel.text = [self verificationStep].title;
        verificationStepView.headerView.instructionLabel.text = [self verificationStep].text;
        verificationStepView.emailLabel.text = [self verificationStep].email;
        [self.view addSubview:verificationStepView];

        [verificationStepView.resendEmailButton addTarget:self
                                                   action:@selector(resendEmailButtonTapped:)
                                         forControlEvents:UIControlEventTouchUpInside];
        
        [verificationStepView.changeEmailButton addTarget:self
                                                   action:@selector(changeEmailButtonTapped:)
                                         forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    [self.internalContinueButtonItem setAction:@selector(continueButtonTapped:)];
    [self.internalDoneButtonItem setAction:@selector(continueButtonTapped:)];
}

- (void)continueButtonTapped:(id)sender {
}

- (void)resendEmailButtonTapped:(id)sender {
    NSLog(@"Resend email button tapped.");
}

- (void)changeEmailButtonTapped:(id)sender {
    NSLog(@"Change email button tapped.");
}

@end
