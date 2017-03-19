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


#import "ORKOperation.h"
#import "ORKErrors.h"
#import "ORKHelpers_Internal.h"


static NSString *keyPathFromOperationState(ORKOperationState state) {
    switch (state) {
        case ORKOperationReady:
            return @"isReady";
        case ORKOperationExecuting:
            return @"isExecuting";
        case ORKOperationFinished:
            return @"isFinished";
        default:
            return @"state";
    }
}

static BOOL stateTransitionIsValid(ORKOperationState fromState, ORKOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case ORKOperationReady:
            switch (toState) {
                case ORKOperationExecuting:
                    return YES;
                case ORKOperationFinished:
                    return isCancelled;
                default:
                    return NO;
            }
        case ORKOperationExecuting:
            switch (toState) {
                case ORKOperationFinished:
                    return YES;
                default:
                    return NO;
            }
        case ORKOperationFinished:
            return NO;
        default:
            return YES;
    }
}


@implementation ORKOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"com.apple.ResearchKit.Operation";
        self.state = ORKOperationReady;
    }
    return self;
}

- (void)setState:(ORKOperationState)state {
    [self.lock lock];
    if (stateTransitionIsValid(self.state, state, [self isCancelled])) {
        NSString *oldStateKey = keyPathFromOperationState(self.state);
        NSString *newStateKey = keyPathFromOperationState(state);
        
        [self willChangeValueForKey:newStateKey];
        [self willChangeValueForKey:oldStateKey];
        _state = state;
        [self didChangeValueForKey:oldStateKey];
        [self didChangeValueForKey:newStateKey];
        
    }
    [self.lock unlock];
}


#pragma mark - NSOperation

- (BOOL)isReady {
    return self.state == ORKOperationReady && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == ORKOperationExecuting;
}

- (BOOL)isFinished {
    return self.state == ORKOperationFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    [self.lock lock];
    
    if ([self isCancelled]) {
        [self finish];
    } else if ([self isReady]) {
        self.state = ORKOperationExecuting;
        
        ORK_Log_Debug(@"%@ start", self.class);
        _startBlock(self);
    }
    [self.lock unlock];
}

- (void)finish {
    ORK_Log_Debug(@"%@ finish: %@", self, (self.error ? : @"OK"));
    self.state = ORKOperationFinished;
}

- (void)cancel {
    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        if (! self.error) {
            self.error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:nil];
        }
        [self willChangeValueForKey:@"isCancelled"];
        [super cancel];
        [self didChangeValueForKey:@"isCancelled"];
    }
    [self.lock unlock];
}

- (void)safeFinish {
    [self.lock lock];
    if ([self isExecuting]) {
        [self finish];
    }
    [self.lock unlock];
}

- (void)doTimeout {
    [self.lock lock];
    if (self.state == ORKOperationExecuting) {
        self.error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:nil];
        [self finish];
    }
    [self.lock unlock];
}

@end
