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


@import UIKit;
#import <ResearchKit/ORKResult.h>

NS_ASSUME_NONNULL_BEGIN

@class ORKTouchAbilityTouch;

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityTrack: NSObject
@property(nonatomic, readonly) NSArray<ORKTouchAbilityTouch *> *touches;
@end

ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityTouch: NSObject

@property(nonatomic, readonly) NSTimeInterval timestamp;
@property(nonatomic, readonly) UITouchPhase phase;
@property(nonatomic, readonly) NSUInteger tapCount;
@property(nonatomic, readonly) UITouchType type;

@property(nonatomic, readonly) CGFloat majorRadius;
@property(nonatomic, readonly) CGFloat majorRadiusTolerance;

@property(nonatomic, readonly) CGPoint locationInWindow;
@property(nonatomic, readonly) CGPoint previousLocationInWindow;
@property(nonatomic, readonly) CGPoint preciseLocationInWindow;
@property(nonatomic, readonly) CGPoint precisePreviousLocationInWindow;

@property(nonatomic, readonly) CGFloat force;
@property(nonatomic, readonly) CGFloat maximumPossibleForce;

@property(nonatomic, readonly) CGFloat azimuthAngleInWindow;
@property(nonatomic, readonly) CGVector azimuthUnitVectorInWindow;
@property(nonatomic, readonly) CGFloat altitudeAngle;

@property(nonatomic, readonly) NSNumber * _Nullable estimationUpdateIndex;
@property(nonatomic, readonly) UITouchProperties estimatedProperties;
@property(nonatomic, readonly) UITouchProperties estimatedPropertiesExpectingUpdates;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTouch:(UITouch *)touch;
@end

NS_ASSUME_NONNULL_END
