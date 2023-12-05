/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKdBHLToneAudiometryStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStep_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepContainerView.h"

#import "ORKdBHLToneAudiometryAudioGenerator.h"
#import "ORKRoundTappingButton.h"
#import "ORKdBHLToneAudiometryContentView.h"
#import "ORKStepContainerView_Private.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKdBHLToneAudiometryResult.h"
#import "ORKdBHLToneAudiometryStep.h"


#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKOrderedTask.h"

#import "ORKNavigableOrderedTask.h"
#import "ORKStepNavigationRule.h"

@interface ORKdBHLToneAudiometryStepViewController () <ORKdBHLToneAudiometryAudioGeneratorDelegate> {
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKAudioChannel _audioChannel;

    ORKdBHLToneAudiometryAudioGenerator *_audioGenerator;
    UIImpactFeedbackGenerator *_hapticFeedback;
    
    dispatch_block_t _preStimulusDelayWorkBlock;
    dispatch_block_t _pulseDurationWorkBlock;
    dispatch_block_t _postStimulusDelayWorkBlock;
    
}

@property (nonatomic, strong) ORKdBHLToneAudiometryContentView *dBHLToneAudiometryContentView;

@end

@implementation ORKdBHLToneAudiometryStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;

        ORKWeakTypeOf(self) weakSelf = self;
        self.audiometryEngine.timestampProvider = ^NSTimeInterval{
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            return strongSelf ? strongSelf.runtime : 0;
        };
    }
    return self;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (ORKdBHLToneAudiometryStep *)dBHLToneAudiometryStep {
    return (ORKdBHLToneAudiometryStep *)self.step;
}

- (id<ORKAudiometryProtocol>)audiometryEngine {
    return self.dBHLToneAudiometryStep.audiometryEngine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureStep];
}

- (void)configureStep {
    ORKdBHLToneAudiometryStep *dBHLTAStep = [self dBHLToneAudiometryStep];

    self.dBHLToneAudiometryContentView = [[ORKdBHLToneAudiometryContentView alloc] init];
    self.activeStepView.activeCustomView = self.dBHLToneAudiometryContentView;
    self.activeStepView.customContentFillsAvailableSpace = YES;
    [self.activeStepView.navigationFooterView setHidden:YES];

    [self.dBHLToneAudiometryContentView.tapButton addTarget:self action:@selector(tapButtonPressed) forControlEvents:UIControlEventTouchDown];
    

    _audioChannel = dBHLTAStep.earPreference;
    _audioGenerator = [[ORKdBHLToneAudiometryAudioGenerator alloc] initForHeadphoneType:dBHLTAStep.headphoneType];
    _audioGenerator.delegate = self;
    _hapticFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
}

- (void)addObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self addObservers];
}


-(void)appWillTerminate:(NSNotification*)note {
    [self stopAudio];
    [self removeObservers];
}

- (void)animatedBHLButton {
    [self.dBHLToneAudiometryContentView.layer removeAllAnimations];
    [UIView animateWithDuration:0.1
                          delay:0.0
         usingSpringWithDamping:0.1
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        [self.dBHLToneAudiometryContentView.tapButton setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.4
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            [self.dBHLToneAudiometryContentView.tapButton setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        } completion:nil];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _audioGenerator.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [self stopAudio];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKdBHLToneAudiometryResult *toneResult = [[ORKdBHLToneAudiometryResult alloc] initWithIdentifier:self.step.identifier];
    toneResult.startDate = sResult.startDate;
    toneResult.endDate = now;
    toneResult.samples = [self.audiometryEngine resultSamples];
    toneResult.outputVolume = [AVAudioSession sharedInstance].outputVolume;
    toneResult.headphoneType = self.dBHLToneAudiometryStep.headphoneType;
    toneResult.tonePlaybackDuration = [self dBHLToneAudiometryStep].toneDuration;
    toneResult.postStimulusDelay = [self dBHLToneAudiometryStep].postStimulusDelay;
    [results addObject:toneResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)stepDidFinish {
    [super stepDidFinish];
    [self stopAudio];
    [self.dBHLToneAudiometryContentView finishStep:self];
    [self goForward];
}

- (void)start {
    [super start];
    [self runTestTrial];
}
    
- (void)stopAudio {
    [_audioGenerator stop];
    if (_preStimulusDelayWorkBlock) {
        dispatch_block_cancel(_preStimulusDelayWorkBlock);
        dispatch_block_cancel(_pulseDurationWorkBlock);
        dispatch_block_cancel(_postStimulusDelayWorkBlock);
    }
}

- (void)runTestTrial {
    [self stopAudio];
	
    
    [self.dBHLToneAudiometryContentView setProgress:self.audiometryEngine.progress animated:YES];

    ORKAudiometryStimulus *stimulus = self.audiometryEngine.nextStimulus;
    if (!stimulus) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self nextTrial];
        });
        return;
    }
        
    const NSTimeInterval toneDuration = [self dBHLToneAudiometryStep].toneDuration;
    const NSTimeInterval postStimulusDelay = [self dBHLToneAudiometryStep].postStimulusDelay;
    
    double delay1 = arc4random_uniform([self dBHLToneAudiometryStep].maxRandomPreStimulusDelay - 1);
    double delay2 = (double)arc4random_uniform(10)/10;
    double preStimulusDelay = delay1 + delay2 + 1;
    [self.audiometryEngine registerPreStimulusDelay:preStimulusDelay];
    
    _preStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        if ([[self audiometryEngine] respondsToSelector:@selector(registerStimulusPlayback)]) {
            [self.audiometryEngine registerStimulusPlayback];
        }
        [_audioGenerator playSoundAtFrequency:stimulus.frequency onChannel:stimulus.channel dBHL:stimulus.level];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(preStimulusDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), _preStimulusDelayWorkBlock);
    
    _pulseDurationWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        [_audioGenerator stop];
    });
    // adding 0.2 seconds to account for the fadeInDuration which is being set in ORKdBHLToneAudiometryAudioGenerator
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + 0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), _pulseDurationWorkBlock);
    
    _postStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        [self.audiometryEngine registerResponse:NO];
        [self nextTrial];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + postStimulusDelay) * NSEC_PER_SEC)), dispatch_get_main_queue(), _postStimulusDelayWorkBlock);
}

- (void)nextTrial {
    if (self.audiometryEngine.testEnded) {
        [self finish];
    } else {
        [self runTestTrial];
    }
}

- (void)tapButtonPressed {
    [self animatedBHLButton];
    [_hapticFeedback impactOccurred];
    
    if (_preStimulusDelayWorkBlock && dispatch_block_testcancel(_preStimulusDelayWorkBlock) == 0) {
        [self.audiometryEngine registerResponse:YES];
    }
    [self nextTrial];
}

- (void)toneWillStartClipping {
    if ([self.audiometryEngine respondsToSelector:@selector(signalClipped)]) {
        [self.audiometryEngine signalClipped];
    }
    [self nextTrial];
}


@end
