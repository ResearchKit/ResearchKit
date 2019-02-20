/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKSpatialSpanTargetView.h"

#import "ORKTintedImageView.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


static const UIEdgeInsets ORKFlowerMargins = (UIEdgeInsets){12,12,12,12};
static const CGSize ORKFlowerBezierPathSize = (CGSize){90,90};
static UIBezierPath *ORKFlowerBezierPath() {
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(58.8, 45)];
    [bezierPath addCurveToPoint: CGPointMake(51.9, 33.2) controlPoint1: CGPointMake(107.8, 41.8) controlPoint2: CGPointMake(79.3, -7.2)];
    [bezierPath addCurveToPoint: CGPointMake(38.1, 33.2) controlPoint1: CGPointMake(73.6, -10.4) controlPoint2: CGPointMake(16.5, -10.4)];
    [bezierPath addCurveToPoint: CGPointMake(31.2, 45) controlPoint1: CGPointMake(10.8, -7.2) controlPoint2: CGPointMake(-17.8, 41.8)];
    [bezierPath addCurveToPoint: CGPointMake(38.1, 56.8) controlPoint1: CGPointMake(-17.8, 48.2) controlPoint2: CGPointMake(10.7, 97.2)];
    [bezierPath addCurveToPoint: CGPointMake(51.9, 56.8) controlPoint1: CGPointMake(16.4, 100.4) controlPoint2: CGPointMake(73.5, 100.4)];
    [bezierPath addCurveToPoint: CGPointMake(58.8, 45) controlPoint1: CGPointMake(79.2, 97.2) controlPoint2: CGPointMake(107.8, 48.2)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(45, 53.1)];
    [bezierPath addCurveToPoint: CGPointMake(36.7, 45) controlPoint1: CGPointMake(40.4, 53.1) controlPoint2: CGPointMake(36.7, 49.5)];
    [bezierPath addCurveToPoint: CGPointMake(45, 36.9) controlPoint1: CGPointMake(36.7, 40.5) controlPoint2: CGPointMake(40.4, 36.9)];
    [bezierPath addCurveToPoint: CGPointMake(53.3, 45) controlPoint1: CGPointMake(49.6, 36.9) controlPoint2: CGPointMake(53.3, 40.5)];
    [bezierPath addCurveToPoint: CGPointMake(45, 53.1) controlPoint1: CGPointMake(53.3, 49.5) controlPoint2: CGPointMake(49.6, 53.1)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    return bezierPath;
}

static const CGSize ORKCheckBezierPathSize = (CGSize){28,28};
static UIBezierPath *ORKCheckBezierPath() {
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(11.6, 19)];
    [bezierPath addCurveToPoint: CGPointMake(11.1, 18.8) controlPoint1: CGPointMake(11.4, 19) controlPoint2: CGPointMake(11.2, 18.9)];
    [bezierPath addLineToPoint: CGPointMake(7.5, 15.5)];
    [bezierPath addCurveToPoint: CGPointMake(7.5, 14.4) controlPoint1: CGPointMake(7.2, 15.2) controlPoint2: CGPointMake(7.2, 14.7)];
    [bezierPath addCurveToPoint: CGPointMake(8.6, 14.4) controlPoint1: CGPointMake(7.8, 14.1) controlPoint2: CGPointMake(8.3, 14.1)];
    [bezierPath addLineToPoint: CGPointMake(11.6, 17.2)];
    [bezierPath addLineToPoint: CGPointMake(19.6, 9.2)];
    [bezierPath addCurveToPoint: CGPointMake(20.7, 9.2) controlPoint1: CGPointMake(19.9, 8.9) controlPoint2: CGPointMake(20.4, 8.9)];
    [bezierPath addCurveToPoint: CGPointMake(20.7, 10.3) controlPoint1: CGPointMake(21, 9.5) controlPoint2: CGPointMake(21, 10)];
    [bezierPath addLineToPoint: CGPointMake(12.2, 18.8)];
    [bezierPath addCurveToPoint: CGPointMake(11.6, 19) controlPoint1: CGPointMake(12, 18.9) controlPoint2: CGPointMake(11.8, 19)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    return bezierPath;
}

