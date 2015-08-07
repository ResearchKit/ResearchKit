/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKHolePegTestPlaceStepViewController.h"
#import "ORKHolePegTestPlaceStep.h"
#import "ORKHolePegTestPlaceContentView.h"
#import "ORKActiveStepViewController_internal.h"
#import "ORKStepViewController_internal.h"
#import "ORKActiveStepView.h"


@interface ORKHolePegTestPlaceStepViewController () <ORKHolePegTestPlaceContentViewDelegate>

@property (nonatomic, strong) ORKHolePegTestPlaceContentView *holePegTestPlaceContentView;

@property (nonatomic, assign) NSUInteger successes;

@end


@implementation ORKHolePegTestPlaceStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (ORKHolePegTestPlaceStep *)holePegTestPlaceStep {
    return (ORKHolePegTestPlaceStep *)self.step;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.successes = 0;
    
    self.holePegTestPlaceContentView = [[ORKHolePegTestPlaceContentView alloc] initWithOrientation:[self holePegTestPlaceStep].orientation];
    self.holePegTestPlaceContentView.translationThreshold = [self holePegTestPlaceStep].translationThreshold;
    self.holePegTestPlaceContentView.rotationThreshold = [self holePegTestPlaceStep].rotationThreshold;
    self.holePegTestPlaceContentView.delegate = self;
    self.activeStepView.activeCustomView = self.holePegTestPlaceContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
}

- (void)start {
    [self.holePegTestPlaceContentView setProgress:0.001f animated:NO];
    [super start];
}

#pragma mark - hole peg test content view delegate

- (void)holePegTestPlaceDidProgress:(ORKHolePegTestPlaceContentView *)holePegTestPlaceContentView {
    if (!self.isStarted) {
        [self start];
    }
    
    [self.activeStepView updateTitle:ORKLocalizedString(@"HOLE_PEG_TEST_INSTRUCTION", nil)
                                text:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT_2", nil)];
}

- (void)holePegTestPlaceDidSucceed:(ORKHolePegTestPlaceContentView *)holePegTestPlaceContentView {
    self.successes++;
    
    [holePegTestPlaceContentView setProgress:((CGFloat)self.successes / [self holePegTestPlaceStep].numberOfHoles) animated:YES];
    [self.activeStepView updateTitle:ORKLocalizedString(@"HOLE_PEG_TEST_INSTRUCTION", nil)
                                text:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)];
    
    if (self.successes >= [self holePegTestPlaceStep].numberOfHoles) {
        [self finish];
    }
}

- (void)holePegTestPlaceDidFail:(ORKHolePegTestPlaceContentView *)holePegTestPlaceContentView {
    [self.activeStepView updateTitle:ORKLocalizedString(@"HOLE_PEG_TEST_INSTRUCTION", nil)
                                text:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)];
}

@end
