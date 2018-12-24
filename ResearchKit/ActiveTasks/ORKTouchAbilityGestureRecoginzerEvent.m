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


#import "ORKTouchAbilityGestureRecoginzerEvent.h"
#import "ORKHelpers_Internal.h"

#pragma mark - ORKTouchAbilityGestureRecoginzerEvent

@interface ORKTouchAbilityGestureRecoginzerEvent ()

@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) UIGestureRecognizerState state;
@property (nonatomic, copy) NSArray<NSNumber *> *allowedTouchTypes;
@property (nonatomic, assign) CGPoint locationInWindow;
@property (nonatomic, assign) NSUInteger numberOfTouches;
@property (nonatomic, copy) NSDictionary<NSNumber *, NSValue *> *locationInWindowOfTouchAtIndex;

@end

@implementation ORKTouchAbilityGestureRecoginzerEvent

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_ENUM(aCoder, state);
    ORK_ENCODE_OBJ(aCoder, allowedTouchTypes);
    ORK_ENCODE_CGPOINT(aCoder, locationInWindow);
    ORK_ENCODE_INTEGER(aCoder, numberOfTouches);
    ORK_ENCODE_OBJ(aCoder, locationInWindowOfTouchAtIndex);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_ENUM(aDecoder, state);
        ORK_DECODE_OBJ(aDecoder, allowedTouchTypes);
        ORK_DECODE_CGPOINT(aDecoder, locationInWindow);
        ORK_DECODE_INTEGER(aDecoder, numberOfTouches);
        ORK_DECODE_OBJ(aDecoder, locationInWindowOfTouchAtIndex);
    }
    return self;
}

- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)recognizer {
    self = [super init];
    if (self) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
        self.state = recognizer.state;
        self.allowedTouchTypes = recognizer.allowedTouchTypes;
        self.locationInWindow = [recognizer locationInView:nil];
        self.numberOfTouches = recognizer.numberOfTouches;
        
        if (recognizer.numberOfTouches == 0) {
            self.locationInWindowOfTouchAtIndex = @{};
        } else {
            NSMutableDictionary *dict = @{}.mutableCopy;
            for (NSUInteger i = 0; i < recognizer.numberOfTouches; i++) {
                CGPoint location = [recognizer locationOfTouch:i inView:nil];
                dict[@(i)] = [NSValue valueWithCGPoint:location];
            }
            self.locationInWindowOfTouchAtIndex = [dict copy];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityGestureRecoginzerEvent *event = [[[self class] allocWithZone:zone] init];
    event.timestamp = self.timestamp;
    event.state = self.state;
    event.allowedTouchTypes = [self.allowedTouchTypes copy];
    event.locationInWindow = self.locationInWindow;
    event.numberOfTouches = self.numberOfTouches;
    event.locationInWindowOfTouchAtIndex = [self.locationInWindowOfTouchAtIndex copy];
    return event;
}

- (BOOL)isEqual:(id)object {
    
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.timestamp == castObject.timestamp) &&
            (self.state == castObject.state) &&
            ORKEqualObjects(self.allowedTouchTypes, castObject.allowedTouchTypes) &&
            CGPointEqualToPoint(self.locationInWindow, castObject.locationInWindow) &&
            self.numberOfTouches == castObject.numberOfTouches &&
            ORKEqualObjects(self.locationInWindowOfTouchAtIndex, castObject.locationInWindowOfTouchAtIndex));
}

- (NSArray<NSNumber *> *)allowedTouchTypes {
    if (!_allowedTouchTypes) {
        _allowedTouchTypes = @[];
    }
    return _allowedTouchTypes;
}

- (NSDictionary<NSNumber *,NSValue *> *)locationInWindowOfTouchAtIndex {
    if (!_locationInWindowOfTouchAtIndex) {
        _locationInWindowOfTouchAtIndex = @{};
    }
    return _locationInWindowOfTouchAtIndex;
}