static const CGSize ORKErrorBezierPathSize = (CGSize){28,28};
static UIBezierPath *ORKErrorBezierPath() {
    UIBezierPath *bezier3Path = UIBezierPath.bezierPath;
    [bezier3Path moveToPoint: CGPointMake(15.1, 14)];
    [bezier3Path addLineToPoint: CGPointMake(18.8, 10.3)];
    [bezier3Path addCurveToPoint: CGPointMake(18.8, 9.2) controlPoint1: CGPointMake(19.1, 10) controlPoint2: CGPointMake(19.1, 9.5)];
    [bezier3Path addCurveToPoint: CGPointMake(17.7, 9.2) controlPoint1: CGPointMake(18.5, 8.9) controlPoint2: CGPointMake(18, 8.9)];
    [bezier3Path addLineToPoint: CGPointMake(14, 12.9)];
    [bezier3Path addLineToPoint: CGPointMake(10.3, 9.2)];
    [bezier3Path addCurveToPoint: CGPointMake(9.2, 9.2) controlPoint1: CGPointMake(10, 8.9) controlPoint2: CGPointMake(9.5, 8.9)];
    [bezier3Path addCurveToPoint: CGPointMake(9.2, 10.3) controlPoint1: CGPointMake(8.9, 9.5) controlPoint2: CGPointMake(8.9, 10)];
    [bezier3Path addLineToPoint: CGPointMake(12.9, 14)];
    [bezier3Path addLineToPoint: CGPointMake(9.2, 17.7)];
    [bezier3Path addCurveToPoint: CGPointMake(9.2, 18.8) controlPoint1: CGPointMake(8.9, 18) controlPoint2: CGPointMake(8.9, 18.5)];
    [bezier3Path addCurveToPoint: CGPointMake(9.7, 19) controlPoint1: CGPointMake(9.3, 18.9) controlPoint2: CGPointMake(9.5, 19)];
    [bezier3Path addCurveToPoint: CGPointMake(10.2, 18.8) controlPoint1: CGPointMake(9.9, 19) controlPoint2: CGPointMake(10.1, 18.9)];
    [bezier3Path addLineToPoint: CGPointMake(13.9, 15.1)];
    [bezier3Path addLineToPoint: CGPointMake(17.6, 18.8)];
    [bezier3Path addCurveToPoint: CGPointMake(18.1, 19) controlPoint1: CGPointMake(17.7, 18.9) controlPoint2: CGPointMake(17.9, 19)];
    [bezier3Path addCurveToPoint: CGPointMake(18.6, 18.8) controlPoint1: CGPointMake(18.3, 19) controlPoint2: CGPointMake(18.5, 18.9)];
    [bezier3Path addCurveToPoint: CGPointMake(18.6, 17.7) controlPoint1: CGPointMake(18.9, 18.5) controlPoint2: CGPointMake(18.9, 18)];
    [bezier3Path addLineToPoint: CGPointMake(15.1, 14)];
    [bezier3Path closePath];
    bezier3Path.miterLimit = 4;
    return bezier3Path;
}

@interface ORKPathView : UIView

- (instancetype)initWithBezierPath:(UIBezierPath *)path canvasSize:(CGSize)canvasSize canvasMargins:(UIEdgeInsets)margins color:(UIColor *)color;

@property (nonatomic, readonly) UIEdgeInsets canvasMargins;
@property (nonatomic, readonly) CGSize canvasSize;
@property (nonatomic, strong, readonly) UIBezierPath *path;
@property (nonatomic, strong, readonly) UIColor *color;

@end


@implementation ORKPathView

