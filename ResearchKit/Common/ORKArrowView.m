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


#import "ORKArrowView.h"


static const CGFloat kArrowWidth = 10;
static const CGFloat kArrowLineWidth = 4;


@interface ORKArrowView ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ORKArrowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return (CGSize){kArrowWidth + 2 * kArrowLineWidth, 2 * (kArrowWidth + kArrowLineWidth)};
}

- (void)didMoveToWindow {
    if (self.window) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)startAnimating {
    [self stopAnimating];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(animate) userInfo:nil repeats:YES];
}

- (void)stopAnimating {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)animate {
    if (self.alpha == 1.0f) {
        self.alpha = 0.6f;
    } else {
        self.alpha = 1.0f;
    }
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, kArrowLineWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    [self.tintColor setStroke];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, kArrowLineWidth, kArrowLineWidth);
    CGPathAddLineToPoint(path, NULL, kArrowLineWidth + kArrowWidth, kArrowLineWidth + kArrowWidth);
    CGPathAddLineToPoint(path, NULL, kArrowLineWidth, kArrowLineWidth + 2 * kArrowWidth);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end
