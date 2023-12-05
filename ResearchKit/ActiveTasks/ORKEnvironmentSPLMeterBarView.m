/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

#import "ORKEnvironmentSPLMeterBarView.h"


#import <QuartzCore/QuartzCore.h>

static const CGFloat ORKEnvironmentSPLMeterSquareSize = 8.0;
static const CGFloat ORKEnvironmentSPLMeterSquareDistance = 4.0;
static const int ORKEnvironmentSPLMeterNumberOfRows = 4;

@interface ORKEnvironmentSPLMeterColumnView : UIView {
    int _numberOfRows;
    CGFloat _squareSize;
    CGFloat _cornerRadius;
    
    NSArray<CAShapeLayer*> *_dots;
}

- (void)setColor:(UIColor *)color;
- (void)setOpacity:(CGFloat)opacity;

@end

@implementation ORKEnvironmentSPLMeterColumnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfRows = ORKEnvironmentSPLMeterNumberOfRows;
        _squareSize = ORKEnvironmentSPLMeterSquareSize;
        _cornerRadius = ORKEnvironmentSPLMeterSquareDistance;
        [self initRows];
    }
    return self;
}

- (void)initRows {
    CGFloat halfSquareSize = _squareSize * 0.5;
    CGFloat spacing = _squareSize + halfSquareSize;
    NSMutableArray<CAShapeLayer*> *dots = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numberOfRows; i++) {
        CAShapeLayer *dot = [CAShapeLayer layer];
        CGRect dotRect = CGRectMake(0,
                                    spacing * i,
                                    _squareSize, _squareSize);
        [dot setPath:[UIBezierPath bezierPathWithRoundedRect:dotRect
                                                cornerRadius:_cornerRadius].CGPath];
        if (@available(iOS 13.0, *)) {
            dot.fillColor = [UIColor systemGray6Color].CGColor;
        }
        [[self layer] addSublayer:dot];
        
        [dots addObject:dot];
    }
    
    _dots = [dots copy];
    
}

- (void)setOpacity:(CGFloat)opacity {
    for (NSInteger i = 0 ; i < _dots.count; i++) {
        CAShapeLayer *dot = _dots[i];
        dot.opacity = opacity;
    }
}

- (void)setColor:(UIColor *)color {
    [_dots makeObjectsPerformSelector:@selector(setFillColor:) withObject:(id)[color CGColor]];
}

@end

@interface ORKEnvironmentSPLMeterBarView () {
    NSArray<ORKEnvironmentSPLMeterColumnView *> *_columnViews;
    
    int _currentIndex;
    int _targetIndex;
    int _maximumNumberOfDots;
    int _greenIndexLimit;
    
    BOOL _didLayoutViews;
    BOOL _isAnimating;
    
    NSTimer *_animationTimer;
}

@end

@implementation ORKEnvironmentSPLMeterBarView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    _didLayoutViews = NO;
    _isAnimating = NO;
}

- (void)setupView {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat dotSpacing = (ORKEnvironmentSPLMeterSquareSize + ORKEnvironmentSPLMeterSquareDistance);
    _maximumNumberOfDots = (int) (floor(width/dotSpacing)) + 1;
    NSMutableArray<ORKEnvironmentSPLMeterColumnView*> *columnViews = [[NSMutableArray alloc] init];
    _greenIndexLimit = _maximumNumberOfDots * 0.66;
    _currentIndex = 0;
    _targetIndex = _greenIndexLimit;
    
    for (int i = 1 ; i <= _maximumNumberOfDots; i++) {
        CGRect columnRect = CGRectMake((i - 1) * dotSpacing,
                                       0, ORKEnvironmentSPLMeterSquareSize, ORKEnvironmentSPLMeterSquareSize);
        
        ORKEnvironmentSPLMeterColumnView *columnView = [[ORKEnvironmentSPLMeterColumnView alloc] initWithFrame:columnRect];
        
        if (i <= _greenIndexLimit - 1) {
            [columnView setColor:[UIColor systemGreenColor]];
        } else {
            [columnView setColor:[UIColor systemOrangeColor]];
        }
        
        [self addSubview:columnView];

        [columnViews addObject:columnView];
    }
    
    _columnViews = [columnViews copy];
    
    [self updateViewForIndex:_currentIndex];
    
    [self animateColumns];
}

