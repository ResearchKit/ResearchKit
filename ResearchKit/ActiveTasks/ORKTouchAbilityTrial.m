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


#import "ORKTouchAbilityTrial.h"
#import "ORKTouchAbilityTrial_Internal.h"
#import "ORKTouchAbilityTrack.h"
#import "ORKTouchAbilityGestureRecoginzerEvent.h"

#import "ORKHelpers_Internal.h"

#pragma mark - ORKTouchAbilityTrial

@interface ORKTouchAbilityTrial ()

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilityTrack *> *mutableTracks;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilityTapGestureRecoginzerEvent *> *mutableTapEvents;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilityLongPressGestureRecoginzerEvent *> *mutableLongPressEvents;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilitySwipeGestureRecoginzerEvent *> *mutableSwipeEvents;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilityPanGestureRecoginzerEvent *> *mutablePanEvents;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilityPinchGestureRecoginzerEvent *> *mutablePinchEvents;
@property (nonatomic, copy) NSMutableArray<ORKTouchAbilityRotationGestureRecoginzerEvent *> *mutableRotationEvents;

@end

@implementation ORKTouchAbilityTrial

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, startTime);
    ORK_ENCODE_DOUBLE(aCoder, endTime);
    ORK_ENCODE_BOOL(aCoder, success);
    ORK_ENCODE_OBJ(aCoder, mutableTracks);
    ORK_ENCODE_OBJ(aCoder, mutableTapEvents);
    ORK_ENCODE_OBJ(aCoder, mutableLongPressEvents);
    ORK_ENCODE_OBJ(aCoder, mutableSwipeEvents);
    ORK_ENCODE_OBJ(aCoder, mutablePanEvents);
    ORK_ENCODE_OBJ(aCoder, mutablePinchEvents);
    ORK_ENCODE_OBJ(aCoder, mutableRotationEvents);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, startTime);
        ORK_DECODE_DOUBLE(aDecoder, endTime);
        ORK_DECODE_BOOL(aDecoder, success);
        ORK_DECODE_OBJ(aDecoder, mutableTracks);
        ORK_DECODE_OBJ(aDecoder, mutableTapEvents);
        ORK_DECODE_OBJ(aDecoder, mutableLongPressEvents);
        ORK_DECODE_OBJ(aDecoder, mutableSwipeEvents);
        ORK_DECODE_OBJ(aDecoder, mutablePanEvents);
        ORK_DECODE_OBJ(aDecoder, mutablePinchEvents);
        ORK_DECODE_OBJ(aDecoder, mutableRotationEvents);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityTrial *trial = [[[self class] allocWithZone:zone] init];
    trial.startTime = self.startTime;
    trial.endTime = self.endTime;
    trial.success = self.success;
    trial.mutableTracks = [self.mutableTracks mutableCopy];
    trial.mutableTapEvents = [self.mutableTapEvents mutableCopy];
    trial.mutableLongPressEvents = [self.mutableLongPressEvents mutableCopy];
    trial.mutableSwipeEvents = [self.mutableSwipeEvents mutableCopy];
    trial.mutablePanEvents = [self.mutablePanEvents mutableCopy];
    trial.mutablePinchEvents = [self.mutablePinchEvents mutableCopy];
    trial.mutableRotationEvents = [self.mutableRotationEvents mutableCopy];
    return trial;
}

- (BOOL)isEqual:(id)object {
    
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.startTime == castObject.startTime) &&
            (self.endTime == castObject.endTime) &&
            (self.success == castObject.success) &&
            [self.mutableTracks isEqual:castObject.mutableTracks] &&
            [self.mutableTapEvents isEqual:castObject.mutableTapEvents] &&
            [self.mutableLongPressEvents isEqual:castObject.mutableLongPressEvents] &&
            [self.mutableSwipeEvents isEqual:castObject.mutableSwipeEvents] &&
            [self.mutablePanEvents isEqual:castObject.mutablePanEvents] &&
            [self.mutablePinchEvents isEqual:castObject.mutablePinchEvents] &&
            [self.mutableRotationEvents isEqual:castObject.mutableRotationEvents]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startTime = [NSDate distantPast].timeIntervalSince1970;
        self.endTime = [NSDate distantFuture].timeIntervalSince1970;
        self.success = NO;
        self.mutableTracks = [NSMutableArray new];
        self.mutableTapEvents = [NSMutableArray new];
        self.mutableLongPressEvents = [NSMutableArray new];
        self.mutableSwipeEvents = [NSMutableArray new];
        self.mutablePanEvents = [NSMutableArray new];
        self.mutablePinchEvents = [NSMutableArray new];
        self.mutableRotationEvents = [NSMutableArray new];
    }
    return self;
}

