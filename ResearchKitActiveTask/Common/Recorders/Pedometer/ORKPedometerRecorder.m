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


#import "ORKPedometerRecorder.h"

#import "ORKDataLogger.h"

#import "ORKRecorder_Internal.h"

#import "ORKHelpers_Internal.h"
#import "CMPedometerData+ORKJSONDictionary.h"

#import "ResearchKit/ResearchKit-Swift.h"

@interface ORKPedometerRecorder () {
    ORKDataLogger *_logger;
    BOOL _isRecording;
}

@property (nonatomic, strong) CMPedometer *pedometer;

@end


@implementation ORKPedometerRecorder

- (instancetype)initWithIdentifier:(NSString *)identifier
                              step:(ORKStep *)step {
    return [self initWithIdentifier:identifier step:step outputDirectory:nil rollingFileSizeThreshold:0];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                              step:(ORKStep *)step
                   outputDirectory:(nullable NSURL *)outputDirectory
          rollingFileSizeThreshold:(size_t)rollingFileSizeThreshold {
    self = [super initWithIdentifier:identifier
                                step:step
                     outputDirectory:outputDirectory
            rollingFileSizeThreshold:rollingFileSizeThreshold];
    if (self) {
        self.continuesInBackground = YES;
    }
    return self;
}

- (void)dealloc {
    [_logger finishCurrentLog];
}

- (void)updateStatisticsWithData:(CMPedometerData *)pedometerData {
    _lastUpdateDate = pedometerData.endDate;
    _totalNumberOfSteps = pedometerData.numberOfSteps.integerValue;
    if (pedometerData.distance != nil) {
        _totalDistance = pedometerData.distance.doubleValue;
    } else {
        _totalDistance = -1;
    }
    
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pedometerRecorderDidUpdate:)]) {
        [delegate pedometerRecorderDidUpdate:self];
    }
}

- (CMPedometer *)createPedometer {
    return [[CMPedometer alloc] init];
}

- (void)start {
    [super start];
    
    _lastUpdateDate = nil;
    _totalNumberOfSteps = 0;
    _totalDistance = -1;
    
    if (!_logger) {
        NSError *error = nil;
        _logger = [self makeJSONDataLoggerWithError:&error];
        if (!_logger) {
            [self finishRecordingWithError:error];
            return;
        }
    }
    
    self.pedometer = [self createPedometer];
    
    if (![[self.pedometer class] isStepCountingAvailable]) {
        [self finishRecordingWithError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                           code:NSFeatureUnsupportedError
                                                       userInfo:@{@"recorder": self}]];
        return;
    }

    _isRecording = YES;
    ORKWeakTypeOf(self) weakSelf = self;
    [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        
        BOOL success = NO;
        if (pedometerData) {
            success = [self->_logger append:[pedometerData ork_JSONDictionary] error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                [strongSelf updateStatisticsWithData:pedometerData];
            });
        }
        if (!success || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                [strongSelf finishRecordingWithError:error];
            });
        }
    }];
}

- (NSString *)recorderType {
    return @"pedometer";
}

- (void)stop {
    [self doStopRecording];
    [_logger finishCurrentLog];
    
    NSError *error = nil;
    __block NSMutableArray<NSURL *> *fileUrls = [[NSMutableArray alloc] init];
    [_logger enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        [fileUrls addObject:logFileUrl];
    }
                     error:&error];
    
    [self reportFileResultsWithFiles:fileUrls error:error];
    
    [super stop];
}

- (void)doStopRecording {
    if (_isRecording) {
        [self.pedometer stopPedometerUpdates];
        _isRecording = NO;
        self.pedometer = nil;
    }
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];
    [super finishRecordingWithError:error];
}

- (BOOL)isRecording {
    return _isRecording;
}

- (NSString *)mimeType {
    return @"application/json";
}

- (void)reset {
    [super reset];
    
    _logger = nil;
}

@end


@implementation ORKPedometerRecorderConfiguration

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier outputDirectory:nil rollingFileSizeThreshold:0];
}

- (instancetype)initWithIdentifier:(NSString *)identifier outputDirectory:(nullable NSURL *)outputDirectory {
    return [self initWithIdentifier:identifier outputDirectory:outputDirectory rollingFileSizeThreshold:0];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                   outputDirectory:(nullable NSURL *)outputDirectory
          rollingFileSizeThreshold:(size_t)rollingFileSizeThreshold {
    return [super initWithIdentifier:identifier
                     outputDirectory:outputDirectory
            rollingFileSizeThreshold:rollingFileSizeThreshold];
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step {
    return [[ORKPedometerRecorder alloc] initWithIdentifier:self.identifier
                                                       step:step
                                            outputDirectory:self.outputDirectory
                                   rollingFileSizeThreshold:self.rollingFileSizeThreshold];
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
    
    return (isParentSame);
}

- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionCoreMotionActivity;
}

@end