- (void)setProgress:(CGFloat)progress {
    CGFloat resultProgress = progress;
    if (progress == 20.0) {
        return;
    }
    if(progress < 0) {
        resultProgress = 0.0;
    }
    
    float inMin = 0.0;
    float inMax = 1.0;
    float outMin = 0.0;
    float outMax = 0.66;
    
    float normalizedIndexValue = outMin + (outMax - outMin) * (resultProgress - inMin) / (inMax - inMin);
    
    if (resultProgress > 1.0) {
        inMin = 1.0;
        inMax = 1.5;
        outMin = 0.66;
        outMax = 1.0;
        
        normalizedIndexValue = outMin + (outMax - outMin) * (resultProgress - inMin) / (inMax - inMin);
    }
    
    int newTargetIndex = (int) (floor(normalizedIndexValue * _maximumNumberOfDots) + 1);
    
    if (newTargetIndex != _targetIndex) {
        [self stopAnimation];
        _targetIndex = newTargetIndex;
        _currentIndex = _targetIndex + (-1 + arc4random_uniform(3));
        [self updateViewForIndex:newTargetIndex];
    } else if (!_isAnimating) {
        int indexDistance = abs(_currentIndex - newTargetIndex);
        for (int i = 0; i < indexDistance; i++) {
            int newIndex;
            if (newTargetIndex < _currentIndex) {
                newIndex = _currentIndex - i;
            } else {
                newIndex = _currentIndex + i;
            }
            [self updateViewForIndex:newIndex];
        }
        
        [self animateColumns];
    }
}

- (void)animateColumns {
    [_animationTimer invalidate];
    _isAnimating = YES;
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES];
}

- (void)timerTicked {
    if (_currentIndex > _targetIndex) {
        _currentIndex = _currentIndex - 1;
    } else if (_currentIndex < _targetIndex) {
        _currentIndex = _currentIndex + 1;
    } else {
        _currentIndex = _currentIndex + (-1 + arc4random_uniform(3));
    }
    [self updateViewForIndex:_currentIndex];
}

- (void)updateViewForIndex:(int)index {
    for (int i = 0 ; i < _maximumNumberOfDots; i++) {
        ORKEnvironmentSPLMeterColumnView *columnView = _columnViews[i];
        NSInteger distanceToIndex = i - index;
        CGFloat opacityFactor = 0.1 * distanceToIndex;
        UIColor *grayColor;
        UIColor *greenColor;
        UIColor *orangeColor;
        if (@available(iOS 13.0, *)) {

            greenColor = [UIColor systemGreenColor];
            orangeColor = [UIColor systemOrangeColor];
        } else {
            grayColor = [UIColor grayColor];
            greenColor = [UIColor greenColor];
            orangeColor = [UIColor orangeColor];
        }
        if (i <= _greenIndexLimit) {
            if (i < index) {
                [columnView setColor:greenColor];
                [columnView setOpacity:1.0];
            } else {
                if (distanceToIndex < 3){
                    [columnView setColor:greenColor];
                    [columnView setOpacity:0.5 - opacityFactor];
                } else {
                    [columnView setColor:grayColor];
                    [columnView setOpacity:1.0];
                }
            }
        } else {
            if (i < index) {
                [columnView setColor:orangeColor];
                [columnView setOpacity:1.0];
            } else {
                if (distanceToIndex < 3){
                    [columnView setColor:orangeColor];
                    [columnView setOpacity:0.5 - opacityFactor];
                } else {
                    [columnView setColor:grayColor];
                    [columnView setOpacity:1.0];
                }
            }
        }
    }
}

- (void)stopAnimation {
    _isAnimating = NO;
    [_animationTimer invalidate];
    _animationTimer = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_didLayoutViews) {
        _didLayoutViews = YES;
        [self setupView];
    }
}

- (void)dealloc {
    [_animationTimer invalidate];
    _animationTimer = nil;
}

@end
