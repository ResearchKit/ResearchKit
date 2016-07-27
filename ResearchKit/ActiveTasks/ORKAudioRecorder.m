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


#import "ORKAudioRecorder.h"
#import "ORKHelpers.h"
#import "ORKRecorder_Internal.h"
#import "ORKRecorder_Private.h"


@interface ORKAudioRecorder ()

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (nonatomic, copy) NSDictionary *recorderSettings;

@property (nonatomic, copy) NSString *savedSessionCategory;

@end


@implementation ORKAudioRecorder

- (void)dealloc {
    ORK_Log_Debug(@"Remove audiorecorder %p", self);
    [_audioRecorder stop];
    _audioRecorder = nil;
}

+ (NSDictionary *)defaultRecorderSettings {
    return @{AVFormatIDKey              : @(kAudioFormatMPEG4AAC),
             AVEncoderAudioQualityKey   : @(AVAudioQualityMin),
             AVNumberOfChannelsKey      : @(2),
             AVSampleRateKey            : @(44100.0)};
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                  recorderSettings:(NSDictionary *)recorderSettings
                              step:(ORKStep *)step
                   outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier step:step outputDirectory:outputDirectory];
    if (self) {
        
        self.continuesInBackground = YES;
        if (!recorderSettings) {
            recorderSettings = [[self class] defaultRecorderSettings];
        }
        if (![recorderSettings isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"recorderSettings should be a dictionary" userInfo:recorderSettings];
        }
        self.recorderSettings = recorderSettings;
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

- (void)start {
    if (self.outputDirectory == nil) {
        @throw [NSException exceptionWithName:NSDestinationInvalidException reason:@"audioRecorder requires an output directory" userInfo:nil];
    }
    // Only create the file when we should actually start recording.
    if (!_audioRecorder) {
        
        NSError *error = nil;
        NSURL *soundFileURL = [self recordingFileURL];
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
        
        ORK_Log_Debug(@"Create audioRecorder %p", self);
        _audioRecorder = [[AVAudioRecorder alloc]
                          initWithURL:soundFileURL
                          settings:self.recorderSettings
                          error:&error];
        if (!_audioRecorder) {
            [self finishRecordingWithError:error];
            return;
        }
        
#if !TARGET_IPHONE_SIMULATOR
        if (!_audioRecorder.recording) {
            [_audioRecorder prepareToRecord];
        }
#endif
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if (!_audioRecorder.recording) {
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
    }
#endif
    [super start];
    
}

- (void)stop {
    if (!_audioRecorder) {
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
    return _audioRecorder.recording;
}

- (NSString *)mimeType {
    NSDictionary *recorderSettings = [self recorderSettings];
    unsigned int recorderFormat = ((NSNumber *)recorderSettings[AVFormatIDKey]).unsignedIntValue;
    
    NSString *contentType = @"audio";
    switch (recorderFormat) {
        case kAudioFormatLinearPCM: {
            int numBits = ((NSNumber *)recorderSettings[AVLinearPCMBitDepthKey]).intValue ? : 16;
            contentType = [NSString stringWithFormat:@"audio/L%d", numBits];
            break;
        }
        case kAudioFormatAC3: {
            contentType = @"audio/ac3";
            break;
        }
        case kAudioFormatMPEG4AAC:
        case kAudioFormatMPEG4CELP:
        case kAudioFormatMPEG4HVXC:
        case kAudioFormatMPEG4TwinVQ:
        case kAudioFormatAppleLossless: {
            contentType = @"audio/m4a";
            break;
        }
        case kAudioFormatULaw: {
            contentType = @"audio/basic";
            break;
        }
    }
    return contentType;
}

- (NSString *)recorderType {
    return @"audio";
}

- (void)doStopRecording {
    if (self.isRecording) {
#if !TARGET_IPHONE_SIMULATOR
        [_audioRecorder stop];
        
        [self applyFileProtection:ORKFileProtectionComplete toFileAtURL:[self recordingFileURL]];
#endif
        [self restoreSavedAudioSessionCategory];
    }
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];

    [super finishRecordingWithError:error];
}

- (NSString *)extension {
    NSDictionary *recorderSettings = [self recorderSettings];
    unsigned int recorderFormat = ((NSNumber *)recorderSettings[AVFormatIDKey]).unsignedIntValue;
    
    NSString *extension = @"au";
    switch (recorderFormat) {
        case kAudioFormatLinearPCM:
        {
            extension = @"pcm";
            break;
        }
        case kAudioFormatAC3: {
            extension = @"ac3";
            break;
        }
        case kAudioFormatMPEG4AAC:
        case kAudioFormatMPEG4CELP:
        case kAudioFormatMPEG4HVXC:
        case kAudioFormatMPEG4TwinVQ:
        case kAudioFormatAppleLossless: {
            extension = @"m4a";
            break;
        }
    }
    return extension;
}

- (NSURL *)recordingFileURL {
    return [[self recordingDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self logName], [self extension]]];
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

- (void)reset {
    [_audioRecorder stop];
    _audioRecorder = nil;
    [super reset];
}

@end


@implementation ORKAudioRecorderConfiguration

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithIdentifier:(NSString *)identifier {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Use subclass designated initializer" userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                  recorderSettings:(NSDictionary *)recorderSettings {
    self = [super initWithIdentifier:identifier];
    if (self) {
        if (recorderSettings && ![recorderSettings isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"recorderSettings should be a dictionary" userInfo:recorderSettings];
        }
        _recorderSettings = recorderSettings;
    }
    return self;
}
#pragma clang diagnostic pop

- (ORKRecorder *)recorderForStep:(ORKStep *)step
                 outputDirectory:(NSURL *)outputDirectory {
    return [[ORKAudioRecorder alloc] initWithIdentifier:self.identifier
                                       recorderSettings:self.recorderSettings
                                                   step:step
                                        outputDirectory:outputDirectory];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, recorderSettings, NSDictionary);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, recorderSettings);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.recorderSettings, castObject.recorderSettings));
}

- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionAudioRecording;
}

@end
