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

#import "Availability.h"

#import "ORKTouchAbilityTouch.h"
#import "ORKHelpers_Internal.h"

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

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_ENUM(aCoder, phase);
    ORK_ENCODE_INTEGER(aCoder, tapCount);
    ORK_ENCODE_ENUM(aCoder, type);
    ORK_ENCODE_DOUBLE(aCoder, majorRadius);
    ORK_ENCODE_DOUBLE(aCoder, majorRadiusTolerance);
    ORK_ENCODE_CGPOINT(aCoder, locationInWindow);
    ORK_ENCODE_CGPOINT(aCoder, previousLocationInWindow);
    ORK_ENCODE_CGPOINT(aCoder, preciseLocationInWindow);
    ORK_ENCODE_CGPOINT(aCoder, precisePreviousLocationInWindow);
    ORK_ENCODE_DOUBLE(aCoder, force);
    ORK_ENCODE_DOUBLE(aCoder, maximumPossibleForce);
    ORK_ENCODE_DOUBLE(aCoder, azimuthAngleInWindow);
    
    [aCoder encodeCGVector:self.azimuthUnitVectorInWindow forKey:@ORK_STRINGIFY(azimuthUnitVectorInWindow)];
    
    ORK_ENCODE_DOUBLE(aCoder, altitudeAngle);
    
    if (self.estimationUpdateIndex) {
        ORK_ENCODE_OBJ(aCoder, estimationUpdateIndex);
    }
    
    ORK_ENCODE_INTEGER(aCoder, estimatedProperties);
    ORK_ENCODE_INTEGER(aCoder, estimatedPropertiesExpectingUpdates);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_ENUM(aDecoder, phase);
        ORK_DECODE_INTEGER(aDecoder, tapCount);
        ORK_DECODE_ENUM(aDecoder, type);
        ORK_DECODE_DOUBLE(aDecoder, majorRadius);
        ORK_DECODE_DOUBLE(aDecoder, majorRadiusTolerance);
        ORK_DECODE_CGPOINT(aDecoder, locationInWindow);
        ORK_DECODE_CGPOINT(aDecoder, previousLocationInWindow);
        ORK_DECODE_CGPOINT(aDecoder, preciseLocationInWindow);
        ORK_DECODE_CGPOINT(aDecoder, precisePreviousLocationInWindow);
        ORK_DECODE_DOUBLE(aDecoder, force);
        ORK_DECODE_DOUBLE(aDecoder, maximumPossibleForce);
        ORK_DECODE_DOUBLE(aDecoder, azimuthAngleInWindow);
        
        self.azimuthUnitVectorInWindow = [aDecoder decodeCGVectorForKey:@ORK_STRINGIFY(azimuthUnitVectorInWindow)];
        
        ORK_DECODE_DOUBLE(aDecoder, altitudeAngle);
        ORK_DECODE_OBJ(aDecoder, estimationUpdateIndex);
        ORK_DECODE_INTEGER(aDecoder, estimatedProperties);
        ORK_DECODE_INTEGER(aDecoder, estimatedPropertiesExpectingUpdates);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityTouch *touch = [[[self class] allocWithZone:zone] init];
    touch.timestamp = self.timestamp;
    touch.phase = self.phase;
    touch.tapCount = self.tapCount;
    touch.type = self.type;
    touch.majorRadius = self.majorRadius;
    touch.majorRadiusTolerance = self.majorRadiusTolerance;
    touch.locationInWindow = self.locationInWindow;
    touch.previousLocationInWindow = self.previousLocationInWindow;
    touch.preciseLocationInWindow = self.preciseLocationInWindow;
    touch.precisePreviousLocationInWindow = self.precisePreviousLocationInWindow;
    touch.force = self.force;
    touch.maximumPossibleForce = self.maximumPossibleForce;
    touch.azimuthAngleInWindow = self.azimuthAngleInWindow;
    touch.azimuthUnitVectorInWindow = self.azimuthUnitVectorInWindow;
    touch.altitudeAngle = self.altitudeAngle;
    touch.estimationUpdateIndex = [self.estimationUpdateIndex copy];
    touch.estimatedProperties = self.estimatedProperties;
    touch.estimatedPropertiesExpectingUpdates = self.estimatedPropertiesExpectingUpdates;
    return touch;
}

- (instancetype)initWithUITouch:(UITouch *)touch {
    self = [super init];
    if (self) {
        self.timestamp = touch.timestamp + [NSDate dateWithTimeIntervalSinceNow:-[[NSProcessInfo processInfo] systemUptime]].timeIntervalSince1970;
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

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.timestamp == castObject.timestamp) &&
            (self.phase == castObject.phase) &&
            (self.tapCount == castObject.tapCount) &&
            (self.type == castObject.type) &&
            (self.majorRadius == castObject.majorRadius) &&
            (self.majorRadiusTolerance == castObject.majorRadius) &&
            CGPointEqualToPoint(self.locationInWindow, castObject.locationInWindow) &&
            CGPointEqualToPoint(self.previousLocationInWindow, castObject.previousLocationInWindow) &&
            CGPointEqualToPoint(self.preciseLocationInWindow, castObject.preciseLocationInWindow) &&
            CGPointEqualToPoint(self.precisePreviousLocationInWindow, castObject.precisePreviousLocationInWindow) &
            (self.force == castObject.force) &&
            (self.maximumPossibleForce == castObject.maximumPossibleForce) &&
            (self.azimuthAngleInWindow == castObject.azimuthAngleInWindow) &&
            (self.azimuthUnitVectorInWindow.dx == castObject.azimuthUnitVectorInWindow.dx) &&
            (self.azimuthUnitVectorInWindow.dy == castObject.azimuthUnitVectorInWindow.dy) &&
            (self.altitudeAngle == castObject.altitudeAngle) &&
            ORKEqualObjects(self.estimationUpdateIndex, castObject.estimationUpdateIndex) &&
            (self.estimatedProperties == castObject.estimatedProperties) &&
            (self.estimatedPropertiesExpectingUpdates == castObject.estimatedPropertiesExpectingUpdates));
}

- (NSString *)description {
    NSString *phaseString;
    switch (self.phase) {
        case UITouchPhaseBegan:
            phaseString = @"began";
            break;
        case UITouchPhaseMoved:
            phaseString = @"moved";
            break;
        case UITouchPhaseEnded:
            phaseString = @"ended";
            break;
        case UITouchPhaseCancelled:
            phaseString = @"cancelled";
            break;
        case UITouchPhaseStationary:
            phaseString = @"stationary";
            break;
#if defined(__IPHONE_13_4)
        case UITouchPhaseRegionEntered:
            phaseString = @"entered";
            break;
        case UITouchPhaseRegionMoved:
            phaseString = @"moved";
            break;
        case UITouchPhaseRegionExited:
            phaseString = @"exited";
            break;
#endif
    }
    
    return [NSString stringWithFormat:@"<%@: %p; phase: %@; timestamp: %.6f; location: (%@, %@)>", self.class.description, self, phaseString, self.timestamp, @(self.locationInWindow.x), @(self.locationInWindow.y)];
}

@end
