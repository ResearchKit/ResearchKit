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


#import "ORKSpeechRecognitionContentView.h"
#import "ORKAudioGraphView.h"

#import "ORKHeadlineLabel.h"
#import "ORKSubheadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"

@interface ORKSpeechRecognitionContentView () <UITextFieldDelegate>

@property (nonatomic, strong) ORKHeadlineLabel *alertLabel;
@property (nonatomic, strong) ORKAudioGraphView *graphView;
@property (nonatomic, strong) ORKSubheadlineLabel *transcriptLabel;

@end


@implementation ORKSpeechRecognitionContentView {
    NSMutableArray *_samples;
    UIColor *_keyColor;
    UIImageView *_imageView;
    UILabel *_textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setupTranscriptLabel];
        [self setupGraphView];
        [self setupRecordButton];
        [self setupImageView];
        [self setupTextLabel];
        [self updateGraphSamples];
        [self applyKeyColor];
        [self setUpConstraints];
    }
    return self;
}

- (void)setupImageView {
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
}

- (void)setupTextLabel {
    _textLabel = [UILabel new];
    _textLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleTitle2] scaledFontForFont:[UIFont systemFontOfSize:25.0 weight:UIFontWeightMedium]];
    _textLabel.textColor = [self tintColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.numberOfLines = 0;
    _textLabel.adjustsFontForContentSizeCategory = YES;
    [self addSubview:_textLabel];
}

- (void)setupGraphView {
    self.graphView = [ORKAudioGraphView new];
    _graphView.translatesAutoresizingMaskIntoConstraints = NO;
    _graphView.isAccessibilityElement = YES;
    _graphView.accessibilityLabel = ORKLocalizedString(@"AX_SPEECH_RECOGNITION_WAVEFORM", nil);
    _graphView.accessibilityTraits = UIAccessibilityTraitImage;
    
    [self addSubview:_graphView];
}

- (void)setupTranscriptLabel {
    _transcriptLabel = [ORKSubheadlineLabel new];
    _transcriptLabel.textAlignment = NSTextAlignmentCenter;
    _transcriptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _transcriptLabel.text = ORKLocalizedString(@"SPEECH_RECOGNITION_TRANSCRIPTION_LABEL", nil);
    _transcriptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _transcriptLabel.numberOfLines = 0;
    
    [self addSubview:_transcriptLabel];
}

- (void)setupRecordButton {
    self.recordButton = [[ORKBorderedButton alloc] init];
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.recordButton setTitle:ORKLocalizedString(@"SPEECH_RECOGNITION_START_RECORD_LABEL", nil)
                       forState:UIControlStateNormal];
    self.recordButton.enabled = YES;
    self.recordButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStartsMediaSession;
    self.recordButton.accessibilityHint = ORKLocalizedString(@"AX_SPEECH_RECOGNITION_START_RECORDING_HINT", nil);
    [self addSubview:_recordButton];
}

- (void)setSpeechRecognitionText:(NSString *)speechRecognitionText {
    _speechRecognitionText = speechRecognitionText;
    [_textLabel setText:speechRecognitionText];
}

- (void)setSpeechRecognitionImage:(UIImage *)speechRecognitionImage {
    _speechRecognitionImage = speechRecognitionImage;
    [_imageView setImage:speechRecognitionImage];
}

- (void)tintColorDidChange {
    [self applyKeyColor];
}

- (void)setFinished:(BOOL)finished {
    _finished = finished;
}

- (void)applyKeyColor {
    UIColor *keyColor = [self keyColor];
    _graphView.keyColor = keyColor;
}

- (UIColor *)keyColor {
    return _keyColor ? : [self tintColor];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = keyColor;
    [self applyKeyColor];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _textLabel, _transcriptLabel, _graphView, _recordButton);
    const CGFloat graphHeight = 150;
    
    // In case the text on the button is large, ensure that the button can grow larger than the default height if needed
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_imageView]-[_textLabel]-(5)-[_graphView(graphHeight)]-[_transcriptLabel]-buttonGap-[_recordButton(50@250)]-topBottomMargin-|"
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
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_imageView]-|"
                                             options:0
                                             metrics: nil
                                               views:views]];
    
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
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_transcriptLabel]-|"
                                             options:0
                                             metrics: @{@"sideMargin": @(sideMargin)}
                                               views:views]];
    
    // In case the text on the button is large, ensure that the button can grow larger than the default width if needed
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-twiceSideMargin@250-[_recordButton(200@250)]-twiceSideMargin@250-|"
                                             options:0
                                             metrics: @{@"twiceSideMargin": @(twiceSideMargin)}
                                               views:views]];
    [constraints addObject:[_recordButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    [constraints addObject:[_recordButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor]];
    [constraints addObject:[_recordButton.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setShouldHideTranscript:(BOOL)shouldHideTranscript {
    _shouldHideTranscript = shouldHideTranscript;
    if (shouldHideTranscript) {
        _transcriptLabel.text = nil;
    }
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

- (void)updateRecognitionText:(NSString *)recognitionText {
    if (!_shouldHideTranscript) {
        _transcriptLabel.text = recognitionText;
    }
}

- (void)addRecognitionError:(NSString *)errorMsg {
    _transcriptLabel.textColor = [UIColor ork_redColor];
    _transcriptLabel.text = errorMsg;
}

- (void)removeAllSamples {
    _samples = nil;
    [self updateGraphSamples];
}

@end
