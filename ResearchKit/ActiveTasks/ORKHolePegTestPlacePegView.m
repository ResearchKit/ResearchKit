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


#import "ORKHolePegTestPlacePegView.h"


static const CGFloat ORKPlacePegViewDiameter = 148.0f;
static const CGFloat ORKPlacePegViewRotation = 45.0f;
static const CGFloat ORKMaximumTouchesDistance = 210.0f;


@interface ORKHolePegTestPlacePegView ()

@property (nonatomic, assign) CGFloat transformX;
@property (nonatomic, assign) CGFloat transformY;
@property (nonatomic, assign) CGFloat transformRotation;
@property (nonatomic, assign, getter = isMoving) BOOL moving;
@property (nonatomic, assign, getter = isMoveEnded) BOOL moveEnded;

@end


@implementation ORKHolePegTestPlacePegView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 2;
        panRecognizer.maximumNumberOfTouches = 2;
        panRecognizer.delegate = self;
        [self addGestureRecognizer:panRecognizer];
        
        UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                                       action:@selector(handleRotation:)];
        rotationRecognizer.delegate = self;
        [self addGestureRecognizer:rotationRecognizer];

        self.opaque = NO;
        self.moving = NO;
        self.moveEnded = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(ORKPlacePegViewDiameter, ORKPlacePegViewDiameter);
}

#pragma mark - gesture recognizer methods

- (void)updateTransform
{
    if (!self.isMoveEnded) {
        self.transform = CGAffineTransformMakeTranslation(self.transformX, self.transformY);
        self.transform = CGAffineTransformRotate(self.transform, self.transformRotation);
        
        if ([self.delegate respondsToSelector:@selector(pegViewDidMove:)]) {
            [self.delegate pegViewDidMove:self];
        }
        
        if (!self.isMoving) {
            self.alpha = 0.2f;
            self.moving = YES;
        }
    }
}

- (void)resetTransform {
    if (!self.isMoveEnded) {
        self.moving = NO;
        self.moveEnded = YES;
        
        __block BOOL animated = NO;
        
        if ([self.delegate respondsToSelector:@selector(pegViewMoveEnded:success:)]) {
            [self.delegate pegViewMoveEnded:self
                                    success:^(BOOL succeeded){
                                        animated = !succeeded;
                                        self.hidden = succeeded;
                                    }];
        }
        
        [UIView animateWithDuration:animated ? 0.15f : 0.0f
                              delay:animated ? 0.0f : 0.05f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             self.transform = CGAffineTransformIdentity;
                             self.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             self.transformX = 0.0f;
                             self.transformY = 0.0f;
                             self.transformRotation = 0.0f;
                             self.moveEnded = NO;
                             self.hidden = NO;
                         }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTouches != 2 ||
        gestureRecognizer.state == UIGestureRecognizerStateEnded ||
        gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self resetTransform];
    } else {
        CGPoint firstPoint = [gestureRecognizer locationOfTouch:0 inView:nil];
        CGPoint secondPoint = [gestureRecognizer locationOfTouch:1 inView:nil];
        double touchesDistance = hypot(firstPoint.x - secondPoint.x, firstPoint.y - secondPoint.y);
        
        if (touchesDistance > ORKMaximumTouchesDistance) {
            [self resetTransform];
        } else {
            CGPoint translation = [gestureRecognizer translationInView:self.superview];
            self.transformX = translation.x;
            self.transformY = translation.y;
            [self updateTransform];
        }
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTouches != 2 ||
        gestureRecognizer.state == UIGestureRecognizerStateEnded ||
        gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self resetTransform];
    } else {
        self.transformRotation = gestureRecognizer.rotation;
        [self updateTransform];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - drawing method

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = [self bounds];
    
    UIBezierPath *crossPath = [[UIBezierPath alloc] init];
    [crossPath moveToPoint:CGPointMake(bounds.size.width * 7/16, bounds.size.height * 1/4)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 7/16, bounds.size.height * 7/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 1/4, bounds.size.height * 7/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 1/4, bounds.size.height * 9/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 7/16, bounds.size.height * 9/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 7/16, bounds.size.height * 3/4)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 9/16, bounds.size.height * 3/4)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 9/16, bounds.size.height * 9/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 3/4, bounds.size.height * 9/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 3/4, bounds.size.height * 7/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 9/16, bounds.size.height * 7/16)];
    [crossPath addLineToPoint:CGPointMake(bounds.size.width * 9/16, bounds.size.height * 1/4)];
    [crossPath closePath];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = crossPath.CGPath;
    shapeLayer.bounds = CGPathGetBoundingBox(shapeLayer.path);
    shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    shapeLayer.fillColor = [self.tintColor CGColor];
    
    CATransform3D transform = CATransform3DMakeTranslation(ORKPlacePegViewDiameter/2, ORKPlacePegViewDiameter/2, 1);
    transform = CATransform3DRotate(transform, ORKPlacePegViewRotation * (M_PI / 180), 0, 0, 1);
    shapeLayer.transform = transform;
    
    [self.layer addSublayer:shapeLayer];
    
    CGContextRestoreGState(context);
}

@end
