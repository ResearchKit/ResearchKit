/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import <ResearchKit/ORKRecorder.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The ORKAudioRecorder class represents a recorder that uses the app's 
 `AVAudioSession` object to record audio.
 
 To ensure audio recording continues when a task enters the background,
 add the `audio` tag to `UIBackgroundModes` in your app's `Info.plist` file.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioRecorder : ORKRecorder

/**
 The default audio format settings.
 
 If no settings are specified, the audio configuration is
 MPEG4 AAC, 2 channels, 16 bit, 44.1 kHz, AVAudioQualityMin.
 */
+ (NSDictionary *)defaultRecorderSettings;

/**
 Audio format settings
 
 Settings for the recording session.
 Passed to  AVAudioRecorder`'s `-initWithURL:settings:error:`
 For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, copy, readonly) NSDictionary *recorderSettings;

/**
 Returns an initialized audio recorder using the specified settings, step, and output directory.
 
 @param identifier          The unique identifier of the recorder (assigned by the recorder configuration).
 @param recorderSettings    The settings for the recording session.
 @param step                The step that requested this recorder.
 @param outputDirectory     The directory in which the audio output should be stored.
 
 @return An initialized audio recorder.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                  recorderSettings:(nullable NSDictionary *)recorderSettings
                              step:(nullable ORKStep *)step
                   outputDirectory:(nullable NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;

/**
 Reference to the audio recorder being used.
 
 The value of this property is used in the audio task in order to display recorded volume in real time during the task.
 */
@property (nonatomic, strong, readonly, nullable) AVAudioRecorder *audioRecorder;

@end

NS_ASSUME_NONNULL_END
