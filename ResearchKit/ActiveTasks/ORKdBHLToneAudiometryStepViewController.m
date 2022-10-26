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

@interface ORKdBHLToneAudiometryTransitions: NSObject

@property (nonatomic, assign) float userInitiated;
@property (nonatomic, assign) float totalTransitions;

@end

@implementation ORKdBHLToneAudiometryTransitions

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userInitiated = 1;
        _totalTransitions = 1;
    }
    return self;
}

@end

@interface ORKdBHLToneAudiometryStepViewController () <ORKdBHLToneAudiometryAudioGeneratorDelegate> {
    double _prevFreq;
    double _currentdBHL;
    double _dBHLStepUpSize;
    double _dBHLStepDownSize;
    double _dBHLMinimumThreshold;
    int _currentTestIndex;
    int _indexOfFreqLoopList;
    NSUInteger _indexOfStepUpMissingList;
    int _numberOfTransitionsPerFreq;
    NSInteger _maxNumberOfTransitionsPerFreq;
    BOOL _initialDescent;
    BOOL _ackOnce;
    BOOL _usingMissingList;
    ORKdBHLToneAudiometryAudioGenerator *_audioGenerator;
    NSArray *_freqLoopList;
    NSArray *_stepUpMissingList;
    NSMutableArray *_arrayOfResultSamples;
    NSMutableArray *_arrayOfResultUnits;
    NSMutableDictionary *_transitionsDictionary;
    UIImpactFeedbackGenerator *_hapticFeedback;
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKdBHLToneAudiometryUnit *_resultUnit;
    ORKAudioChannel _audioChannel;
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
        _indexOfFreqLoopList = 0;
        _indexOfStepUpMissingList = 0;
        _initialDescent = YES;
        _ackOnce = NO;
        _usingMissingList = YES;
        _prevFreq = 0;
        _currentTestIndex = 0;
        _transitionsDictionary = [NSMutableDictionary dictionary];
        _arrayOfResultSamples = [NSMutableArray array];
        _arrayOfResultUnits = [NSMutableArray array];
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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureStep];
}

