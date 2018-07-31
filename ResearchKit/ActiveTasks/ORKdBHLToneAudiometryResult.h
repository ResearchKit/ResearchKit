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


#import <ResearchKit/ORKResult.h>

NS_ASSUME_NONNULL_BEGIN

@class ORKdBHLToneAudiometryFrequencySample;
@class ORKdBHLToneAudiometryUnit;

ORK_CLASS_AVAILABLE
@interface ORKdBHLToneAudiometryResult : ORKResult

@property (nonatomic, assign) double outputVolume;

@property (nonatomic, assign) NSTimeInterval tonePlaybackDuration;

@property (nonatomic, assign) NSTimeInterval postStimulusDelay;

@property (nonatomic, copy, nullable) NSString *headphoneType;

@property (nonatomic, copy, nullable) NSArray<ORKdBHLToneAudiometryFrequencySample *> *samples;

@end

ORK_CLASS_AVAILABLE
@interface ORKdBHLToneAudiometryFrequencySample : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, assign) double frequency;

@property (nonatomic, assign) double calculatedThreshold;

@property (nonatomic, assign) ORKAudioChannel channel;

@property (nonatomic, copy, nullable) NSArray<ORKdBHLToneAudiometryUnit *> *units;

@end

ORK_CLASS_AVAILABLE
@interface ORKdBHLToneAudiometryUnit : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, assign) double dBHLValue;

@property (nonatomic, assign) NSTimeInterval startOfUnitTimeStamp;

@property (nonatomic, assign) NSTimeInterval preStimulusDelay;

@property (nonatomic, assign) NSTimeInterval userTapTimeStamp;

@property (nonatomic, assign) NSTimeInterval timeoutTimeStamp;

@end

NS_ASSUME_NONNULL_END
