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


#import "ORKHolePegTestHoleView.h"


static const UIEdgeInsets ORKHoleViewMargins = (UIEdgeInsets){22, 22, 22, 22};
static const CGFloat ORKHoleViewDiameter = 148.0f;

static UIBezierPath *ORKCheckBezierPath() {
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint:CGPointMake(23.2, 82.1)];
    [bezierPath addCurveToPoint:CGPointMake(22.2, 81.7) controlPoint1:CGPointMake(22.8, 82.1) controlPoint2:CGPointMake(22.4, 81.9)];
    [bezierPath addLineToPoint:CGPointMake(15, 75.1)];
    [bezierPath addCurveToPoint:CGPointMake(15, 72.9) controlPoint1:CGPointMake(14.4, 74.5) controlPoint2:CGPointMake(14.4, 73.5)];
    [bezierPath addCurveToPoint:CGPointMake(17.2, 72.9) controlPoint1:CGPointMake(15.6, 72.3) controlPoint2:CGPointMake(16.6, 72.3)];
    [bezierPath addLineToPoint:CGPointMake(23.2, 78.5)];
    [bezierPath addLineToPoint:CGPointMake(39.2, 62.5)];
    [bezierPath addCurveToPoint:CGPointMake(41.4, 62.5) controlPoint1:CGPointMake(39.8, 61.9) controlPoint2:CGPointMake(40.8, 61.9)];
    [bezierPath addCurveToPoint:CGPointMake(41.4, 64.7) controlPoint1:CGPointMake(42, 63.1) controlPoint2:CGPointMake(42, 64.1)];
    [bezierPath addLineToPoint:CGPointMake(24.4, 81.7)];
    [bezierPath addCurveToPoint:CGPointMake(23.2, 82.1) controlPoint1:CGPointMake(24, 81.9) controlPoint2:CGPointMake(23.6, 82.1)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    return bezierPath;
}


@implementation ORKHolePegTestHoleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.success = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(ORKHoleViewDiameter, ORKHoleViewDiameter);
}

- (void)setSuccess:(BOOL)success
{
    _success = success;
    [self setNeedsDisplay];
}

#pragma mark - drawing method

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = CGRectInset([self bounds], ORKHoleViewMargins.left, ORKHoleViewMargins.top);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    [self.tintColor setFill];
    [path fill];
    
    if (self.isSuccess) {
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(52.2f, 78.3f)];
        [path addLineToPoint:CGPointMake(63.8f, 89.4f)];
        [path addLineToPoint:CGPointMake(95.4f, 58.7f)];
        path.lineCapStyle = kCGLineCapRound;
        path.lineWidth = 5.0f;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 5;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.frame = self.layer.bounds;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = nil;
        [self.layer addSublayer:shapeLayer];
        
        CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.180739998817444
                                                                                            :0
                                                                                            :0.577960014343262
                                                                                            :0.918200016021729];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [animation setTimingFunction:timing];
        [animation setFillMode:kCAFillModeBoth];
        animation.fromValue = @([(CAShapeLayer *)[shapeLayer presentationLayer] strokeEnd]);
        [shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    } else {
        CGRect bounds = [self bounds];
        [[UIColor whiteColor] setFill];
        
        CGRect verticalRect = CGRectMake(bounds.size.width * 7/16, bounds.size.height * 1/4,
                                         bounds.size.width * 1/8, bounds.size.height * 1/2);
        CGRect horizontalRect = CGRectMake(bounds.size.width * 1/4, bounds.size.height * 7/16,
                                           bounds.size.width * 1/2, bounds.size.height * 1/8);
        
        CGContextFillRect(context, verticalRect);
        CGContextFillRect(context, horizontalRect);
    }
    
    CGContextRestoreGState(context);
}

@end
