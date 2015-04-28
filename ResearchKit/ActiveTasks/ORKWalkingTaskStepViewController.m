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


#import "ORKWalkingTaskStepViewController.h"
#import "ORKHelpers.h"
#import "ORKStep_Private.h"
#import "ORKStepViewController_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKSkin.h"
#import "ORKWalkingTaskStep.h"
#import "ORKPedometerRecorder.h"
#import "ORKActiveStepView.h"


static const CGFloat kProgressCircleDiameter = 10;
static const CGFloat kProgressCircleSpacing = 4;

@interface ORKWalkingProgressCircleView : UIView

@property (nonatomic, assign) BOOL completed;

@end


@implementation ORKWalkingProgressCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setCompleted:NO];
        self.backgroundColor = [self tintColor];
        self.layer.cornerRadius = kProgressCircleDiameter/2;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.backgroundColor = [self tintColor];
}

- (CGSize)intrinsicContentSize {
    return (CGSize){kProgressCircleDiameter,kProgressCircleDiameter};
}

- (CGSize)sizeThatFits:(CGSize)size {
    return (CGSize){kProgressCircleDiameter,kProgressCircleDiameter};
}

- (void)setCompleted:(BOOL)completed {
    _completed = completed;
    self.alpha = (completed ? 1.0 : 0.6);
}

@end


@interface ORKWalkingProgressView : UIView

@property (nonatomic, assign) NSInteger count;

@end


@implementation ORKWalkingProgressView {
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
    if (count != [_circles count]) {
        for (UIView *v in _circles) {
            [v removeFromSuperview];
        }
        NSMutableArray *newCircles = [NSMutableArray array];
        for (NSInteger idx = 0; idx < count; idx ++) {
            ORKWalkingProgressCircleView *circle = [ORKWalkingProgressCircleView new];
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
    [_circles enumerateObjectsUsingBlock:^(ORKWalkingProgressCircleView *circle, NSUInteger idx, BOOL *stop) {
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
    size.height = kProgressCircleDiameter;
    size.width = (_count * kProgressCircleDiameter) + MAX(_count-1,0) * kProgressCircleSpacing;
    return size;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (void)layoutSubviews {
    CGSize sz = (CGSize){kProgressCircleDiameter,kProgressCircleDiameter};
    CGFloat xStep = kProgressCircleDiameter + kProgressCircleSpacing;
    CGFloat x0 = 0;
    for (UIView *v in _circles) {
        v.frame = (CGRect){{x0,0},sz};
        x0 += xStep;
    }
}

@end


@interface ORKWalkingContentView : ORKActiveStepCustomView {
    ORKScreenType _screenType;
    NSLayoutConstraint *_topConstraint;
}

@property  (nonatomic, strong, readonly) ORKWalkingProgressView *progressView;

@end


@implementation ORKWalkingContentView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _screenType = ORKGetScreenTypeForWindow(newWindow);
    [self updateConstraintConstants];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progressView = [ORKWalkingProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _screenType = ORKScreenTypeiPhone4;
        
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        _progressView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2];
#endif
        
        [self addSubview:_progressView];
        [self setNeedsUpdateConstraints];
        
    }
    return self;
}

- (void)updateConstraintConstants {
    
    ORKScreenType screenType = _screenType;
    const CGFloat CaptionBaselineToProgressTop = 100;
    const CGFloat CaptionBaselineToStepViewTop = ORKGetMetricForScreenType(ORKScreenMetricLearnMoreBaselineToStepViewTop, screenType);
    [_topConstraint setConstant:(CaptionBaselineToProgressTop - CaptionBaselineToStepViewTop)];
}

- (void)updateConstraints {
    [self removeConstraints:[self constraints]];
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView]-(>=0)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    _topConstraint = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self updateConstraintConstants];
    [self addConstraint:_topConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [super updateConstraints];
}

@end


@interface ORKWalkingTaskStepViewController () <ORKPedometerRecorderDelegate> {
    NSInteger _intendedSteps;
    ORKWalkingContentView *_contentView;
}

@end


@implementation ORKWalkingTaskStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = NO;
    }
    return self;
}

- (ORKWalkingTaskStep *)walkingTaskStep {
    return (ORKWalkingTaskStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentView = [ORKWalkingContentView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _contentView;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    _intendedSteps = [[self walkingTaskStep] numberOfStepsPerLeg];
}

- (void)pedometerRecorderDidUpdate:(ORKPedometerRecorder *)pedometerRecorder {
    NSInteger numberOfSteps = [pedometerRecorder totalNumberOfSteps];
    ORK_Log_Debug(@"Steps: %lld", (long long)numberOfSteps);
    if (_intendedSteps > 0 && numberOfSteps >= _intendedSteps) {
        [self finish];
    }
}

@end
