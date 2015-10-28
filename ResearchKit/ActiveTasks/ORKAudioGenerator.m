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

#import "ORKAudioGenerator.h"

@import AudioToolbox;

@interface ORKAudioGenerator () {
    @public
    AudioComponentInstance _toneUnit;

@public
    double _frequency;
    double _theta;
    ORKAudioChannel _activeChannel;
    BOOL _playsStereo;
    double _fadeInFactor;
    NSTimeInterval _fadeInDuration;
}

- (void)setupAudioSession;
- (void)createToneUnit;
- (void)play;
- (void)handleInterruption:(id)sender;

@end


const double ORKSineWaveToneGeneratorAmplitudeDefault = 0.03f;
const double ORKSineWaveToneGeneratorSampleRateDefault = 44100.0f;

OSStatus ORKAudioGeneratorRenderTone(void *inRefCon,
                                     AudioUnitRenderActionFlags *ioActionFlags,
                                     const AudioTimeStamp 		*inTimeStamp,
                                     UInt32 					inBusNumber,
                                     UInt32 					inNumberFrames,
                                     AudioBufferList 			*ioData) {
    // Fixed amplitude is good enough for our purposes
    const double amplitude = ORKSineWaveToneGeneratorAmplitudeDefault;

    // Get the tone parameters out of the view controller
    ORKAudioGenerator *audioGenerator = (__bridge ORKAudioGenerator *)inRefCon;
    double theta = audioGenerator->_theta;
    double theta_increment = 2.0 * M_PI * audioGenerator->_frequency / ORKSineWaveToneGeneratorSampleRateDefault;

    double fadeInFactor = audioGenerator->_fadeInFactor;

    // This is a mono tone generator so we only need the first buffer
    Float32 *bufferActive    = (Float32 *)ioData->mBuffers[audioGenerator->_activeChannel].mData;
    Float32 *bufferNonActive = (Float32 *)ioData->mBuffers[1 - audioGenerator->_activeChannel].mData;

    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        double bufferValue = sin(theta) * amplitude * pow(10, 2 * fadeInFactor - 2);
        bufferActive[frame] = bufferValue;
        if (audioGenerator->_playsStereo) {
            bufferNonActive[frame] = bufferValue;
        } else {
            bufferNonActive[frame] = 0;
        }

        theta += theta_increment;
        if (theta > 2.0 * M_PI) {
            theta -= 2.0 * M_PI;
        }

        fadeInFactor += 1.0 / (ORKSineWaveToneGeneratorSampleRateDefault * audioGenerator->_fadeInDuration);
        if (fadeInFactor >= 1) {
            fadeInFactor = 1;
        }
    }

    // Store the theta back in the view controller
    audioGenerator->_theta = theta;
    audioGenerator->_fadeInFactor = fadeInFactor;

    return noErr;
}


@implementation ORKAudioGenerator

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAudioSession];
        
        // Automatically stop and then restart audio playback when the app resigns active.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [self stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (_toneUnit) {
        __unused OSErr err = AudioOutputUnitStart(_toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    if (_toneUnit) {
        __unused OSErr err = AudioOutputUnitStop(_toneUnit);
        NSAssert1(err == noErr, @"Error stopping unit: %hd", err);
    }
}

- (double)volumeInDecibels {
    return 20 * log(self.volumeAmplitude);
}

- (double)volumeAmplitude {
    return ORKSineWaveToneGeneratorAmplitudeDefault * pow(10, 2 * _fadeInFactor - 2);
}

- (void)playSoundAtFrequency:(double)playFrequency {
    _frequency = playFrequency;
    _fadeInFactor = 0;
    _fadeInDuration = 0.5;
    _playsStereo = YES;

    [self play];
}

- (void)playSoundAtFrequency:(double)playFrequency
                   onChannel:(ORKAudioChannel)playChannel
              fadeInDuration:(NSTimeInterval)duration {
    _frequency = playFrequency;
    _activeChannel = playChannel;
    _fadeInFactor = 0;
    _fadeInDuration = duration;
    _playsStereo = NO;

    [self play];
}

- (void)play {
    if (!_toneUnit) {
        [self createToneUnit];

        // Stop changing parameters on the unit
        OSErr err = AudioUnitInitialize(_toneUnit);
        NSAssert1(err == noErr, @"Error initializing unit: %hd", err);

        // Start playback
        err = AudioOutputUnitStart(_toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    }
}

- (void)stop {
    if (_toneUnit) {
        AudioOutputUnitStop(_toneUnit);
        AudioUnitUninitialize(_toneUnit);
        AudioComponentInstanceDispose(_toneUnit);
        _toneUnit = nil;
    }
}

- (void)setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSAssert1(ok, @"Audio error %@", setCategoryError);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:audioSession];
}

- (void)createToneUnit {
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;

    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");

    // Create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
    NSAssert1(_toneUnit, @"Error creating unit: %hd", err);

    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = ORKAudioGeneratorRenderTone;
    input.inputProcRefCon = (__bridge void *)(self);
    err = AudioUnitSetProperty(_toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);

    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = ORKSineWaveToneGeneratorSampleRateDefault;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (_toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

- (void)handleInterruption:(id)sender {
    [self stop];
}

@end
