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
#import "ORKTouchAbilityTrack.h"
#import "ORKTouchAbilityGestureRecoginzerEvent.h"

#import "ORKHelpers_Internal.h"

#pragma mark - ORKTouchAbilityTrial

@implementation ORKTouchAbilityTrial

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, startTime);
    ORK_ENCODE_DOUBLE(aCoder, endTime);
    ORK_ENCODE_BOOL(aCoder, success);
    ORK_ENCODE_OBJ(aCoder, tracks);
    ORK_ENCODE_OBJ(aCoder, gestureRecognizerEvents);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, startTime);
        ORK_DECODE_DOUBLE(aDecoder, endTime);
        ORK_DECODE_BOOL(aDecoder, success);
        ORK_DECODE_OBJ(aDecoder, tracks);
        ORK_DECODE_OBJ(aDecoder, gestureRecognizerEvents);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityTrial *trial = [[[self class] allocWithZone:zone] init];
    trial.startTime = self.startTime;
    trial.endTime = self.endTime;
    trial.success = self.success;
    trial.tracks = [self.tracks mutableCopy];
    trial.gestureRecognizerEvents = [self.gestureRecognizerEvents mutableCopy];
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
            ORKEqualObjects(self.tracks, castObject.tracks) &&
            ORKEqualObjects(self.gestureRecognizerEvents, castObject.gestureRecognizerEvents));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startTime = [NSDate distantPast].timeIntervalSince1970;
        self.endTime = [NSDate distantFuture].timeIntervalSince1970;
        self.success = NO;
    }
    return self;
}

- (NSMutableArray<ORKTouchAbilityTrack *> *)tracks {
    if (!_tracks) {
        _tracks = [NSMutableArray new];
    }
    return _tracks;
}

- (NSArray<ORKTouchAbilityTapGestureRecoginzerEvent *> *)tapEvents {
    NSMutableArray *result = [NSMutableArray new];
    
    [self.gestureRecognizerEvents enumerateObjectsUsingBlock:^(ORKTouchAbilityGestureRecoginzerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ORKTouchAbilityTapGestureRecoginzerEvent class]]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray<ORKTouchAbilityLongPressGestureRecoginzerEvent *> *)longPressEvents {
    NSMutableArray *result = [NSMutableArray new];
    
    [self.gestureRecognizerEvents enumerateObjectsUsingBlock:^(ORKTouchAbilityGestureRecoginzerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ORKTouchAbilityLongPressGestureRecoginzerEvent class]]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray<ORKTouchAbilitySwipeGestureRecoginzerEvent *> *)swipeEvents {
    NSMutableArray *result = [NSMutableArray new];
    
    [self.gestureRecognizerEvents enumerateObjectsUsingBlock:^(ORKTouchAbilityGestureRecoginzerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ORKTouchAbilitySwipeGestureRecoginzerEvent class]]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray<ORKTouchAbilityPanGestureRecoginzerEvent *> *)panEvents {
    NSMutableArray *result = [NSMutableArray new];
    
    [self.gestureRecognizerEvents enumerateObjectsUsingBlock:^(ORKTouchAbilityGestureRecoginzerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ORKTouchAbilitySwipeGestureRecoginzerEvent class]]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray<ORKTouchAbilityPinchGestureRecoginzerEvent *> *)pinchEvents {
    NSMutableArray *result = [NSMutableArray new];
    
    [self.gestureRecognizerEvents enumerateObjectsUsingBlock:^(ORKTouchAbilityGestureRecoginzerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ORKTouchAbilityPinchGestureRecoginzerEvent class]]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray<ORKTouchAbilityRotationGestureRecoginzerEvent *> *)rotationEvents {
    NSMutableArray *result = [NSMutableArray new];
    
    [self.gestureRecognizerEvents enumerateObjectsUsingBlock:^(ORKTouchAbilityGestureRecoginzerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ORKTouchAbilityRotationGestureRecoginzerEvent class]]) {
            [result addObject:obj];
        }
    }];
    
    return [result copy];
}

- (NSArray<ORKTouchAbilityGestureRecoginzerEvent *> *)gestureRecoginzerEvents {
    if (!_gestureRecognizerEvents) {
        _gestureRecognizerEvents = [NSMutableArray new];
    }
    return _gestureRecognizerEvents;
}

- (void)setGestureRecoginzerEvents:(NSMutableArray<ORKTouchAbilityGestureRecoginzerEvent *> *)gestureRecoginzerEvents {
    _gestureRecognizerEvents = [gestureRecoginzerEvents mutableCopy];
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
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
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