- (instancetype)initWithBezierPath:(UIBezierPath *)path canvasSize:(CGSize)canvasSize canvasMargins:(UIEdgeInsets)margins color:(UIColor *)color {
    CGRect canvasRect = (CGRect){CGPointZero, canvasSize};
    CGRect outsetRect = UIEdgeInsetsInsetRect(canvasRect, (UIEdgeInsets){.top=-margins.top, .left=-margins.left, .right=-margins.right, .bottom=-margins.bottom});
    self = [super initWithFrame:outsetRect];
    if (self) {
        _canvasMargins = margins;
        _canvasSize = canvasSize;
        _path = path;
        _color = color;
        self.tintColor = color;
        self.opaque = NO;
        [self setNeedsDisplay];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.tintColor = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(ctx, bounds);
    
    CGFloat baseWidth = _canvasSize.width + _canvasMargins.left + _canvasMargins.right;
    CGFloat baseHeight = _canvasSize.height + _canvasMargins.top + _canvasMargins.bottom;
    
    CGFloat aspectRatio = MIN( bounds.size.width / baseWidth, bounds.size.height / baseHeight);
    
    CGContextSaveGState(ctx);
    
    CGContextScaleCTM(ctx, aspectRatio, aspectRatio);
    CGContextTranslateCTM(ctx, _canvasMargins.left, _canvasMargins.top);
    
    [self.tintColor setFill];
    [_path fill];
    
    CGContextRestoreGState(ctx);
}

- (void)tintColorDidChange {
    [self setNeedsDisplay];
}

@end


@implementation ORKSpatialSpanTargetView {
    UITapGestureRecognizer *_tapRecognizer;
    
    CGFloat _flowerScaleFactor;
    UIView *_flowerView;
    UIView *_checkView;
    UIView *_errorView;
}

- (UIView *)newFlowerViewWithImage:(UIImage *)image {
    if (image == nil) {
        return [[ORKPathView alloc] initWithBezierPath:ORKFlowerBezierPath() canvasSize:ORKFlowerBezierPathSize canvasMargins:ORKFlowerMargins color:[UIColor blackColor]];
    } else {
        ORKTintedImageView *imageView = [[ORKTintedImageView alloc] initWithImage:image];
        imageView.shouldApplyTint = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        return imageView;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:_tapRecognizer];
        
        _flowerScaleFactor = 1;
        _flowerView = [self newFlowerViewWithImage:nil];
        [self addSubview:_flowerView];
        
        _checkView = [[ORKPathView alloc] initWithBezierPath:ORKCheckBezierPath() canvasSize:ORKCheckBezierPathSize canvasMargins:UIEdgeInsetsZero color:[self tintColor]];
        _checkView.backgroundColor = [UIColor whiteColor];
        _checkView.layer.masksToBounds = YES;
        _checkView.hidden = YES;
        [self addSubview:_checkView];
        
        _errorView = [[ORKPathView alloc] initWithBezierPath:ORKErrorBezierPath() canvasSize:ORKErrorBezierPathSize canvasMargins:UIEdgeInsetsZero color:[UIColor ork_redColor]];
        _errorView.backgroundColor = [UIColor whiteColor];
        _errorView.layer.masksToBounds = YES;
        _errorView.hidden = YES;
        [self addSubview:_errorView];
        
        for (UIView *view in @[_flowerView, _checkView, _errorView]) {
            view.isAccessibilityElement = NO;
        }
    }
    return self;
}

- (void)setCustomTargetImage:(UIImage *)customTargetImage {
    UIImage *oldTargetImage = _customTargetImage;
    _customTargetImage = customTargetImage;
    if ((customTargetImage == nil) != (oldTargetImage == nil)) {
        [_flowerView removeFromSuperview];
        _flowerView = [self newFlowerViewWithImage:customTargetImage];
        _flowerScaleFactor = (customTargetImage ? 0.8 : 1);
        _flowerView.transform = CGAffineTransformMakeScale(_flowerScaleFactor, _flowerScaleFactor);
        [self insertSubview:_flowerView atIndex:0];
    } else if (customTargetImage) {
        [(UIImageView *)_flowerView setImage:customTargetImage];
    }
    [self setNeedsLayout];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [_delegate targetView:self recognizer:recognizer];
}

- (void)setState:(ORKSpatialSpanTargetState)state {
    [self setState:state animated:NO];
}

- (void)tintColorDidChange {
    if ([_checkView isKindOfClass:[ORKPathView class]]) {
        [(ORKPathView *)_checkView setColor:[self tintColor]];
    }
    [self setState:_state];
}

