/*
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

#import <ResearchKit/ORKRecorder.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKAudioGenerator` class represents an audio tone generator.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioGenerator : NSObject

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
