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


static const CGFloat ORKPlaceHoleViewRotation = 45.0f;


@interface ORKHolePegTestPlaceHoleView ()

@property (nonatomic, strong) CAShapeLayer *checkLayer;
@property (nonatomic, strong) CAShapeLayer *crossLayer;

@end


@implementation ORKHolePegTestPlaceHoleView

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
        checkLayer.strokeColor = self.tintColor.CGColor;
        checkLayer.backgroundColor = [UIColor clearColor].CGColor;
        checkLayer.fillColor = nil;
        self.checkLayer = checkLayer;
        
        self.opaque = NO;
        self.success = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

#pragma mark - drawing method

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.checkLayer.strokeColor = self.tintColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setSuccess:(BOOL)success
{
    _success = success;
    [self.checkLayer removeFromSuperlayer];
    [self.crossLayer removeFromSuperlayer];
    [self setNeedsDisplay];
}

- (void)setRotated:(BOOL)rotated
{
    _rotated = rotated;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(bounds, 1.0f, 1.0f)];
    path.lineWidth = 2.0f;
    [self.tintColor setStroke];
    [path stroke];

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
        animation.duration = 0.3f;
        animation.delegate = self;
        [self.checkLayer addAnimation:animation forKey:@"strokeEnd"];
    } else if (self.isRotated) {
        UIBezierPath *crossPath = [[UIBezierPath alloc] init];
        [crossPath moveToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 1/4)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 7/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 1/4, CGRectGetHeight(bounds) * 7/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 1/4, CGRectGetHeight(bounds) * 9/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 9/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 3/4)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 3/4)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 9/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 3/4, CGRectGetHeight(bounds) * 9/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 3/4, CGRectGetHeight(bounds) * 7/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 7/16)];
        [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 1/4)];
        [crossPath closePath];
        
        CAShapeLayer *crossLayer = [[CAShapeLayer alloc] init];
        crossLayer.path = crossPath.CGPath;
        crossLayer.bounds = CGPathGetBoundingBox(crossLayer.path);
        crossLayer.anchorPoint = CGPointMake(0.5, 0.5);
        crossLayer.fillColor = self.tintColor.CGColor;
        
        CATransform3D transform = CATransform3DMakeTranslation(CGRectGetMidX(bounds), CGRectGetMidY(bounds), 1);
        transform = CATransform3DRotate(transform, ORKPlaceHoleViewRotation * (M_PI / 180), 0, 0, 1);
        crossLayer.transform = transform;
        
        self.crossLayer = crossLayer;
        
        [self.layer addSublayer:self.crossLayer];
    }
    
    CGContextRestoreGState(context);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        typeof(self) strongSelf = weakSelf;
        strongSelf.success = NO;
    });
}

@end
