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


#import "ORKDeviceMotionRecorder.h"
#import "ORKHelpers.h"
#import "ORKRecorder_Internal.h"
#import "ORKRecorder_Private.h"
#import "ORKDataLogger.h"
#import <CoreMotion/CoreMotion.h>
#import "CMDeviceMotion+ORKJSONDictionary.h"


@interface ORKDeviceMotionRecorder () {
    ORKDataLogger *_logger;
}

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic) NSTimeInterval uptime;

@end


@implementation ORKDeviceMotionRecorder

- (instancetype)initWithIdentifier:(NSString *)identifier
                         frequency:(double)frequency
                              step:(ORKStep *)step
                   outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier
                                step:step
                     outputDirectory:outputDirectory];
    if (self) {
        self.frequency = frequency;
        self.continuesInBackground = YES;
    }
    return self;
}

- (void)dealloc {
    [_logger finishCurrentLog];
}

- (void)setFrequency:(double)frequency {
    if (frequency <= 0) {
        _frequency = 1;
    } else {
        _frequency = frequency;
    }
}

- (CMMotionManager *)createMotionManager {
    return [[CMMotionManager alloc] init];
}

- (void)start {
    [super start];
    
    if (!_logger) {
        NSError *err = nil;
        _logger = [self makeJSONDataLoggerWithError:&err];
        if (!_logger) {
            [self finishRecordingWithError:err];
            return;
        }
    }
    
    self.motionManager = [self createMotionManager];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / _frequency;
    
    self.uptime = [NSProcessInfo processInfo].systemUptime;
    
    [self.motionManager stopDeviceMotionUpdates];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
         BOOL success = NO;
         if (data) {
             success = [_logger append:[data ork_JSONDictionary] error:&error];
             id delegate = self.delegate;
             if ([delegate respondsToSelector:@selector(deviceMotionRecorderDidUpdateWithMotion:)]) {
                 [delegate deviceMotionRecorderDidUpdateWithMotion:data];
             }
         }
         if (!success) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self finishRecordingWithError:error];
             });
         }
     }];
}

- (NSString *)recorderType {
    return @"deviceMotion";
}

- (void)stop {
    [self doStopRecording];
    [_logger finishCurrentLog];
    
    NSError *error = nil;
    __block NSURL *fileUrl = nil;
    [_logger enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        fileUrl = logFileUrl;
    } error:&error];
    
    [self reportFileResultWithFile:fileUrl error:error];
    
    [super stop];
}

- (void)doStopRecording {
    if (self.isRecording) {
        [self.motionManager stopDeviceMotionUpdates];
        self.motionManager = nil;
    }
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];
    [super finishRecordingWithError:error];
}

- (BOOL)isRecording {
    return self.motionManager.deviceMotionActive;
}

- (NSString *)mimeType {
    return @"application/json";
}

- (void)reset {
    [super reset];
    
    _logger = nil;
}

@end


@implementation ORKDeviceMotionRecorderConfiguration

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithIdentifier:(NSString *)identifier {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Use subclass designated initializer" userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier frequency:(double)freq {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _frequency = freq;
    }
    return self;
}
#pragma clang diagnostic pop

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    return [[ORKDeviceMotionRecorder alloc] initWithIdentifier:self.identifier
                                                     frequency:self.frequency
                                                          step:step
                                               outputDirectory:outputDirectory];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, frequency);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.frequency == castObject.frequency));
}

- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionCoreMotionAccelerometer;
}

@end
