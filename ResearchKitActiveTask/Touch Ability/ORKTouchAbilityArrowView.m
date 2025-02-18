/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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

#import "ORKTouchAbilityArrowView.h"

@implementation ORKTouchAbilityArrowView

- (CGSize)intrinsicContentSize {
    return CGSizeMake(300.0, 300.0);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.style = ORKTouchAbilityArrowViewStyleFill;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(ORKTouchAbilityArrowViewStyle)style {
    if (self = [super initWithFrame:frame]) {
        self.style = style;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setStyle:(ORKTouchAbilityArrowViewStyle)style {
    _style = style;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // Background color
    
    [self.backgroundColor setFill];
    [[UIBezierPath bezierPathWithRect:rect] fill];
    
    
    // Arrow dimensions
    
    CGFloat tailWidth = CGRectGetHeight(self.bounds) / 4;
    CGFloat headWidth = CGRectGetHeight(self.bounds) / 2;
    CGFloat headLength = CGRectGetWidth(self.bounds) / 3;
    
    CGPoint start = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    CGPoint end = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
    
    CGFloat length = hypot(end.x - start.x, end.y -start.y);
    CGFloat tailLength = length - headLength;
    
    // Path points
    
    CGPoint points[7]; // It's a C array.
    points[0] = CGPointMake(0, tailWidth / 2);
    points[1] = CGPointMake(tailLength, tailWidth / 2);
    points[2] = CGPointMake(tailLength, headWidth / 2);
    points[3] = CGPointMake(length, 0);
    points[4] = CGPointMake(tailLength, -headWidth / 2);
    points[5] = CGPointMake(tailLength, -tailWidth / 2);
    points[6] = CGPointMake(0, -tailWidth / 2);
    
    CGFloat cosine = (end.x - start.x) / length;
    CGFloat sine = (end.y - start.y) / length;
    
    CGAffineTransform transform = { cosine, sine, -sine, cosine, start.x, start.y };
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines(path, &transform, points, sizeof points / sizeof *points);
    CGPathCloseSubpath(path);
    
    // Fill the path
    
    if (self.style == ORKTouchAbilityArrowViewStyleFill) {
        [self.tintColor setFill];
        [[UIBezierPath bezierPathWithCGPath:path] fill];
    } else {
        UIBezierPath *bPath = [UIBezierPath bezierPathWithCGPath:path];
        
        CGFloat dashes[2] = {4.0, 4.0};
        [bPath setLineDash:dashes count:2 phase:0];
        [bPath setLineCapStyle:kCGLineCapButt];
        [bPath setLineWidth:4.0];
        
        [UIColor.blackColor setStroke];
        [bPath stroke];
    }
    
    // Release path ref
    CGPathRelease(path);
}

@end
