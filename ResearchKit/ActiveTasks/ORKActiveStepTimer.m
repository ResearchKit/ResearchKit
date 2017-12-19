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


#import "ORKActiveStepTimer.h"

#import "ORKHelpers_Internal.h"

@import UIKit;
#include <mach/mach.h>
#include <mach/mach_time.h>


static NSTimeInterval timeIntervalFromMachTime(uint64_t delta) {
    static mach_timebase_info_data_t    sTimebaseInfo;
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    uint64_t elapsedNano = delta * sTimebaseInfo.numer / sTimebaseInfo.denom;
    return elapsedNano * 1.0 / NSEC_PER_SEC;
}


@implementation ORKActiveStepTimer {
    uint64_t _startTime;
    NSTimeInterval _preExistingRuntime;
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
    UIBackgroundTaskIdentifier _backgroundTaskIdentifier;
    uint32_t _isRunning;
}

- (instancetype)initWithDuration:(NSTimeInterval)duration interval:(NSTimeInterval)interval runtime:(NSTimeInterval)runtime handler:(ORKActiveStepTimerHandler)handler {
    self = [super init];
    if (self) {
        if (!handler) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Handler is required" userInfo:nil];
        }
        
        _duration = duration;
        _interval = interval;
        _handler = [handler copy];
        _preExistingRuntime = runtime;
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        
        _queue = dispatch_queue_create("active_step", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

- (void)dealloc {
    [self queue_pauseAtFinish:NO];
}

- (NSTimeInterval)runtime {
    __block NSTimeInterval runtime = 0;
    dispatch_sync(_queue, ^{
        runtime = [self queue_runtime];
    });
    return MIN(runtime,_duration);
}

- (void)pause {
    dispatch_sync(_queue, ^{
        [self queue_pauseAtFinish:NO];
    });
}

- (void)resume {
    dispatch_sync(_queue, ^{
        [self queue_resume];
    });
}

- (void)reset {
    dispatch_sync(_queue, ^{
        [self queue_reset];
    });
}

- (NSTimeInterval)queue_runtime {
    NSTimeInterval runtime = _preExistingRuntime;
    if (_timer != NULL) {
        uint64_t now = mach_absolute_time();
        runtime += timeIntervalFromMachTime(now - _startTime);
    }
    return runtime;
}

- (void)setDuration:(NSTimeInterval)duration {
    dispatch_sync(_queue, ^{
        _duration = duration;
    });
}

- (void)hiqueue_event {
    dispatch_sync(_queue, ^{
        [self queue_event];
    });
}

- (void)queue_event {
    [self queue_assertBackgroundTask];
    
    NSTimeInterval runtime = [self queue_runtime];
    BOOL finished = (runtime >= _duration);
    if (finished) {
        [self queue_pauseAtFinish:YES];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _handler(self, finished);
        dispatch_sync(_queue, ^{
            
            // If the timer is still NULL here, we can safely release the background task.
            if (_timer == NULL) {
                [self queue_releaseBackgroundTask];
            }
        });
    });
}

- (void)queue_clearTimer {
    if (_timer != NULL) {
        
        dispatch_source_cancel(_timer);
        _timer = NULL;
    }
}

- (void)queue_releaseBackgroundTask {
    if (_backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        return;
    }
    UIBackgroundTaskIdentifier identifier = _backgroundTaskIdentifier;
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endBackgroundTask:identifier];
    });
}

- (void)queue_assertBackgroundTask {
    if (_backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        return;
    }
    _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // This is guaranteed to be called synchronously on the main queue, switch to our queue to invalidate the identifier
        dispatch_sync(_queue, ^{
            _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        });
    }];
}

- (void)queue_resume {
    if (_timer != NULL) {
        // Already resumed
        return;
    }
    if ([self queue_runtime] >= _duration) {
        // Already finished. Fire one event to indicate.
        [self queue_event];
        return;
    }
    
    // We want to run in the background if we can, so voice can be played, etc.
    assert(_backgroundTaskIdentifier == UIBackgroundTaskInvalid);
    
    [self queue_assertBackgroundTask];
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                    0, 0, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0));
    if (_timer == NULL) {
        assert(0);
        return;
    }
    ORKWeakTypeOf(self) weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        [strongSelf hiqueue_event];
    });
    
    NSTimeInterval timeUntilNextFire = (floor(_preExistingRuntime / _interval) + 1)*_interval -  _preExistingRuntime;
    
    _startTime = mach_absolute_time();
    dispatch_source_set_timer(_timer,
                              dispatch_time(DISPATCH_TIME_NOW, timeUntilNextFire * NSEC_PER_SEC),
                              _interval * NSEC_PER_SEC,
                              0.05 * NSEC_PER_SEC);
    dispatch_resume(_timer);
}

- (void)queue_pauseAtFinish:(BOOL)atFinish {
    if (_timer == NULL) {
        // Not running
        return;
    }
    
    uint64_t now = mach_absolute_time();
    [self queue_clearTimer];
    _preExistingRuntime += timeIntervalFromMachTime(now - _startTime);
    _startTime = 0;
    
    if (!atFinish) {
        // If we are atFinish, the task will be released after the handler completes
        [self queue_releaseBackgroundTask];
    }
}

- (void)queue_reset {
    [self queue_clearTimer];
    _preExistingRuntime = 0;
    [self queue_releaseBackgroundTask];
}

@end
