//
//  ORKTouchAbilityGestureRecoginzerEvent.h
//  ResearchKit
//
//  Created by Tommy Lin on 2018/11/2.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ORKTouchAbilityGestureRecoginzerEvent

@interface ORKTouchAbilityGestureRecoginzerEvent : NSObject

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) UIGestureRecognizerState state;
@property (nonatomic, readonly) NSArray<NSNumber *> *allowedTouchTypes;
@property (nonatomic, readonly) CGPoint locationInWindow;
@property (nonatomic, readonly) NSUInteger numberOfTouches;
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSValue *> *locationInWindowOfTouchAtIndex;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityTapGestureRecoginzerEvent

@interface ORKTouchAbilityTapGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger numberOfTapsRequired;
@property (nonatomic, readonly) NSUInteger numberOfTouchesRequired;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithTapGestureRecognizer:(UITapGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityLongPressGestureRecoginzerEvent

@interface ORKTouchAbilityLongPressGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger numberOfTapsRequired;
@property (nonatomic, readonly) NSUInteger numberOfTouchesRequired;
@property (nonatomic, readonly) NSTimeInterval minimumPressDuration;
@property (nonatomic, readonly) CGFloat allowableMovement;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityPanGestureRecoginzerEvent

@interface ORKTouchAbilityPanGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger minimumNumberOfTouches;
@property (nonatomic, readonly) NSUInteger maximumNumberOfTouches;
@property (nonatomic, readonly) CGPoint velocityInWindow;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilitySwipeGestureRecoginzerEvent

@interface ORKTouchAbilitySwipeGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger numberOfTouchesRequired;
@property (nonatomic, readonly) UISwipeGestureRecognizerDirection direction;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilitySwipeGestureRecoginzerEvent

@interface ORKTouchAbilityPinchGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat velocity;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityRotationGestureRecoginzerEvent

@interface ORKTouchAbilityRotationGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly) CGFloat velocity;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithRotationGestureRecognizer:(UIRotationGestureRecognizer *)recognizer;

@end

NS_ASSUME_NONNULL_END
