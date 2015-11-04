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


@implementation ORKVerificationStepViewController {
    ORKVerificationStepView *_verificationStepView;
}

- (ORKVerificationStep *)verificationStep {
    return (ORKVerificationStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (self.step && [self isViewLoaded]) {
        _verificationStepView = [[ORKVerificationStepView alloc] initWithFrame:self.view.bounds];
        _verificationStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _verificationStepView.headerView.captionLabel.text = [self verificationStep].title;
        _verificationStepView.headerView.instructionLabel.text = [self verificationStep].text;
        _verificationStepView.emailLabel.text = self.emailAddress;
        [self.view addSubview:_verificationStepView];
        
        [_verificationStepView.resendEmailButton addTarget:self
                                                   action:@selector(resendEmailButtonHandler:)
                                         forControlEvents:UIControlEventTouchUpInside];
        
        [_verificationStepView.changeEmailButton addTarget:self
                                                   action:@selector(changeEmailButtonHandler:)
                                         forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    
    [continueButtonItem setTarget:self];
    [continueButtonItem setAction:@selector(continueButtonHandler:)];
    
    _verificationStepView.continueSkipContainer.continueButtonItem = continueButtonItem;
    _verificationStepView.continueSkipContainer.continueEnabled = YES;
}

- (void)continueButtonHandler:(id)sender{
    [self continueButtonTapped];
}

- (void)resendEmailButtonHandler:(id)sender {
    [self resendEmailButtonTapped];
}

- (void)changeEmailButtonHandler:(id)sender {
    [self changeEmailButtonTapped];
}

#pragma mark Override methods

- (void)continueButtonTapped {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)resendEmailButtonTapped {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)changeEmailButtonTapped {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSString *)emailAddress {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
    return nil;
}

@end
