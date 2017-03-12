/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
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


#import "ORKDataCollectionManager_Internal.h"
#import "ORKCollector_Internal.h"
#import "ORKOperation.h"
#import "ORKHelpers_Internal.h"
#import <HealthKit/HealthKit.h>


static  NSString *const ORKDataCollectionPersistenceFileName = @".dataCollection.ork.data";

@implementation ORKDataCollectionManager {
    dispatch_queue_t _queue;
    NSOperationQueue *_operationQueue;
    NSString * _Nonnull _managedDirectory;
    NSArray<ORKCollector *> *_collectors;
    HKHealthStore *_healthStore;
    CMMotionActivityManager *_activityManager;
    NSMutableArray<HKObserverQueryCompletionHandler> *_completionHandlers;
}

- (instancetype)initWithPersistenceDirectoryURL:(NSURL *)directoryURL {

    self = [super init];
    if (self) {
        if (directoryURL == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"directory cannot be nil" userInfo:nil];
        }
        
        _managedDirectory = directoryURL.path;
        
        BOOL isDir;
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        BOOL directoryExist = [defaultManager fileExistsAtPath:_managedDirectory isDirectory:&isDir];
        
        if ((directoryExist && isDir == NO)) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"URL is not a directory" userInfo:nil];
        }
        
        // Create directory if needed
        if (NO == directoryExist) {
            NSError *error;
            [defaultManager createDirectoryAtPath:_managedDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Failed to create directory at URL." userInfo:@{@"error" : error}];
            }
        }
        
        // Create persistance file if needed
        if (![defaultManager fileExistsAtPath:self.persistFilePath]) {
            _collectors = [NSArray new];
            [self persistCollectors];
        }
        
        NSString *queueId = [@"ResearchKit.DataCollection." stringByAppendingString:_managedDirectory];
        _queue = dispatch_queue_create([queueId cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#pragma mark Data collection

// dispatch_sync, but tries not to deadlock if we're already on the specified queue
static inline void dispatch_sync_if_not_on_queue(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_queue_set_specific(queue, (__bridge const void *)(queue), (void*)1, NULL);
    if (dispatch_get_specific((__bridge const void *)queue)) {
        block();
    } else {
        dispatch_sync(queue, block);
    }
}

- (void)onWorkQueueSync:(BOOL (^)(ORKDataCollectionManager *manager))block {
    dispatch_sync_if_not_on_queue(_queue, ^{
        if (block(self)) {
            [self persistCollectors];
        }
    });
}

- (void)onWorkQueueAsync:(BOOL (^)(ORKDataCollectionManager *manager))block {
    dispatch_async(_queue, ^{
        if (block(self)) {
            [self persistCollectors];
        }
    });
}

- (HKHealthStore *)healthStore {
    if (!_healthStore && [HKHealthStore isHealthDataAvailable]){
        _healthStore = [[HKHealthStore alloc] init];
    }
    return _healthStore;
}

- (CMMotionActivityManager *)activityManager {
    if (!_activityManager && [CMMotionActivityManager isActivityAvailable]) {
        _activityManager = [[CMMotionActivityManager alloc] init];
    }
    return _activityManager;
}

- (NSArray<ORKCollector *> *)collectors {
    if (_collectors == nil) {
        _collectors = [NSKeyedUnarchiver unarchiveObjectWithFile:[self persistFilePath]];
        if (_collectors == nil) {
            @throw [NSException exceptionWithName:NSGenericException reason: [NSString stringWithFormat:@"Failed to read from path %@", [self persistFilePath]] userInfo:nil];
        }
    }
    return _collectors;
}

- (NSString * _Nonnull)persistFilePath {
    return [_managedDirectory stringByAppendingPathComponent:ORKDataCollectionPersistenceFileName];
}

- (void)persistCollectors {
    NSArray *collectors = self.collectors;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:collectors];
    NSError *error;
    [data writeToFile:[self persistFilePath] options:NSDataWritingAtomic|NSDataWritingFileProtectionComplete error:&error];
    
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason: [NSString stringWithFormat:@"Failed to write to path %@", [self persistFilePath]] userInfo:nil];
    }
}

- (void)addCollector:(ORKCollector *)collector {
    NSMutableArray *collectors = [self.collectors mutableCopy];
    [collectors addObject:collector];
    _collectors = [collectors copy];
}

- (ORKHealthCollector *)addHealthCollectorWithSampleType:(HKSampleType*)sampleType unit:(HKUnit *)unit startDate:(NSDate *)startDate error:(NSError**)error {
    
    if (!sampleType) {
        @throw [NSException exceptionWithName:ORKInvalidArgumentException reason:@"sampleType cannot be nil" userInfo:nil];
    }
    if (!unit) {
        @throw [NSException exceptionWithName:ORKInvalidArgumentException reason:@"unit cannot be nil" userInfo:nil];
    }
    
    __block ORKHealthCollector *healthCollector = nil;

    [self onWorkQueueSync:^BOOL(ORKDataCollectionManager *manager){
        
        ORKHealthCollector *collector = [[ORKHealthCollector alloc] initWithSampleType:sampleType unit:unit startDate:startDate];
        [self addCollector:collector];
        healthCollector = collector;
    
        return YES;
    }];
    
    return healthCollector;
}

