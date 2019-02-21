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


#import "ORKTimedWalkStepViewController.h"

#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKTimedWalkContentView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult.h"
#import "ORKTimedWalkResult.h"
#import "ORKTimedWalkStep.h"

#import "ORKHelpers_Internal.h"


@interface ORKTimedWalkStepViewController ()

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, strong) ORKTimedWalkContentView *timedWalkContentView;
@property (nonatomic, assign) NSTimeInterval trialDuration;

@end


@implementation ORKTimedWalkStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKTimedWalkStep *)timedWalkStep {
    return (ORKTimedWalkStep *)self.step;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalDoneButtonItem = nil;
    self.continueButtonTitle = ORKLocalizedString(@"BUTTON_NEXT", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timedWalkContentView = [ORKTimedWalkContentView new];
    self.timedWalkContentView.image = [self timedWalkStep].image;
    self.activeStepView.activeCustomView = self.timedWalkContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.navigationFooterView.continueEnabled = YES;
    
    self.timerUpdateInterval = 0.1f;
}

- (void)finish {
    [super finish];
    
    [self goForward];
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    self.trialDuration = timer.runtime;
    [super countDownTimerFired:timer finished:finished];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKTimedWalkResult *timedWalkResult = [[ORKTimedWalkResult alloc] initWithIdentifier:self.step.identifier];
    timedWalkResult.distanceInMeters = [self timedWalkStep].distanceInMeters;
    timedWalkResult.timeLimit = [self timedWalkStep].stepDuration;
    timedWalkResult.duration = self.trialDuration;
    
    [results addObject:timedWalkResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

@end
