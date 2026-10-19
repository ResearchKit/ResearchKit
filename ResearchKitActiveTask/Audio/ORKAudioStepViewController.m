/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2026, Daniel Emden. All rights reserved.
 
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


#import "ORKAudioStepViewController.h"

#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKAudioContentView.h"
#import "ORKActiveStepCustomView.h"
#import "ORKVerticalContainerView.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepViewController_Internal.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKAudioRecorder.h"

#import "ORKAudioStep.h"
#import "ORKStep_Private.h"

#import "ORKHelpers_Internal.h"

@import AVFoundation;


@interface ORKAudioStepViewController ()

@property (nonatomic, strong) AVAudioRecorder *avAudioRecorder;

@end


@implementation ORKAudioStepViewController {
    ORKAudioContentView *_audioContentView;
    ORKAudioRecorder *_audioRecorder;
    ORKActiveStepTimer *_timer;
    NSError *_audioRecorderError;
    UIBarButtonItem *_earlyFinishButtonItem;
    BOOL _recordingActive;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        // Continue audio recording in the background
        self.suspendIfInactive = NO;
    }
    return self;
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    if (self.isViewLoaded && alertThreshold > 0) {
        _audioContentView.alertThreshold = alertThreshold;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _audioContentView = [ORKAudioContentView new];
    _audioContentView.timeLeft = self.audioStep.stepDuration;
    _audioContentView.useRecordButton = self.audioStep.useRecordButton;
    
    __weak typeof(self) weakSelf = self;
    [_audioContentView setViewEventHandler:^(ORKAudioContentViewEvent event) {
        [weakSelf handleContentViewEvent:event];
    }];

    if (self.alertThreshold > 0) {
        _audioContentView.alertThreshold = self.alertThreshold;
    }

    self.activeStepView.activeCustomView = _audioContentView;
    if (self.audioStep.allowsEarlyFinish) {
        _earlyFinishButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_DONE", nil)
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(finishEarly:)];
        _earlyFinishButtonItem.accessibilityIdentifier = @"ORKAudioEarlyFinish";
        [self updateEarlyFinishButton];
    }
}

// Use the recording timer, which starts with recording and pauses on suspension.
// Recheck on tap as well as in the UI, including queued taps after completion.
- (BOOL)canFinishEarly {
    return self.audioStep.allowsEarlyFinish && _recordingActive && !self.finished
        && !_audioRecorderError && _timer != nil && _timer.runtime >= self.audioStep.minDuration;
}

- (void)updateEarlyFinishButton {
    if (!_earlyFinishButtonItem) {
        return;
    }
    ORKNavigationContainerView *footer = self.activeStepView.navigationFooterView;
    if (!self.finished) {
        footer.neverHasContinueButton = NO;
        footer.continueButtonItem = _earlyFinishButtonItem;
        footer.continueEnabled = [self canFinishEarly];
    } else {
        footer.continueButtonItem = self.continueButtonItem;
        footer.neverHasContinueButton = self.audioStep.shouldContinueOnFinish;
        footer.continueEnabled = YES;
    }
}

- (void)finishEarly:(id)sender {
    if ([self canFinishEarly]) {
        [self finish];
    }
}

- (void)handleContentViewEvent:(ORKAudioContentViewEvent)event {
    
    switch (event) {
        case ORKAudioContentViewEventStartRecording:
            [self startRecording];
            break;
            
        case ORKAudioContentViewEventStopRecording:
            [self finish];
            break;
    }
}

- (void)audioRecorderDidChange {
    _audioRecorder.audioRecorder.meteringEnabled = YES;
    [self setAvAudioRecorder:_audioRecorder.audioRecorder];
}

- (void)recordersDidChange {
    ORKAudioRecorder *audioRecorder = nil;
    for (ORKRecorder *recorder in self.recorders) {
        if ([recorder isKindOfClass:[ORKAudioRecorder class]]) {
            audioRecorder = (ORKAudioRecorder *)recorder;
            break;
        }
    }
    _audioRecorder = audioRecorder;
    [self audioRecorderDidChange];
}

- (ORKAudioStep *)audioStep {
    return (ORKAudioStep *)self.step;
}

