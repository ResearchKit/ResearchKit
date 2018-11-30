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


#import "ORKTouchAbilityCustomView.h"

#import "ORKTouchAbilityTouchTracker.h"
#import "ORKTouchAbilityGestureRecoginzerEvent.h"


@interface ORKTouchAbilityCustomView () <ORKTouchAbilityTouchTrackerDelegate>

@property (nonatomic, strong) ORKTouchAbilityTouchTracker *touchTracker;
@property (nonatomic, readwrite) NSArray<ORKTouchAbilityGestureRecoginzerEvent *> *gestureRecognizerEvents;

@end

@implementation ORKTouchAbilityCustomView


#pragma mark - Properties

- (ORKTouchAbilityTouchTracker *)touchTracker {
    if (!_touchTracker) {
        _touchTracker = [[ORKTouchAbilityTouchTracker alloc] init];
        _touchTracker.delegate = self;
    }
    return _touchTracker;
}

- (NSArray<ORKTouchAbilityTrack *> *)tracks {
    return self.touchTracker.tracks;
}

- (NSArray<ORKTouchAbilityGestureRecoginzerEvent *> *)gestureRecognizerEvents {
    if (!_gestureRecognizerEvents) {
        _gestureRecognizerEvents = [NSArray new];
    }
    return _gestureRecognizerEvents;
}


#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        [self addGestureRecognizer:self.touchTracker];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.cancelsTouchesInView = NO;
        tap.delegate = self;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.cancelsTouchesInView = NO;
        longPress.delegate = self;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.cancelsTouchesInView = NO;
        pan.delegate = self;
        
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        swipeUp.cancelsTouchesInView = NO;
        swipeUp.delegate = self;
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        swipeDown.cancelsTouchesInView = NO;
        swipeDown.delegate = self;
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        swipeLeft.cancelsTouchesInView = NO;
        swipeLeft.delegate = self;
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        swipeRight.cancelsTouchesInView = NO;
        swipeRight.delegate = self;
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        pinch.cancelsTouchesInView = NO;
        pinch.delegate = self;
        
        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
        rotation.cancelsTouchesInView = NO;
        rotation.delegate = self;
        
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:longPress];
        [self addGestureRecognizer:pan];
        [self addGestureRecognizer:swipeUp];
        [self addGestureRecognizer:swipeDown];
        [self addGestureRecognizer:swipeLeft];
        [self addGestureRecognizer:swipeRight];
        [self addGestureRecognizer:pinch];
        [self addGestureRecognizer:rotation];
    }
    return self;
}


#pragma mark - ORKTouchAbilityCustomView

- (void)startTracking {
    [self.touchTracker startTracking];
}

- (void)stopTracking {
    [self.touchTracker stopTracking];
}

- (void)resetTracks {
    [self.touchTracker resetTracks];
}


#pragma mark - GestureRecognizer Handlers

- (void)handleTap:(UITapGestureRecognizer *)sender {
    ORKTouchAbilityTapGestureRecoginzerEvent *event = [[ORKTouchAbilityTapGestureRecoginzerEvent alloc] initWithTapGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    ORKTouchAbilityLongPressGestureRecoginzerEvent *event = [[ORKTouchAbilityLongPressGestureRecoginzerEvent alloc] initWithLongPressGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    ORKTouchAbilityPanGestureRecoginzerEvent *event = [[ORKTouchAbilityPanGestureRecoginzerEvent alloc] initWithPanGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender {
    ORKTouchAbilitySwipeGestureRecoginzerEvent *event = [[ORKTouchAbilitySwipeGestureRecoginzerEvent alloc] initWithSwipeGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
    ORKTouchAbilityPinchGestureRecoginzerEvent *event = [[ORKTouchAbilityPinchGestureRecoginzerEvent alloc] initWithPinchGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleRotation:(UIRotationGestureRecognizer *)sender {
    ORKTouchAbilityRotationGestureRecoginzerEvent *event = [[ORKTouchAbilityRotationGestureRecoginzerEvent alloc] initWithRotationGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}


#pragma mark - ORKTouchAbilityTouchTrackerDelegate

- (void)touchTrackerDidBeginNewTrack:(ORKTouchAbilityTouchTracker *)touchTracker {
    if ([self.delegate respondsToSelector:@selector(touchAbilityCustomViewDidBeginNewTrack:)]) {
        [self.delegate touchAbilityCustomViewDidBeginNewTrack:self];
    }
}

- (void)touchTrackerDidCompleteNewTracks:(ORKTouchAbilityTouchTracker *)touchTracker {
    if ([self.delegate respondsToSelector:@selector(touchAbilityCustomViewDidCompleteNewTracks:)]) {
        [self.delegate touchAbilityCustomViewDidCompleteNewTracks:self];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
