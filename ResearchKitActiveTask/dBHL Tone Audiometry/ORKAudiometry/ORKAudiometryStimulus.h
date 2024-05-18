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

#import <ResearchKit/ORKTypes.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKAudiometryStimulus` class represents a set of parameters to represent a tone to be
 presented to the user during an audiometry test.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudiometryStimulus : NSObject

/**
 A double value representing the frequency in hertz of the audio tone to be presented (read-only)
 */
@property (nonatomic, readonly) double frequency;

/**
 A double value representing the level in dBHL of the audio tone to be presented (read-only)
 */
@property (nonatomic, readonly) double level;

/**
 A ORKAudioChannel enum value representing the audio channel of the tone to be presented (read-only)
 */
@property (nonatomic, readonly) ORKAudioChannel channel;


/**
 Returns a ORKAudiometryStimulus initialized with the provided parameters.
 
 @param frequency   A double value representing the frequency in hertz of the audio tone.

 @param level   A double value representing the level in dBHL of the audio tone.

 @param channel   A ORKAudioChannel representing the audio channel of the tone.

 @return A ORKAudiometryStimulus object initialized with the passed tone parameters.
 */
- (instancetype)initWithFrequency:(double)frequency level:(double)level channel:(ORKAudioChannel)channel;

@end

NS_ASSUME_NONNULL_END
