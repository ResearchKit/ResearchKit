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


#import "ORKEnvironmentSPLMeterStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKRoundTappingButton.h"
#import "ORKEnvironmentSPLMeterContentView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKEnvironmentSPLMeterResult.h"
#import "ORKEnvironmentSPLMeterStep.h"

#import "ORKHelpers_Internal.h"
#import <AVFoundation/AVFoundation.h>
#include <sys/sysctl.h>

@interface ORKEnvironmentSPLMeterStepViewController () {
    AVAudioEngine *_audioEngine;
    AVAudioInputNode *_inputNode;
    AVAudioUnitEQ *_eqUnit;
    AVAudioFrameCount _bufferSize;
    uint32_t _sampleRate;
    AVAudioFormat *_inputNodeOutputFormat;
    int _countToFetch;
    NSMutableArray *_rmsBuffer;
    dispatch_semaphore_t _semaphoreRms;
    float _rmsData;
    float _spl;
    double _samplingInterval;
    double _thresholdValue;
    double _sensitivityOffset;
    NSInteger _requiredContiguousSamples;
    int _counter;
    NSMutableArray *_recordedSamples;
}

@property (nonatomic, strong) ORKEnvironmentSPLMeterContentView *environmentSPLMeterContentView;

@end

@implementation ORKEnvironmentSPLMeterStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _rmsBuffer = [NSMutableArray new];
        _semaphoreRms = dispatch_semaphore_create(1);
        _rmsData = 0.0;
        _spl = 0.0;
        _counter = 0;
        _samplingInterval = 1.0;
        _requiredContiguousSamples = 1;
        _sensitivityOffset = -23.3;
        _recordedSamples = [NSMutableArray new];
    }
    
    return self;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _sensitivityOffset = [self sensitivityOffsetForDevice];
    _environmentSPLMeterContentView = [ORKEnvironmentSPLMeterContentView new];
    [_environmentSPLMeterContentView setProgress:0.01 animated:YES];
    self.activeStepView.activeCustomView = _environmentSPLMeterContentView;
    [self requestMicrophoneAuthorization];
    [self configureAudioSession];
    _audioEngine = [[AVAudioEngine alloc] init];
    _eqUnit = [[AVAudioUnitEQ alloc] initWithNumberOfBands:6];
    _inputNode = [_audioEngine inputNode];
    _inputNodeOutputFormat = [_inputNode inputFormatForBus:0];
    _sampleRate = (uint32_t)_inputNodeOutputFormat.sampleRate;
    _bufferSize = _sampleRate/10;
    _countToFetch = _sampleRate/(int)_bufferSize;
    [self configureEQ];
    [_audioEngine attachNode:_eqUnit];
    [_audioEngine connect:_inputNode to:_eqUnit format:_inputNodeOutputFormat];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self start];
    
    _samplingInterval = [self environmentSPLMeterStep].samplingInterval;
    _requiredContiguousSamples = [self environmentSPLMeterStep].requiredContiguousSamples;
    _thresholdValue = [self environmentSPLMeterStep].thresholdValue;
    [_environmentSPLMeterContentView setThreshold:_thresholdValue];
    [self splWorkBlock];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_eqUnit removeTapOnBus:0];
    [_audioEngine stop];
    [_rmsBuffer removeAllObjects];
}

- (NSString *)deviceType {
    return [[UIDevice currentDevice] model];
}

- (double)sensitivityOffsetForDevice {
    NSDictionary *lookupTable = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"splMeter_sensitivity_offset"  ofType:@"plist"]];
    NSString *deviceTypeString = [self deviceType];
    double sensitivity = [[lookupTable valueForKey:deviceTypeString] doubleValue];
    return ( sensitivity ? : _sensitivityOffset);
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = sResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKEnvironmentSPLMeterResult *splResult = [[ORKEnvironmentSPLMeterResult alloc] initWithIdentifier:self.step.identifier];
    splResult.startDate = sResult.startDate;
    splResult.endDate = now;
    splResult.sensitivityOffset = _sensitivityOffset;
    splResult.recordedSPLMeterSamples = [_recordedSamples copy];
    
    [results addObject:splResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)requestMicrophoneAuthorization {
    [[AVAudioSession sharedInstance] recordPermission];
}

- (void)configureAudioSession {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if ([AVAudioSession sharedInstance].isOtherAudioPlaying) {
        NSError *activationError = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
    }
}

