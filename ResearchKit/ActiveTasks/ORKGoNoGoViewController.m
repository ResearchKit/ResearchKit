/*
 Copyright (c) 2015, James Cox. All rights reserved.
 
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


#import "ORKGoNoGoViewController.h"

#import "ORKActiveStepView.h"
#import "ORKGoNoGoContentView.h"

#import "ORKActiveStepViewController_Internal.h"

#import "ORKGoNoGoStep.h"
#import "ORKResult.h"

#import "ORKHelpers_Internal.h"

#import <AudioToolbox/AudioServices.h>
#import <CoreMotion/CMDeviceMotion.h>


@implementation ORKGoNoGoViewController {
    ORKGoNoGoContentView *_gonogoContentView;
    
    NSMutableArray *_results;
    NSTimer *_stimulusTimer;
    NSTimer *_timeoutTimer;
    NSTimeInterval _stimulusTimestamp;
    BOOL _validResult;
    BOOL _timedOut;
    BOOL _shouldIndicateFailure;
    NSMutableArray<NSNumber*>* tests;
    BOOL go;
}

static const NSTimeInterval OutcomeAnimationDuration = 0.3;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureTitle];
    _results = [NSMutableArray new];
    go = true;
    UIColor* color = self.view.tintColor;
    _gonogoContentView = [[ORKGoNoGoContentView alloc] initWithColor:color];
    
    // Generate the type of tests we are going to display
    // Always do go first, and make sure there is at least 1 no-go
    tests = [NSMutableArray array];
    [tests addObject:[NSNumber numberWithBool:YES]];
    while (tests.count < [self gonogoTimeStep].numberOfAttempts)
        [tests addObject:[NSNumber numberWithBool:((float)arc4random_uniform(RAND_MAX) / RAND_MAX) < 0.667]];
    
    // Check to make sure we have a no go
    BOOL hasNoGo = NO;
    for (NSNumber* go in tests)
        if ([go boolValue] == NO)
            hasNoGo = YES;
    
    // If not, put one in
    if (!hasNoGo && tests.count > 1)
        [tests setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:arc4random_uniform(tests.count - 1) + 1];
    
    self.activeStepView.activeCustomView = _gonogoContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    [_gonogoContentView setStimulusHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    _shouldIndicateFailure = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _shouldIndicateFailure = NO;
}

#pragma mark - ORKActiveStepViewController

- (void)start {
    [super start];
    [self startStimulusTimer];
    
}

#if TARGET_IPHONE_SIMULATOR
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        [self attemptDidFinish:nil];
    }
}

#endif


- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    stepResult.results = _results;
    return stepResult;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [super applicationWillResignActive:notification];
    _validResult = NO;
    [_stimulusTimer invalidate];
    [_timeoutTimer invalidate];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [super applicationDidBecomeActive:notification];
    [self resetAfterDelay:0];
}

#pragma mark - ORKRecorderDelegate

- (void)recorder:(ORKRecorder *)recorder didCompleteWithResult:(ORKResult *)result {
    if (_validResult) {
    }
    [self attemptDidFinish:result];
}

#pragma mark - ORKDeviceMotionRecorderDelegate

- (void)deviceMotionRecorderDidUpdateWithMotion:(CMDeviceMotion *)motion {
    CMAcceleration v = motion.userAcceleration;
    double vectorMagnitude = sqrt(((v.x * v.x) + (v.y * v.y) + (v.z * v.z)));
    if (vectorMagnitude > [self gonogoTimeStep].thresholdAcceleration) {
        [self stopRecorders];
    }
}

#pragma mark - ORKGoNoGoStepViewController

- (ORKGoNoGoStep *)gonogoTimeStep {
    return (ORKGoNoGoStep *)self.step;
}

- (void)configureTitle {
    int successCount = 0;
    int errorCount = 0;
    NSTimeInterval lastReactionTime = 0;
    
    for (ORKGoNoGoResult* res in _results)
    {
        if (res.incorrect == NO)
            successCount++;
        else
            errorCount++;
        if (res.go && !res.incorrect)
            lastReactionTime = res.timeToThreshold;
    }
    
    NSString *format = ORKLocalizedString(@"GONOGO_TASK_ATTEMPTS_FORMAT", nil);
    NSString *text = [NSString stringWithFormat:format, ORKLocalizedStringFromNumber(@(successCount + 1)), ORKLocalizedStringFromNumber(@([self gonogoTimeStep].numberOfAttempts))];
    
    if (errorCount > 0)
    {
        NSString *errorsFormat = ORKLocalizedString(@"GONOGO_TASK_ERRORS_FORMAT", nil);
        NSString *errorsText = [NSString stringWithFormat:errorsFormat, errorCount];
        text = [text stringByAppendingString:errorsText];
    }
    if (lastReactionTime > 0)
    {
        NSString *reactionFormat = ORKLocalizedString(@"GONOGO_TASK_REACTION_FORMAT", nil);
        NSString *reactionText = [NSString stringWithFormat:reactionFormat, lastReactionTime];
        text = [text stringByAppendingString:reactionText];
    }
    
    [self.activeStepView updateTitle:ORKLocalizedString(@"GONOGO_TASK_ACTIVE_STEP_TITLE", nil) text:text];
}

- (void)attemptDidFinish:(ORKResult *)result {
    void (^completion)(void) = ^{
        int successCount = 0;
        for (ORKGoNoGoResult* res in _results)
            if (res.incorrect == NO)
                successCount++;
        
        if (successCount == [self gonogoTimeStep].numberOfAttempts) {
            [self finish];
        } else {
            [self resetAfterDelay:2];
        }
    };
    if(go) {
        if (_validResult) {
            [self indicateSuccess:completion result:result];
        } else {
            [self indicateFailure:completion result:result];
        }
    }
    else {
        if (_validResult) {
            [self indicateFailure:completion result:result];
        } else {
            [self indicateSuccess:completion result:result];
        }
    }
    
    _validResult = NO;
    _timedOut = NO;
    [_stimulusTimer invalidate];
    [_timeoutTimer invalidate];
}

- (void)indicateSuccess:(void(^)(void))completion result:(ORKResult *)result {
    ORKGoNoGoResult *gonogoResult = [[ORKGoNoGoResult alloc] initWithIdentifier:self.step.identifier];
    gonogoResult.timestamp = _stimulusTimestamp;
    gonogoResult.timeToThreshold = [NSProcessInfo processInfo].systemUptime - _stimulusTimestamp;
    if (result)
        gonogoResult.fileResult = (ORKFileResult *)result;
    gonogoResult.go = go;
    gonogoResult.incorrect = NO;
    [_results addObject:gonogoResult];
    
    [_gonogoContentView startSuccessAnimationWithDuration:OutcomeAnimationDuration completion:completion];
    AudioServicesPlaySystemSound([self gonogoTimeStep].successSound);
}

- (void)indicateFailure:(void(^)(void))completion result:(ORKResult *)result {
    if (!_shouldIndicateFailure) {
        return;
    }
    ORKGoNoGoResult *gonogoResult = [[ORKGoNoGoResult alloc] initWithIdentifier:self.step.identifier];
    gonogoResult.timestamp = _stimulusTimestamp;
    gonogoResult.timeToThreshold = [NSProcessInfo processInfo].systemUptime - _stimulusTimestamp;
    if (result)
        gonogoResult.fileResult = (ORKFileResult *)result;
    gonogoResult.go = go;
    gonogoResult.incorrect = YES;
    [_results addObject:gonogoResult];

    
    [_gonogoContentView startFailureAnimationWithDuration:OutcomeAnimationDuration completion:completion];
    SystemSoundID sound = _timedOut ? [self gonogoTimeStep].timeoutSound : [self gonogoTimeStep].failureSound;
    AudioServicesPlayAlertSound(sound);
}

- (BOOL)getNextTestType {
    if (tests.count > 0) {
        BOOL res = [[tests firstObject] boolValue];
        [tests removeObjectAtIndex:0];
        return res;
    }
    else {
        return ((float)arc4random_uniform(RAND_MAX) / RAND_MAX) < 0.667;
    }
}

- (void)resetAfterDelay:(NSTimeInterval)delay {
    ORKWeakTypeOf(self) weakSelf = self;
    
    go = [self getNextTestType];
    
    [_gonogoContentView changeColor:go ? self.view.tintColor : UIColor.greenColor];
    [_gonogoContentView resetAfterDelay:delay completion:^{
        [weakSelf configureTitle];
        [weakSelf start];
    }];
}

- (void)startStimulusTimer {
    _stimulusTimer = [NSTimer scheduledTimerWithTimeInterval:[self stimulusInterval] target:self selector:@selector(stimulusTimerDidFire) userInfo:nil repeats:NO];
}

- (void)stimulusTimerDidFire {
    _stimulusTimestamp = [NSProcessInfo processInfo].systemUptime;
    [_gonogoContentView setStimulusHidden:NO];
    _validResult = YES;
    [self startTimeoutTimer];
}

- (void)startTimeoutTimer {
    NSTimeInterval timeout = [self gonogoTimeStep].timeout;
    if (timeout > 0) {
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeoutTimerDidFire) userInfo:nil repeats:NO];
    }
}

- (void)timeoutTimerDidFire {
    _validResult = NO;
    _timedOut = YES;
    [self stopRecorders];
    
#if TARGET_IPHONE_SIMULATOR
    // Device motion recorder won't work, so manually trigger didfinish
    [self attemptDidFinish:nil];
#endif
}

- (NSTimeInterval)stimulusInterval {
    ORKGoNoGoStep *step = [self gonogoTimeStep];
    NSTimeInterval range = step.maximumStimulusInterval - step.minimumStimulusInterval;
    NSTimeInterval randomFactor = ((NSTimeInterval)rand() / RAND_MAX) * range;
    return randomFactor + step.minimumStimulusInterval;
}

@end
