/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.

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

 ---

 This software is based on the original source by Matt Gallagher.
 http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html

 Copyright (c) 2009-2011 Matt Gallagher. All rights reserved.

 This software is provided 'as-is', without any express or implied warranty. In
 no event will the authors be held liable for any damages arising from the use
 of this software. Permission is granted to anyone to use this software for any
 purpose, including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not claim
    that you wrote the original software. If you use this software in a product,
    an acknowledgment in the product documentation would be appreciated but is
    not required.
 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
 */


@import UIKit;
@import AVFoundation;
#import "ORKTypes.h"


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKAudioGenerator` class represents an audio tone generator.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioGenerator : NSObject

/**
 Plays a tone at a specific frequency in stereo.

 The sound is a "pure" sinusoid tone.

 @param frequency The audio frequency in hertz.
 */
- (void)playSoundAtFrequency:(double)frequency;

/**
 Plays a tone at a specific frequency on a specific channel, with a fade-in effect.

 The sound is a "pure" sinusoid tone.
 The fade-in effect is applied linearly for the peak amplitude, from a 0 to 1 factor.

 @param frequency The audio frequency in hertz.
 @param channel The audio channel (left or right).
 @param duration The fade-in duration.
 */
- (void)playSoundAtFrequency:(double)frequency
                   onChannel:(ORKAudioChannel)channel
              fadeInDuration:(NSTimeInterval)duration;

/**
 Stops the audio being played.
 */
- (void)stop;

/**
 Returns the peak audio volume being currently played, in decibels (dB).

 @return The current audio volume in decibels.
 */
- (double)volumeInDecibels;

/**
 Returns the peak audio volume amplitude being currently played (from 0 to 1).

 @return The current audio volume amplitude.
 */
- (double)volumeAmplitude;

@end

NS_ASSUME_NONNULL_END
