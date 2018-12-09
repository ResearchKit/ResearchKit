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


#import "ORKAudioGraphView.h"
#import "ORKSkin.h"


static const CGFloat ValueLineWidth = 4.5;
static const CGFloat ValueLineMargin = 1.5;
static const CGFloat GraphHeight = 150.0;


@implementation ORKAudioGraphView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpConstraints];
        
#if TARGET_IPHONE_SIMULATOR
        _values = @[ @(0.2), @(0.6), @(0.55), @(0.1), @(0.75), @(0.7) ];
#endif
    }
    return self;
}

- (void)setUpConstraints {
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:GraphHeight];
    heightConstraint.priority = UILayoutPriorityFittingSizeLevel;
    
    [NSLayoutConstraint activateConstraints:@[heightConstraint]];
}

- (void)setValues:(NSArray *)values {
    _values = [values copy];
    [self setNeedsDisplay];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = [keyColor copy];
    [self setNeedsDisplay];
}

- (void)setAlertColor:(UIColor *)alertColor {
    _alertColor = [alertColor copy];
    [self setNeedsDisplay];
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, ORKNeedWideScreenDesign(self) ? ORKColor(ORKiPadBackgroundViewColorKey).CGColor : ORKColor(ORKBackgroundColorKey).CGColor);
    CGContextFillRect(context, bounds);
    
    CGFloat scale = self.window.screen.scale;
    
    CGFloat midY = CGRectGetMidY(bounds);
    CGFloat maxX = CGRectGetMaxX(bounds);
    CGFloat halfHeight = bounds.size.height / 2;
    CGContextSaveGState(context);
    {
        UIBezierPath *centerLine = [UIBezierPath new];
        [centerLine moveToPoint:(CGPoint){.x = 0, .y = midY}];
        [centerLine addLineToPoint:(CGPoint){.x = maxX, .y = midY}];
        
        CGContextSetLineWidth(context, 1.0 / scale);
        [_keyColor setStroke];
        CGFloat lengths[2] = {3, 3};
        CGContextSetLineDash(context, 0, lengths, 2);
        
        [centerLine stroke];
    }
    CGContextRestoreGState(context);
    
    CGFloat lineStep = ValueLineMargin + ValueLineWidth;
    
    CGContextSaveGState(context);
    {
        CGFloat x = maxX - lineStep / 2;
        CGContextSetLineWidth(context, ValueLineWidth);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        UIBezierPath *path1 = [UIBezierPath new];
        path1.lineCapStyle = kCGLineCapRound;
        path1.lineWidth = ValueLineWidth;
        UIBezierPath *path2 = [path1 copy];
        
        for (NSNumber *value in [_values reverseObjectEnumerator]) {
            CGFloat floatValue = value.doubleValue;
            
            UIBezierPath *path = nil;
            if (floatValue > _alertThreshold) {
                path = path1;
                [_alertColor setStroke];
            } else {
                path = path2;
                [_keyColor setStroke];
            }
            [path moveToPoint:(CGPoint){.x = x, .y = midY - floatValue*halfHeight}];
            [path addLineToPoint:(CGPoint){.x = x, .y = midY + floatValue*halfHeight}];
            
            x -= lineStep;
            
            if (x < 0) {
                break;
            }
            
        }
        
        [_alertColor setStroke];
        [path1 stroke];
        
        [_keyColor setStroke];
        [path2 stroke];
        
    }
    CGContextRestoreGState(context);
}

@end
