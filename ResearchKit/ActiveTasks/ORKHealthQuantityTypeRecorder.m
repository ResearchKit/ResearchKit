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


#import "ORKHealthQuantityTypeRecorder.h"
#import "ORKHelpers.h"
#import "ORKDataLogger.h"
#import "ORKRecorder_Private.h"
#import "ORKRecorder_Internal.h"
#import "HKSample+ORKJSONDictionary.h"


@interface ORKHealthQuantityTypeRecorder () {
    ORKDataLogger *_logger;
    BOOL _isRecording;
    HKHealthStore *_healthStore;
    NSPredicate *_samplePredicate;
    HKObserverQuery *_observerQuery;
    NSInteger _anchor;
    HKQuantitySample *_lastSample;
}

@end


@implementation ORKHealthQuantityTypeRecorder

- (instancetype)initWithIdentifier:(NSString *)identifier
                healthQuantityType:(HKQuantityType *)quantityType
                              unit:(HKUnit *)unit
                              step:(ORKStep *)step
                   outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier
                                step:step
                     outputDirectory:outputDirectory];
    if (self) {
        NSParameterAssert(quantityType != nil);
        NSParameterAssert(unit != nil);
        // Quantity type and unit are immutable, so should be equivalent to -copy
        _quantityType = quantityType;
        _unit = unit;
        self.continuesInBackground = YES;
        _anchor = HKAnchoredObjectQueryNoAnchor;
    }
    return self;
}

- (void)dealloc {
    [_logger finishCurrentLog];
}

- (void)updateMostRecentSample:(HKQuantitySample *)sample {
    [self willChangeValueForKey:@"lastSample"];
    _lastSample = sample;
    [self didChangeValueForKey:@"lastSample"];
    
    id<ORKHealthQuantityTypeRecorderDelegate> delegate =  (id<ORKHealthQuantityTypeRecorderDelegate>)self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(healthQuantityTypeRecorderDidUpdate:)]) {
        [delegate healthQuantityTypeRecorderDidUpdate:self];
    }
}

static const NSInteger _HealthAnchoredQueryLimit = 100;

- (void)query_logResults:(NSArray *)results withAnchor:(NSUInteger)newAnchor {
    
    NSUInteger resultCount = results.count;
    if (resultCount == 0) {
        return;
    }
    
    // Do conversion to dictionary on whatever queue we happen to be on.
    NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:resultCount];
    [results enumerateObjectsUsingBlock:^(HKQuantitySample *sample, NSUInteger idx, BOOL *stop) {
        [dictionaries addObject:[sample ork_JSONDictionaryWithOptions:ORKSampleIncludeSource|ORKSampleIncludeMetadata unit:_unit]];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateMostRecentSample:results.lastObject];
        
        NSError *error = nil;
        if (![_logger appendObjects:dictionaries error:&error]) {
            // Logger writes are unrecoverable
            [self finishRecordingWithError:error];
            return;
        }
        
        _anchor = newAnchor;
        
        if (resultCount == _HealthAnchoredQueryLimit) {
            // Do another fetch immediately rather than wait for an observation
            [self doFetchNewData];
        }
    });
}

- (void)doFetchNewData {
    if (!_healthStore || !_isRecording) {
        return;
    }
    NSAssert(_samplePredicate != nil, @"Sample predicate should be non-nil if recording");
    
    __weak typeof(self) weakSelf = self;
    HKAnchoredObjectQuery *anchoredQuery = [[HKAnchoredObjectQuery alloc]
                                            initWithType:_quantityType
                                            predicate:_samplePredicate
                                            anchor:_anchor
                                            limit:_HealthAnchoredQueryLimit
                                            completionHandler:^(HKAnchoredObjectQuery *query, NSArray *results, NSUInteger newAnchor, NSError *error)
                                            {
                                                if (error) {
                                                    // An error in the query's not the end of the world: we'll probably get another chance. Just log it.
                                                    ORK_Log_Warning(@"Anchored query error: %@", error);
                                                    return;
                                                }
                                                
                                                __typeof(self) strongSelf = weakSelf;
                                                [strongSelf query_logResults:results withAnchor:newAnchor];
                                                
                                            }];
    [_healthStore executeQuery:anchoredQuery];
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
        // Get a new obsever query
        _healthStore = [HKHealthStore new];
    } else {
        // Reset
        if (_observerQuery) {
            [_healthStore stopQuery:_observerQuery];
            _observerQuery = nil;
        }
    }
    
    _lastSample = nil;
    _samplePredicate = [HKQuery predicateForSamplesWithStartDate:[NSDate date] endDate:nil options:HKQueryOptionStrictStartDate];
    
    NSAssert(!_observerQuery, @"observer query should not exist if not recording");
    
    __weak __typeof(self) weakSelf = self;
    _observerQuery = [[HKObserverQuery alloc]
                      initWithSampleType:_quantityType
                      predicate:_samplePredicate
                      updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
                          __typeof(self) strongSelf = weakSelf;
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (error) {
                                  [strongSelf finishRecordingWithError:error];
                              } else {
                                  [strongSelf doFetchNewData];
                              }
                          });
                          
                          // Immediately signal receipt. We've fired off to either finish or do a new fetch.
                          completionHandler();
                          
                      }];
    
    _isRecording = YES;
    [_healthStore executeQuery:_observerQuery];
}

- (NSString *)recorderType {
    return _quantityType.identifier;
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
        NSAssert(_observerQuery != nil, @"Observer query should be non-nil when recording");
        [_healthStore stopQuery:_observerQuery];
        _observerQuery = nil;
        
        _samplePredicate = nil;
        _isRecording = NO;
        
        [self updateMostRecentSample:nil];
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


@implementation ORKHealthQuantityTypeRecorderConfiguration

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithIdentifier:(NSString *)identifier {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Use subclass designated initializer" userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier healthQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit {
    self = [super initWithIdentifier:identifier];
    if (self) {
        NSParameterAssert(quantityType != nil);
        NSParameterAssert(unit != nil);
        // Quantity type and unit are immutable, so should be equivalent to -copy
        _quantityType = quantityType;
        _unit = unit;
    }
    return self;
}
#pragma clang diagnostic pop

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    return [[ORKHealthQuantityTypeRecorder alloc] initWithIdentifier:self.identifier
                                                  healthQuantityType:_quantityType
                                                                unit:_unit
                                                                step:step
                                                     outputDirectory:outputDirectory];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, quantityType, HKQuantityType);
        ORK_DECODE_OBJ_CLASS(aDecoder, unit, HKUnit);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, quantityType);
    ORK_ENCODE_OBJ(aCoder, unit);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.quantityType, castObject.quantityType)&&
            ORKEqualObjects(self.unit, castObject.unit));
}

- (NSSet *)requestedHealthKitTypesForReading {
    return [NSSet setWithObject:_quantityType];
}

@end
