/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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

#import <Availability.h>

#if defined(__IPHONE_12_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0

#import "ORKHealthClinicalTypeRecorder.h"
#import "ORKHelpers_Internal.h"
#import "ORKDataLogger.h"
#import "ORKRecorder_Private.h"
#import "ORKRecorder_Internal.h"
#import "HKSample+ORKJSONDictionary.h"


@interface ORKHealthClinicalTypeRecorder () {
    ORKDataLogger *_logger;
    BOOL _isRecording;
    HKHealthStore *_healthStore;
    ORKStep *_step;
}

@end

@implementation ORKHealthClinicalTypeRecorder

- (instancetype)initWithIdentifier:(NSString *)identifier
                healthClinicalType:(HKClinicalType *)healthClinicalType
            healthFHIRResourceType:(nullable HKFHIRResourceType)healthFHIRResourceType
                              step:(ORKStep *)step
                   outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier
                                step:step
                     outputDirectory:outputDirectory];
    if (self) {
        NSParameterAssert(healthClinicalType != nil);
        _healthClinicalType = healthClinicalType;
        _healthFHIRResourceType = healthFHIRResourceType;
        self.continuesInBackground = YES;
        _step = step;
    }
    return self;
}

- (void)dealloc {
    [_logger finishCurrentLog];
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
    
    if (![HKHealthStore isHealthDataAvailable]) {
        [self finishRecordingWithError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                           code:NSFeatureUnsupportedError
                                                       userInfo:@{@"recorder" : self}]];
        return;
    }
    
    if (!_healthStore) {
        _healthStore = [HKHealthStore new];
    }
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:_healthClinicalType
                                                           predicate:_healthFHIRResourceType ? [HKQuery predicateForClinicalRecordsWithFHIRResourceType:_healthFHIRResourceType] : nil limit:HKObjectQueryNoLimit
                                                     sortDescriptors:nil
                                                      resultsHandler:^(HKSampleQuery * _Nonnull sampleQuery, NSArray<__kindof HKSample *> * _Nullable sampleResults, NSError * _Nullable error) {
                                                          NSUInteger resultCount = sampleResults.count;
                                                          if (resultCount == 0) {
                                                              return;
                                                          }
                                                          
                                                          [sampleResults enumerateObjectsUsingBlock:^(HKClinicalRecord *clinicalRecord, NSUInteger idx, BOOL *stop) {
                                                              
                                                              NSError *logError = nil;
                                                              [_logger append:clinicalRecord.FHIRResource.data error:&logError];
                                                              if (logError) {
                                                                  ORK_Log_Warning(@"Failed to add health records object to the logger with error: %@", logError);
                                                                  return;
                                                              }
                                                          }];
                                                      }];
    
    _isRecording = YES;
    [_healthStore executeQuery:query];
}

- (NSString *)recorderType {
    return _healthClinicalType.identifier;
}

- (void)stop {
    if (!_isRecording) {
        return;
    }
    
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
    if (_isRecording) {
        _isRecording = NO;
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


@implementation ORKHealthClinicalTypeRecorderConfiguration

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithIdentifier:(NSString *)identifier {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Use subclass designated initializer" userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                healthClinicalType:(HKClinicalType *)healthClinicalType
            healthFHIRResourceType:(nullable HKFHIRResourceType)healthFHIRResourceType {
    self = [super initWithIdentifier:identifier];
    if (self) {
        NSParameterAssert(healthClinicalType != nil);
        _healthClinicalType = healthClinicalType;
        _healthFHIRResourceType = healthFHIRResourceType;
    }
    return self;
}
#pragma clang diagnostic pop

- (ORKRecorder *)recorderForStep:(ORKStep *)step
                 outputDirectory:(NSURL *)outputDirectory {
    return [[ORKHealthClinicalTypeRecorder alloc] initWithIdentifier:self.identifier
                                                  healthClinicalType:_healthClinicalType
                                              healthFHIRResourceType:_healthFHIRResourceType
                                                                step:step
                                                     outputDirectory:outputDirectory];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, healthClinicalType, HKClinicalType);
        ORK_DECODE_OBJ(aDecoder, healthFHIRResourceType);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, healthClinicalType);
    ORK_ENCODE_OBJ(aCoder, healthFHIRResourceType);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.healthClinicalType, castObject.healthClinicalType)&&
            ORKEqualObjects(self.healthFHIRResourceType, castObject.healthFHIRResourceType));
}

- (NSSet *)requestedHealthKitTypesForReading {
    return [NSSet setWithObject:_healthClinicalType];
}

@end
#endif
