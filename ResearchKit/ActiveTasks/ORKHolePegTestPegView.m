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


#import "ORKHolePegTestPegView.h"


static const UIEdgeInsets kPegViewMargins = (UIEdgeInsets){22, 22, 22, 22};
static const CGFloat kPegViewRotation = 45.0f;


@interface ORKHolePegTestPegView ()

@property (nonatomic, assign) ORKHolePegType type;
@property (nonatomic, assign) CGFloat transformX;
@property (nonatomic, assign) CGFloat transformY;
@property (nonatomic, assign) CGFloat initialRotation;
@property (nonatomic, assign) CGFloat transformRotation;
@property (nonatomic, assign, getter=isMoving) BOOL moving;

@end


@implementation ORKHolePegTestPegView

#pragma mark - gesture recognizer methods

- (instancetype)initWithType:(ORKHolePegType)type
{
    self = [super init];
    if (self) {
        if (type == ORKHolePegTypeHole) {
            _type = ORKHolePegTypeHole;
            _initialRotation = 0.0f;
        } else {
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
            
            _type = ORKHolePegTypePeg;
            _initialRotation = kPegViewRotation * (M_PI / 180);
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.transform = CGAffineTransformMakeRotation(_initialRotation);
        self.moving = NO;
    }
    
    return self;
}

- (void)updateTransform
{
    self.transform = CGAffineTransformMakeTranslation(self.transformX, self.transformY);
    self.transform = CGAffineTransformRotate(self.transform, self.transformRotation + self.initialRotation);
    
    if ([self.delegate respondsToSelector:@selector(pegViewDidMove:)]) {
        [self.delegate pegViewDidMove:self];
    }
    
    if (!self.isMoving) {
        self.alpha = 0.2f;
        self.moving = YES;
    }
}

- (void)resetTransform {
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.transform = CGAffineTransformMakeRotation(self.initialRotation);
                         self.transformX = 0.0f;
                         self.transformY = 0.0f;
                         self.transformRotation = 0.0f;
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         self.moving = NO;
                     }];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.superview];
    self.transformX = translation.x;
    self.transformY = translation.y;
    [self updateTransform];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self resetTransform];
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
    self.transformRotation = gestureRecognizer.rotation;
    [self updateTransform];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self resetTransform];
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
    [self.tintColor setFill];
    
    CGRect verticalRect = CGRectMake(bounds.size.width * 7/16, bounds.size.height * 1/4,
                                     bounds.size.width * 1/8, bounds.size.height * 1/2);
    CGRect horizontalRect = CGRectMake(bounds.size.width * 1/4, bounds.size.height * 7/16,
                                       bounds.size.width * 1/2, bounds.size.height * 1/8);
    
    if (self.type == ORKHolePegTypeHole) {
        CGContextFillRect(context, verticalRect);
        CGContextFillRect(context, horizontalRect);
    } else {
        CGRect intersectionRect = CGRectIntersection(verticalRect, horizontalRect);
        CGContextAddRect(context, verticalRect);
        CGContextAddRect(context, horizontalRect);
        CGContextAddRect(context, intersectionRect);
        CGRect boundingRect = CGContextGetClipBoundingBox(context);
        CGContextAddRect(context, boundingRect);
        CGContextEOClip(context);
        
        bounds = CGRectInset([self bounds], kPegViewMargins.left, kPegViewMargins.top);
        UIBezierPath *pegPath = [UIBezierPath bezierPathWithOvalInRect:bounds];
        [pegPath fill];
    }
    
    CGContextRestoreGState(context);
}

@end