- (NSArray<ORKTouchAbilityTrack *> *)tracks {
    return [self.mutableTracks copy];
}

- (NSArray<ORKTouchAbilityTapGestureRecoginzerEvent *> *)tapEvents {
    return [self.mutableTapEvents copy];
}

- (NSArray<ORKTouchAbilityLongPressGestureRecoginzerEvent *> *)longPressEvents {
    return [self.mutableLongPressEvents copy];
}

- (NSArray<ORKTouchAbilitySwipeGestureRecoginzerEvent *> *)swipeEvents {
    return [self.mutableSwipeEvents copy];
}

- (NSArray<ORKTouchAbilityPanGestureRecoginzerEvent *> *)panEvents {
    return [self.mutablePanEvents copy];
}

- (NSArray<ORKTouchAbilityPinchGestureRecoginzerEvent *> *)pinchEvents {
    return [self.mutablePinchEvents copy];
}

- (NSArray<ORKTouchAbilityRotationGestureRecoginzerEvent *> *)rotationEvents {
    return [self.mutableRotationEvents copy];
}

- (NSArray<ORKTouchAbilityGestureRecoginzerEvent *> *)gestureRecoginzerEvents {
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    
    [events addObjectsFromArray:self.mutableTapEvents];
    [events addObjectsFromArray:self.mutableLongPressEvents];
    [events addObjectsFromArray:self.mutableSwipeEvents];
    [events addObjectsFromArray:self.mutablePanEvents];
    [events addObjectsFromArray:self.mutablePinchEvents];
    [events addObjectsFromArray:self.mutableRotationEvents];
    
    return [events copy];
}

- (void)addTrack:(ORKTouchAbilityTrack *)track {
    [self.mutableTracks addObject:track];
}

- (void)addGestureEvent:(ORKTouchAbilityGestureRecoginzerEvent *)gestureEvent {
    
    if ([gestureEvent isMemberOfClass:[ORKTouchAbilityTapGestureRecoginzerEvent class]]) {
        [self.mutableTapEvents addObject:(ORKTouchAbilityTapGestureRecoginzerEvent *)gestureEvent];
    }
    else if ([gestureEvent isMemberOfClass:[ORKTouchAbilityLongPressGestureRecoginzerEvent class]]) {
        [self.mutableLongPressEvents addObject:(ORKTouchAbilityLongPressGestureRecoginzerEvent *)gestureEvent];
    }
    else if ([gestureEvent isMemberOfClass:[ORKTouchAbilitySwipeGestureRecoginzerEvent class]]) {
        [self.mutableSwipeEvents addObject:(ORKTouchAbilitySwipeGestureRecoginzerEvent *)gestureEvent];
    }
    else if ([gestureEvent isMemberOfClass:[ORKTouchAbilityPanGestureRecoginzerEvent class]]) {
        [self.mutablePanEvents addObject:(ORKTouchAbilityPanGestureRecoginzerEvent *)gestureEvent];
    }
    else if ([gestureEvent isMemberOfClass:[ORKTouchAbilityPinchGestureRecoginzerEvent class]]) {
        [self.mutablePinchEvents addObject:(ORKTouchAbilityPinchGestureRecoginzerEvent *)gestureEvent];
    }
    else if ([gestureEvent isMemberOfClass:[ORKTouchAbilityRotationGestureRecoginzerEvent class]]) {
        [self.mutableRotationEvents addObject:(ORKTouchAbilityRotationGestureRecoginzerEvent *)gestureEvent];
    }
}

@end


#pragma mark - ORKTouchAbilityTapTrial

@interface ORKTouchAbilityTapTrial ()

@property (nonatomic, assign) CGRect targetFrameInWindow;

@end

@implementation ORKTouchAbilityTapTrial

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_CGRECT(aCoder, targetFrameInWindow);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_CGRECT(aDecoder, targetFrameInWindow);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityTapTrial *trial = [super copyWithZone:zone];
    trial.targetFrameInWindow = self.targetFrameInWindow;
    return trial;
}

- (BOOL)isEqual:(id)object {
    
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ([super isEqual:castObject] &&
            CGRectEqualToRect(self.targetFrameInWindow, castObject.targetFrameInWindow));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.targetFrameInWindow = CGRectZero;
    }
    return self;
}

- (instancetype)initWithTargetFrameInWindow:(CGRect)targetFrame {
    self = [super init];
    if (self) {
        self.targetFrameInWindow = targetFrame;
    }
    return self;
}

@end
