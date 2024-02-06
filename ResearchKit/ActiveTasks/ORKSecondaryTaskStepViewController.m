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

#import "ORKSecondaryTaskStepViewController.h"
#import "ORKSecondaryTaskStep.h"
#import "ORKStepViewController_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController.h"
#import "ORKInstructionStepContainerView.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepView.h"
#import "ORKNavigationContainerView.h"

@interface ORKSecondaryTaskStepViewController ()<ORKTaskViewControllerDelegate>

@end

@implementation ORKSecondaryTaskStepViewController {
    ORKTaskViewController *secondaryTaskViewController;
    NSUInteger requiredAttempts;
    NSUInteger numberOfTimesTaskCompleted;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    numberOfTimesTaskCompleted = 0;
}

- (ORKSecondaryTaskStep *)secondaryTaskStep {
    return (ORKSecondaryTaskStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    [self resetSecondaryTaskViewController];
    requiredAttempts = [self secondaryTaskStep].requiredAttempts;
    [self updateButtonState];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    if ([self secondaryTaskStep].nextButtonTitle) {
        [continueButtonItem setTitle:[self secondaryTaskStep].nextButtonTitle];
    }
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    
    [skipButtonItem setTitle:[self secondaryTaskStep].secondaryTaskButtonTitle ? : ORKLocalizedString(@"SECONDARY_TASK_START_BUTTON", nil)];
    [skipButtonItem setTarget:self];
    [skipButtonItem setAction:@selector(startSecondaryTaskHandler:)];
}

- (void)startSecondaryTaskHandler:(id)sender{
    [self startSecondaryTaskButtonTapped];
}

- (void)startSecondaryTaskButtonTapped {
    if (secondaryTaskViewController) {
        [self presentViewController:secondaryTaskViewController animated:YES completion:NULL];
    }
}

- (void)resetSecondaryTaskViewController {
    secondaryTaskViewController.delegate = nil;
    secondaryTaskViewController = nil;
    secondaryTaskViewController = [[ORKTaskViewController alloc] initWithTask:[self secondaryTaskStep].secondaryTask taskRunUUID:[NSUUID UUID]];
    secondaryTaskViewController.delegate = self;
    secondaryTaskViewController.outputDirectory = self.taskViewController.outputDirectory;
}

- (void)taskCompleted {
    numberOfTimesTaskCompleted = numberOfTimesTaskCompleted + 1;
    [self updateButtonState];
}

- (void)updateButtonState {
    
    [self.stepView.navigationFooterView setContinueEnabled:(requiredAttempts == 0) || (numberOfTimesTaskCompleted >= requiredAttempts)];

    [self.stepView.navigationFooterView setSkipEnabled:(numberOfTimesTaskCompleted > requiredAttempts)];
}

#pragma mark ORKTaskViewControllerDelegate

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    if (reason == ORKTaskViewControllerFinishReasonCompleted) {
        
        [self taskCompleted];
        [self resetSecondaryTaskViewController];
    }
    [taskViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
