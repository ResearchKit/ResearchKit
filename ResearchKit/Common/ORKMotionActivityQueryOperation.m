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


#import "ORKMotionActivityQueryOperation.h"
#import <CoreMotion/CoreMotion.h>
#import "ORKCollector.h"
#import "ORKHelpers_Internal.h"
#import "ORKCollector_Internal.h"
#import "ORKDataCollectionManager_Internal.h"


@implementation ORKMotionActivityQueryOperation {
    
    // All of these are strong references created at init time
    ORKMotionActivityCollector *_collector;
    NSOperationQueue *_queue;
    NSDate *_currentDate;
    __weak ORKDataCollectionManager *_manager;
}

- (instancetype)initWithCollector:(ORKMotionActivityCollector*)collector
                      queryQueue:(NSOperationQueue*)queue
                         manager:(ORKDataCollectionManager *)manager {
    self = [super init];
    if (self) {
        _collector = collector;
        _manager = manager;
        _queue = queue ? : [NSOperationQueue mainQueue];
        _currentDate = nil;
        
        self.startBlock = ^void(ORKOperation* a) {
            [(ORKMotionActivityQueryOperation*)a doQuery];
        };
        
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@(%p):%@>",NSStringFromClass([self class]), self, _collector];
}

- (void)finishWithErrorCode:(ORKErrorCode)error {
    self.error = [NSError errorWithDomain:ORKErrorDomain code:error userInfo:nil];
    [self safeFinish];
}

- (void)doQuery {
    [self.lock lock];
    
    __block NSDate *startDate = nil;
    
    __block NSDate *lastDate = nil;
    __block NSString *itemIdentifier = nil;
    
    [_manager onWorkQueueSync:^BOOL(ORKDataCollectionManager *manager) {
        BOOL changed = NO;
        
        // _currentAnchor will be NSNotFound on the first pass of the operation
        if (_currentDate != nil) {
            changed = YES;
            
            // Update the anchor if we have one
            _collector.lastDate = _currentDate;
        }
        
        lastDate = _collector.lastDate;
        startDate = _collector.startDate;
        itemIdentifier = _collector.identifier;
        
        return changed;
    }];
    
    if (_currentDate == nil) {
        _currentDate = lastDate;
    }

    __weak ORKMotionActivityQueryOperation * weakSelf = self;
    
    NSDate *queryBeginDate = _currentDate?:startDate;
    NSDate *queryEndDate = [NSDate date];
    if (!queryBeginDate) {
        queryBeginDate = [NSDate distantPast];
    }
    
    ORK_Log_Debug(@"\nMotion Query: %@\n", @{@"from": queryBeginDate, @"to":queryEndDate});
    
    // Run a single query up to current date
    [_manager.activityManager queryActivityStartingFromDate:queryBeginDate toDate:queryEndDate toQueue:_queue withHandler:^(NSArray<CMMotionActivity *> *activities, NSError *error) {
        ORKMotionActivityQueryOperation *op = weakSelf;
        ORK_Log_Debug(@"\nMotion Query: %@\n", @{@"from": queryBeginDate, @"to":queryEndDate, @"returned count": @(activities.count)});
        [op handleResults:activities queryBegin:queryBeginDate queryEnd:queryEndDate error:error itemIdentifier:itemIdentifier];
    }];
    
    [self.lock unlock];
    
}

/*
 Handles the results, and starts a new query if needed
 */
- (void)handleResults:(NSArray<CMMotionActivity *> *)results
          queryBegin:(NSDate *)queryBegin
            queryEnd:(NSDate *)queryEnd
               error:(NSError *)error
      itemIdentifier:(NSString *)itemIdentifier {
    [self.lock lock];
    // Check our actual state under the lock
    
    if ([self isCancelled]) {
        // Give up immediately if we've been cancelled
        [self.lock unlock];
        return;
    }
    if (error) {
        // Give up if there was an error performing the query
        self.error = error;
        [self safeFinish];
        [self.lock unlock];
        return;
    }
    
    [self.lock unlock];
    
    if (results && [results count] > 0) {
        CMMotionActivity *lastObject = (CMMotionActivity *)[results lastObject];
        NSDate *lastObservedDate = lastObject.startDate;
        if (![lastObservedDate isEqual:queryBegin] && [lastObservedDate earlierDate:queryBegin] == lastObservedDate && [results count] == 1) {
            // Ignore a one-off if it was before the beginning of the query
            [self safeFinish];
            return;
        }
        
        __block BOOL handoutSuccess = NO;
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        // Dispatch the results back to the data handler, if any
        [_manager onWorkQueueAsync:^BOOL(ORKDataCollectionManager *manager) {
            id<ORKDataCollectionManagerDelegate> delegate = _manager.delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(motionActivityCollector:didCollectMotionActivities:)]) {
                handoutSuccess = [delegate motionActivityCollector:_collector didCollectMotionActivities:results];
            }
            
            dispatch_semaphore_signal(sem);
            return YES;
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        if (!handoutSuccess) {
            self.error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:@{NSLocalizedFailureReasonErrorKey: @"Results were not properly delivered to the data collection manager delegate."}];
        }
        
        // If successfully reported to delegate, and we observed at
        // least one valid sample, update the "current" date
        // (the start date of the next query)
        if (lastObservedDate && handoutSuccess) {
            
            // Write the query end as the finish date. This is ok because in CoreMotion
            // entries are local and unlikely to be written for dates prior to "now".
            NSDate *nextStartDate = queryEnd ? : lastObservedDate;
            self->_currentDate = nextStartDate;
            
            // Store it on the collector
            [_manager onWorkQueueAsync:^BOOL(ORKDataCollectionManager *manager) {
                _collector.lastDate = nextStartDate;
                return YES;
            }];
            
        }
            
    }
    
    [self safeFinish];
}

@end
