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


#import "ORKStreamingAudioRecorder.h"

#import "ORKRecorder_Internal.h"

#import "ORKHelpers_Internal.h"


@interface ORKStreamingAudioRecorder ()

@property (nonatomic, copy) NSString *savedSessionCategory;

@end


@implementation ORKStreamingAudioRecorder

- (void)dealloc {
    ORK_Log_Debug(@"Remove audiorecorder %p", self);
    if ([_audioEngine isRunning]) {
        [_audioEngine stop];
        [[_audioEngine inputNode] removeTapOnBus:0];
    }
    _audioEngine = nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                              step:(ORKStep *)step
                   outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier step:step outputDirectory:outputDirectory];
    if (self) {
        
        self.continuesInBackground = YES;
    }
    return self;
}

- (void)restoreSavedAudioSessionCategory {
    if (_savedSessionCategory) {
        NSError *error;
        if (![[AVAudioSession sharedInstance] setCategory:_savedSessionCategory error:&error]) {
            ORK_Log_Error(@"Failed to restore the audio session category: %@", [error localizedDescription]);
        }
        _savedSessionCategory = nil;
    }
}

- (NSURL *)recordingFileURL {
    return [[self recordingDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self logName], @"wav"]];
}

- (BOOL)recreateFileWithError:(NSError **)error {
    NSURL *url = [self recordingFileURL];
    if (!url) {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteInvalidFileNameError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"ERROR_RECORDER_NO_OUTPUT_DIRECTORY", nil)}];
        }
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    
    if ([fileManager fileExistsAtPath:[url path]]) {
        if (![fileManager removeItemAtPath:[url path] error:error]) {
            return NO;
        }
    }
    
    [fileManager createFileAtPath:[url path] contents:nil attributes:nil];
    [fileManager setAttributes:@{NSFileProtectionKey: ORKFileProtectionFromMode(ORKFileProtectionCompleteUnlessOpen)} ofItemAtPath:[url path] error:error];
    return YES;
}

- (void)start {
    if (self.outputDirectory == nil) {
        @throw [NSException exceptionWithName:NSDestinationInvalidException reason:@"StreamingAudioRecorder requires an output directory" userInfo:nil];
    }
    if (!_audioEngine)
    {
        NSError *error = nil;
        
        if (![self recreateFileWithError:&error]) {
            [self finishRecordingWithError:error];
            return;
        }
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        _savedSessionCategory = audioSession.category;
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
            [self finishRecordingWithError:error];
            return;
        }
        [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
        if (error != nil) {
            [self finishRecordingWithError:error];
            return;
        }
        [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (error != nil) {
            [self finishRecordingWithError:error];
            return;
        }
        
        ORK_Log_Debug(@"Create audioEngine recorder %p", self);
        
        _audioEngine = [[AVAudioEngine alloc] init];
        AVAudioInputNode *inputnode = _audioEngine.inputNode;
        AVAudioFormat *mainMixerFormat = [[_audioEngine mainMixerNode] outputFormatForBus:0];
        
        NSURL *audiourl = [self recordingFileURL];
        
        // Update the file type to be written to the file
        NSMutableDictionary *modifiedSettings = [NSMutableDictionary dictionaryWithDictionary:[mainMixerFormat settings]];
        if (@available(iOS 11.0, *)) {
            modifiedSettings[AVAudioFileTypeKey] = [NSNumber numberWithInt:kAudioFileWAVEType];
        } else {
            // Fallback on earlier versions
            ORK_Log_Warning(@"ORKStreamingAudioRecorder can only be used with iOS 11.0 or above.");
        }
        
        AVAudioFile *mixerOutputFile = [[AVAudioFile alloc] initForWriting:audiourl settings:modifiedSettings error:&error];
        if (error!=nil) {
            [self finishRecordingWithError:error];
            return;
        }
        
        [inputnode installTapOnBus:0 bufferSize:1024 format:mainMixerFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            id<ORKStreamingAudioResultDelegate> delegate = (id<ORKStreamingAudioResultDelegate>)self.delegate;
            NSError *recordingError;
            [mixerOutputFile writeFromBuffer:buffer error:&recordingError];
            if (recordingError!=nil) {
                [self finishRecordingWithError:recordingError];
                return;
            }
            
            if (delegate && [delegate respondsToSelector:@selector(audioAvailable:)]) {
                [delegate audioAvailable:buffer];
            }
        }];
        
        [_audioEngine prepare];
        [_audioEngine startAndReturnError:&error];
        if (error != nil) {
            [self finishRecordingWithError:error];
            return;
        }
    }
    
    [super start];
    
}

- (void)stop {
    if (!_audioEngine) {
        // Error has already been returned.
        return;
    }
    [self doStopRecording];
    
    NSURL *fileUrl = [self recordingFileURL];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[self recordingFileURL] path]]) {
        fileUrl = nil;
    }
    [self reportFileResultWithFile:fileUrl error:nil];
    
    [super stop];
}

- (BOOL)isRecording {
    return [_audioEngine isRunning];
}

- (NSString *)recorderType {
    return @"streamingAudio";
}

- (void)doStopRecording {
    if (self.isRecording) {
        if ([_audioEngine isRunning]) {
            [_audioEngine stop];
            [[_audioEngine inputNode] removeTapOnBus:0];
        }
        _audioEngine = nil;
#if !TARGET_IPHONE_SIMULATOR
        [self applyFileProtection:ORKFileProtectionComplete toFileAtURL:[self recordingFileURL]];
#endif
        [self restoreSavedAudioSessionCategory];
    }
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];
    
    [super finishRecordingWithError:error];
}

- (void)reset {
    if ([_audioEngine isRunning]) {
        [_audioEngine stop];
        [[_audioEngine inputNode] removeTapOnBus:0];
    }
    _audioEngine = nil;
    [super reset];
}

@end


@implementation ORKStreamingAudioRecorderConfiguration

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"


- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    
    return self;
}
#pragma clang diagnostic pop

- (ORKRecorder *)recorderForStep:(ORKStep *)step
                 outputDirectory:(NSURL *)outputDirectory {
    ORKStreamingAudioRecorder *obj = [[ORKStreamingAudioRecorder alloc] initWithIdentifier:self.identifier
                                                                                      step:step
                                                                           outputDirectory:outputDirectory];
    return obj;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    return [super isEqual:object];
}

- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionAudioRecording;
}

@end