- (void)configureStep {
    ORKdBHLToneAudiometryStep *dBHLTAStep = [self dBHLToneAudiometryStep];

    _maxNumberOfTransitionsPerFreq = dBHLTAStep.maxNumberOfTransitionsPerFrequency;
    _freqLoopList = dBHLTAStep.frequencyList;
    _stepUpMissingList = @[ [NSNumber numberWithDouble:dBHLTAStep.dBHLStepUpSizeFirstMiss],
                            [NSNumber numberWithDouble:dBHLTAStep.dBHLStepUpSizeSecondMiss],
                            [NSNumber numberWithDouble:dBHLTAStep.dBHLStepUpSizeThirdMiss] ];
    _currentdBHL = dBHLTAStep.initialdBHLValue;
    _dBHLStepDownSize = dBHLTAStep.dBHLStepDownSize;
    _dBHLStepUpSize = dBHLTAStep.dBHLStepUpSize;
    _dBHLMinimumThreshold = dBHLTAStep.dBHLMinimumThreshold;

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
    toneResult.samples = [_arrayOfResultSamples copy];
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
    [self estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
}
    
- (void)stopAudio {
    [_audioGenerator stop];
    if (_preStimulusDelayWorkBlock) {
        dispatch_block_cancel(_preStimulusDelayWorkBlock);
        dispatch_block_cancel(_pulseDurationWorkBlock);
        dispatch_block_cancel(_postStimulusDelayWorkBlock);
    }
}

- (void)estimatedBHLAndPlayToneWithFrequency: (NSNumber *)freq {
    [self stopAudio];
    if (_prevFreq != [freq doubleValue]) {
        CGFloat progress = 0.001 + (CGFloat)_indexOfFreqLoopList / _freqLoopList.count;
        [self.dBHLToneAudiometryContentView setProgress:progress
                                               animated:YES];
        
        _numberOfTransitionsPerFreq = 0;
        _currentdBHL = [self dBHLToneAudiometryStep].initialdBHLValue;
        _initialDescent = YES;
        _ackOnce = NO;
        _usingMissingList = YES;
        _indexOfStepUpMissingList = 0;
        _transitionsDictionary = nil;
        _transitionsDictionary = [NSMutableDictionary dictionary];
        if (_resultSample) {
           _resultSample.units = [_arrayOfResultUnits copy];
        }
        _arrayOfResultUnits = [NSMutableArray array];
        _prevFreq = [freq doubleValue];
        _resultSample = [ORKdBHLToneAudiometryFrequencySample new];
        _resultSample.channel = _audioChannel;
        _resultSample.frequency = [freq doubleValue];
        _resultSample.calculatedThreshold = ORKInvalidDBHLValue;
        [_arrayOfResultSamples addObject:_resultSample];
    } else {
        _numberOfTransitionsPerFreq += 1;
        if (_numberOfTransitionsPerFreq >= _maxNumberOfTransitionsPerFreq) {
            _indexOfFreqLoopList += 1;
            if (_indexOfFreqLoopList >= _freqLoopList.count) {
                _resultSample.units = [_arrayOfResultUnits copy];
                [self finish];
                return;
            } else {
                [self estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
                return;
            }
        }
    }
    
    _resultUnit = [ORKdBHLToneAudiometryUnit new];
    _resultUnit.dBHLValue = _currentdBHL;
    _resultUnit.startOfUnitTimeStamp = self.runtime;
    [_arrayOfResultUnits addObject:_resultUnit];
    
    ORKdBHLToneAudiometryTransitions *currentTransition = [_transitionsDictionary objectForKey:[NSNumber numberWithFloat:_currentdBHL]];
    if (!_initialDescent) {
        if (currentTransition) {
            currentTransition.userInitiated += 1;
            currentTransition.totalTransitions += 1;
        } else {
            currentTransition = [[ORKdBHLToneAudiometryTransitions alloc] init];
            [_transitionsDictionary setObject:currentTransition forKey:[NSNumber numberWithFloat:_currentdBHL]];
        }
    }
    const NSTimeInterval toneDuration = [self dBHLToneAudiometryStep].toneDuration;
    const NSTimeInterval postStimulusDelay = [self dBHLToneAudiometryStep].postStimulusDelay;
    
    double delay1 = arc4random_uniform([self dBHLToneAudiometryStep].maxRandomPreStimulusDelay - 1);
    double delay2 = (double)arc4random_uniform(10)/10;
    double preStimulusDelay = delay1 + delay2 + 1;
    _resultUnit.preStimulusDelay = preStimulusDelay;
    
    _preStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        [_audioGenerator playSoundAtFrequency:[freq floatValue] onChannel:_audioChannel dBHL:_currentdBHL];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(preStimulusDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), _preStimulusDelayWorkBlock);
    
    _pulseDurationWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        [_audioGenerator stop];
    });
    // adding 0.2 seconds to account for the fadeInDuration which is being set in ORKdBHLToneAudiometryAudioGenerator
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + 0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), _pulseDurationWorkBlock);

    ORKWeakTypeOf(self)weakSelf = self;
    _postStimulusDelayWorkBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        NSUInteger storedTestIndex = _currentTestIndex;
        if (_currentTestIndex == storedTestIndex) {
            if (_initialDescent && _ackOnce) {
                _initialDescent = NO;
                ORKdBHLToneAudiometryTransitions *newTransition = [[ORKdBHLToneAudiometryTransitions alloc] init];
                newTransition.userInitiated -= 1;
                [_transitionsDictionary setObject:newTransition forKey:[NSNumber numberWithFloat:_currentdBHL]];
            }
            if (_usingMissingList && (_indexOfStepUpMissingList < _stepUpMissingList.count)) {
                _currentdBHL = _currentdBHL + [_stepUpMissingList[_indexOfStepUpMissingList] doubleValue];
                _indexOfStepUpMissingList = _indexOfStepUpMissingList + 1;
            } else {
                _usingMissingList = NO;
                _currentdBHL = _currentdBHL + _dBHLStepUpSize;
            }
            if (currentTransition) {
                currentTransition.userInitiated -= 1;
            }
            _resultUnit.timeoutTimeStamp = self.runtime;
            _currentTestIndex += 1;
            [strongSelf estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
            return;
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preStimulusDelay + toneDuration + postStimulusDelay) * NSEC_PER_SEC)), dispatch_get_main_queue(), _postStimulusDelayWorkBlock);

}

