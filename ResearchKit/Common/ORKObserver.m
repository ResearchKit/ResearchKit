//
//  ORKObserver.m
//  ResearchKit
//
//  Created by Ricardo Sánchez-Sáez on 22/04/2015.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

#import "ORKObserver.h"
#import "ORKHelpers.h"

@implementation ORKObserver

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSAssert(context == self.context, @"Unexpected KVO");
    ORKSuppressPerformSelectorWarning(
                                      (void)[self.responder performSelector:self.action withObject:self.target];);
}

- (void)startObserving {
    if (_observing == NO) {
        NSAssert(self.keyPaths, @"");
        NSAssert(self.target, @"");
        NSAssert(self.context, @"");
        NSAssert(self.responder, @"");
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


@implementation ORKViewControllerObserver

static void *_ORKViewControllerContext = &_ORKViewControllerContext;

- (instancetype)initWithTargetViewController:(UIViewController *)target responder:(id <ORKViewControllerObserverProtocol>)responder {
    self = [super init];
    if (self) {
        self.keyPaths = @[@"navigationItem.leftBarButtonItem", @"navigationItem.rightBarButtonItem", @"toolbarItems"];
        self.target = target;
        self.responder = responder;
        self.action = @selector(collectToolbarItemsFromViewController:);
        self.context = _ORKViewControllerContext;
        [self startObserving];
    }
    return self;
}

@end


@implementation ORKScrollViewObserver

static void *_ORKScrollViewObserverContext = &_ORKScrollViewObserverContext;

- (instancetype)initWithTargetView:(UIScrollView *)scrollView responder:(id <ORKViewControllerObserverProtocol>)responder {
    self = [super init];
    if (self) {
        self.keyPaths = @[@"contentOffset"];
        self.target = scrollView;
        self.responder = responder;
        self.action = @selector(observedScrollViewDidScroll:);
        self.context = _ORKScrollViewObserverContext;
        [self startObserving];
    }
    return self;
}

@end