- (ORKHealthCorrelationCollector *)addHealthCorrelationCollectorWithCorrelationType:(HKCorrelationType *)correlationType
                                                                        sampleTypes:(NSArray<HKSampleType *> *)sampleTypes
                                                                              units:(NSArray<HKUnit *> *)units
                                                                          startDate:(NSDate *)startDate
                                                                              error:(NSError * __autoreleasing *)error {
    if (!correlationType) {
        @throw [NSException exceptionWithName:ORKInvalidArgumentException reason:@"correlationType cannot be nil" userInfo:nil];
    }
    if (![sampleTypes count]) {
        @throw [NSException exceptionWithName:ORKInvalidArgumentException reason:@"sampleTypes cannot be empty" userInfo:nil];
    }
    if ([units count] != [sampleTypes count]) {
        @throw [NSException exceptionWithName:ORKInvalidArgumentException reason:@"units should be same length as sampleTypes" userInfo:nil];
    }
    
    __block ORKHealthCorrelationCollector *healthCorrelationCollector = nil;
    [self onWorkQueueSync:^BOOL(ORKDataCollectionManager *manager) {
        
        ORKHealthCorrelationCollector *collector = [[ORKHealthCorrelationCollector alloc] initWithCorrelationType:correlationType
                                                                                                      sampleTypes:sampleTypes
                                                                                                            units:units
                                                                                                        startDate:startDate];
        [self addCollector:collector];
        healthCorrelationCollector = collector;
        return YES;
    }];
    
    return healthCorrelationCollector;
}

- (ORKMotionActivityCollector *)addMotionActivityCollectorWithStartDate:(NSDate *)startDate
                                                                  error:(NSError* __autoreleasing *)error {
   
    __block ORKMotionActivityCollector *motionActivityCollector = nil;

    [self onWorkQueueSync:^BOOL(ORKDataCollectionManager *manager) {
        
        ORKMotionActivityCollector *collector = [[ORKMotionActivityCollector alloc] initWithStartDate:startDate];
        [self addCollector:collector];
        motionActivityCollector = collector;

        return YES;
    }];

    return motionActivityCollector;
}

- (BOOL)removeCollector:(ORKCollector *)collector error:(NSError* __autoreleasing *)error {
    if (!collector) {
        @throw [NSException exceptionWithName:ORKInvalidArgumentException reason:@"collector cannot be nil" userInfo:nil];
    }
    
    __block BOOL success = NO;
    __block NSError *errorOut = nil;
    [self onWorkQueueSync:^BOOL(ORKDataCollectionManager *manager) {
        
        if (_operationQueue.operationCount > 0) {
            ORK_Log_Debug(@"[startWithObserving] returned due to operation queue is not empty (queue size = %@)", @(_operationQueue.operationCount));
            errorOut = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:@{NSLocalizedFailureReasonErrorKey: @"Cannot remove collector during collection."}];
            return NO;
        }
        
        NSMutableArray *collectors = [self.collectors mutableCopy];
      
        if (![collectors containsObject:collector]) {
            errorOut = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorObjectNotFound userInfo:@{NSLocalizedFailureReasonErrorKey: @"Cannot find collector."}];
            return NO;
        }
        
        
        // Remove the collector from the collectors array
        [collectors removeObject:collector];
        _collectors = [collectors copy];
        
        success = YES;
        return YES;
    }];
    
    if (error) {
        *error = errorOut;
    }
    return success;
}

- (void)startCollection {
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray<ORKOperation *> *operations = [NSMutableArray array];
    [self onWorkQueueAsync:^BOOL(ORKDataCollectionManager *manager) {
        
        if (_operationQueue.operationCount > 0) {
            ORK_Log_Debug(@"[startWithObserving] returned due to operation queue is not empty (queue size = %@)", @(_operationQueue.operationCount));
            return NO;
        }
        
        self.lastCollectionDate = [NSDate date];
        
        // Create an operation for each collector
        for (ORKCollector *collector in self.collectors) {
            
            __block ORKOperation *operation = [collector collectionOperationWithManager:self];
            
            // operation could be nil if this type of data collection is not possible
            // on this device.
            if (operation) {
                __block ORKOperation *blockOp = operation;
                
                [operation setCompletionBlock:^{
                    typeof(self) strongSelf = weakSelf;
                    if (blockOp.error) {
                        id<ORKDataCollectionManagerDelegate> delegate = strongSelf.delegate;
                        if (delegate && [delegate respondsToSelector:@selector(collector:didDetectError:)]) {
                            [delegate collector:collector didDetectError:blockOp.error];
                        }
                    }
                }];
                
                [operations addObject:operation];
            }
        }
        
        NSBlockOperation *completionOperation = [NSBlockOperation new];
        [completionOperation addExecutionBlock:^{
            
            typeof(self) strongSelf = weakSelf;
            [strongSelf onWorkQueueSync:^BOOL(ORKDataCollectionManager *manager) {
                if (_delegate && [_delegate respondsToSelector:@selector(dataCollectionManagerDidCompleteCollection:)]) {
                    [_delegate dataCollectionManagerDidCompleteCollection:self];
                }
                
                for (HKObserverQueryCompletionHandler handler in _completionHandlers) {
                    handler();
                }
                [_completionHandlers removeAllObjects];
                
                return NO;
            }];
        }];
        
        for (NSOperation *operation in operations) {
            [completionOperation addDependency:operation];
        }
        
        ORK_Log_Debug(@"Data Collection queue - new operations:\n%@", operations);
        [_operationQueue addOperations:operations waitUntilFinished:NO];
        [_operationQueue addOperation:completionOperation];
        
        // No need to persist collectors
        return NO;
    }];

}

@end
