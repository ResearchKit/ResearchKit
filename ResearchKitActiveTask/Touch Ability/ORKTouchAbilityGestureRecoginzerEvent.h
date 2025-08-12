/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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


#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ORKTouchAbilityGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityGestureRecoginzerEvent : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) UIGestureRecognizerState state;
@property (nonatomic, readonly) NSArray<NSNumber *> *allowedTouchTypes;
@property (nonatomic, readonly) CGPoint locationInWindow;
@property (nonatomic, readonly) NSUInteger numberOfTouches;
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSValue *> *locationInWindowOfTouchAtIndex;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityTapGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityTapGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger numberOfTapsRequired;
@property (nonatomic, readonly) NSUInteger numberOfTouchesRequired;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithTapGestureRecognizer:(UITapGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityLongPressGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityLongPressGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger numberOfTapsRequired;
@property (nonatomic, readonly) NSUInteger numberOfTouchesRequired;
@property (nonatomic, readonly) NSTimeInterval minimumPressDuration;
@property (nonatomic, readonly) CGFloat allowableMovement;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityPanGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityPanGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger minimumNumberOfTouches;
@property (nonatomic, readonly) NSUInteger maximumNumberOfTouches;
@property (nonatomic, readonly) CGPoint velocityInWindow;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilitySwipeGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilitySwipeGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) NSUInteger numberOfTouchesRequired;
@property (nonatomic, readonly) UISwipeGestureRecognizerDirection direction;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilitySwipeGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityPinchGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat velocity;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer;

@end


#pragma mark - ORKTouchAbilityRotationGestureRecoginzerEvent

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityRotationGestureRecoginzerEvent : ORKTouchAbilityGestureRecoginzerEvent

@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly) CGFloat velocity;

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer NS_UNAVAILABLE;
- (instancetype)initWithRotationGestureRecognizer:(UIRotationGestureRecognizer *)recognizer;

@end

NS_ASSUME_NONNULL_END
