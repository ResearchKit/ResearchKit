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

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUp;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDown;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotation;

@end

@implementation ORKTouchAbilityCustomView


#pragma mark - Properties

- (ORKTouchAbilityTouchTracker *)touchTracker {
    if (!_touchTracker) {
        _touchTracker = [[ORKTouchAbilityTouchTracker alloc] init];
        _touchTracker.delaysTouchesBegan = NO;
        _touchTracker.delaysTouchesEnded = NO;
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewTap:)];
        tap.cancelsTouchesInView = NO;
        tap.delaysTouchesBegan = NO;
        tap.delaysTouchesEnded = NO;
        tap.delegate = self;
        tap.enabled = NO;
        self.tap = tap;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewLongPress:)];
        longPress.cancelsTouchesInView = NO;
        longPress.delaysTouchesBegan = NO;
        longPress.delaysTouchesEnded = NO;
        longPress.delegate = self;
        longPress.enabled = NO;
        self.longPress = longPress;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewPan:)];
        pan.cancelsTouchesInView = NO;
        pan.delaysTouchesBegan = NO;
        pan.delaysTouchesEnded = NO;
        pan.delegate = self;
        pan.enabled = NO;
        self.pan = pan;
        
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewSwipe:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        swipeUp.cancelsTouchesInView = NO;
        swipeUp.delaysTouchesBegan = NO;
        swipeUp.delaysTouchesEnded = NO;
        swipeUp.delegate = self;
        swipeUp.enabled = NO;
        self.swipeUp = swipeUp;
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewSwipe:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        swipeDown.cancelsTouchesInView = NO;
        swipeDown.delaysTouchesBegan = NO;
        swipeDown.delaysTouchesEnded = NO;
        swipeDown.delegate = self;
        swipeDown.enabled = NO;
        self.swipeDown = swipeDown;
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewSwipe:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        swipeLeft.cancelsTouchesInView = NO;
        swipeLeft.delaysTouchesBegan = NO;
        swipeLeft.delaysTouchesEnded = NO;
        swipeLeft.delegate = self;
        swipeLeft.enabled = NO;
        self.swipeLeft = swipeLeft;
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewSwipe:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        swipeRight.cancelsTouchesInView = NO;
        swipeRight.delaysTouchesBegan = NO;
        swipeRight.delaysTouchesEnded = NO;
        swipeRight.delegate = self;
        swipeRight.enabled = NO;
        self.swipeRight = swipeRight;
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewPinch:)];
        pinch.cancelsTouchesInView = NO;
        pinch.delaysTouchesBegan = NO;
        pinch.delaysTouchesEnded = NO;
        pinch.delegate = self;
        pinch.enabled = NO;
        self.pinch = pinch;
        
        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchAbilityCustomViewRotation:)];
        rotation.cancelsTouchesInView = NO;
        rotation.delaysTouchesBegan = NO;
        rotation.delaysTouchesEnded = NO;
        rotation.delegate = self;
        rotation.enabled = NO;
        self.rotation = rotation;
        
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
    self.tap.enabled        = YES;
    self.longPress.enabled  = YES;
    self.pan.enabled        = YES;
    self.swipeUp.enabled    = YES;
    self.swipeDown.enabled  = YES;
    self.swipeLeft.enabled  = YES;
    self.swipeRight.enabled = YES;
    self.pinch.enabled      = YES;
    self.rotation.enabled   = YES;
}

- (void)stopTracking {
    [self.touchTracker stopTracking];
    self.tap.enabled        = NO;
    self.longPress.enabled  = NO;
    self.pan.enabled        = NO;
    self.swipeUp.enabled    = NO;
    self.swipeDown.enabled  = NO;
    self.swipeLeft.enabled  = NO;
    self.swipeRight.enabled = NO;
    self.pinch.enabled      = NO;
    self.rotation.enabled   = NO;
}

- (void)resetTracks {
    [self.touchTracker resetTracks];
}

- (BOOL)isTracking {
    return self.touchTracker.isTracking;
}


#pragma mark - GestureRecognizer Handlers

- (void)handleTouchAbilityCustomViewTap:(UITapGestureRecognizer *)sender {
    ORKTouchAbilityTapGestureRecoginzerEvent *event = [[ORKTouchAbilityTapGestureRecoginzerEvent alloc] initWithTapGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleTouchAbilityCustomViewLongPress:(UILongPressGestureRecognizer *)sender {
    ORKTouchAbilityLongPressGestureRecoginzerEvent *event = [[ORKTouchAbilityLongPressGestureRecoginzerEvent alloc] initWithLongPressGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleTouchAbilityCustomViewPan:(UIPanGestureRecognizer *)sender {
    ORKTouchAbilityPanGestureRecoginzerEvent *event = [[ORKTouchAbilityPanGestureRecoginzerEvent alloc] initWithPanGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleTouchAbilityCustomViewSwipe:(UISwipeGestureRecognizer *)sender {
    ORKTouchAbilitySwipeGestureRecoginzerEvent *event = [[ORKTouchAbilitySwipeGestureRecoginzerEvent alloc] initWithSwipeGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleTouchAbilityCustomViewPinch:(UIPinchGestureRecognizer *)sender {
    ORKTouchAbilityPinchGestureRecoginzerEvent *event = [[ORKTouchAbilityPinchGestureRecoginzerEvent alloc] initWithPinchGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}

- (void)handleTouchAbilityCustomViewRotation:(UIRotationGestureRecognizer *)sender {
    ORKTouchAbilityRotationGestureRecoginzerEvent *event = [[ORKTouchAbilityRotationGestureRecoginzerEvent alloc] initWithRotationGestureRecognizer:sender];
    NSMutableArray *events = [self.gestureRecognizerEvents mutableCopy];
    [events addObject:event];
    self.gestureRecognizerEvents = [events copy];
}


#pragma mark - ORKTouchAbilityTouchTrackerDelegate

- (void)touchTrackerDidBeginNewTrack:(ORKTouchAbilityTouchTracker *)touchTracker {
    
    if (!self.isTracking) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(touchAbilityCustomViewDidBeginNewTrack:)]) {
        [self.delegate touchAbilityCustomViewDidBeginNewTrack:self];
    }
}

- (void)touchTrackerDidCompleteNewTracks:(ORKTouchAbilityTouchTracker *)touchTracker {
    
    if (!self.isTracking) {
        return;
    }
    
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
