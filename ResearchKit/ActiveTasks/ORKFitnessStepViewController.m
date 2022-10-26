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


#import "ORKFitnessStepViewController.h"
#import "ORKFitnessContentView.h"
#import "ORKFitnessStep.h"
#import "ORKActiveStepView.h"
#import "ORKActiveStepTimer.h"

#import "ORKStepViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKHelpers_Internal.h"

#import "ORKStepContainerView_Private.h"

@interface ORKFitnessStepViewController () {
    ORKFitnessContentView *_contentView;
}

@end


@implementation ORKFitnessStepViewController

- (instancetype)initWithStep:(ORKStep *)step {    
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = NO;
    }
    return self;
}

- (ORKFitnessStep *)fitnessStep {
    return (ORKFitnessStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _contentView = [[ORKFitnessContentView alloc] initWithDuration:self.fitnessStep.stepDuration];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;

    self.activeStepView.activeCustomView = _contentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    self.continueButtonTitle = ORKLocalizedString(@"BUTTON_SKIP_STEP", nil);
}

- (void)finish {
    [super finish];
    _contentView.labelHidden = YES;
    self.continueButtonTitle = ORKLocalizedString(@"BUTTON_NEXT", nil);
}

- (void)stepDidChange {
    [super stepDidChange];
    _contentView.duration = self.fitnessStep.stepDuration;
    _contentView.timeLeft = self.fitnessStep.stepDuration;
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    _contentView.timeLeft = finished ? 0 : (timer.duration - timer.runtime);
    _contentView.duration = self.fitnessStep.stepDuration;
    [super countDownTimerFired:timer finished:finished];
}

- (void)goForward {

    if (self.finished) {
        [super goForward];
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"FITNESS_STOP_TEST_CONFIRMATION", nil)
                                                                   message:ORKLocalizedString(@"FITNESS_STOP_TEST_DETAIL", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"FITNESS_RESUME_TEST", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_SKIP_STEP", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:^{
            [super goForward];
        }];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
