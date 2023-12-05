/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKAudioStreamer.h"
#import "ORKHelpers_Internal.h"
#import "ORKRecorder_Internal.h"
#import "ORKStep.h"

#pragma mark - ORKAudioStreamerConfiguration

@implementation ORKAudioStreamerConfiguration

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    return self;
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    ORKAudioStreamer *obj = [[ORKAudioStreamer alloc] initWithIdentifier:self.identifier step:step];
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

#pragma mark - ORKAudioStreamer

@implementation ORKAudioStreamer
{
    NSString *_savedSessionCategory;
}

- (instancetype)initWithIdentifier:(NSString *)identifier step:(ORKStep *)step
{
    self = [super initWithIdentifier:identifier step:step outputDirectory:nil];
    if (self)
    {
        self.continuesInBackground = YES;
    }
    return self;
}

- (void)restoreSavedAudioSessionCategory
{
    if (_savedSessionCategory)
    {
        NSError *error;
        if (![[AVAudioSession sharedInstance] setCategory:_savedSessionCategory error:&error])
        {
            ORK_Log_Error("Failed to restore the audio session category: %@", [error localizedDescription]);
        }
        _savedSessionCategory = nil;
    }
}

- (BOOL)isRecording
{
    return [_audioEngine isRunning];
}

- (NSString *)recorderType
{
    return @"audioStreaming";
}

- (void)start
{
    if (!_audioEngine)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        _savedSessionCategory = audioSession.category;
        
        NSError *error = nil;
        BOOL success =
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error] &&
        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeMeasurement error:&error] &&
        [[AVAudioSession sharedInstance] setActive:YES  withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        
        if (!success && error)
        {
            [self finishRecordingWithError:error];
            return;
        }
        
        ORK_Log_Debug("Create audioEngine recorder %p", self);
        
        _audioEngine = [[AVAudioEngine alloc] init];
        AVAudioInputNode *inputnode = _audioEngine.inputNode;
        AVAudioFormat *recordingFormat = [inputnode inputFormatForBus:0];
        
        [inputnode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when)
        {
            id<ORKAudioStreamingDelegate> delegate = (id<ORKAudioStreamingDelegate>)self.delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(audioAvailable:)]) {
                [delegate audioAvailable:buffer];
            }
        }];
        
        [_audioEngine prepare];
        
        [_audioEngine startAndReturnError:&error];
        
        if (error != nil)
        {
            [self finishRecordingWithError:error];
            return;
        }
    }
    
    [super start];
}

- (void)stop
{
    if (!_audioEngine)
    {
        return;
    }
    
    [self doStopRecording];
    
    [super stop];
}

- (void)doStopRecording
{
    if (self.isRecording)
    {
        if ([_audioEngine isRunning])
        {
            [_audioEngine stop];
            [[_audioEngine inputNode] removeTapOnBus:0];
        }
        _audioEngine = nil;
        
        [self restoreSavedAudioSessionCategory];
    }
}

- (void)finishRecordingWithError:(NSError *)error
{
    [self doStopRecording];
    
    [super finishRecordingWithError:error];
}

- (void)reset
{
    if ([_audioEngine isRunning])
    {
        [_audioEngine stop];
        [[_audioEngine inputNode] removeTapOnBus:0];
    }
    _audioEngine = nil;
    [super reset];
}

- (void)dealloc
{
    ORK_Log_Debug("Remove audiorecorder %p", self);
    
    if ([_audioEngine isRunning])
    {
        [_audioEngine stop];
        [[_audioEngine inputNode] removeTapOnBus:0];
    }
    
    _audioEngine = nil;
}

@end
