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
