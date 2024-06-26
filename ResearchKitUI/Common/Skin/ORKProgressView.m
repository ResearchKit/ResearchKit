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


#import "ORKProgressView.h"


static const CGFloat ProgressCircleDiameter = 10;
static const CGFloat ProgressCircleSpacing = 4;

@interface ORKProgressCircleView : UIView

@property (nonatomic, assign) BOOL completed;

@end


@implementation ORKProgressCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setCompleted:NO];
        self.backgroundColor = [self tintColor];
        self.layer.cornerRadius = ProgressCircleDiameter / 2;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.backgroundColor = [self tintColor];
}

- (CGSize)intrinsicContentSize {
    return (CGSize){ProgressCircleDiameter, ProgressCircleDiameter};
}

- (CGSize)sizeThatFits:(CGSize)size {
    return (CGSize){ProgressCircleDiameter, ProgressCircleDiameter};
}

- (void)setCompleted:(BOOL)completed {
    _completed = completed;
    self.alpha = (completed ? 1.0 : 0.6);
}

@end


@implementation ORKProgressView {
    NSArray *_circles;
    NSInteger _index;
    NSTimer *_timer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.count = 3;
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)setCount:(NSInteger)count {
    _count = count;
    if (count != _circles.count) {
        for (UIView *v in _circles) {
            [v removeFromSuperview];
        }
        NSMutableArray *newCircles = [NSMutableArray array];
        for (NSInteger idx = 0; idx < count; idx ++) {
            ORKProgressCircleView *circle = [ORKProgressCircleView new];
            [newCircles addObject:circle];
            [self addSubview:circle];
        }
        
        _circles = newCircles;
        [self invalidateIntrinsicContentSize];
        [self setNeedsLayout];
        self.index = _index;
    }
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    [_circles enumerateObjectsUsingBlock:^(ORKProgressCircleView *circle, NSUInteger idx, BOOL *stop) {
        circle.completed = (idx < _index);
    }];
}

- (void)didMoveToWindow {
    if (self.window) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}
- (void)stopAnimating {
    [_timer invalidate];
    _timer = nil;
}

- (void)incrementIndex {
    self.index = (_index + 1) % (_count + 1);
}

- (void)startAnimating {
    [self stopAnimating];
    self.index = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(incrementIndex) userInfo:nil repeats:YES];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.height = ProgressCircleDiameter;
    size.width = (_count * ProgressCircleDiameter) + MAX(_count - 1,0) * ProgressCircleSpacing;
    return size;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (void)layoutSubviews {
    CGSize  size = (CGSize){ProgressCircleDiameter,ProgressCircleDiameter};
    CGFloat xStep = ProgressCircleDiameter + ProgressCircleSpacing;
    CGFloat x0 = 0;
    for (UIView *view in _circles) {
        view.frame = (CGRect){{x0, 0}, size};
        x0 += xStep;
    }
}

@end