- (void)doSample {
    if (_audioRecorderError) {
        return;
    }

    [_avAudioRecorder updateMeters];
    float value = [_avAudioRecorder averagePowerForChannel:0];
    // Assume value is in range roughly -60dB to 0dB
    float clampedValue = MAX(value / 60.0, -1) + 1;
    [_audioContentView addSample:@(clampedValue)];
    
    _audioContentView.timeLeft = [self shouldRunTimerIndefinitely] ? 0 : [_timer duration] - [_timer runtime];
    [self updateEarlyFinishButton];
}

- (void)startNewTimerIfNeeded {
    NSTimeInterval interval = 0.2;
    
    if (!_timer) {
        if ([self shouldRunTimerIndefinitely]) {
            NSTimeInterval duration = DBL_MAX;
            ORKWeakTypeOf(self) weakSelf = self;
            _timer = [[ORKActiveStepTimer alloc] initWithDuration:duration
                                                         interval:interval
                                                          runtime:0
                                                          handler:^(ORKActiveStepTimer *timer, BOOL finished) {
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                if (!strongSelf || strongSelf->_timer != timer) {
                    return; // Ignore callbacks queued before a reset or completion.
                }
                [strongSelf doSample];
            }];
        } else {
            NSTimeInterval duration = self.audioStep.stepDuration;
            ORKWeakTypeOf(self) weakSelf = self;
            _timer = [[ORKActiveStepTimer alloc] initWithDuration:duration
                                                         interval:interval
                                                          runtime:0
                                                          handler:^(ORKActiveStepTimer *timer, BOOL finished) {
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                if (!strongSelf || strongSelf->_timer != timer) {
                    return; // Ignore callbacks queued before a reset or completion.
                }
                [strongSelf doSample];
                if (finished) {
                    [strongSelf finish];
                }
            }];
        }
        
        [_timer resume];
    }
    
    _audioContentView.finished = NO;
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    // For early-finish recordings, only the audio timer may complete the step.
    // The superclass timer starts before the recorder and may have queued a
    // completion callback before a recording was restarted.
    if (self.audioStep.allowsEarlyFinish && finished) {
        return;
    }
    [super countDownTimerFired:timer finished:finished];
}

- (BOOL)shouldRunTimerIndefinitely {
    return [self audioStep].useRecordButton == YES && [self audioStep].stepDuration == 0;
}

- (void)start {
    // Don't start recording here if the record button is present
    if ([self audioStep].useRecordButton) {
        return;
    }
    
    [self startRecording];
}

- (void)startRecording {
    if (self.finished || _recordingActive) {
        return;
    }
    [super start];
    if (_audioRecorderError) {
        return;
    }
    _recordingActive = YES;
    
    [self audioRecorderDidChange];
    
    [_timer reset];
    _timer = nil;
    
    [self startNewTimerIfNeeded];
    [self updateEarlyFinishButton];
}

- (void)suspend {
    _recordingActive = NO;
    [_timer pause];
    [self updateEarlyFinishButton];
    [super suspend];
    
    if (_avAudioRecorder) {
        [_audioContentView addSample:@(0)];
    }
}

- (void)resume {
    if (self.finished || !self.started || _audioRecorderError || _recordingActive) {
        return;
    }
    [super resume];
    if (_audioRecorderError) {
        return;
    }
    _recordingActive = YES;
    [self audioRecorderDidChange];
    
    [self startNewTimerIfNeeded];
    
    [_timer resume];
    [self updateEarlyFinishButton];
}

- (void)finish {
    if (_audioRecorderError || self.finished) {
        return;
    }
    _recordingActive = NO;
    [super finish];
    
    [_timer reset];
    _timer = nil;
    [self updateEarlyFinishButton];
}

- (void)stepDidFinish {
    _audioContentView.finished = YES;
}

- (void)setAvAudioRecorder:(AVAudioRecorder *)recorder {
    _avAudioRecorder = nil;
    _avAudioRecorder = recorder;
}

- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    [super recorder:recorder didFailWithError:error];
    _audioRecorderError = error;
    _recordingActive = NO;
    [_timer pause];
    [self updateEarlyFinishButton];
    _audioContentView.failed = YES;
}

@end

