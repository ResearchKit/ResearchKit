/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
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


#import "ORKNormalizedReactionTimeViewController.h"

#import "ORKBorderedButton.h"

#import "ORKActiveStepView.h"
#import "ORKNormalizedReactionTimeContentView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKVerticalContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKNormalizedReactionTimeResult.h"
#import "ORKNormalizedReactionTimeStep.h"
#import "ORKResult.h"

#import "ORKHelpers_Internal.h"

#import <AudioToolbox/AudioServices.h>


@implementation ORKNormalizedReactionTimeViewController {
    ORKNormalizedReactionTimeContentView *_reactionTimeContentView;
    NSMutableArray *_results;
    NSTimer *_stimulusTimer;
    NSTimer *_timeoutTimer;
    NSTimeInterval _stimulusTimestamp;
    BOOL _validResult;
    BOOL _timedOut;
    BOOL _shouldIndicateFailure;
    
    UIView *_backgroundView;
    ORKNormalizedReactionTimeStimulusView *_stimulusView;

    NSDate *_timerStartDate;
    NSDate *_stimulusStartDate;
    NSDate *_reactionDate;
}

static const NSTimeInterval OutcomeAnimationDuration = 0.3;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureTitle];
    _results = [NSMutableArray new];
    _reactionTimeContentView = [ORKNormalizedReactionTimeContentView new];
    [_reactionTimeContentView.button addTarget:self action:@selector(startStimulusTimer) forControlEvents:UIControlEventTouchDown];
    [_reactionTimeContentView.button addTarget:self action:@selector(startReactionTimer) forControlEvents:UIControlEventTouchUpInside];
    
    self.activeStepView.activeCustomView = _reactionTimeContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.activeStepView.scrollContainerShouldCollapseNavbar = NO;
    _backgroundView = [_reactionTimeContentView getBackgroundView];
    _stimulusView = [_reactionTimeContentView getStimulusView];

    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)]];
    [_stimulusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)]];

    [_reactionTimeContentView setStimulusHidden:YES];
}


-(void)startReactionTimer {
    if (_stimulusView.hidden) {
            _validResult = NO;
            _timedOut = YES;
            [self addReactionTimeResult];
        #if TARGET_IPHONE_SIMULATOR
            // Device motion recorder won't work, so manually trigger didfinish
            [self attemptDidFinish];
        #endif
    } else {
        _timerStartDate = [NSDate date];
    }
}

- (void)tapDetected {
    if ([_stimulusTimer isValid] || [_timeoutTimer isValid]) {
        _reactionDate = [NSDate date];
        [self addReactionTimeResult];
    }
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
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    stepResult.results = [self.addedResults arrayByAddingObjectsFromArray:_results] ? : _results;
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

- (void)addReactionTimeResult {
    ORKNormalizedReactionTimeResult *reactionTimeResult = [[ORKNormalizedReactionTimeResult alloc] initWithIdentifier:self.step.identifier];
    reactionTimeResult.timerStartDate = _timerStartDate;
    reactionTimeResult.timerEndDate = [NSDate date];
    reactionTimeResult.reactionDate = _reactionDate;
    reactionTimeResult.stimulusStartDate = _stimulusStartDate;
    reactionTimeResult.currentInterval = [self reactionTimeStep].currentInterval;
    [_results addObject:reactionTimeResult];
    _timerStartDate = nil;
    _reactionDate = nil;
    _stimulusStartDate = nil;
    [self reactionTimeStep].currentInterval = 0;
    
    [self attemptDidFinish];
}

#pragma mark - ORKReactionTimeStepViewController

- (ORKNormalizedReactionTimeStep *)reactionTimeStep {
    return (ORKNormalizedReactionTimeStep *)self.step;
}

- (void)configureTitle {
    NSString *format = ORKLocalizedString(@"REACTION_TIME_TASK_ATTEMPTS_FORMAT", nil);
    NSString *text = [[NSString stringWithFormat: @"%@\n",ORKLocalizedString(@"REACTION_TIME_NORMALIZED_TASK_ACTIVE_STEP_TITLE", nil)] stringByAppendingString: [NSString stringWithFormat:format, ORKLocalizedStringFromNumber(@(_results.count + 1)), ORKLocalizedStringFromNumber(@([self reactionTimeStep].numberOfAttempts))]];
                      [self.activeStepView updateTitle:nil text:text];
}

- (void)attemptDidFinish {
    void (^completion)(void) = ^{
        if (_results.count == [self reactionTimeStep].numberOfAttempts) {
            [self finish];
        } else {
            [self resetAfterDelay:2];
        }
    };
    if (_validResult) {
        [self indicateSuccess:completion];
    } else {
        [self indicateFailure:completion];
    }
    _validResult = NO;
    _timedOut = NO;
    [_stimulusTimer invalidate];
    [_timeoutTimer invalidate];
}

- (void)indicateSuccess:(void(^)(void))completion {
    [_reactionTimeContentView startSuccessAnimationWithDuration:OutcomeAnimationDuration completion:completion];
    AudioServicesPlaySystemSound([self reactionTimeStep].successSound);
}

- (void)indicateFailure:(void(^)(void))completion {
    if (!_shouldIndicateFailure) {
        return;
    }
    [_reactionTimeContentView startFailureAnimationWithDuration:OutcomeAnimationDuration completion:completion];
    SystemSoundID sound = _timedOut ? [self reactionTimeStep].timeoutSound : [self reactionTimeStep].failureSound;
    AudioServicesPlayAlertSound(sound);
}

- (void)resetAfterDelay:(NSTimeInterval)delay {
    ORKWeakTypeOf(self) weakSelf = self;
    [_reactionTimeContentView resetAfterDelay:delay completion:^{
        [weakSelf configureTitle];
        [weakSelf start];
    }];
}

- (void)startStimulusTimer {
    _stimulusTimer = [NSTimer scheduledTimerWithTimeInterval:[self stimulusInterval] target:self selector:@selector(stimulusTimerDidFire) userInfo:nil repeats:NO];
}

- (void)stimulusTimerDidFire {
    _stimulusStartDate = [NSDate date];
    
    _stimulusTimestamp = [NSProcessInfo processInfo].systemUptime;
    [_reactionTimeContentView setStimulusHidden:NO];
    _validResult = YES;
    [self startTimeoutTimer];
}

- (void)startTimeoutTimer {
    NSTimeInterval timeout = [self reactionTimeStep].timeout;
    if (timeout > 0) {
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeoutTimerDidFire) userInfo:nil repeats:NO];
    }
}

- (void)timeoutTimerDidFire {
    _validResult = NO;
    _timedOut = YES;
    [self addReactionTimeResult];
#if TARGET_IPHONE_SIMULATOR
    // Device motion recorder won't work, so manually trigger didfinish
    [self attemptDidFinish];
#endif
}

- (NSTimeInterval)stimulusInterval {
    ORKNormalizedReactionTimeStep *step = [self reactionTimeStep];
    NSNumber* interval = [self getRandomInterval];
    step.currentInterval = interval;
    return [interval doubleValue];
}
    
    
- (NSNumber*) getRandomInterval {
    NSArray* values = @[@2,@4,@6];

    int randIndex = arc4random() % [values count];
    return (NSNumber*)values[randIndex];
}



@end
