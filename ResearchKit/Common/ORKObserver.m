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


#import "ORKObserver.h"
#import "ORKHelpers.h"


@implementation ORKObserver

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithTarget:(id)target keyPaths:(NSArray *)keyPaths delegate:(id)delegate action:(SEL)action context:(void *)context {
    self = [super init];
    if (self) {
        self.keyPaths = keyPaths;
        self.target = target;
        self.delegate = delegate;
        self.action = action;
        self.context = context;
        [self startObserving];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSAssert(context == self.context, @"Unexpected KVO");
    ORKSuppressPerformSelectorWarning(
                                      (void)[self.delegate performSelector:self.action withObject:self.target];
                                      );
}

- (void)startObserving {
    if (_observing == NO) {
        NSAssert(self.keyPaths, @"");
        NSAssert(self.target, @"");
        NSAssert(self.context, @"");
        NSAssert(self.delegate, @"");
        NSAssert(self.action, @"");
        for (NSString *keyPath in self.keyPaths) {
            [self.target addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptions)0 context:self.context];
        }
        self.observing = YES;
    }
}

- (void)stopObserving {
    if (_observing) {
        for (NSString *keyPath in _keyPaths) {
            [self.target removeObserver:self forKeyPath:keyPath];
        }
        _observing = NO;
    }
}

- (void)dealloc {
    [self stopObserving];
}

@end


@implementation ORKScrollViewObserver

static void *_ORKScrollViewObserverContext = &_ORKScrollViewObserverContext;

- (instancetype)initWithTargetView:(UIScrollView *)scrollView delegate:(id <ORKScrollViewObserverDelegate>)delegate {
    return [super initWithTarget:scrollView
                        keyPaths:@[@"contentOffset"]
                        delegate:delegate
                          action:@selector(observedScrollViewDidScroll:)
                         context:_ORKScrollViewObserverContext];
}

@end
