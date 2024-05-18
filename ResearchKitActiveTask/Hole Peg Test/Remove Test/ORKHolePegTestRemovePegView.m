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


#import "ORKHolePegTestRemovePegView.h"


@interface ORKHolePegTestRemovePegView ()

@property (nonatomic, strong) CAShapeLayer *checkLayer;

@end


@implementation ORKHolePegTestRemovePegView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(27.7f, 46.9f)];
        [path addLineToPoint:CGPointMake(36.1f, 56.3f)];
        [path addLineToPoint:CGPointMake(62.8f, 30.3f)];
        path.lineCapStyle = kCGLineCapRound;
        path.lineWidth = 3.6f;
        
        CAShapeLayer *checkLayer = [CAShapeLayer new];
        checkLayer.path = path.CGPath;
        checkLayer.lineWidth = 3.6f;
        checkLayer.lineCap = kCALineCapRound;
        checkLayer.lineJoin = kCALineJoinRound;
        checkLayer.frame = self.layer.bounds;
        checkLayer.strokeColor = [UIColor whiteColor].CGColor;
        checkLayer.backgroundColor = [UIColor clearColor].CGColor;
        checkLayer.fillColor = nil;
        self.checkLayer = checkLayer;
        
        self.opaque = NO;
        self.success = NO;
    }
    
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
}

#pragma mark - drawing method

- (void)setSuccess:(BOOL)success
{
    _success = success;
    [self.checkLayer removeFromSuperlayer];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    path.lineWidth = 2.0f;
    [self.tintColor setFill];
    [path fill];
    
    if (self.isSuccess) {
        [self.layer addSublayer:self.checkLayer];
        
        CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.180739998817444
                                                                                            :0
                                                                                            :0.577960014343262
                                                                                            :0.918200016021729];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [animation setTimingFunction:timing];
        [animation setFillMode:kCAFillModeBoth];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.duration = 0.25f;
        animation.delegate = self;
        [self.checkLayer addAnimation:animation forKey:@"strokeEnd"];
    }
    
    CGContextRestoreGState(context);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    self.success = NO;
}

@end
