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
#import "ORKProgressView.h"


@interface ORKWalkingContentView : ORKActiveStepCustomView {
    ORKScreenType _screenType;
    NSLayoutConstraint *_topConstraint;
}

@property  (nonatomic, strong, readonly) ORKProgressView *progressView;

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
        _progressView = [ORKProgressView new];
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
