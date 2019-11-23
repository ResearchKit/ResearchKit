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


#import "ORKEnvironmentSPLMeterContentView.h"

#import "ORKRoundTappingButton.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKRingView.h"
#import "ORKProgressView.h"
#import "ORKCompletionCheckmarkView.h"

static const CGFloat CircleIndicatorMaxDiameter = 150.0;
static const CGFloat RingViewTopPadding = 24.0;
static const CGFloat InstructionLabelTopPadding = 50.0;

@implementation ORKEnvironmentSPLMeterContentView {
    UIView *_circleIndicatorView;
    UILabel *_DBInstructionLabel;
    CGFloat preValue;
    CGFloat currentValue;
    UIColor *_circleIndicatorNoiseColor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        preValue = -M_PI_2;
        currentValue = 0.0;
        _circleIndicatorNoiseColor = UIColor.systemOrangeColor;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupRingView];
        [self setupCircleIndicatorView];
        [self setProgressCircle:0.0];
        [self setupDBInstructionLabel];
    }

    return self;
}

- (void)setupRingView {
    if (!_ringView) {
        _ringView = [ORKRingView new];
    }
    _ringView.animationDuration = 0.0;
    _ringView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_ringView];
    
    [[_ringView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[_ringView.topAnchor constraintEqualToAnchor:self.topAnchor constant:RingViewTopPadding] setActive:YES];
    [_ringView setColor:UIColor.grayColor];
}

- (void)setupCircleIndicatorView {
    if (!_circleIndicatorView) {
        _circleIndicatorView = [UIView new];
    }
    _circleIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_circleIndicatorView belowSubview:_ringView];
    
    [[_circleIndicatorView.centerXAnchor constraintEqualToAnchor:_ringView.centerXAnchor] setActive:YES];
    [[_circleIndicatorView.centerYAnchor constraintEqualToAnchor:_ringView.centerYAnchor] setActive:YES];
    [[_circleIndicatorView.heightAnchor constraintEqualToConstant:CircleIndicatorMaxDiameter] setActive:YES];
    [[_circleIndicatorView.widthAnchor constraintEqualToConstant:CircleIndicatorMaxDiameter] setActive:YES];
    _circleIndicatorView.layer.cornerRadius = CircleIndicatorMaxDiameter * 0.5;
}

- (void)setupDBInstructionLabel {
    if (!_DBInstructionLabel) {
        _DBInstructionLabel = [ORKLabel new];
        _DBInstructionLabel.numberOfLines = 0;
        _DBInstructionLabel.textColor = UIColor.systemGrayColor;
        _DBInstructionLabel.text = ORKLocalizedString(@"ENVIRONMENTSPL_OK", nil);
    }
    _DBInstructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_DBInstructionLabel];
    
    [[_DBInstructionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[_DBInstructionLabel.topAnchor constraintEqualToAnchor:_circleIndicatorView.bottomAnchor constant:InstructionLabelTopPadding] setActive:YES];
}

- (void)setProgressCircle:(CGFloat)progress {
    CGFloat circleDiameter;
    CGFloat y1 = 0.5, x1 = 0.8, y2 = 1.4, x2 = 1.2;

    if (progress < x1) {
        // lower limit for diameter
        circleDiameter = y1;
    } else if (progress > x2) {
        // upper limit for diameter
        circleDiameter = y2;
    } else {
        // linear interpolation
        circleDiameter = y1 + (y2 - y1)/(x2 - x1) * (progress - x1);
    }
    if (progress > 1.0) {
        [_ringView setBackgroundLayerStrokeColor:[UIColor.whiteColor colorWithAlphaComponent:0.3] circleStrokeColor:UIColor.whiteColor];
    }
    else {
        [_ringView resetLayerColors];
    }
    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                    _circleIndicatorView.transform = CGAffineTransformMakeScale(circleDiameter, circleDiameter);
                    _circleIndicatorView.backgroundColor = progress > 1.0 ? _circleIndicatorNoiseColor : self.tintColor;
    }
                     completion:nil];
    [self updateInstructionForValue:progress];
}

- (void)setProgress:(CGFloat)progress {
    CGFloat value = progress < 0.001 ? 0.001 : progress;
    [_ringView setValue:value];
}

- (void)updateInstructionForValue:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        _DBInstructionLabel.text = progress >= 1.0 ? ORKLocalizedString(@"ENVIRONMENTSPL_NOISE", nil) : ORKLocalizedString(@"ENVIRONMENTSPL_OK", nil);
    });
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
}

- (void)reachedOptimumNoiseLevel {
    _ringView.hidden = YES;
    _circleIndicatorView.hidden = YES;
    ORKCompletionCheckmarkView *checkmarkView = [[ORKCompletionCheckmarkView alloc] initWithDimension:_ringView.bounds.size.width];
    checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:checkmarkView aboveSubview:_ringView];
    [[checkmarkView.centerXAnchor constraintEqualToAnchor:_ringView.centerXAnchor] setActive:YES];
    [[checkmarkView.centerYAnchor constraintEqualToAnchor:_ringView.centerYAnchor] setActive:YES];
    [checkmarkView setAnimationPoint:1 animated:YES];
}

@end
