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


#import "ORKHolePegTestPlacePegView.h"


@implementation ORKHolePegTestPlacePegView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

#pragma mark - drawing method

- (void)tintColorDidChange {
    [super tintColorDidChange];
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
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    
    if (self.isRotated) {
        [path moveToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 1/4)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 7/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 1/4, CGRectGetHeight(bounds) * 7/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 1/4, CGRectGetHeight(bounds) * 9/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 9/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 7/16, CGRectGetHeight(bounds) * 3/4)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 3/4)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 9/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 3/4, CGRectGetHeight(bounds) * 9/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 3/4, CGRectGetHeight(bounds) * 7/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 7/16)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) * 9/16, CGRectGetHeight(bounds) * 1/4)];
        [path closePath];
    }
    
    [self.tintColor setFill];
    [path fill];
    
    CGContextRestoreGState(context);
}

@end
