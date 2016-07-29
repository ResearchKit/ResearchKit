/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKHolePegTestPlaceContentView.h"
#import "ORKHolePegTestPlacePegView.h"
#import "ORKHolePegTestPlaceHoleView.h"
#import "ORKDirectionView.h"
#import "ORKHelpers.h"
#import "ORKSkin.h"


static const CGFloat ORKOrientationThreshold = 12.0f;
static const CGFloat ORKHolePegViewDiameter = 88.0f;
#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)


@interface ORKHolePegTestPlaceContentView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKHolePegTestPlacePegView *pegView;
@property (nonatomic, strong) ORKHolePegTestPlaceHoleView *holeView;
@property (nonatomic, strong) ORKDirectionView *directionView;
@property (nonatomic, copy) NSArray *constraints;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, assign, getter = isMovable) BOOL movable;
@property (nonatomic, assign, getter = hasMoveEnded) BOOL moveEnded;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat rotationOffset;
@property (nonatomic, assign) CGPoint translation;
@property (nonatomic, assign) CGPoint translationOffset;
@property (nonatomic, assign) CGPoint startPoint;

@end


@implementation ORKHolePegTestPlaceContentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithFrame:(CGRect)frame {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithMovingDirection:(ORKBodySagittal)movingDirection rotated:(BOOL)rotated {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.movingDirection = movingDirection;
        self.rotated = rotated;

        self.progressView = [UIProgressView new];
        self.progressView.progressTintColor = self.tintColor;
        [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.progressView setAlpha:0];
        [self addSubview:self.progressView];
        
        self.holeView = [[ORKHolePegTestPlaceHoleView alloc] initWithFrame:CGRectMake(0, 0, ORKHolePegViewDiameter, ORKHolePegViewDiameter)];
        self.holeView.rotated = self.isRotated;
        [self.holeView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.holeView];
        
        self.pegView = [[ORKHolePegTestPlacePegView alloc] initWithFrame:CGRectMake(0, 0, ORKHolePegViewDiameter, ORKHolePegViewDiameter)];
        self.pegView.rotated = self.isRotated;
        [self.pegView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.pegView];
        
        self.directionView = [[ORKDirectionView alloc] initWithOrientation:(self.movingDirection == ORKBodySagittalLeft) ? ORKBodySagittalRight : ORKBodySagittalLeft];
        [self.directionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.directionView];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setNeedsUpdateConstraints];
        
        self.movable = NO;
        self.moveEnded = NO;
        self.startPoint = CGPointZero;
        
        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handlePinch:)];
        self.pinchRecognizer.delegate = self;
        [self addGestureRecognizer:self.pinchRecognizer];
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(handlePan:)];
        self.panRecognizer.delegate = self;
        [self addGestureRecognizer:self.panRecognizer];
        
        if (rotated) {
            self.rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleRotate:)];
            self.rotationRecognizer.delegate = self;
            [self addGestureRecognizer:self.rotationRecognizer];
        }
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressView.progressTintColor = self.tintColor;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
}

- (void)updateLayoutMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin * 2, .right = margin * 2};
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateLayoutMargins];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateLayoutMargins];
}

- (void)updateConstraints {
    if ([self.constraints count]) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
        self.constraints = nil;
    }

    NSMutableArray *constraintsArray = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _pegView, _holeView, _directionView);
    NSDictionary *metrics = @{@"diameter": @(ORKHolePegViewDiameter)};
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressView]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:(self.movingDirection == ORKBodySagittalLeft) ? @"H:|-[_pegView]->=0-[_holeView]-|" : @"H:|-[_holeView]->=0-[_pegView]-|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_progressView]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_pegView(diameter)]->=0-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:metrics views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_holeView]->=0-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];

    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.pegView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.directionView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.directionView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]];
    
    self.constraints = constraintsArray;
    [self addConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:self.constraints];
    [super updateConstraints];
}

#pragma mark - gesture recognizer methods

- (void)pickupPegWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touch = [gestureRecognizer locationInView:self];
    CGPoint touch1 = [gestureRecognizer locationOfTouch:0 inView:self];
    CGPoint touch2 = [gestureRecognizer locationOfTouch:1 inView:self];
    double distance = hypot(touch1.x - touch2.x, touch1.y - touch2.y);
    
    if (distance < 3 * CGRectGetWidth(self.pegView.frame) &&
        CGRectContainsPoint(self.pegView.frame, touch)) {
        self.movable = YES;
    } else {
        self.movable = NO;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if ([pinchGestureRecognizer numberOfTouches] == 2) {
        [self pickupPegWithGestureRecognizer:pinchGestureRecognizer];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    if ([panGestureRecognizer numberOfTouches] != 2 ||
        panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
        panGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        panGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self resetTransformAtPoint:[panGestureRecognizer locationInView:self]];
    } else {
        if (self.isMovable) {
            self.translation = CGPointMake([panGestureRecognizer translationInView:self].x - self.translationOffset.x,
                                           [panGestureRecognizer translationInView:self].y - self.translationOffset.y);
            [self updateTransformAtPoint:[panGestureRecognizer locationInView:self]];
        } else {
            self.translationOffset = CGPointMake([panGestureRecognizer translationInView:self].x - self.translation.x,
                                                 [panGestureRecognizer translationInView:self].y - self.translation.y);
            if (CGPointEqualToPoint(self.startPoint, CGPointZero)) {
                [self pickupPegWithGestureRecognizer:panGestureRecognizer];
            }
        }
    }
}

