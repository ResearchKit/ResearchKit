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


#import "ORKTouchAbilityTrack.h"
#import "ORKTouchAbilityTrack_Internal.h"

@interface ORKTouchAbilityTrack ()
@property(nonatomic, copy) NSMutableArray<ORKTouchAbilityTouch *> *mutableTouches;
@end

@implementation ORKTouchAbilityTrack

- (NSMutableArray<ORKTouchAbilityTouch *> *)mutableTouches {
    if (!_mutableTouches) {
        _mutableTouches = @[].mutableCopy;
    }
    return _mutableTouches;
}

- (NSArray<ORKTouchAbilityTouch *> *)touches {
    return [self.mutableTouches copy];
}

- (void)addTouch:(ORKTouchAbilityTouch *)touch {
    [self.mutableTouches addObject:touch];
}

@end

@interface ORKTouchAbilityTouch ()

@property(nonatomic, assign) NSTimeInterval timestamp;
@property(nonatomic, assign) UITouchPhase phase;
@property(nonatomic, assign) NSUInteger tapCount;
@property(nonatomic, assign) UITouchType type;

@property(nonatomic, assign) CGFloat majorRadius;
@property(nonatomic, assign) CGFloat majorRadiusTolerance;

@property(nonatomic, assign) CGPoint locationInWindow;
@property(nonatomic, assign) CGPoint previousLocationInWindow;
@property(nonatomic, assign) CGPoint preciseLocationInWindow;
@property(nonatomic, assign) CGPoint precisePreviousLocationInWindow;

@property(nonatomic, assign) CGFloat force;
@property(nonatomic, assign) CGFloat maximumPossibleForce;

@property(nonatomic, assign) CGFloat azimuthAngleInWindow;
@property(nonatomic, assign) CGVector azimuthUnitVectorInWindow;
@property(nonatomic, assign) CGFloat altitudeAngle;

@property(nonatomic, copy) NSNumber * _Nullable estimationUpdateIndex;
@property(nonatomic, assign) UITouchProperties estimatedProperties;
@property(nonatomic, assign) UITouchProperties estimatedPropertiesExpectingUpdates;

@end

@implementation ORKTouchAbilityTouch

- (instancetype)initWithTouch:(UITouch *)touch {
    self = [super init];
    if (self) {
        self.timestamp = touch.timestamp;
        self.phase = touch.phase;
        self.tapCount = touch.tapCount;
        self.type = touch.type;
        self.majorRadius = touch.majorRadius;
        self.majorRadiusTolerance = touch.majorRadiusTolerance;
        self.locationInWindow = [touch locationInView:nil];
        self.previousLocationInWindow = [touch previousLocationInView:nil];
        self.preciseLocationInWindow = [touch preciseLocationInView:nil];
        self.precisePreviousLocationInWindow = [touch precisePreviousLocationInView:nil];
        self.force = touch.force;
        self.maximumPossibleForce = touch.maximumPossibleForce;
        self.azimuthAngleInWindow = [touch azimuthAngleInView:nil];
        self.azimuthUnitVectorInWindow = [touch azimuthUnitVectorInView:nil];
        self.altitudeAngle = touch.altitudeAngle;
        self.estimationUpdateIndex = touch.estimationUpdateIndex;
        self.estimatedProperties = touch.estimatedProperties;
        self.estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates;
    }
    return self;
}

@end
