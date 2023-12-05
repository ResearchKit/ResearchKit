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

#import <ResearchKit/ORKAudiometryStimulus.h>

typedef NSTimeInterval(^ORKAudiometryTimestampProvider)(void);

@class ORKdBHLToneAudiometryFrequencySample;

/**
 Defines the interface of an audiometry algorithm.
 */
@protocol ORKAudiometryProtocol <NSObject>

/**
 A float value indicating the progress of the test from 0.0 to 1.0 (read-only)
 */
@property (nonatomic, readonly) float progress;

/**
 A Boolean value indicating the end of the test (read-only)
 */
@property (nonatomic, readonly) BOOL testEnded;

/**
 A block used to retrieve timestamp from external sources to be included in the results.
 */
@property (nonatomic, strong) ORKAudiometryTimestampProvider timestampProvider;

/**
 This method should return a `ORKAudiometryStimulus` providing the parameters of the tone that should presented next, if available.
 */
- (ORKAudiometryStimulus *)nextStimulus;

/**
 Called just before presenting tone.
 */
- (void)registerStimulusPlayback;

/**
 Register the user response for the last presented tone.
 
 @param BOOL  A Boolean representing if the user acknowledged the last presented tone.
 */
- (void)registerResponse:(BOOL)response;

/**
 Informs the audiometry algorithm that the last provided tone could not be reproduced due to signal clipping. Optional.
 */
@optional
- (void)signalClipped;

/**
 Used by some UIs to setup the prestimulus delay.
 
 @param double The value of the preStimulusDelay
 */
@optional
- (void)registerPreStimulusDelay:(double)preStimulusDelay;

/**
 Returns an array of containing the results of the audiometry test.
  
 @return An array of  `ORKdBHLToneAudiometryFrequencySample` representing the results of the audiometry test..
 */
- (NSArray<ORKdBHLToneAudiometryFrequencySample *> *)resultSamples;

@end
