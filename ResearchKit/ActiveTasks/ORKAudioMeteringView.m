/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKAudioMeteringView.h"


#import "ORKAudioGraphView.h"

NSArray<NSNumber *> * ORKLastNSamples(NSArray<NSNumber *> *samples, NSInteger limit) {
    
    if (samples.count > limit) {
        
        return [samples subarrayWithRange:(NSRange){samples.count - limit, samples.count - 1}];
    }
    
    return [samples copy];
}

@interface ORKAudioMeteringView ()
@property (nonatomic, strong) UIView<ORKAudioMetering, ORKAudioMeteringDisplay> *meteringView;
@end

@implementation ORKAudioMeteringView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configureMeteringView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureMeteringView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self configureMeteringView];
    }
    return self;
}

- (void)configureMeteringView
{
    if (!_meteringView) {
        [self setMeteringView:[[ORKAudioGraphView alloc] init]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_meteringView setFrame:[self bounds]];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [_meteringView setHidden:hidden];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if ([self superview] == nil)
    {
        [_meteringView removeFromSuperview];
    }
    else
    {
        [self addSubview:_meteringView];
    }
}

#pragma mark - ORKAudioMetering

- (void)setSamples:(NSArray<NSNumber *> *)samples
{
    [_meteringView setSamples:samples];
}

- (void)setAlertThreshold:(float)threshold
{
    [_meteringView setAlertThreshold:threshold];
}

#pragma mark - ORKAudioMeteringDisplay

- (void)setMeterColor:(UIColor *)meterColor
{
    [_meteringView setMeterColor:meterColor];
}

- (void)setAlertColor:(UIColor *)alertColor
{
    [_meteringView setAlertColor:alertColor];
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

@end

