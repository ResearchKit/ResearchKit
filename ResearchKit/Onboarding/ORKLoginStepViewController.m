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


#import "ORKLoginStepViewController.h"

#import "ORKFormStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController.h"

#import "ORKHelpers_Internal.h"


@implementation ORKLoginStepViewController

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    continueButtonItem.title = ORKLocalizedString(@"LOGIN_CONTINUE_BUTTON_TITLE", nil);
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    
    [skipButtonItem setTitle:ORKLocalizedString(@"FORGOT_PASSWORD_BUTTON_TITLE", nil)];
    [skipButtonItem setTarget:self];
    [skipButtonItem setAction:@selector(forgotPasswordButtonHandler:)];
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    [super setCancelButtonItem:cancelButtonItem];
    [cancelButtonItem setTarget:self];
    [cancelButtonItem setAction:@selector(cancelButtonHandler:)];
}

- (void)cancelButtonHandler:(id)sender {
    ORKStrongTypeOf(self.taskViewController.delegate) strongDelegate = self.taskViewController.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
        [strongDelegate taskViewController:self.taskViewController didFinishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
    }
}

- (void)forgotPasswordButtonHandler:(id)sender{
    [self forgotPasswordButtonTapped];
}

#pragma mark Override methods

- (void)forgotPasswordButtonTapped {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

@end
