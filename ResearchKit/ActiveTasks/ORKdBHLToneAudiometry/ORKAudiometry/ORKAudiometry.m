/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#import "ORKAudiometry.h"
#import "ORKdBHLToneAudiometryStep.h"
#import "ORKdBHLToneAudiometryResult.h"
#import "ORKAudiometryStimulus.h"

@interface ORKAudiometryTransition: NSObject

@property (nonatomic, assign) float userInitiated;
@property (nonatomic, assign) float totalTransitions;

@end

@implementation ORKAudiometryTransition

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

@interface ORKAudiometry () {
    double _prevFreq;
    double _currentdBHL;
    double _initialdBHLValue;
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
    NSArray *_freqLoopList;
    NSArray *_stepUpMissingList;
    NSMutableArray *_arrayOfResultSamples;
    NSMutableArray *_arrayOfResultUnits;
    NSMutableDictionary *_transitionsDictionary;
    
    ORKdBHLToneAudiometryFrequencySample *_resultSample;
    ORKdBHLToneAudiometryUnit *_resultUnit;
    ORKAudioChannel _audioChannel;
    int _minimumThresholdCounter;
    
    ORKAudiometryTimestampProvider _getTimestamp;
    ORKAudiometryStimulus *_nextStimulus;
    BOOL _preStimulusResponse;
}

@end


@implementation ORKAudiometry

@synthesize progress;
@synthesize testEnded;
@synthesize timestampProvider;

- (instancetype)initWithStep:(ORKdBHLToneAudiometryStep *)step {
    self = [super init];
    
    if (self) {
        _indexOfFreqLoopList = 0;
        _indexOfStepUpMissingList = 0;
        _initialDescent = YES;
        _ackOnce = NO;
        _usingMissingList = YES;
        _prevFreq = 0;
        _minimumThresholdCounter = 0;
        _currentTestIndex = 0;
        _transitionsDictionary = [NSMutableDictionary dictionary];
        _arrayOfResultSamples = [NSMutableArray array];
        _arrayOfResultUnits = [NSMutableArray array];
        _preStimulusResponse = YES;
        _getTimestamp = ^NSTimeInterval{
            return 0;
        };
        
        [self configureWithStep:step];
    }

    return self;
}

- (void)setTimestampProvider:(ORKAudiometryTimestampProvider)provider {
    _getTimestamp = provider;
}

- (ORKAudiometryStimulus *)nextStimulus {
    return _nextStimulus;
}

- (void)registerPreStimulusDelay:(double)preStimulusDelay {
    _resultUnit.preStimulusDelay = preStimulusDelay;
}

- (void)registerStimulusPlayback {
    _preStimulusResponse = NO;
}

- (void)registerResponse:(BOOL)response {
    if (response) {
        [self stimulusAcknowledged];
    } else {
        [self stimulusMissed];
    }
}

