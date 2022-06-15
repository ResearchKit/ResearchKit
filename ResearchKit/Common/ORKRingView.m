/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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

@import UIKit;
#import "ORKRingView.h"

const double ORKRingViewMinimumValue = 0.001;
const double ORKRingViewMaximumValue = 1.0;

static const double VIEW_DIMENSION = 150.0;
static const CFTimeInterval DEFAULT_ANIMATION_DURATION = 1.25;
static const CGFloat RingLineWidth = 3.0;
static const CGFloat CircleLineWidth = 6.0;

@implementation ORKRingView {
    CAShapeLayer *_circleLayer;
    CAShapeLayer *_backgroundLayer;
    CAShapeLayer *_filledCircleLayer;
    
    NSUUID *_transactionID;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _color = [[self tintColor] colorWithAlphaComponent:0.8];
        _animationDuration = DEFAULT_ANIMATION_DURATION;
        _value = ORKRingViewMinimumValue;
        _backgroundLayer = [self createShapeLayer];
        _backgroundLayer.borderColor = _color.CGColor;
        
        [self resetLayerColors];
        
        [self.layer addSublayer:_backgroundLayer];

        _filledCircleLayer = [self filledCircleLayer];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.safeAreaLayoutGuide.widthAnchor constraintEqualToConstant:VIEW_DIMENSION],
            [self.safeAreaLayoutGuide.heightAnchor constraintEqualToConstant:VIEW_DIMENSION]
        ]];
    }
    
    return self;
}

- (CAShapeLayer *)createShapeLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineCap = kCALineCapRound;
    layer.path = [self createPath].CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = _color.CGColor;
    layer.lineWidth = RingLineWidth;
    return layer;
}

- (UIBezierPath *)createPath {
    CGFloat radius = VIEW_DIMENSION / 2.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:[self ringCenter]
                                                        radius:radius
                                                    startAngle:2 * M_PI * (ORKRingViewMaximumValue - 0.25)
                                                      endAngle:-M_PI_2
                                                     clockwise:NO];
    return path;
}

- (CGPoint)ringCenter {
    CGFloat radius = VIEW_DIMENSION / 2.0;
    return CGPointMake(radius, radius);
}

- (CAShapeLayer *)filledCircleLayer {
    CAShapeLayer *filledCircle = [CAShapeLayer layer];
    CGRect bounds = self.bounds;
    UIBezierPath *maskLayerPath = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:VIEW_DIMENSION / 2.0];
    filledCircle.path = maskLayerPath.CGPath;
    filledCircle.fillColor = [UIColor whiteColor].CGColor;
    return filledCircle;
}

- (void)setValue:(double)value {
    
    if (value != _value) {
        
        double oldValue = _value;
        _value = value;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSNumber *presentationLayerValue;
            if (![_circleLayer.presentationLayer animationForKey:@"strokeStart"]) {
                presentationLayerValue = @(1.0 - oldValue);
            } else {
                presentationLayerValue = [_circleLayer.presentationLayer valueForKey:@"strokeStart"];
                [_circleLayer removeAllAnimations];
            }
            
            NSUUID *caid = [NSUUID UUID];
            _transactionID = caid;
            
            [CATransaction begin];
            
            [_circleLayer removeFromSuperlayer];
            _circleLayer = [self createShapeLayer];
            _circleLayer.lineWidth = CircleLineWidth;
            _circleLayer.strokeColor = UIColor.systemGrayColor.CGColor;
            [self.layer addSublayer:_circleLayer];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            animation.fromValue = @([presentationLayerValue doubleValue]);
            animation.toValue = @(1.0 - value);
            animation.beginTime = 0.0;
            animation.duration = _animationDuration;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.fillMode = kCAFillModeBoth;
            animation.removedOnCompletion = NO;
            
            [CATransaction setCompletionBlock:^{
                if([caid isEqual:_transactionID]){
                    if (_value == ORKRingViewMinimumValue) {
                        [_circleLayer removeFromSuperlayer];
                    }
                    else {
                        _circleLayer.strokeColor = _color.CGColor;
                        if (_value == ORKRingViewMaximumValue && self.delegate && [self.delegate respondsToSelector:@selector(ringViewDidFinishFillAnimation)]) {
                            [self.delegate ringViewDidFinishFillAnimation];
                        }
                    }
                }
            }];
            
            [_circleLayer addAnimation:animation forKey:animation.keyPath];
            [CATransaction commit];
        });
        
    } else {
        
        if (value != ORKRingViewMaximumValue) {
            _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
            [_filledCircleLayer removeFromSuperlayer];
        }
    }
}

- (void)setValue:(double)value WithColor:(nullable UIColor *)color {
    if (color) {
        _color = color;
    }
    [self setValue:value];
}

- (void)setBackgroundLayerStrokeColor:(UIColor *)backgroundStrokeColor circleStrokeColor:(UIColor *)circleStrokeColor withAnimationDuration:(NSTimeInterval)animationDuration {
    
    if (_backgroundLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:(CFTimeInterval)animationDuration];
        _backgroundLayer.strokeColor = backgroundStrokeColor.CGColor;
        [CATransaction commit];
    }
        
    if (_circleLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:(CFTimeInterval)animationDuration];
        _circleLayer.strokeColor = circleStrokeColor.CGColor;
        [CATransaction commit];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self resetLayerColors];
}

- (void)resetLayerColors
{
    if (@available(iOS 13.0, *))
    {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        {
            _backgroundLayer.strokeColor = [[UIColor systemGray3Color] CGColor];
        }
        else
        {
            _backgroundLayer.strokeColor = [[UIColor systemGray3Color] CGColor];
        }
    }
    else
    {
        _backgroundLayer.strokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    }
    
    _circleLayer.strokeColor = UIColor.systemGrayColor.CGColor;
}

- (void)fillRingWithDuration:(NSTimeInterval)duration {
    _animationDuration = duration;
    [self setValue:1.0];
}

- (void)ringAnimation {
    [self.layer insertSublayer:_filledCircleLayer above:_backgroundLayer];
    _backgroundLayer.fillColor = _color.CGColor;

    UIBezierPath *endShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(55, 55, 0, 0)
                                                        cornerRadius:VIEW_DIMENSION / 2.0];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.toValue = (__bridge id _Nullable)(endShape.CGPath);
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;

    [_filledCircleLayer addAnimation:animation forKey:animation.keyPath];
}

@end
