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


#import "ORKTouchAbilityTouchTracker.h"
#import "ORKTouchAbilityTouch.h"
#import "ORKTouchAbilityTrack.h"
#import "ORKTouchAbilityTrack_Internal.h"


@interface ORKTouchAbilityTouchTracker ()
@property (nonatomic, assign, getter=hasBegun) BOOL begun;
@end



@implementation ORKTouchAbilityTouchTracker


#pragma mark - Properties

@dynamic delegate;

- (NSMutableArray<ORKTouchAbilityTrack *> *)tracks {
    if (!_tracks) {
        _tracks = [NSMutableArray new];
    }
    return _tracks;
}


#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        self.tracking = NO;
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        self.tracking = NO;
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; tracking: %@; tracks count: %@;>",
            self.class.description,
            self,
            self.isTracking ? @"true" : @"false",
            @(self.tracks.count)];
}


#pragma mark - ORKTouchAbilityTouchTracker

- (void)startTracking {
    [self resetTracks];
    self.tracking = YES;
}

- (void)stopTracking {
    self.begun = NO;
    self.tracking = NO;
}

- (void)resetTracks {
    self.begun = NO;
    [self.tracks removeAllObjects];
}


#pragma mark - UIGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.isTracking == NO) {
        return;
    }
    
    self.begun = YES;
    
    if ([self.delegate respondsToSelector:@selector(touchTrackerDidBeginNewTrack:)]) {
        [self.delegate touchTrackerDidBeginNewTrack:self];
    }
    
    for (UITouch *touch in touches) {
        
        ORKTouchAbilityTrack *track = [[ORKTouchAbilityTrack alloc] init];
        track.touches = [NSArray arrayWithObject:[[ORKTouchAbilityTouch alloc] initWithUITouch:touch]];
        
        [self.tracks addObject:track];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.isTracking == NO || self.hasBegun == NO) {
        return;
    }
    
    [self addTouchesToTracks:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.isTracking == NO || self.hasBegun == NO) {
        return;
    }
   
    [self addTouchesToTracks:touches withEvent:event];
    
    if (event.allTouches.count == touches.count) {
        if ([self.delegate respondsToSelector:@selector(touchTrackerDidCompleteNewTracks:)]) {
            [self.delegate touchTrackerDidCompleteNewTracks:self];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.isTracking == NO || self.hasBegun == NO) {
        return;
    }
    
    [self addTouchesToTracks:touches withEvent:event];
    
    if (event.allTouches.count == touches.count) {
        if ([self.delegate respondsToSelector:@selector(touchTrackerDidCompleteNewTracks:)]) {
            [self.delegate touchTrackerDidCompleteNewTracks:self];
        }
    }
}


#pragma mark - Private Methods

- (void)addTouchesToTracks:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        NSArray<UITouch *> *coalescedTouches = [event coalescedTouchesForTouch:touch] ?: [NSArray arrayWithObject:touch];
        NSMutableArray<ORKTouchAbilityTouch *> *translatedTouches = [NSMutableArray new];
        
        for (UITouch *coalescedTouch in coalescedTouches) {
            [translatedTouches addObject:[[ORKTouchAbilityTouch alloc] initWithUITouch:coalescedTouch]];
        }
        
        
        for (ORKTouchAbilityTrack *track in self.tracks) {
            
            if (track.touches.count == 0) {
                continue;
            }
            
            ORKTouchAbilityTouch *lastTouch = track.touches.lastObject;
            ORKTouchAbilityTouch *firstTranslatedTouch = translatedTouches.firstObject;
            
            if (lastTouch.phase != UITouchPhaseEnded &&
                CGPointEqualToPoint(lastTouch.locationInWindow, firstTranslatedTouch.previousLocationInWindow)) {
                
                NSMutableArray *trackTouches = [NSMutableArray arrayWithArray:track.touches];
                [trackTouches addObjectsFromArray:translatedTouches];
                track.touches = trackTouches;
            }
        }
    }
}

@end