- (void)signalClipped {
    if (_usingMissingList
        && (_indexOfStepUpMissingList <= _stepUpMissingList.count)) {
        _usingMissingList = NO;
        _currentdBHL = _currentdBHL - [_stepUpMissingList[_indexOfStepUpMissingList - (_indexOfStepUpMissingList == 0 ? 0 : 1)] doubleValue] + _dBHLStepUpSize;
        [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
    } else {
        _indexOfFreqLoopList += 1;
        if (_indexOfFreqLoopList >= _freqLoopList.count) {
            _resultSample.units = [_arrayOfResultUnits copy];
            testEnded = YES;
        } else {
            [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
        }
    }
}

- (NSArray<ORKdBHLToneAudiometryFrequencySample *> *)resultSamples {
    return [_arrayOfResultSamples copy];
}

- (void)configureWithStep:(ORKdBHLToneAudiometryStep *)step {
    _maxNumberOfTransitionsPerFreq = step.maxNumberOfTransitionsPerFrequency;
    _freqLoopList = step.frequencyList;
    _stepUpMissingList = @[ [NSNumber numberWithDouble:step.dBHLStepUpSizeFirstMiss],
                            [NSNumber numberWithDouble:step.dBHLStepUpSizeSecondMiss],
                            [NSNumber numberWithDouble:step.dBHLStepUpSizeThirdMiss] ];
    _currentdBHL = step.initialdBHLValue;
    _initialdBHLValue = step.initialdBHLValue;
    _dBHLStepDownSize = step.dBHLStepDownSize;
    _dBHLStepUpSize = step.dBHLStepUpSize;
    _dBHLMinimumThreshold = step.dBHLMinimumThreshold;
    _audioChannel = step.earPreference;
    
    [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
}

- (void)estimatedBHLForFrequency:(NSNumber *)freq {
    if (_prevFreq != [freq doubleValue]) {
        progress = 0.001 + (CGFloat)_indexOfFreqLoopList / _freqLoopList.count;
        
        _numberOfTransitionsPerFreq = 0;
        _currentdBHL = _initialdBHLValue;
        _initialDescent = YES;
        _ackOnce = NO;
        _usingMissingList = YES;
        _indexOfStepUpMissingList = 0;
        _minimumThresholdCounter = 0;
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
                testEnded = YES;
                return;
            } else {
                [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
                return;
            }
        }
    }
    
    _resultUnit = [ORKdBHLToneAudiometryUnit new];
    _resultUnit.dBHLValue = _currentdBHL;
    _resultUnit.startOfUnitTimeStamp = _getTimestamp();
    [_arrayOfResultUnits addObject:_resultUnit];
    
    ORKAudiometryTransition *currentTransition = [_transitionsDictionary objectForKey:[NSNumber numberWithFloat:_currentdBHL]];
    if (!_initialDescent) {
        if (currentTransition) {
            currentTransition.userInitiated += 1;
            currentTransition.totalTransitions += 1;
        } else {
            currentTransition = [[ORKAudiometryTransition alloc] init];
            [_transitionsDictionary setObject:currentTransition forKey:[NSNumber numberWithFloat:_currentdBHL]];
        }
    }

    _preStimulusResponse = YES;
    _nextStimulus = [[ORKAudiometryStimulus alloc] initWithFrequency:[freq doubleValue] level:_currentdBHL channel:_audioChannel];
}

- (void)stimulusMissed {
    ORKAudiometryTransition *currentTransition = [_transitionsDictionary objectForKey:[NSNumber numberWithFloat:_currentdBHL]];
    NSUInteger storedTestIndex = _currentTestIndex;
    if (_currentTestIndex == storedTestIndex) {
        if (_initialDescent && _ackOnce) {
            _initialDescent = NO;
            ORKAudiometryTransition *newTransition = [[ORKAudiometryTransition alloc] init];
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
        _resultUnit.timeoutTimeStamp = _getTimestamp();
        _currentTestIndex += 1;
        [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
    }
}

- (void)stimulusAcknowledged {
    _ackOnce = YES;
    _currentTestIndex += 1;
    _resultUnit.userTapTimeStamp = _getTimestamp();
    if (_preStimulusResponse) {
        NSNumber *currentKey = [NSNumber numberWithFloat:_currentdBHL];
        ORKAudiometryTransition *currentTransitionObject = [_transitionsDictionary objectForKey:currentKey];
        currentTransitionObject.userInitiated -= 1;
    } else if ([self validateResultFordBHL:_currentdBHL]) {
        _resultSample.calculatedThreshold = _currentdBHL;
        _indexOfFreqLoopList += 1;
        if (_indexOfFreqLoopList >= _freqLoopList.count) {
            _resultSample.units = [_arrayOfResultUnits copy];
            testEnded = YES;
            return;
        } else {
            _currentdBHL = _initialdBHLValue;
            [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
            return;
        }
    }
    
    if (!_preStimulusResponse) {
        _usingMissingList = NO;
        
        if (_currentdBHL - _dBHLStepDownSize > _dBHLMinimumThreshold) {
            _currentdBHL = _currentdBHL - _dBHLStepDownSize;
        } else {
            _currentdBHL = _dBHLMinimumThreshold;
            if (_initialDescent) {
                _minimumThresholdCounter += 1;
            }
        }
    }

    [self estimatedBHLForFrequency:_freqLoopList[_indexOfFreqLoopList]];
    return;
}

- (BOOL)validateResultFordBHL:(float)dBHL {
    NSNumber *currentKey = [NSNumber numberWithFloat:_currentdBHL];
    ORKAudiometryTransition *currentTransitionObject = [_transitionsDictionary objectForKey:currentKey];
    if ((currentTransitionObject.userInitiated/currentTransitionObject.totalTransitions >= 0.5) && currentTransitionObject.totalTransitions >= 2) {
        ORKAudiometryTransition *previousTransitionObject = [_transitionsDictionary objectForKey:[NSNumber numberWithFloat:(dBHL - _dBHLStepUpSize)]];
        if (((previousTransitionObject.userInitiated/previousTransitionObject.totalTransitions <= 0.5) && (previousTransitionObject.totalTransitions >= 2)) || dBHL == _dBHLMinimumThreshold) {
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
    } else if (_minimumThresholdCounter > 2) {
        _resultSample.calculatedThreshold = dBHL;
        return YES;
    }
    return NO;
}

@end