- (void)configureEQ {
    _eqUnit.globalGain = 0;
    
    // A-weighting EQ
    AVAudioUnitEQFilterParameters *eqCoefficient = _eqUnit.bands[0];
    eqCoefficient.filterType = AVAudioUnitEQFilterTypeHighPass;
    eqCoefficient.frequency = 290;
    eqCoefficient.bypass = NO;
    
    eqCoefficient = _eqUnit.bands[1];
    eqCoefficient.filterType = AVAudioUnitEQFilterTypeParametric;
    eqCoefficient.frequency = 243;
    eqCoefficient.bandwidth = 1.3882;
    eqCoefficient.gain = -4.5;
    eqCoefficient.bypass = NO;
    
    eqCoefficient = _eqUnit.bands[2];
    eqCoefficient.filterType = AVAudioUnitEQFilterTypeParametric;
    eqCoefficient.frequency = 450;
    eqCoefficient.bandwidth = 0.94428;
    eqCoefficient.gain = -1.5;
    eqCoefficient.bypass = NO;
    
    eqCoefficient = _eqUnit.bands[3];
    eqCoefficient.filterType = AVAudioUnitEQFilterTypeParametric;
    eqCoefficient.frequency = 2650;
    eqCoefficient.bandwidth = 2.4924;
    eqCoefficient.gain = 1.25;
    eqCoefficient.bypass = NO;
    
    eqCoefficient = _eqUnit.bands[4];
    eqCoefficient.filterType = AVAudioUnitEQFilterTypeParametric;
    eqCoefficient.frequency = 10000;
    eqCoefficient.bandwidth = 1.0246;
    eqCoefficient.gain = -1.5;
    eqCoefficient.bypass = NO;
    
    eqCoefficient = _eqUnit.bands[5];
    eqCoefficient.filterType = AVAudioUnitEQFilterTypeLowPass;
    eqCoefficient.frequency = 11800;
    eqCoefficient.bypass = NO;
}


- (void)splWorkBlock {
    if (!_audioEngine.isRunning && ![[AVAudioSession sharedInstance] isOtherAudioPlaying]) {
        [_eqUnit installTapOnBus:0
                      bufferSize:_bufferSize
                          format:_inputNodeOutputFormat
                           block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
                               if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted) {
                                   if (buffer.frameLength != _bufferSize) {
                                       _bufferSize = buffer.frameLength;
                                   }
                                   int sampleCount = _samplingInterval * _countToFetch;
                                   float rms = 0.0;
                                   for (int i = 0; i < buffer.frameLength; i++) {
                                       float value = [@(buffer.floatChannelData[0][i]) floatValue];
                                       rms +=  value * value;
                                   }
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       [_rmsBuffer addObject:@(rms)];
                                       
                                       // perform averaging based on capture interval
                                       if (_rmsBuffer.count >= sampleCount + 1) {
                                           float rmsSum = 0.0;
                                           int i = sampleCount;
                                           NSUInteger j = _rmsBuffer.count - 1;
                                           while (i>0) {
                                               rmsSum += [_rmsBuffer[j] floatValue];
                                               i --;
                                               j --;
                                           }
                                           _rmsData = rmsSum/_samplingInterval;
                                           float calValue = _sensitivityOffset;
                                           _spl = (20 * log10f(sqrtf(_rmsData/(float)_sampleRate))) - calValue + 94;
                                           [_recordedSamples addObject:[NSNumber numberWithFloat:_spl]];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.environmentSPLMeterContentView setProgressCircle:(_spl/_thresholdValue)];
                                               [self.environmentSPLMeterContentView setDBText:[NSString stringWithFormat:@"%.f", _spl]];
                                           });
                                           [self evaluateThreshold:_spl];
                                           [_rmsBuffer removeAllObjects];
                                       }
                                       dispatch_semaphore_signal(_semaphoreRms);
                                   });
                                   dispatch_semaphore_wait(_semaphoreRms, DISPATCH_TIME_FOREVER);
                               } else if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionDenied) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self.environmentSPLMeterContentView setDBText:[NSString stringWithFormat:@"N/A"]];
                                       [_eqUnit removeTapOnBus:0];
                                       [_audioEngine stop];
                                       [_rmsBuffer removeAllObjects];
                                   });
                               }
                           }];
        if (!_audioEngine.isRunning && ![[AVAudioSession sharedInstance] isOtherAudioPlaying]) {
            NSError *error = nil;
            [_audioEngine startAndReturnError:&error];
        } else {
            [_eqUnit removeTapOnBus:0];
            [_audioEngine stop];
            [_rmsBuffer removeAllObjects];
        }
    }
}

- (void) evaluateThreshold: (float)spl {
    if (spl < _thresholdValue) {
        _counter += 1;
        if (_counter >= _requiredContiguousSamples) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finish];
            });
        }
    } else {
        _counter = 0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.environmentSPLMeterContentView setProgress:((float)_counter/_requiredContiguousSamples) + 0.01 animated:YES];
    });
}

- (void) resetAudioSession {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if (error) {
        ORK_Log_Error(@"Setting AVAudioSessionCategory failed with error message: \"%@\"", error.localizedDescription);
    }
    if ([AVAudioSession sharedInstance].isOtherAudioPlaying) {
        NSError *activationError = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
        if (activationError) {
            ORK_Log_Error(@"Activating AVAudioSession failed with error message: \"%@\"", activationError.localizedDescription);
        }
    }
}

- (void)stepDidFinish {
    [super stepDidFinish];
    
    [self.environmentSPLMeterContentView finishStep:self];
    [self resetAudioSession];
    [self goForward];
}

- (void)start {
    [super start];
}

- (ORKEnvironmentSPLMeterStep *)environmentSPLMeterStep {
    return (ORKEnvironmentSPLMeterStep *)self.step;
}

@end

