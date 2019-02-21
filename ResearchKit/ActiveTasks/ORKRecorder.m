/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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


#import "ORKRecorder.h"
#import "ORKRecorder_Internal.h"

#import "ORKDataLogger.h"
#import "ORKFileResult.h"

#import "ORKHelpers_Internal.h"


@implementation ORKRecorderConfiguration

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        _identifier = [identifier copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    return 0;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    return nil;
}

- (NSSet<HKObjectType *> *)requestedHealthKitTypesForReading {
    return nil;
}
- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionNone;
}

@end


@implementation ORKRecorder {
    UIBackgroundTaskIdentifier _backgroundTask;
    NSUUID *_recorderUUID;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Use designated initializer" userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier step:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    self = [super init];
    if (self) {
        if (nil == identifier) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"identifier cannot be nil." userInfo:nil];
        }
        
        _identifier = [identifier copy];
        _outputDirectory = outputDirectory;
        self.step = step;
        _backgroundTask = NSNotFound;
        _recorderUUID = [NSUUID UUID];
    }
    return self;
}

- (void)viewController:(UIViewController *)viewController willStartStepWithView:(UIView *)view {
}

- (void)start {
    if (self.continuesInBackground) {
        UIApplication *app = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier oldTask = _backgroundTask;
        _backgroundTask = [app beginBackgroundTaskWithName:[NSString stringWithFormat:@"%@.%p",NSStringFromClass([self class]),self]
                                         expirationHandler:^{
            [self stop];
        }];
        if (oldTask != NSNotFound) {
            [app endBackgroundTask:oldTask];
        }
    }
    self.startDate = [NSDate date];
}

- (void)stop {
    [self finishRecordingWithError:nil];
    [self reset];
}

- (void)finishRecordingWithError:(NSError *)error {
    // NOTE. This method may be called multiple times (once when someone tries
    // to finish, and another time with -stop is actually called.
    
    if (error) {
        // ALWAYS report errors to the delegate, even if we think we're finished already
        id<ORKRecorderDelegate> localDelegate = self.delegate;
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didFailWithError:)]) {
            [localDelegate recorder:self didFailWithError:error];
        }
        [self reset];
    }
    
    if (_backgroundTask != NSNotFound) {
        // End the background task asynchronously, so whatever we're doing cleaning up the recorder has a chance to complete.
        UIBackgroundTaskIdentifier identifier = _backgroundTask;
        _backgroundTask = NSNotFound;
        
        // Hold the background task for a little extra to give time for the next step to kick in,
        // if it is an automatic transition.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
        });
    }
}

- (NSURL *)recordingDirectoryURL {
    if (!_outputDirectory) {
        return nil;
    }
    return [NSURL fileURLWithPath:[_outputDirectory.path stringByAppendingPathComponent:[NSString stringWithFormat:@"recorder-%@", _recorderUUID.UUIDString]]];
}

- (NSString *)recorderType {
    return @"recorder";
}

- (NSString *)logName {
    return [NSString stringWithFormat:@"%@_%@", [self recorderType], _recorderUUID.UUIDString];
}

- (ORKDataLogger *)makeJSONDataLoggerWithError:(NSError **)error {
    NSURL *workingDir = [self recordingDirectoryURL];
    if (!workingDir) {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteInvalidFileNameError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"ERROR_RECORDER_NO_OUTPUT_DIRECTORY", nil)}];
        }
        return nil;
    }
    if (![[NSFileManager defaultManager] createDirectoryAtURL:workingDir withIntermediateDirectories:YES attributes:nil error:error]) {
        return nil;
    }
    
    NSString *identifier = [self logName];
    NSString *logName = [identifier stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    
    // Class B data protection for temporary file during active task logging.
    ORKDataLogger *logger = [[ORKDataLogger alloc] initWithDirectory:workingDir logName:logName formatter:[ORKJSONLogFormatter new] delegate:nil];
    
    logger.fileProtectionMode = ORKFileProtectionCompleteUnlessOpen;
    return logger;
}

- (void)reset {
    _recorderUUID = [NSUUID UUID];
}

- (NSString *)mimeType {
    return nil;
}

- (NSDictionary *)userInfo {
    return nil;
}

- (void)applyFileProtection:(ORKFileProtectionMode)fileProtection toFileAtURL:(NSURL *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (! [fileManager setAttributes:@{NSFileProtectionKey: ORKFileProtectionFromMode(fileProtection)} ofItemAtPath:[url path] error:&error]) {
        ORK_Log_Warning(@"Error setting %@ on %@: %@", ORKFileProtectionFromMode(fileProtection), url, error);
    }
}

- (void)reportFileResultWithFile:(NSURL *)fileUrl error:(NSError *)error {
    
    id<ORKRecorderDelegate> localDelegate = self.delegate;
    if (fileUrl && !error) {
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            ORKFileResult *result = [[ORKFileResult alloc] initWithIdentifier:self.identifier];
            result.contentType = [self mimeType];
            result.fileURL = fileUrl;
            result.userInfo = self.userInfo;
            result.startDate = self.startDate;
            
            [localDelegate recorder:self didCompleteWithResult:result];
            
            // Point future recording at a new directory
            [self reset];
        }
    } else {
        if (!error) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileReadNoSuchFileError
                                    userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"ERROR_RECORDER_NO_DATA", nil)}];
        }
        [self finishRecordingWithError:error];
    }
}

@end
