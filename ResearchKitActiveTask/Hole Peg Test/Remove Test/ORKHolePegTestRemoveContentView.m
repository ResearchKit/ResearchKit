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


#import "ORKHolePegTestRemoveContentView.h"

#import "ORKDirectionView.h"
#import "ORKHolePegTestRemovePegView.h"
#import "ORKSeparatorView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


static const CGFloat PegViewSeparatorWidth = 2.0f;


@interface ORKHolePegTestRemoveContentView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKHolePegTestRemovePegView *pegView;
@property (nonatomic, strong) ORKSeparatorView *separatorView;
@property (nonatomic, strong) ORKDirectionView *directionView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, copy) NSArray *constraints;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign, getter = isMovable) BOOL movable;
@property (nonatomic, assign, getter = hasMoveEnded) BOOL moveEnded;
@property (nonatomic, assign) CGPoint translation;
@property (nonatomic, assign) CGPoint translationOffset;
@property (nonatomic, assign) CGPoint startPoint;

@end


@implementation ORKHolePegTestRemoveContentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithFrame:(CGRect)frame {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithMovingDirection:(ORKBodySagittal)movingDirection {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.movingDirection = movingDirection;
        self.opaque = NO;
        
        self.container = [UIView new];
        self.container.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.progressView = [UIProgressView new];
        self.progressView.progressTintColor = self.tintColor;
        [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.progressView setAlpha:0];
        [self addSubview:self.progressView];
        
        self.pegView = [[ORKHolePegTestRemovePegView alloc] initWithFrame:CGRectMake(0, 0, ORKHolePegTestViewDiameter, ORKHolePegTestViewDiameter)];
        [self.pegView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.container addSubview:self.pegView];
        
        self.separatorView = [[ORKSeparatorView alloc] init];
        [self.separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.container addSubview:self.separatorView];
        
        self.directionView = [[ORKDirectionView alloc] initWithOrientation:(self.movingDirection == ORKBodySagittalLeft) ? ORKBodySagittalRight : ORKBodySagittalLeft];
        [self.directionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.directionView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:self.directionView];
        
        [self addSubview:self.container];
        
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

- (void)updateConstraints {
    if ([self.constraints count]) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
        self.constraints = nil;
    }

    NSMutableArray *constraintsArray = [NSMutableArray array];

    // Progress view - pinned to top, leading and trailing edges
    [constraintsArray addObject:[self.progressView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8]];
    [constraintsArray addObject:[self.progressView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8]];
    [constraintsArray addObject:[self.progressView.topAnchor constraintEqualToAnchor:self.topAnchor]];

    // Container view - fills width, below progress view to bottom
    [constraintsArray addObject:[self.container.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [constraintsArray addObject:[self.container.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    [constraintsArray addObject:[self.container.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor]];
    [constraintsArray addObject:[self.container.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]];

    // Position pegView on one side based on moving direction
    if (self.movingDirection == ORKBodySagittalLeft) {
        // Peg on left
        [constraintsArray addObject:[self.pegView.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor]];
    } else {
        // Peg on right
        [constraintsArray addObject:[self.pegView.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor]];
    }

    // Peg view size and vertical centering
    [constraintsArray addObject:[self.pegView.widthAnchor constraintEqualToConstant:ORKHolePegTestViewDiameter]];
    [constraintsArray addObject:[self.pegView.heightAnchor constraintEqualToConstant:ORKHolePegTestViewDiameter]];
    [constraintsArray addObject:[self.pegView.centerYAnchor constraintEqualToAnchor:self.container.centerYAnchor]];

    // Separator view - offset from the edge opposite to the peg by (1 + threshold) * ORKHolePegTestViewDiameter
    // This intentionally requires the user to drag the peg farther across the screen
    CGFloat separatorMargin = (1 + self.threshold) * ORKHolePegTestViewDiameter;
    if (self.movingDirection == ORKBodySagittalLeft) {
        // Peg on left, separator offset from right edge
        [constraintsArray addObject:[self.separatorView.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor constant:-separatorMargin]];
    } else {
        // Peg on right, separator offset from left edge
        [constraintsArray addObject:[self.separatorView.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor constant:separatorMargin]];
    }
    [constraintsArray addObject:[self.separatorView.widthAnchor constraintEqualToConstant:PegViewSeparatorWidth]];
    [constraintsArray addObject:[self.separatorView.topAnchor constraintEqualToAnchor:self.container.topAnchor constant:8]];
    [constraintsArray addObject:[self.separatorView.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor constant:-8]];

    // Direction view - positioned adjacent to the peg, vertically centered
    if (self.movingDirection == ORKBodySagittalLeft) {
        // Peg on left, arrows to the right of peg
        [constraintsArray addObject:[self.directionView.leadingAnchor constraintEqualToAnchor:self.pegView.trailingAnchor constant:8]];
    } else {
        // Peg on right, arrows to the left of peg
        [constraintsArray addObject:[self.directionView.trailingAnchor constraintEqualToAnchor:self.pegView.leadingAnchor constant:-8]];
    }
    [constraintsArray addObject:[self.directionView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];

    self.constraints = constraintsArray;
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

- (void)updateTransformAtPoint:(CGPoint)point {
    self.pegView.transform = CGAffineTransformMakeTranslation(self.translation.x, self.translation.y);
    [self pegViewDidMoveAtPoint:point];
}

- (void)resetTransformAtPoint:(CGPoint)point {
    if (!self.hasMoveEnded) {
        self.movable = NO;
        self.moveEnded = YES;
        
        self.pinchRecognizer.enabled = NO;
        self.panRecognizer.enabled = NO;
        
        BOOL animated = ![self pegViewMoveDidEndAtPoint:point];
        
        [UIView animateWithDuration:animated ? 0.15f : 0.0f
                              delay:animated ? 0.0f : 0.30f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             self.pegView.transform = CGAffineTransformIdentity;
                             self.pegView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             self.translation = CGPointZero;
                             self.translationOffset = CGPointZero;
                             self.pinchRecognizer.enabled = YES;
                             self.panRecognizer.enabled = YES;
                             self.moveEnded = NO;
                             self.pegView.hidden = NO;
                         }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [otherGestureRecognizer.view isDescendantOfView:self];
}

#pragma mark - peg view delegate

- (void)pegViewDidMoveAtPoint:(CGPoint)point {
    self.directionView.hidden = YES;
    
    if (CGPointEqualToPoint(self.startPoint, CGPointZero)) {
        self.startPoint = point;
    }
    
    if ([self.delegate respondsToSelector:@selector(holePegTestRemoveDidProgress:)]) {
        [self.delegate holePegTestRemoveDidProgress:self];
    }
    
    if (self.pegView.isSuccess) {
        self.pegView.success = NO;
    }
    
    if ([self pegViewBehindLine]) {
        self.pegView.alpha = 1.0f;
    } else {
        self.pegView.alpha = 0.2f;
    }
}

- (BOOL)pegViewMoveDidEndAtPoint:(CGPoint)point {
    self.directionView.hidden = NO;
    
    BOOL succeeded = NO;
    if ([self pegViewBehindLine]) {
        if ([self.delegate respondsToSelector:@selector(holePegTestRemoveDidSucceed:withDistance:)]) {
            CGFloat distance = hypotf(point.x - self.startPoint.x, point.y - self.startPoint.y);
            [self.delegate holePegTestRemoveDidSucceed:self withDistance:distance];
        }
        self.pegView.success = YES;
        succeeded = YES;
    } else {
        if ([self.delegate respondsToSelector:@selector(holePegTestRemoveDidFail:)]) {
            [self.delegate holePegTestRemoveDidFail:self];
        }
        self.pegView.success = NO;
    }
    self.startPoint = CGPointZero;
    return succeeded;
}

- (BOOL)pegViewBehindLine {
    if (self.movingDirection == ORKBodySagittalLeft) {
        if (CGRectGetMinX(self.pegView.frame) > CGRectGetMaxX(self.separatorView.frame)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (CGRectGetMaxX(self.pegView.frame) < CGRectGetMinX(self.separatorView.frame)) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
