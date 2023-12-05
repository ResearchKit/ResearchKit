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
#import "ORKEnvironmentSPLMeterBarView.h"
#import "ORKRoundTappingButton.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKRingView.h"
#import "ORKProgressView.h"
#import "ORKCompletionCheckmarkView.h"


static const CGFloat RingViewPadding = 18.0;
static const CGFloat InstructionLabelPadding = 8.0;
static const CGFloat HalfCircleSize = 14.0;
static const CGFloat BarViewHeight = 50.0;

@interface ORKEnvironmentSPLMeterContentView ()
@property(nonatomic, strong) ORKRingView *ringView;
@property(nonatomic, strong) ORKEnvironmentSPLMeterBarView *barView;
@end

@implementation ORKEnvironmentSPLMeterContentView {
    UIView *_containerView;
    UILabel *_DBInstructionLabel;
    UIImage *_checkmarkImage;
    UIImage *_xmarkImage;
    UIImageView *_xmarkView;
    CGFloat preValue;
    CGFloat currentValue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        preValue = -M_PI_2;
        currentValue = 0.0;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupContainerView];
        [self setupDBInstructionLabel];
        [self setupRingView];
        [self setupBarView];
        [self setupXmarkView];
        [self setProgressCircle:0.0];
    }

    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    _DBInstructionLabel.font = [self title3TextFont];
}

- (UIFont *)title3TextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle3];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_containerView];
    
    [[_containerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-RingViewPadding] setActive:YES];
    [[_containerView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor] setActive:YES];
    [[_containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_containerView.topAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor] setActive:YES];
}

- (void)setupXmarkView {
    if (!_xmarkView) {
        if (@available(iOS 13.0, *)) {
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:HalfCircleSize weight:UIImageSymbolWeightBold scale:UIImageSymbolScaleDefault];
            _xmarkImage = [[UIImage systemImageNamed:@"xmark" withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _checkmarkImage = [[UIImage systemImageNamed:@"checkmark" withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _xmarkView = [[UIImageView alloc] initWithImage: _xmarkImage];
        _xmarkView.tintColor = UIColor.systemOrangeColor;
    }
    _xmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_xmarkView];
    
    [[_xmarkView.centerYAnchor constraintEqualToAnchor:_ringView.centerYAnchor] setActive:YES];
    [[_xmarkView.centerXAnchor constraintEqualToAnchor:_ringView.centerXAnchor] setActive:YES];
    _xmarkView.hidden = YES;
}

- (void)setupBarView {
    if (!_barView) {
        _barView = [[ORKEnvironmentSPLMeterBarView alloc] initWithFrame:CGRectZero];
    }
    
    _barView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_barView];

    [[_barView.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor] setActive:YES];
    [[_barView.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor] setActive:YES];

    [[_barView.heightAnchor constraintEqualToConstant:BarViewHeight] setActive:YES];
    [[_barView.topAnchor constraintEqualToAnchor:_DBInstructionLabel.bottomAnchor constant:RingViewPadding] setActive:YES];
    [[_barView.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor constant:RingViewPadding] setActive:YES];
}

- (void)setupRingView {
    if (!_ringView) {
        _ringView = [ORKRingView new];
    }
    _ringView.animationDuration = 0.0;
    _ringView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_ringView];

    [[_ringView.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor] setActive:YES];
    [[_ringView.centerYAnchor constraintEqualToAnchor:_DBInstructionLabel.centerYAnchor] setActive:YES];
    [[_ringView.trailingAnchor constraintEqualToAnchor:_DBInstructionLabel.leadingAnchor constant:-InstructionLabelPadding] setActive:YES];

    if (@available(iOS 13.0, *)) {
        [_ringView setColor:UIColor.systemGray6Color];
    }
}

- (void)setupDBInstructionLabel {
    if (!_DBInstructionLabel) {
        _DBInstructionLabel = [ORKLabel new];
        _DBInstructionLabel.numberOfLines = 0;
        _DBInstructionLabel.font = [self title3TextFont];
        if (@available(iOS 13.0, *)) {
            _DBInstructionLabel.textColor = UIColor.labelColor;
        }
        _DBInstructionLabel.text = ORKLocalizedString(@"ENVIRONMENTSPL_CALCULATING", nil);
    }
    _DBInstructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_DBInstructionLabel];

    [[_DBInstructionLabel.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:InstructionLabelPadding] setActive:YES];
    [[_DBInstructionLabel.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor constant:-InstructionLabelPadding] setActive:YES];
}

- (void)setProgressBar:(CGFloat)progress {
    [_barView setProgress:progress];
}

- (void)setProgressCircle:(CGFloat)progress {
    if (progress >= ORKRingViewMaximumValue) {
    } else {
        [_ringView resetLayerColors];
    }

    [self updateInstructionForValue:progress];
}

- (ORKRingView *)ringView {
    return _ringView;
}

- (void)setProgress:(CGFloat)progress {
    CGFloat value = progress < ORKRingViewMinimumValue ? ORKRingViewMinimumValue : progress;
    [_ringView setValue:value];
}

- (void)updateInstructionForValue:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentInstruction = [_DBInstructionLabel.text copy];
        BOOL isNoise = (progress >= ORKRingViewMaximumValue);
        NSString *newInstruction = isNoise ? ORKLocalizedString(@"ENVIRONMENTSPL_NOISE", nil) : ORKLocalizedString(@"ENVIRONMENTSPL_CALCULATING", nil);
        _xmarkView.hidden = !isNoise;

        if (![newInstruction isEqualToString:currentInstruction]) {
            _DBInstructionLabel.text = newInstruction;
            if (UIAccessibilityIsVoiceOverRunning() && [self.voiceOverDelegate respondsToSelector:@selector(contentView:shouldAnnounce:)]) {
                [self.voiceOverDelegate contentView:self shouldAnnounce:_DBInstructionLabel.text];
            }
        }
    });
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
}

- (void)reachedOptimumNoiseLevel {
    _xmarkView.hidden = NO;
    _xmarkView.image = _checkmarkImage;
    _xmarkView.tintColor = UIColor.systemGreenColor;

    _DBInstructionLabel.text = ORKLocalizedString(@"ENVIRONMENTSPL_OK", nil);
    
    if (UIAccessibilityIsVoiceOverRunning() && [self.voiceOverDelegate respondsToSelector:@selector(contentView:shouldAnnounce:)]) {
        [self.voiceOverDelegate contentView:self shouldAnnounce:_DBInstructionLabel.text];
    }
    
    [_ringView setBackgroundLayerStrokeColor:UIColor.systemGreenColor circleStrokeColor:UIColor.systemGreenColor withAnimationDuration:0.0];
    
    [_barView stopAnimation];
}

@end
