/*
  ORKDeviceMotionReactionTimeViewController.m
  ResearchKit

  Created by James Cox on 07/05/2015.
  Copyright (c) 2015 researchkit.org. All rights reserved.
*/


#import "ORKDeviceMotionReactionTimeViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKActiveStepView.h"
#import "ORKDeviceMotionReactionTimeContentView.h"
#import "ORKDeviceMotionReactionTimeStep.h"
#import <CoreMotion/CMDeviceMotion.h>
#import <AudioToolbox/AudioServices.h>


@implementation ORKDeviceMotionReactionTimeViewController {
    
    ORKDeviceMotionReactionTimeContentView *_reactionTimeContentView;
    NSMutableArray *_results;
    NSTimer *_stimulusTimer;
    NSTimer *_timeoutTimer;
    NSTimeInterval _stimulusTimestamp;
    BOOL _validResult;
    BOOL _timedOut;
    BOOL _shouldIndicateFailure;
}

static const NSTimeInterval OutcomeAnimationDuration = 0.3;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _results = [@[] mutableCopy];
    _reactionTimeContentView = [ORKDeviceMotionReactionTimeContentView new];
    self.activeStepView.activeCustomView = _reactionTimeContentView;
    [_reactionTimeContentView setStimulusHidden:true];
    [self configureTitle];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    _shouldIndicateFailure = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _shouldIndicateFailure = false;
}

#pragma mark - ORKActiveStepViewController

- (void) start {
    [super start];
    [self startStimulusTimer];
}

- (ORKStepResult *) result {
    ORKStepResult *sResult = [super result];
    sResult.results = _results;
    return sResult;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [super applicationWillResignActive:notification];
    _validResult = false;
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
        ORKDeviceMotionReactionTimeResult *rtResult = [[ORKDeviceMotionReactionTimeResult alloc] initWithIdentifier: self.step.identifier];
        rtResult.timestamp = _stimulusTimestamp;
        rtResult.fileResult = (ORKFileResult *) result;
        [_results addObject: rtResult];
    }
    [self attemptDidFinish];
}

#pragma mark - ORKDeviceMotionRecorderDelegate

- (void)deviceMotionRecorderDidUpdateWithMotion:(CMDeviceMotion *)motion {
    CMAcceleration ua = motion.userAcceleration;
    double vectormag = sqrt(((ua.x * ua.x) + (ua.y * ua.y) + (ua.z * ua.z)));
    if (vectormag > [self reactionTimeStep].thresholdAcceleration) {
        for (ORKRecorder *r in self.recorders) {
            [r stop];
        }
    }
}

#pragma mark - ORKReactionTimeStepViewController

- (ORKDeviceMotionReactionTimeStep *)reactionTimeStep {
    return (ORKDeviceMotionReactionTimeStep *) self.step;
}

- (void)configureTitle {
    NSString *format = ORKLocalizedString(@"REACTION_TIME_TASK_ATTEMPTS_FORMAT", nil);
    NSString *text = [NSString stringWithFormat:format, _results.count + 1, [self reactionTimeStep].numberOfAttempts];
    [self.activeStepView updateTitle: ORKLocalizedString(@"REACTION_TIME_TASK_ACTIVE_STEP_TITLE", nil) text: text];
}

- (void)attemptDidFinish {
    void (^completion)(void) = ^{
        _results.count == [self reactionTimeStep].numberOfAttempts ? [self finish] : [self resetAfterDelay:2];
    };
    _validResult ? [self indicateSuccess:completion] : [self indicateFailure:completion];
    _validResult = false;
    _timedOut = false;
    [_stimulusTimer invalidate];
    [_timeoutTimer invalidate];
}

- (void)indicateSuccess:(void(^)(void)) completion {
    [_reactionTimeContentView startSuccessAnimationWithDuration:OutcomeAnimationDuration completion:completion];
    AudioServicesPlaySystemSound([self reactionTimeStep].successSound);
}

- (void)indicateFailure:(void(^)(void)) completion {
    if (!_shouldIndicateFailure) {
        return;
    }
    [_reactionTimeContentView startFailureAnimationWithDuration:OutcomeAnimationDuration completion:completion];
    UInt32 sound = _timedOut ? [self reactionTimeStep].timeoutSound : [self reactionTimeStep].failureSound;
    AudioServicesPlayAlertSound(sound);
}

- (void)resetAfterDelay:(NSTimeInterval) delay {
    __weak __typeof(self) weakSelf = self;
    [_reactionTimeContentView resetAfterDelay:delay completion:^{
        [weakSelf configureTitle];
        [weakSelf start];
    }];
}

- (void)startStimulusTimer {
    _stimulusTimer = [NSTimer scheduledTimerWithTimeInterval: [self stimulusInterval] target:self selector:@selector(stimulusTimerDidFire) userInfo:nil repeats:NO];
}

- (void)stimulusTimerDidFire {
    _stimulusTimestamp = [NSProcessInfo processInfo].systemUptime;
    [_reactionTimeContentView setStimulusHidden:false];
    _validResult = true;
    [self startTimeoutTimer];
}

- (void)startTimeoutTimer {
    NSTimeInterval timeout = [self reactionTimeStep].timeout;
    if (timeout > 0) {
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval: timeout target:self selector:@selector(timeoutTimerDidFire) userInfo:nil repeats:NO];
    }
}

- (void)timeoutTimerDidFire {
    _validResult = false;
    _timedOut = true;
    [self attemptDidFinish];
}

- (NSTimeInterval)stimulusInterval {
    ORKDeviceMotionReactionTimeStep *step = [self reactionTimeStep];
    NSTimeInterval range = step.maximumStimulusInterval - step.minimumStimulusInterval;
    NSTimeInterval randfac = ((NSTimeInterval) rand() / RAND_MAX) * range;
    return randfac + step.minimumStimulusInterval;
}

@end
