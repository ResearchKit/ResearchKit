//
//  ORKTouchAbilityGestureRecoginzerEvent.m
//  ResearchKit
//
//  Created by Tommy Lin on 2018/11/2.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import "ORKTouchAbilityGestureRecoginzerEvent.h"


#pragma mark - ORKTouchAbilityGestureRecoginzerEvent

@interface ORKTouchAbilityGestureRecoginzerEvent ()

@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) UIGestureRecognizerState state;
@property (nonatomic, copy) NSArray<NSNumber *> *allowedTouchTypes;
@property (nonatomic, assign) CGPoint locationInWindow;
@property (nonatomic, assign) NSUInteger numberOfTouches;
@property (nonatomic, copy) NSDictionary<NSNumber *, NSValue *> *locationInWindowOfTouchAtIndex;

@end

@implementation ORKTouchAbilityGestureRecoginzerEvent

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer {
    self = [super init];
    if (self) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
        self.state = recognizer.state;
        self.allowedTouchTypes = recognizer.allowedTouchTypes;
        self.locationInWindow = [recognizer locationInView:nil];
        self.numberOfTouches = recognizer.numberOfTouches;
        
        if (recognizer.numberOfTouches == 0) {
            self.locationInWindowOfTouchAtIndex = @{};
        } else {
            NSMutableDictionary *dict = @{}.mutableCopy;
            for (NSUInteger i = 0; i < recognizer.numberOfTouches; i++) {
                CGPoint location = [recognizer locationOfTouch:i inView:nil];
                dict[@(i)] = [NSValue valueWithCGPoint:location];
            }
            self.locationInWindowOfTouchAtIndex = [dict copy];
        }
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityTapGestureRecoginzerEvent

@interface ORKTouchAbilityTapGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;
@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;

@end

@implementation ORKTouchAbilityTapGestureRecoginzerEvent

- (instancetype)initWithTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.numberOfTapsRequired = recognizer.numberOfTapsRequired;
        self.numberOfTouchesRequired = recognizer.numberOfTouchesRequired;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityLongPressGestureRecoginzerEvent

@interface ORKTouchAbilityLongPressGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;
@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
@property (nonatomic, assign) CGFloat allowableMovement;

@end

@implementation ORKTouchAbilityLongPressGestureRecoginzerEvent

- (instancetype)initWithLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.numberOfTapsRequired = recognizer.numberOfTapsRequired;
        self.numberOfTouchesRequired = recognizer.numberOfTouchesRequired;
        self.minimumPressDuration = recognizer.minimumPressDuration;
        self.allowableMovement = recognizer.allowableMovement;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityPanGestureRecoginzerEvent

@interface ORKTouchAbilityPanGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger minimumNumberOfTouches;
@property (nonatomic, assign) NSUInteger maximumNumberOfTouches;
@property (nonatomic, assign) CGPoint velocityInWindow;

@end

@implementation ORKTouchAbilityPanGestureRecoginzerEvent

- (instancetype)initWithPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.minimumNumberOfTouches = recognizer.minimumNumberOfTouches;
        self.maximumNumberOfTouches = recognizer.maximumNumberOfTouches;
        self.velocityInWindow = [recognizer velocityInView:nil];
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityPanGestureRecoginzerEvent

@interface ORKTouchAbilitySwipeGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;
@property (nonatomic, assign) UISwipeGestureRecognizerDirection direction;

@end

@implementation ORKTouchAbilitySwipeGestureRecoginzerEvent

- (instancetype)initWithSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.numberOfTouchesRequired = recognizer.numberOfTouchesRequired;
        self.direction = recognizer.direction;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilitySwipeGestureRecoginzerEvent

@interface ORKTouchAbilityPinchGestureRecoginzerEvent ()

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat velocity;

@end

@implementation ORKTouchAbilityPinchGestureRecoginzerEvent

- (instancetype)initWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.scale = recognizer.scale;
        self.velocity = recognizer.velocity;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityRotationGestureRecoginzerEvent

@interface ORKTouchAbilityRotationGestureRecoginzerEvent ()

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat velocity;

@end

@implementation ORKTouchAbilityRotationGestureRecoginzerEvent

- (instancetype)initWithRotationGestureRecognizer:(UIRotationGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.rotation = recognizer.rotation;
        self.velocity = recognizer.velocity;
    }
    return self;
}

@end
