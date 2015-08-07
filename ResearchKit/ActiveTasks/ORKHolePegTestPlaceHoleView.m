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


#import "ORKHolePegTestPlaceHoleView.h"


static const UIEdgeInsets ORKPlaceHoleViewMargins = (UIEdgeInsets){22, 22, 22, 22};
static const CGFloat ORKPlaceHoleViewDiameter = 148.0f;


@interface ORKHolePegTestPlaceHoleView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end


@implementation ORKHolePegTestPlaceHoleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIBezierPath *path = [[UIBezierPath alloc] init];
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
        self.shapeLayer = shapeLayer;
        
        self.opaque = NO;
        self.success = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(ORKPlaceHoleViewDiameter, ORKPlaceHoleViewDiameter);
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
    
    CGRect bounds = CGRectInset([self bounds], ORKPlaceHoleViewMargins.left, ORKPlaceHoleViewMargins.top);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    [self.tintColor setFill];
    [path fill];

    if (self.isSuccess) {
        [self.layer addSublayer:self.shapeLayer];
        
        CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.180739998817444
                                                                                            :0
                                                                                            :0.577960014343262
                                                                                            :0.918200016021729];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [animation setTimingFunction:timing];
        [animation setFillMode:kCAFillModeBoth];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.delegate = self;
        [self.shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    } else {
        bounds = [self bounds];
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

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    [self.shapeLayer removeFromSuperlayer];
    self.success = NO;
}

@end