- (void)tapButtonPressed {
    [self animatedBHLButton];
    _ackOnce = YES;
    [_hapticFeedback impactOccurred];
    _currentTestIndex += 1;
    _resultUnit.userTapTimeStamp = self.runtime;
    [self stopAudio];
    BOOL falseResponseTap = (_resultUnit.userTapTimeStamp - _resultUnit.startOfUnitTimeStamp < _resultUnit.preStimulusDelay);
    if (falseResponseTap) {
        NSNumber *currentKey = [NSNumber numberWithFloat:_currentdBHL];
        ORKdBHLToneAudiometryTransitions *currentTransitionObject = [_transitionsDictionary objectForKey:currentKey];
        currentTransitionObject.userInitiated -= 1;
    } else if ([self validateResultFordBHL:_currentdBHL]) {
        _resultSample.calculatedThreshold = _currentdBHL;
        _indexOfFreqLoopList += 1;
        if (_indexOfFreqLoopList >= _freqLoopList.count) {
            _resultSample.units = [_arrayOfResultUnits copy];
            [self finish];
            return;
        } else {
            _currentdBHL = [self dBHLToneAudiometryStep].initialdBHLValue;
            [self estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
            return;
        }
    }
    
    if ((_currentdBHL - _dBHLStepDownSize >= _dBHLMinimumThreshold) && !falseResponseTap) {
        _usingMissingList = NO;
        _currentdBHL = _currentdBHL - _dBHLStepDownSize;
    }

    [self estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
    return;
}

- (BOOL)validateResultFordBHL:(float)dBHL {
    NSNumber *currentKey = [NSNumber numberWithFloat:_currentdBHL];
    ORKdBHLToneAudiometryTransitions *currentTransitionObject = [_transitionsDictionary objectForKey:currentKey];
    if ((currentTransitionObject.userInitiated/currentTransitionObject.totalTransitions >= 0.5) && currentTransitionObject.totalTransitions >= 2) {
        ORKdBHLToneAudiometryTransitions *previousTransitionObject = [_transitionsDictionary objectForKey:[NSNumber numberWithFloat:(dBHL - _dBHLStepUpSize)]];
        if ((previousTransitionObject.userInitiated/previousTransitionObject.totalTransitions <= 0.5) && (previousTransitionObject.totalTransitions >= 2)) {
            if (currentTransitionObject.totalTransitions == 2) {
                if (currentTransitionObject.userInitiated/currentTransitionObject.totalTransitions == 1.0) {
                    _resultSample.calculatedThreshold = dBHL;
                    return YES;
                } else {
                    return NO;
                }
            } else {
                _resultSample.calculatedThreshold = dBHL;
                return YES;
            }
        }
    }
    return NO;
}

- (void)toneWillStartClipping {
    if (_usingMissingList
        && (_indexOfStepUpMissingList <= _stepUpMissingList.count)) {
        _usingMissingList = NO;
        _currentdBHL = _currentdBHL - [_stepUpMissingList[_indexOfStepUpMissingList - (_indexOfStepUpMissingList == 0 ? 0 : 1)] doubleValue] + _dBHLStepUpSize;
        [self estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
    } else {
        _indexOfFreqLoopList += 1;
        if (_indexOfFreqLoopList >= _freqLoopList.count) {
            _resultSample.units = [_arrayOfResultUnits copy];
            [self finish];
        } else {
            [self estimatedBHLAndPlayToneWithFrequency:_freqLoopList[_indexOfFreqLoopList]];
        }
    }
}

@end
