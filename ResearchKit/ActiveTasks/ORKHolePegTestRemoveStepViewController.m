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


#import "ORKHolePegTestRemoveStepViewController.h"
#import "ORKHolePegTestRemoveStep.h"
#import "ORKHolePegTestRemoveContentView.h"
#import "ORKActiveStepViewController_internal.h"
#import "ORKStepViewController_internal.h"
#import "ORKActiveStepView.h"
#import "ORKHelpers.h"


@interface ORKHolePegTestRemoveStepViewController () <ORKHolePegTestRemoveContentViewDelegate>

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, strong) ORKHolePegTestRemoveContentView *holePegTestRemoveContentView;
@property (nonatomic, assign) NSTimeInterval sampleStart;
@property (nonatomic, assign) NSUInteger successes;
@property (nonatomic, assign) NSUInteger failures;

@end


@implementation ORKHolePegTestRemoveStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (ORKHolePegTestRemoveStep *)holePegTestRemoveStep {
    return (ORKHolePegTestRemoveStep *)self.step;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.holePegTestRemoveContentView = [[ORKHolePegTestRemoveContentView alloc] initWithMovingDirection:[self holePegTestRemoveStep].movingDirection];
    self.holePegTestRemoveContentView.threshold = [self holePegTestRemoveStep].threshold;
    self.holePegTestRemoveContentView.delegate = self;
    self.activeStepView.activeCustomView = self.holePegTestRemoveContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    
    NSString *identifier = [[self holePegTestRemoveStep].identifier stringByReplacingOccurrencesOfString:@"remove" withString:@"place"];
    NSTimeInterval placeStepDuration = ((ORKHolePegTestResult *)[[self.taskViewController.result stepResultForStepIdentifier:identifier].results firstObject]).totalTime;
    [self holePegTestRemoveStep].stepDuration -= placeStepDuration;
    
    [self start];
}

#pragma mark - step life cycle methods

- (void)start {
    self.sampleStart = CACurrentMediaTime();
    self.successes = 0;
    self.failures = 0;
    self.samples = [NSMutableArray array];
    [self.holePegTestRemoveContentView setProgress:0.001f animated:NO];
    
    [super start];
}

#pragma mark - result methods

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKHolePegTestResult *holePegTestResult = [[ORKHolePegTestResult alloc] initWithIdentifier:self.step.identifier];
    holePegTestResult.movingDirection = [self holePegTestRemoveStep].movingDirection;
    holePegTestResult.dominantHandTested = [self holePegTestRemoveStep].isDominantHandTested;
    holePegTestResult.numberOfPegs = [self holePegTestRemoveStep].numberOfPegs;
    holePegTestResult.threshold = [self holePegTestRemoveStep].threshold;
    holePegTestResult.rotated = NO;
    holePegTestResult.totalSuccesses = self.successes;
    holePegTestResult.totalFailures = self.failures;
    holePegTestResult.totalTime = [self holePegTestRemoveStep].stepDuration - self.timeRemaining;
    double totalDistance = 0.0;
    for (ORKHolePegTestSample *sample in self.samples) {
        totalDistance += sample.distance;
    }
    holePegTestResult.totalDistance = totalDistance;
    holePegTestResult.samples = self.samples;
    
    [results addObject:holePegTestResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)saveSampleWithDistance:(CGFloat)distance {
    ORKHolePegTestSample *sample = [[ORKHolePegTestSample alloc] init];
    sample.time = CACurrentMediaTime() - self.sampleStart;
    sample.distance = distance;
    self.sampleStart = CACurrentMediaTime();
    
    [self.samples addObject:sample];
}

#pragma mark - hole peg test content view delegate

- (NSString *)stepTitle {
    NSString *title = ([self holePegTestRemoveStep].movingDirection == ORKBodySagittalLeft) ? ORKLocalizedString(@"HOLE_PEG_TEST_REMOVE_INSTRUCTION_RIGHT_HAND", nil) : ORKLocalizedString(@"HOLE_PEG_TEST_REMOVE_INSTRUCTION_LEFT_HAND", nil);
    return title;
}

- (void)holePegTestRemoveDidProgress:(ORKHolePegTestRemoveContentView *)holePegTestRemoveContentView {
    [self.activeStepView updateTitle:[self stepTitle]
                                text:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT_2", nil)];
}

- (void)holePegTestRemoveDidSucceed:(ORKHolePegTestRemoveContentView *)holePegTestRemoveContentView withDistance:(CGFloat)distance {
    self.successes++;
    
    [self saveSampleWithDistance:distance];
    
    [holePegTestRemoveContentView setProgress:((CGFloat)self.successes / [self holePegTestRemoveStep].numberOfPegs) animated:YES];
    [self.activeStepView updateTitle:[self stepTitle]
                                text:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)];
    
    if (self.successes >= [self holePegTestRemoveStep].numberOfPegs) {
        [self finish];
    }
}

- (void)holePegTestRemoveDidFail:(ORKHolePegTestRemoveContentView *)holePegTestRemoveContentView {
    self.failures++;
    
    [self.activeStepView updateTitle:[self stepTitle]
                                text:ORKLocalizedString(@"HOLE_PEG_TEST_TEXT", nil)];
}

@end
