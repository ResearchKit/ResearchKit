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


#import "ORKSpeechInNoiseContentView.h"
#import "ORKAudioMeteringView.h"

#import "ORKHeadlineLabel.h"
#import "ORKSubheadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKPlaybackButton.h"

static CGFloat const ORKSpeechInNoiseContentFlamesViewHeightConstant = 150.0;
static CGFloat const ORKSpeechInNoiseContentFlamesViewVerticalSpacing = 44.0;
static CGFloat const ORKSpeechInNoiseContentViewVerticalMargin = 44;

@interface ORKSpeechInNoiseContentView () <UITextFieldDelegate>

@property (nonatomic, strong) ORKAudioMeteringView *graphView;
@property (nonatomic, strong) ORKSubheadlineLabel *transcriptLabel;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *constraints;

@end


@implementation ORKSpeechInNoiseContentView {
    NSMutableArray *_samples;
    UIColor *_alertColor;
    ORKSubheadlineLabel *_textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setupGraphView];
        [self setupPlayButton];
        [self setupTextLabel];
        [self updateGraphSamples];
        [self applyAlertColor];
        [self setUpConstraints];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self setUpConstraints];
}

- (void)setupTextLabel {
    _textLabel = [ORKSubheadlineLabel new];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
}

- (void)setupGraphView {
    self.graphView = [[ORKAudioMeteringView alloc] init];
    _graphView.translatesAutoresizingMaskIntoConstraints = NO;
    [_graphView setMeterColor:[UIColor lightGrayColor]];
    [self addSubview:_graphView];
}

- (void)setupPlayButton {
    if (@available(iOS 13.0, *)) {
        self.playButton = [[ORKPlaybackButton alloc] initWithText:ORKLocalizedString(@"SPEECH_IN_NOISE_START_AUDIO_LABEL", nil) image:[UIImage systemImageNamed:@"play.circle"]];
    } else {
        self.playButton = [[ORKPlaybackButton alloc] initWithText:ORKLocalizedString(@"SPEECH_IN_NOISE_START_AUDIO_LABEL", nil) image:[UIImage imageNamed:@"play" inBundle:ORKBundle() compatibleWithTraitCollection:nil]];
    }
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.enabled = YES;
    self.playButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStartsMediaSession;
    [self addSubview:_playButton];
}

- (void)tintColorDidChange {
    [self applyAlertColor];
}

- (void)setFinished:(BOOL)finished {
    _finished = finished;
}

- (void)applyAlertColor {
    UIColor *alertColor = [self alertColor];
    _graphView.alertColor = alertColor;
}

- (UIColor *)alertColor {
    return _alertColor ? : [self tintColor];
}

- (void)setAlertColor:(UIColor *)alertColor {
    _alertColor = alertColor;
    [self applyAlertColor];
}

- (void)setUpConstraints
{
    if (self.constraints.count > 0)
    {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
    }
    
    NSLayoutConstraint *centeredYLayoutConstaint = [_graphView.centerYAnchor constraintLessThanOrEqualToAnchor:self.centerYAnchor constant:-ORKSpeechInNoiseContentFlamesViewVerticalSpacing];
    centeredYLayoutConstaint.priority = UILayoutPriorityDefaultLow;
    
    self.constraints = @[
        [_graphView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor],
        centeredYLayoutConstaint,
        [_graphView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_graphView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_graphView.heightAnchor constraintEqualToConstant:ORKSpeechInNoiseContentFlamesViewHeightConstant],
        [_playButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_playButton.topAnchor constraintGreaterThanOrEqualToAnchor:_graphView.bottomAnchor constant:ORKSpeechInNoiseContentFlamesViewVerticalSpacing],
        [_playButton.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:-ORKSpeechInNoiseContentViewVerticalMargin]
    ];
    
    [NSLayoutConstraint activateConstraints:self.constraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self setUpConstraints];
}

- (void)updateGraphSamples
{
    _graphView.samples = _samples;
}

- (void)setGraphViewHidden:(BOOL)hidden
{
    [_graphView setHidden:hidden];
}

- (void)addSample:(NSNumber *)sample
{
    NSAssert(sample != nil, @"Sample should be non-nil");
    if (!_samples) {
        _samples = [NSMutableArray array];
    }
    [_samples addObject:sample];
    
    _samples = [ORKLastNSamples(_samples, 500) mutableCopy];
    
    [self updateGraphSamples];
}

- (void)removeAllSamples
{
    _samples = nil;
    [self updateGraphSamples];
}

@end

