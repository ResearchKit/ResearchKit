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


@implementation ORKDeviceMotionReactionTimeViewController {
    
    ORKDeviceMotionReactionTimeContentView *_reactionTimeContentView;
    NSMutableArray *_results;
    NSTimer *_stimulusTimer;
    NSTimer *_timeoutTimer;
    NSTimeInterval _stimulusTimestamp;
    BOOL _validResult;
}

static const float ReactionTimeResetAnimationDuration = 0.3;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _results = [@[] mutableCopy];
    _reactionTimeContentView = [ORKDeviceMotionReactionTimeContentView new];
    self.activeStepView.activeCustomView = _reactionTimeContentView;
    _reactionTimeContentView.buttonItem = [[UIBarButtonItem alloc] initWithTitle: ORKLocalizedString(@"REACTION_TIME_TASK_READY_BUTTON_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(start)];
    [self enableReady];
}

#pragma mark - ORKActiveStepViewController

- (void) start {
    _reactionTimeContentView.stimulusHidden = false;
    _reactionTimeContentView.readyHidden = true;
    [_reactionTimeContentView startReadyAnimationWithDuration: [self reactionTimeStep].getReadyInterval completion:^{
        [super start];
        [self startStimulusTimer];
    }];
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
    [self enableReady];
}

#pragma mark - ORKRecorderDelegate

- (void)recorder:(ORKRecorder *)recorder didCompleteWithResult:(ORKResult *)result {
    if (_validResult) {
        ORKDeviceMotionReactionTimeResult *rtResult = [[ORKDeviceMotionReactionTimeResult alloc] initWithIdentifier: self.step.identifier];
        rtResult.timestamp = _stimulusTimestamp;
        rtResult.fileResult = (ORKFileResult *) result;
        [_results addObject: rtResult];
    }
    [self resetOrFinish];
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

- (void)resetOrFinish {
    void (^completion)(void) = ^{
        _results.count == [self reactionTimeStep].numberOfAttempts ? [self finish] : [self enableReady];
    };
    NSTimeInterval t = ReactionTimeResetAnimationDuration;
    _validResult ? [_reactionTimeContentView startSuccessAnimationWithDuration:t completion:completion] : [_reactionTimeContentView startFailureAnimationWithDuration:t completion:completion];
    _validResult = false;
    [_stimulusTimer invalidate];
    [_timeoutTimer invalidate];
}

- (ORKDeviceMotionReactionTimeStep *)reactionTimeStep {
    return (ORKDeviceMotionReactionTimeStep *) self.step;
}

- (void) enableReady {
    NSString *format = ORKLocalizedString(@"REACTION_TIME_TASK_ATTEMPTS_FORMAT", nil);
    NSString *text = [NSString stringWithFormat:format, _results.count + 1, [self reactionTimeStep].numberOfAttempts];
    [self.activeStepView updateTitle: ORKLocalizedString(@"REACTION_TIME_TASK_ACTIVE_STEP_TITLE", nil) text: text];
    _reactionTimeContentView.stimulusHidden = true;
    _reactionTimeContentView.readyHidden = false;
}

- (void)startStimulusTimer {
    _stimulusTimer = [NSTimer scheduledTimerWithTimeInterval: [self stimulusInterval] target:self selector:@selector(stimulusTimerDidFire) userInfo:nil repeats:NO];
}

- (void)stimulusTimerDidFire {
    _stimulusTimestamp = [NSProcessInfo processInfo].systemUptime;
    _reactionTimeContentView.stimulusHidden = true;
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
    [self resetOrFinish];
}

- (float)stimulusInterval {
    ORKDeviceMotionReactionTimeStep *step = [self reactionTimeStep];
    float range = step.maximumStimulusInterval - step.minimumStimulusInterval;
    float randfac = ((NSTimeInterval) rand() / RAND_MAX) * range;
    return randfac + step.minimumStimulusInterval;
}

@end
