/*
 Copyright (c) 2015, James Cox. All rights reserved.
 
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


#import "ORKReactionTimeStimulusView.h"


@implementation ORKReactionTimeStimulusView {
    CAShapeLayer *_tickLayer;
    CAShapeLayer *_crossLayer;
}

static const CGFloat RoundReactionTimeViewDiameter = 122;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.cornerRadius = RoundReactionTimeViewDiameter * 0.5;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(RoundReactionTimeViewDiameter, RoundReactionTimeViewDiameter);
}

- (void)reset {
    [_tickLayer removeFromSuperlayer];
    [_crossLayer removeFromSuperlayer];
    _tickLayer = nil;
    _crossLayer = nil;
    self.layer.backgroundColor = self.tintColor.CGColor;
}

- (void)startSuccessAnimationWithDuration:(NSTimeInterval)duration completion:(void(^)(void))completion {
    if (self.hidden) {
        if (completion) {
            completion();
        }
        return;
    }
    
    [self addTickLayer];
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.180739998817444 :0 :0.577960014343262 :0.918200016021729];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setTimingFunction:timing];
    animation.removedOnCompletion = NO;
    [animation setFillMode:kCAFillModeForwards];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.duration = duration;
    [_tickLayer addAnimation:animation forKey:@"strokeEnd"];
    [CATransaction commit];
}

- (void)startFailureAnimationWithDuration:(NSTimeInterval)duration completion:(void(^)(void))completion {
    self.hidden = NO;

    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    [self addCrossLayer];
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setFillMode:kCAFillModeForwards];
    animation.fromValue = @([(CAShapeLayer *)[_crossLayer presentationLayer] strokeEnd]);
    animation.toValue = @(1);
    animation.duration = duration;
    _crossLayer.strokeEnd = 1;
    [_crossLayer addAnimation:animation forKey:@"strokeEnd"];
    [CATransaction commit];
}

- (void)setHidden:(BOOL)hidden {
    [self reset];
    [super setHidden:hidden];
}

- (void)addCrossLayer {
    _crossLayer = [self lineDrawingLayer];
    _crossLayer.strokeColor = [UIColor redColor].CGColor;
    _crossLayer.path = [self crossPath];
    [self.layer addSublayer:_crossLayer];
}

- (void)addTickLayer {
    _tickLayer = [self lineDrawingLayer];
    _tickLayer.strokeColor = [UIColor whiteColor].CGColor;
    _tickLayer.path = [self tickPath];
    [self.layer addSublayer:_tickLayer];
}

- (CGPathRef)concealPath:(CGFloat)radius {
    return [[UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                           radius:radius / 2
                                       startAngle:M_PI + M_PI_2
                                         endAngle:-M_PI_2
                                        clockwise:NO] CGPath];
}

- (CGPathRef)tickPath {
    UIBezierPath *path = [self linePath];
    [path moveToPoint:(CGPoint){37,65}];
    [path addLineToPoint:(CGPoint){50,78}];
    [path addLineToPoint:(CGPoint){87,42}];
    return path.CGPath;
}

- (CGPathRef)crossPath {
    UIBezierPath *path = [self linePath];
    [path moveToPoint:(CGPoint){45,78}];
    [path addLineToPoint:(CGPoint){82,42}];
    [path moveToPoint:(CGPoint){45,42}];
    [path addLineToPoint:(CGPoint){82,78}];
    return path.CGPath;
}

- (UIBezierPath *)linePath {
    UIBezierPath *path = [UIBezierPath new];
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = 5;
    return path;
}

- (CAShapeLayer *)lineDrawingLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.strokeEnd = 0;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.frame = self.layer.bounds;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.fillColor = nil;
    return shapeLayer;
}

@end
