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
#import "ORKAudioGraphView.h"

#import "ORKHeadlineLabel.h"
#import "ORKSubheadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"

@interface ORKSpeechInNoiseContentView () <UITextFieldDelegate>

@property (nonatomic, strong) ORKHeadlineLabel *alertLabel;
@property (nonatomic, strong) ORKAudioGraphView *graphView;
@property (nonatomic, strong) ORKSubheadlineLabel *transcriptLabel;

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

- (void)setupTextLabel {
    _textLabel = [ORKSubheadlineLabel new];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
}

- (void)setupGraphView {
    self.graphView = [ORKAudioGraphView new];
    _graphView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_graphView];
}

- (void)setupPlayButton {
    self.playButton = [[ORKBorderedButton alloc] init];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playButton setTitle:ORKLocalizedString(@"SPEECH_IN_NOISE_START_AUDIO_LABEL", nil)
                       forState:UIControlStateNormal];
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

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel, _graphView, _playButton);
    const CGFloat graphHeight = 150;
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textLabel]-(5)-[_graphView(graphHeight)]-buttonGap-[_playButton(50)]-topBottomMargin-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:@{
                                                                                       @"graphHeight": @(graphHeight),
                                                                                       @"topBottomMargin" : @(5),
                                                                                       @"buttonGap" : @(20)
                                                                                       }
                                                                               views:views]];
    
    
    const CGFloat sideMargin = self.layoutMargins.left + (2 * ORKStandardLeftMarginForTableViewCell(self));
    const CGFloat twiceSideMargin = sideMargin * 2;
    
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textLabel]-|"
                                             options:0
                                             metrics: nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[_graphView]-sideMargin-|"
                                             options:0
                                             metrics: @{@"sideMargin": @(sideMargin)}
                                               views:views]];
    
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-twiceSideMargin-[_playButton(200)]-twiceSideMargin-|"
                                             options:0
                                             metrics: @{@"twiceSideMargin": @(twiceSideMargin)}
                                               views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateGraphSamples {
    _graphView.values = _samples;
}

- (void)addSample:(NSNumber *)sample {
    NSAssert(sample != nil, @"Sample should be non-nil");
    if (!_samples) {
        _samples = [NSMutableArray array];
    }
    [_samples addObject:sample];
    // Try to keep around 250 samples
    if (_samples.count > 500) {
        _samples = [[_samples subarrayWithRange:(NSRange){250, _samples.count - 250}] mutableCopy];
    }
    [self updateGraphSamples];
}


- (void)removeAllSamples {
    _samples = nil;
    [self updateGraphSamples];
}

@end
