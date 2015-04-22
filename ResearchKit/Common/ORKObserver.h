//
//  ORKObserver.h
//  ResearchKit
//
//  Created by Ricardo Sánchez-Sáez on 22/04/2015.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORKTaskViewController;

@interface ORKObserver : NSObject

@property (nonatomic, strong) NSArray *keyPaths;
@property (nonatomic, strong) id target;
@property (nonatomic) BOOL observing;
@property (nonatomic) void *context;

@property (nonatomic, weak) id responder;
@property (nonatomic) SEL action;

- (void)startObserving;

@end


@protocol ORKViewControllerObserverProtocol <NSObject>
@required
- (void)collectToolbarItemsFromViewController:(UIViewController *)viewController;
@end

@interface ORKViewControllerObserver : ORKObserver

- (instancetype)initWithTargetViewController:(UIViewController *)target responder:(id <ORKViewControllerObserverProtocol>)responder;

@end


@protocol ORKScrollViewObserverProtocol <NSObject>
@required
- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface ORKScrollViewObserver  : ORKObserver

- (instancetype)initWithTargetView:(UIScrollView *)scrollView responder:(id <ORKScrollViewObserverProtocol>)responder;

@end
