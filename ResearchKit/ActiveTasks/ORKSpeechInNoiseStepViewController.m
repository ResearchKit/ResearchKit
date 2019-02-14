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


#import "ORKSpeechInNoiseStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKSpeechInNoiseContentView.h"
#import "ORKSpeechInNoiseStep.h"

#import "ORKCollectionResult_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKRoundTappingButton.h"
#import "ORKSkin.h"

#import <AVFoundation/AVFoundation.h>
@import Accelerate;

@interface ORKSpeechInNoiseStepViewController () {
    AVAudioEngine *_audioEngine;
    AVAudioPlayerNode *_playerNode;
    AVAudioMixerNode *_mixerNode;
    float _peakPower;
    float _toneDuration;
    AVAudioPCMBuffer *_noiseAudioBuffer;
    AVAudioPCMBuffer *_speechAudioBuffer;
    AVAudioPCMBuffer *_filterAudioBuffer;
    AVAudioFrameCount _speechToneCapacity;
    AVAudioFrameCount _noiseToneCapacity;
    BOOL _installedTap;
}

@property (nonatomic, strong) ORKSpeechInNoiseContentView *speechInNoiseContentView;

@end

@implementation ORKSpeechInNoiseStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _noiseAudioBuffer = [[AVAudioPCMBuffer alloc] init];
    _speechAudioBuffer = [[AVAudioPCMBuffer alloc] init];
    _filterAudioBuffer = [[AVAudioPCMBuffer alloc] init];
    _installedTap = NO;
    self.speechInNoiseContentView = [[ORKSpeechInNoiseContentView alloc] init];
    self.activeStepView.activeCustomView = self.speechInNoiseContentView;
    _speechInNoiseContentView.alertColor = [UIColor blueColor];
    [self.speechInNoiseContentView.playButton addTarget:self action:@selector(tapButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    _audioEngine = [[AVAudioEngine alloc] init];
    _playerNode = [[AVAudioPlayerNode alloc] init];
    [_audioEngine attachNode:_playerNode];
    [self setupBuffers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_playerNode) {
        [_playerNode stop];
        [_mixerNode removeTapOnBus:0];
        [_audioEngine stop];
        _noiseAudioBuffer = nil;
        _speechAudioBuffer = nil;
        _filterAudioBuffer = nil;
        _audioEngine = nil;
        _playerNode = nil;
        _mixerNode = nil;
    }
}

- (void)setupBuffers {
    [self loadFileName:[self speechInNoiseStep].speechFileNameWithExtension intoBuffer:&_speechAudioBuffer];
    [self loadFileName:[self speechInNoiseStep].noiseFileNameWithExtension intoBuffer:&_noiseAudioBuffer];
    [self loadFileName:[self speechInNoiseStep].filterFileNameWithExtension intoBuffer:&_filterAudioBuffer];
    
    _mixerNode = _audioEngine.mainMixerNode;
    [_audioEngine connect:_playerNode to:_mixerNode format:_speechAudioBuffer.format];
    [_audioEngine startAndReturnError:nil];
    
    if ([self speechInNoiseStep].willAudioLoop) {
        [_playerNode scheduleBuffer:_speechAudioBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
    } else {
        int randomOffset = arc4random_uniform(_noiseToneCapacity - _speechToneCapacity);
        for (int i = 0; i < _speechToneCapacity; i++) {
            _speechAudioBuffer.floatChannelData[0][i] += _noiseAudioBuffer.floatChannelData[0][i + randomOffset] * [self speechInNoiseStep].gainAppliedToNoise;
        }
        for (int i = 0; i < _speechToneCapacity; i++) {
            _speechAudioBuffer.floatChannelData[0][i] *= _filterAudioBuffer.floatChannelData[0][i];
        }
        [_playerNode scheduleBuffer:_speechAudioBuffer atTime:nil options:AVAudioPlayerNodeBufferInterrupts completionHandler:nil];
    }
}

- (void)loadFileName: (NSString *)file intoBuffer: (AVAudioPCMBuffer * __strong *)buffer {
    NSArray *fileComponents = [file componentsSeparatedByString:@"."];
    NSString *fileName = fileComponents[0];
    NSString *fileExtension = fileComponents[1];
    
    NSURL *fileURL = [[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:fileExtension];
    
    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:fileURL error:nil];
    AVAudioFormat *audioFileFormat = audioFile.processingFormat;
    AVAudioFrameCount audioFileCapacity = (AVAudioFrameCount)audioFile.length;
    if (*buffer == _filterAudioBuffer) {
        _speechToneCapacity = audioFileCapacity;
    } else if (*buffer == _noiseAudioBuffer) {
        _noiseToneCapacity = audioFileCapacity;
    } else {
        AVAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        CMTime audioDuration = asset.duration;
        _toneDuration = CMTimeGetSeconds(audioDuration);
    }
    *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFileFormat frameCapacity:audioFileCapacity];
    [audioFile readIntoBuffer:*buffer error:nil];
}

- (void)installTap {

    AVAudioFormat *mainMixerFormat = [[_audioEngine mainMixerNode] outputFormatForBus:0];
    
    [_mixerNode installTapOnBus:0 bufferSize:1024 format:mainMixerFormat block:^(AVAudioPCMBuffer * _Nonnull buffer5, AVAudioTime * _Nonnull when) {
        float * const *channelData = [buffer5 floatChannelData];
        if (channelData[0]) {
            float avgValue = 0;
            unsigned long nFrames = [buffer5 frameLength];
            
            vDSP_maxmgv(channelData[0], 1 , &avgValue, nFrames);
            float lvlLowPassTrig = 0.3;
            _peakPower = lvlLowPassTrig * ((avgValue == 0)? -100 : 20* log10(avgValue)) + (1 - lvlLowPassTrig) * _peakPower;
            float clampedValue = MAX(_peakPower / 60.0, -1) + 1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_speechInNoiseContentView addSample:@(clampedValue)];
            });
        }
    }];
    
}

- (void)tapButtonPressed {
    if (_playerNode.isPlaying) {
        [_playerNode stop];
        [_mixerNode removeTapOnBus:0];
        [self finish];
    } else {
        [self installTap];
        [_playerNode play];
        if ([self speechInNoiseStep].willAudioLoop) {
            [_speechInNoiseContentView.playButton setTitle:ORKLocalizedString(@"SPEECH_IN_NOISE_STOP_AUDIO_LABEL", nil)
                             forState:UIControlStateNormal];
            [_speechInNoiseContentView.playButton setNormalTintColor:[UIColor ork_redColor]];
        } else {
            ORKWeakTypeOf(self) weakSelf = self;
            [_speechInNoiseContentView.playButton setEnabled:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_toneDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
                [_playerNode stop];
                [_mixerNode removeTapOnBus:0];
                [strongSelf finish];
            });
        }
    }
}

- (ORKSpeechInNoiseStep *)speechInNoiseStep {
    return (ORKSpeechInNoiseStep *)self.step;
}

@end