- (void)setState:(ORKSpatialSpanTargetState)state animated:(BOOL)animated {
    _state = state;
    
    CGFloat newAlpha;
    
    BOOL checkHidden = YES;
    BOOL errorHidden = YES;
    CGAffineTransform newTransform = CGAffineTransformMakeScale(_flowerScaleFactor, _flowerScaleFactor);
    
    CGFloat oldCircleAlpha = [_errorView.layer.presentationLayer opacity];
    CGFloat newCircleAlpha;
    CGAffineTransform oldCircleTransform = CGAffineTransformIdentity;
    CGAffineTransform newCircleTransform = CGAffineTransformIdentity;
    BOOL useSpring = NO;
    NSTimeInterval duration = 0.3;
    switch (state) {
        case ORKSpatialSpanTargetStateQuiescent:
            _flowerView.tintColor = [self tintColor];
            newAlpha = 0.2;
            newCircleAlpha = 0.0;
            newCircleTransform = CGAffineTransformMakeScale(0.2, 0.2);
            break;
            
        case ORKSpatialSpanTargetStateActive:
            _flowerView.tintColor = [self tintColor];
            newAlpha = 1.0;
            newCircleTransform = CGAffineTransformMakeScale(0.2, 0.2);
            newCircleAlpha = 0.0;
            break;
            
        case ORKSpatialSpanTargetStateIncorrect:
            _flowerView.tintColor = [UIColor ork_redColor];
            newTransform = CGAffineTransformMakeScale(0.9 * _flowerScaleFactor, 0.9 * _flowerScaleFactor);
            oldCircleAlpha = 0;
            newCircleAlpha = 1;
            oldCircleTransform = CGAffineTransformMakeScale(0.2, 0.2);
            newCircleTransform = CGAffineTransformMakeScale(1.0, 1.0);
            newAlpha = 1.0;
            errorHidden = NO;
            useSpring = NO;
            break;
            
        case ORKSpatialSpanTargetStateCorrect:
            _flowerView.tintColor = [self tintColor];
            newTransform = CGAffineTransformMakeScale(1.1 * _flowerScaleFactor, 1.1 * _flowerScaleFactor);
            oldCircleAlpha = 0;
            newCircleAlpha = 1;
            oldCircleTransform = CGAffineTransformMakeScale(0.2, 0.2);
            newCircleTransform = CGAffineTransformMakeScale(1.0, 1.0);
            newAlpha = 1.0;
            checkHidden = NO;
            useSpring = YES;
            duration = 0.5;
            break;
    }
    
    _checkView.alpha = oldCircleAlpha;
    _errorView.alpha = newCircleAlpha;
    _checkView.transform = oldCircleTransform;
    _errorView.transform = oldCircleTransform;
    
    _errorView.hidden = errorHidden;
    _checkView.hidden = checkHidden;
    _flowerView.transform = CGAffineTransformMakeScale(_flowerScaleFactor, _flowerScaleFactor);
    
    [UIView animateWithDuration:(animated ? duration : 0) delay:0 usingSpringWithDamping:useSpring ? 0.5 : 1 initialSpringVelocity:0 options:(UIViewAnimationOptions)UIViewAnimationOptionBeginFromCurrentState animations:^{
        _errorView.alpha = newCircleAlpha;
        _checkView.alpha = newCircleAlpha;
        _errorView.transform = newCircleTransform;
        _checkView.transform = newCircleTransform;
        self.alpha = newAlpha;
        _flowerView.transform = newTransform;
    } completion:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _flowerView.center = (CGPoint){CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
    _flowerView.bounds = bounds;
    _flowerView.transform = CGAffineTransformMakeScale(_flowerScaleFactor, _flowerScaleFactor);
    
    CGFloat designWidth = ORKFlowerBezierPathSize.width + ORKFlowerMargins.left + ORKFlowerMargins.right;
    CGFloat scaleFactor = bounds.size.width / designWidth;
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    CGRect checkRect = CGRectApplyAffineTransform((CGRect){CGPointZero, ORKCheckBezierPathSize}, transform);
    [_checkView setBounds:checkRect];
    _checkView.layer.cornerRadius = checkRect.size.width / 2;
    CGRect errorRect = CGRectApplyAffineTransform((CGRect){CGPointZero, ORKErrorBezierPathSize}, transform);
    [_errorView setBounds:errorRect];
    _errorView.layer.cornerRadius = errorRect.size.width / 2;
    _errorView.center = _flowerView.center;
    _checkView.center = _flowerView.center;
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *state;
    switch (self.state) {
        case ORKSpatialSpanTargetStateActive:
            state = ORKLocalizedString(@"AX.MEMORY.TILE.ACTIVE", nil);
            break;
        case ORKSpatialSpanTargetStateCorrect:
            state = ORKLocalizedString(@"AX.MEMORY.TILE.CORRECT", nil);
            break;
        case ORKSpatialSpanTargetStateIncorrect:
            state = ORKLocalizedString(@"AX.MEMORY.TILE.INCORRECT", nil);
            break;
        case ORKSpatialSpanTargetStateQuiescent:
            state = ORKLocalizedString(@"AX.MEMORY.TILE.QUIESCENT", nil);
            break;
    }
    return ORKAccessibilityStringForVariables(ORKLocalizedString(@"AX.MEMORY.TILE.LABEL", nil), state);
}

@end