- (NSString *)description {
    NSString *stateString;
    switch (self.state) {
        case UIGestureRecognizerStatePossible:  stateString = @"possible";  break;
        case UIGestureRecognizerStateBegan:     stateString = @"began";     break;
        case UIGestureRecognizerStateChanged:   stateString = @"changed";   break;
        case UIGestureRecognizerStateEnded:     stateString = @"ended";     break;
        case UIGestureRecognizerStateFailed:    stateString = @"failed";    break;
        case UIGestureRecognizerStateCancelled: stateString = @"cancelled"; break;
    }
    
    return [NSString stringWithFormat:@"<%@: %p; state: %@; numberOfTouches: %@; location: (%@, %@)>", self.class.description, self, stateString, @(self.numberOfTouches), @(self.locationInWindow.x), @(self.locationInWindow.y)];
}

@end


#pragma mark - ORKTouchAbilityTapGestureRecoginzerEvent

@interface ORKTouchAbilityTapGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;
@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;

@end

@implementation ORKTouchAbilityTapGestureRecoginzerEvent

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, numberOfTapsRequired);
    ORK_ENCODE_INTEGER(aCoder, numberOfTouchesRequired);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, numberOfTapsRequired);
        ORK_DECODE_INTEGER(aDecoder, numberOfTouchesRequired);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityTapGestureRecoginzerEvent *event = [super copyWithZone:zone];
    event.numberOfTapsRequired = self.numberOfTapsRequired;
    event.numberOfTouchesRequired = self.numberOfTouchesRequired;
    return event;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.numberOfTapsRequired == castObject.numberOfTapsRequired &&
            self.numberOfTouchesRequired == castObject.numberOfTouchesRequired);
}

- (instancetype)initWithTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.numberOfTapsRequired = recognizer.numberOfTapsRequired;
        self.numberOfTouchesRequired = recognizer.numberOfTouchesRequired;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityLongPressGestureRecoginzerEvent

@interface ORKTouchAbilityLongPressGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;
@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
@property (nonatomic, assign) CGFloat allowableMovement;

@end

@implementation ORKTouchAbilityLongPressGestureRecoginzerEvent

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, numberOfTapsRequired);
    ORK_ENCODE_INTEGER(aCoder, numberOfTouchesRequired);
    ORK_ENCODE_ENUM(aCoder, minimumPressDuration);
    ORK_ENCODE_DOUBLE(aCoder, allowableMovement);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, numberOfTapsRequired);
        ORK_DECODE_INTEGER(aDecoder, numberOfTouchesRequired);
        ORK_DECODE_ENUM(aDecoder, minimumPressDuration);
        ORK_DECODE_DOUBLE(aDecoder, allowableMovement);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityLongPressGestureRecoginzerEvent *event = [super copyWithZone:zone];
    event.numberOfTapsRequired = self.numberOfTapsRequired;
    event.numberOfTouchesRequired = self.numberOfTouchesRequired;
    event.minimumPressDuration = self.minimumPressDuration;
    event.allowableMovement = self.allowableMovement;
    return event;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.numberOfTapsRequired == castObject.numberOfTapsRequired &&
            self.numberOfTouchesRequired == castObject.numberOfTouchesRequired &&
            self.minimumPressDuration == castObject.minimumPressDuration &&
            self.allowableMovement == castObject.allowableMovement);
}


- (instancetype)initWithLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.numberOfTapsRequired = recognizer.numberOfTapsRequired;
        self.numberOfTouchesRequired = recognizer.numberOfTouchesRequired;
        self.minimumPressDuration = recognizer.minimumPressDuration;
        self.allowableMovement = recognizer.allowableMovement;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityPanGestureRecoginzerEvent

@interface ORKTouchAbilityPanGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger minimumNumberOfTouches;
@property (nonatomic, assign) NSUInteger maximumNumberOfTouches;
@property (nonatomic, assign) CGPoint velocityInWindow;

@end

