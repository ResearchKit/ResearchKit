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


#import "ORKLocationRecorder.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+ORKJSONDictionary.h"
#import "ORKDataLogger.h"
#import "ORKRecorder_Internal.h"
#import "ORKRecorder_Private.h"


@interface ORKLocationRecorder () <CLLocationManagerDelegate> {
    ORKDataLogger *_logger;
    NSError *_recordingError;
    BOOL _started;
}

@property (nonatomic, strong, nullable) CLLocationManager *locationManager;

@property (nonatomic) NSTimeInterval uptime;

@end


@implementation ORKLocationRecorder

- (instancetype)initWithIdentifier:(NSString *)identifier step:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier step:step outputDirectory:outputDirectory];
    if (self) {
        self.continuesInBackground = YES;
    }
    return self;
}

- (void)dealloc {
    [_logger finishCurrentLog];
}

- (NSString *)recorderType {
    return @"location";
}

- (CLLocationManager *)createLocationManager {
    return [[CLLocationManager alloc] init];
}

- (void)start {
    [super start];
    
    if (!_logger) {
        NSError *error = nil;
        _logger = [self makeJSONDataLoggerWithError:&error];
        if (!_logger) {
            [self finishRecordingWithError:error];
            return;
        }
    }
    
    self.locationManager = [self createLocationManager];
    if ([CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.delegate = self;
    
    if (!self.locationManager) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSFeatureUnsupportedError
                                         userInfo:@{@"recorder": self}];
        [self finishRecordingWithError:error];
        return;
    }
    
    self.uptime = [NSProcessInfo processInfo].systemUptime;
    [self.locationManager startUpdatingLocation];
}

- (void)doStopRecording {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)stop {
    [self doStopRecording];
    [_logger finishCurrentLog];
    
    NSError *error = _recordingError;
    _recordingError = nil;
    __block NSURL *fileUrl = nil;
    [_logger enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        fileUrl = logFileUrl;
    } error:&error];
    
    [self reportFileResultWithFile:fileUrl error:error];
    
    [super stop];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    BOOL success = YES;
    NSParameterAssert(locations.count >= 0);
    NSError *error = nil;
    if (locations) {
        NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:locations.count];
        [locations enumerateObjectsUsingBlock:^(CLLocation *obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *d = [obj ork_JSONDictionary];
            [dictionaries addObject:d];
        }];
        
        success = [_logger appendObjects:dictionaries error:&error];
    }
    if (!success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _recordingError = error;
            [self stop];
        });
    }
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];
    [super finishRecordingWithError:nil];
}

- (BOOL)isRecording {
    return [CLLocationManager locationServicesEnabled] && (self.locationManager != nil) && ([CLLocationManager authorizationStatus] > kCLAuthorizationStatusDenied);
}

- (void)reset {
    [super reset];
    
    _logger = nil;
}

- (NSString *)mimeType {
    return @"application/json";
}

@end


@implementation ORKLocationRecorderConfiguration

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [super initWithIdentifier:identifier];
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    return [[ORKLocationRecorder alloc] initWithIdentifier:self.identifier step:step outputDirectory:outputDirectory];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    return isParentSame;
}

- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionCoreLocation;
}

@end
