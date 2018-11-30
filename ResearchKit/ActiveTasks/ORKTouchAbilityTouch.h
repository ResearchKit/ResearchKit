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

/**
 The `ORKTouchAbilityTouch` class is a reflection of `UITouch` class.
 
 All of the location, azimuth and altitudeAngle properties are relative to the touch's window.
 */
ORK_CLASS_AVAILABLE
@interface ORKTouchAbilityTouch: NSObject <NSCopying, NSSecureCoding>


/**
 An ISO 8601 UNIX timestamp indicating the time of the touch.
 
 `ORKTouchAbilityTouch` convert `UITouch.timestamp` to UNIX timestamp automatically. The timestamp property of `UITouch` is relative to system uptime.
 
 @code ORKTouchAbilityTouch.timestamp = UITouch.timestamp + [NSDate dateWithTimeIntervalSinceNow:-[[NSProcessInfo processInfo] systemUptime]].timeIntervalSince1970;
 */
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

/**
 Force of the touch, where 1.0 represents the force of an average touch
 */
@property(nonatomic, readonly) CGFloat force;

/**
 Maximum possible force with this input mechanism
 */
@property(nonatomic, readonly) CGFloat maximumPossibleForce;

/**
 Azimuth angle relative to the touch's window.
 Valid only for stylus touch types. Zero radians points along the positive X axis.
 */
@property(nonatomic, readonly) CGFloat azimuthAngleInWindow;

/**
 A unit vector relative to the touch's window that points in the direction of the azimuth angle.
 Valid only for stylus touch types.
 */
@property(nonatomic, readonly) CGVector azimuthUnitVectorInWindow;

/**
 Altitude angle. Valid only for stylus touch types.
 Zero radians indicates that the stylus is parallel to the screen surface,
 while M_PI/2 radians indicates that it is normal to the screen surface.
 */
@property(nonatomic, readonly) CGFloat altitudeAngle;

/**
 An index which allows you to correlate updates with the original touch.
 Is only guaranteed non-nil if this UITouch expects or is an update.
 */
@property(nonatomic, readonly) NSNumber * _Nullable estimationUpdateIndex;

/**
 A set of properties that has estimated values
 Only denoting properties that are currently estimated
 */
@property(nonatomic, readonly) UITouchProperties estimatedProperties;

/**
 A set of properties that expect to have incoming updates in the future.
 If no updates are expected for an estimated property the current value is our final estimate.
 This happens e.g. for azimuth/altitude values when entering from the edges
 */
@property(nonatomic, readonly) UITouchProperties estimatedPropertiesExpectingUpdates;


/**
 Initialize an `ORKTouchAbilityTouch` object with an `UITouch`.

 @param touch The `UITouch` object it reflects.
 @return An `ORKTouchAbilityTouch` object.
 */
- (instancetype)initWithUITouch:(UITouch *)touch;

@end

NS_ASSUME_NONNULL_END