@implementation ORKTouchAbilityPanGestureRecoginzerEvent

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, minimumNumberOfTouches);
    ORK_ENCODE_INTEGER(aCoder, maximumNumberOfTouches);
    ORK_ENCODE_CGPOINT(aCoder, velocityInWindow);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, minimumNumberOfTouches);
        ORK_DECODE_INTEGER(aDecoder, maximumNumberOfTouches);
        ORK_DECODE_CGPOINT(aDecoder, velocityInWindow);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityPanGestureRecoginzerEvent *event = [super copyWithZone:zone];
    event.minimumNumberOfTouches = self.minimumNumberOfTouches;
    event.maximumNumberOfTouches = self.maximumNumberOfTouches;
    event.velocityInWindow = self.velocityInWindow;
    return event;
}

- (BOOL)isEqual:(id)object {

    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.minimumNumberOfTouches == castObject.minimumNumberOfTouches &&
            self.maximumNumberOfTouches == castObject.maximumNumberOfTouches &&
            CGPointEqualToPoint(self.velocityInWindow, castObject.velocityInWindow));
}

- (instancetype)initWithPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.minimumNumberOfTouches = recognizer.minimumNumberOfTouches;
        self.maximumNumberOfTouches = recognizer.maximumNumberOfTouches;
        self.velocityInWindow = [recognizer velocityInView:nil];
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityPanGestureRecoginzerEvent

@interface ORKTouchAbilitySwipeGestureRecoginzerEvent ()

@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;
@property (nonatomic, assign) UISwipeGestureRecognizerDirection direction;

@end

@implementation ORKTouchAbilitySwipeGestureRecoginzerEvent

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, numberOfTouchesRequired);
    ORK_ENCODE_ENUM(aCoder, direction);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, numberOfTouchesRequired);
        ORK_DECODE_ENUM(aDecoder, direction);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilitySwipeGestureRecoginzerEvent *event = [super copyWithZone:zone];
    event.numberOfTouchesRequired = self.numberOfTouchesRequired;
    event.direction = self.direction;
    return event;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.numberOfTouchesRequired == castObject.numberOfTouchesRequired &&
            self.direction == castObject.direction);
}

- (instancetype)initWithSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.numberOfTouchesRequired = recognizer.numberOfTouchesRequired;
        self.direction = recognizer.direction;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilitySwipeGestureRecoginzerEvent

@interface ORKTouchAbilityPinchGestureRecoginzerEvent ()

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat velocity;

@end

@implementation ORKTouchAbilityPinchGestureRecoginzerEvent

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, scale);
    ORK_ENCODE_DOUBLE(aCoder, velocity);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, scale);
        ORK_DECODE_DOUBLE(aDecoder, velocity);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityPinchGestureRecoginzerEvent *event = [super copyWithZone:zone];
    event.scale = self.scale;
    event.velocity = self.velocity;
    return event;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.scale == castObject.scale &&
            self.velocity == castObject.velocity);
}

- (instancetype)initWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.scale = recognizer.scale;
        self.velocity = recognizer.velocity;
    }
    return self;
}

@end


#pragma mark - ORKTouchAbilityRotationGestureRecoginzerEvent

@interface ORKTouchAbilityRotationGestureRecoginzerEvent ()

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat velocity;

@end

@implementation ORKTouchAbilityRotationGestureRecoginzerEvent

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, rotation);
    ORK_ENCODE_DOUBLE(aCoder, velocity);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, rotation);
        ORK_DECODE_DOUBLE(aDecoder, velocity);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityRotationGestureRecoginzerEvent *event = [super copyWithZone:zone];
    event.rotation = self.rotation;
    event.velocity = self.velocity;
    return event;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.rotation == castObject.rotation &&
            self.velocity == castObject.velocity);
}

- (instancetype)initWithRotationGestureRecognizer:(UIRotationGestureRecognizer *)recognizer {
    self = [super initWithGestureRecognizer:recognizer];
    if (self) {
        self.rotation = recognizer.rotation;
        self.velocity = recognizer.velocity;
    }
    return self;
}

@end