- (void)handleRotate:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    if ([rotationGestureRecognizer numberOfTouches] != 2 ||
        rotationGestureRecognizer.state == UIGestureRecognizerStateEnded ||
        rotationGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        rotationGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self resetTransformAtPoint:[rotationGestureRecognizer locationInView:self]];
    } else {
        if (self.isMovable) {
            self.rotation = rotationGestureRecognizer.rotation - self.rotationOffset;
            [self updateTransformAtPoint:[rotationGestureRecognizer locationInView:self]];
        } else {
            self.rotationOffset = rotationGestureRecognizer.rotation - self.rotation;
        }
    }
}

- (void)updateTransformAtPoint:(CGPoint)point {
    self.pegView.transform = CGAffineTransformMakeTranslation(self.translation.x, self.translation.y);
    self.pegView.transform = CGAffineTransformRotate(self.pegView.transform, self.rotation);
    [self pegViewDidMoveAtPoint:point];
}

- (void)resetTransformAtPoint:(CGPoint)point {
    if (!self.hasMoveEnded) {
        self.movable = NO;
        self.moveEnded = YES;

        self.pinchRecognizer.enabled = NO;
        self.panRecognizer.enabled = NO;
        self.rotationRecognizer.enabled = NO;

        BOOL animated = ![self pegViewMoveDidEndAtPoint:point];
        self.pegView.hidden = !animated;

        [UIView animateWithDuration:animated ? 0.15f : 0.0f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             self.pegView.transform = CGAffineTransformIdentity;
                             self.pegView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             self.rotation = 0.0f;
                             self.rotationOffset = 0.0f;
                             self.translation = CGPointZero;
                             self.translationOffset = CGPointZero;
                             self.pinchRecognizer.enabled = YES;
                             self.panRecognizer.enabled = YES;
                             self.rotationRecognizer.enabled = YES;
                             self.moveEnded = NO;
                             self.pegView.hidden = NO;
                         }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - peg view delegate

- (void)pegViewDidMoveAtPoint:(CGPoint)point {
    self.directionView.hidden = YES;
    
    if (CGPointEqualToPoint(self.startPoint, CGPointZero)) {
        self.startPoint = point;
    }
    
    if ([self.delegate respondsToSelector:@selector(holePegTestPlaceDidProgress:)]) {
        [self.delegate holePegTestPlaceDidProgress:self];
    }
    
    if (self.holeView.isSuccess) {
        self.holeView.success = NO;
    }
    
    if ([self holeViewContainsPegView]) {
        self.pegView.alpha = 1.0f;
    } else {
        self.pegView.alpha = 0.2f;
    }
}

- (BOOL)pegViewMoveDidEndAtPoint:(CGPoint)point {
    self.directionView.hidden = NO;
    
    BOOL succeeded = NO;
    if ([self holeViewContainsPegView]) {
        if ([self.delegate respondsToSelector:@selector(holePegTestPlaceDidSucceed:withDistance:)]) {
            CGFloat distance = hypotf(point.x - self.startPoint.x, point.y - self.startPoint.y);
            [self.delegate holePegTestPlaceDidSucceed:self withDistance:distance];
        }
        self.holeView.success = YES;
        succeeded = YES;
    } else {
        if ([self.delegate respondsToSelector:@selector(holePegTestPlaceDidFail:)]) {
            [self.delegate holePegTestPlaceDidFail:self];
        }
        self.holeView.success = NO;
    }
    self.startPoint = CGPointZero;
    return succeeded;
}

- (BOOL)holeViewContainsPegView {
    CGRect detectionFrame = CGRectMake(CGRectGetMidX(self.holeView.frame) - (self.threshold * CGRectGetWidth(self.holeView.frame) / 2),
                                       CGRectGetMidY(self.holeView.frame) - (self.threshold * CGRectGetHeight(self.holeView.frame) / 2),
                                       self.threshold * CGRectGetWidth(self.holeView.frame),
                                       self.threshold * CGRectGetHeight(self.holeView.frame));
    
    CGPoint pegCenter = CGPointMake(CGRectGetMaxX(self.pegView.frame) - CGRectGetWidth(self.pegView.frame) / 2,
                                    CGRectGetMaxY(self.pegView.frame) - CGRectGetHeight(self.pegView.frame) / 2);
    
    if (CGRectContainsPoint(detectionFrame, pegCenter)) {
        if (self.isRotated) {
            double rotation = atan2(self.pegView.transform.b, self.pegView.transform.a);
            double angle = fmod(fabs(rotation), M_PI_2);
            if (angle > M_PI_4 - degreesToRadians(ORKOrientationThreshold) &&
                angle < M_PI_4 + degreesToRadians(ORKOrientationThreshold)) {
                return YES;
            }
        } else {
            return YES;
        }
    }
    
    return NO;
}

@end
