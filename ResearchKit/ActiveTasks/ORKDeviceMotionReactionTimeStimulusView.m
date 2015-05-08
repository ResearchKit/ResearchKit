//
//  ORKDeviceMotionReactionTimeStimulusView.m
//  ResearchKit
//
//  Created by James Cox on 07/05/2015.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

#import "ORKDeviceMotionReactionTimeStimulusView.h"

@implementation ORKDeviceMotionReactionTimeStimulusView {
    CAShapeLayer *_concealLayer;
    CAShapeLayer *_tickLayer;
    CAShapeLayer *_crossLayer;
}

static const CGFloat RoundReactionTimeViewDiameter = 122;

- (instancetype) init {
    self = [super init];
    if (self) {
        self.layer.cornerRadius = RoundReactionTimeViewDiameter * 0.5;
        [self addConcealLayer];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(RoundReactionTimeViewDiameter, RoundReactionTimeViewDiameter);
}

- (void)startReadyAnimationWithDuration:(NSTimeInterval)duration completion:(void(^)(void))completion {
    [_tickLayer removeFromSuperlayer];
    [_crossLayer removeFromSuperlayer];
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    animation.delegate = self;
    animation.duration = duration*2;
    animation.removedOnCompletion = NO;
    animation.values = @[@(1.0), @(0.0), @(0.0)];
    animation.keyTimes =  @[@(0.0), @(0.5), @(1.0)];
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    [_concealLayer addAnimation:animation forKey:@"drawCircleAnimation"];
    [CATransaction commit];
}

- (void)startSuccessAnimationWithDuration:(NSTimeInterval)duration completion:(void(^)(void))completion {
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
    [self hideStimulus:true];
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

- (void)hideStimulus: (BOOL) hidden {
    self.layer.backgroundColor = hidden ? [UIColor clearColor].CGColor : self.tintColor.CGColor;
}

- (void)addConcealLayer {
    CGFloat radius = RoundReactionTimeViewDiameter * 0.5;
    _concealLayer = [CAShapeLayer layer];
    _concealLayer.path = [self concealPath:radius];
    _concealLayer.fillColor = [UIColor clearColor].CGColor;
    _concealLayer.strokeColor = [UIColor whiteColor].CGColor;
    _concealLayer.lineWidth = radius + 1;
    [self.layer addSublayer:_concealLayer];
}

- (void)addCrossLayer {
     _crossLayer =  [self lineDrawingLayer];
    _crossLayer.path = [self crossPath];
    [self.layer addSublayer:_crossLayer];
}

- (void)addTickLayer {
    _tickLayer =  [self lineDrawingLayer];
    _tickLayer.path = [self tickPath];
    [self.layer addSublayer:_tickLayer];
}

- (CGPathRef) concealPath: (CGFloat) radius {
    return [[UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                           radius: radius / 2
                                       startAngle:M_PI + M_PI_2
                                         endAngle:-M_PI_2
                                        clockwise:NO] CGPath];
}

- (CGPathRef) tickPath {
    UIBezierPath *path = [self linePath];
    [path moveToPoint:(CGPoint){37,65}];
    [path addLineToPoint:(CGPoint){50,78}];
    [path addLineToPoint:(CGPoint){87,42}];
    return path.CGPath;
}

- (CGPathRef) crossPath {
    UIBezierPath *path = [self linePath];
    [path moveToPoint:(CGPoint){37,78}];
    [path addLineToPoint:(CGPoint){87,42}];
    [path moveToPoint:(CGPoint){87,78}];
    [path addLineToPoint:(CGPoint){37,42}];
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
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.fillColor = nil;
    return shapeLayer;
}

@end