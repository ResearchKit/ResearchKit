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
#import "ORKAudioMeteringView.h"

#import "ORKHeadlineLabel.h"
#import "ORKSubheadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKRecordButton.h"

static CGFloat const ORKSpeechRecognitionContentFlamesViewHeightConstant = 150.0;
static CGFloat const ORKSpeechRecognitionContentFlamesViewMaxOffset = 44.0;
static CGFloat const ORKSpeechRecognitionContentRecordButtonVerticalSpacing = 20.0;
static CGFloat const ORKSpeechRecognitionContentBottomLayoutMargin = 44.0;

@interface ORKSpeechRecognitionContentView () <UITextFieldDelegate, ORKRecordButtonDelegate>

@property (nonatomic, strong) ORKAudioMeteringView *graphView;
@property (nonatomic, strong) ORKSubheadlineLabel *transcriptLabel;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *constraints;

@end

@implementation ORKSpeechRecognitionContentView {
    NSMutableArray *_samples;
    UIColor *_keyColor;
    UIImageView *_imageView;
    UILabel *_textLabel;
    UIButton *_useKeyboardButton;
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
        [self setupUseKeyboardButton];
        [self updateGraphSamples];
        [self applyKeyColor];
        [self setUpConstraints];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self setUpConstraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self setUpConstraints];
    
    
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc]
                                           initWithString:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_USE_KEYBOARD_INSTEAD", nil)
                                           attributes:@{NSFontAttributeName:[self buttonTextFont],
                                                        NSForegroundColorAttributeName:self.tintColor}];
    [_useKeyboardButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

- (void)setupImageView {
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.backgroundColor = [UIColor redColor];
    [self addSubview:_imageView];
}

- (void)setupTextLabel {
    _textLabel = [UILabel new];
    _textLabel.backgroundColor = [UIColor greenColor];
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
    self.graphView = [[ORKAudioMeteringView alloc] init];
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

- (void)setupRecordButton
{
    if (!_recordButton)
    {
        self.recordButton = [[ORKRecordButton alloc] init];
        self.recordButton.delegate = self;
        self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.recordButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStartsMediaSession;
        self.recordButton.accessibilityHint = ORKLocalizedString(@"AX_SPEECH_RECOGNITION_START_RECORDING_HINT", nil);
        [self addSubview:_recordButton];
    }
}

- (void)buttonPressed:(ORKRecordButton *)recordButton
{
    if ([self.delegate conformsToProtocol:@protocol(ORKSpeechRecognitionContentViewDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressRecordButton:)])
    {
        [self.delegate didPressRecordButton:recordButton];
    }
    
    switch ([recordButton buttonType])
    {
        case ORKRecordButtonTypeRecord:
            
            [recordButton setButtonType:ORKRecordButtonTypeStop animated:YES];
            [self setKeyboardButtonEnabled:NO];
            break;
            
        default:
            [recordButton setButtonType:ORKRecordButtonTypeRecord animated:YES];
            [self setKeyboardButtonEnabled:YES];
            break;
    }
}

- (void)updateButtonStates
{
    switch ([_recordButton buttonType])
       {
           case ORKRecordButtonTypeRecord:
               
               [self setKeyboardButtonEnabled:YES];
               break;
               
           default:
               [self setKeyboardButtonEnabled:NO];
               break;
       }
}

- (void)setupUseKeyboardButton
{
    _useKeyboardButton = [[UIButton alloc] init];
    if (@available(iOS 13.0, *))
    {
        [_useKeyboardButton setImage:[UIImage systemImageNamed:@"keyboard" compatibleWithTraitCollection:self.traitCollection] forState:UIControlStateNormal];
    }
    _useKeyboardButton.adjustsImageWhenHighlighted = NO;
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:ORKLocalizedString(@"SPEECH_IN_NOISE_PREDEFINED_USE_KEYBOARD_INSTEAD", nil)
                                                                          attributes:@{NSFontAttributeName:[self buttonTextFont],
                                                                                       NSForegroundColorAttributeName:self.tintColor}];
    [_useKeyboardButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [_useKeyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    _useKeyboardButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _useKeyboardButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    CGFloat spacing = 8;
    _useKeyboardButton.imageEdgeInsets = UIEdgeInsetsMake(0, -(spacing/2), 0, (spacing/2));
    _useKeyboardButton.titleEdgeInsets = UIEdgeInsetsMake(0, (spacing/2), 0, -(spacing/2));
    _useKeyboardButton.contentEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, -spacing);
    [self addSubview:_useKeyboardButton];
    
    [_useKeyboardButton addTarget:self action:@selector(useKeyboardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setKeyboardButtonEnabled:(BOOL)enabled
{
    _useKeyboardButton.userInteractionEnabled = enabled;
    _useKeyboardButton.alpha = enabled ? 1.0 : 0.25;
}

- (void)useKeyboardButtonPressed
{
    if ([self.delegate conformsToProtocol:@protocol(ORKSpeechRecognitionContentViewDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressUseKeyboardButton)])
    {
        [self.delegate didPressUseKeyboardButton];
    }
}

- (UIFont *)buttonTextFont
{
    CGFloat fontSize = [[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCallout] pointSize];
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
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
    [_graphView setMeterColor:keyColor];
}

- (UIColor *)keyColor {
    return _keyColor ? : [self tintColor];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = keyColor;
    [self applyKeyColor];
}

- (void)setUpConstraints
{
    if (self.constraints.count > 0)
    {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
    }
      
    NSLayoutConstraint *centeredGraphOnScreenLayoutConstraint = [_graphView.centerYAnchor constraintLessThanOrEqualToAnchor:self.centerYAnchor constant:-ORKSpeechRecognitionContentFlamesViewMaxOffset];
    centeredGraphOnScreenLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    
    self.constraints = @[
        
        [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        
        [_textLabel.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor],
        [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        
        [_graphView.topAnchor constraintGreaterThanOrEqualToAnchor:_textLabel.bottomAnchor],
        centeredGraphOnScreenLayoutConstraint,
        [_graphView.heightAnchor constraintEqualToConstant:ORKSpeechRecognitionContentFlamesViewHeightConstant],
        [_graphView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_graphView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        
        [_transcriptLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_transcriptLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_transcriptLabel.topAnchor constraintGreaterThanOrEqualToAnchor:_graphView.bottomAnchor],
        [_transcriptLabel.bottomAnchor constraintEqualToAnchor:_recordButton.topAnchor constant:-ORKSpeechRecognitionContentRecordButtonVerticalSpacing],
        [_recordButton.topAnchor constraintGreaterThanOrEqualToAnchor:_transcriptLabel.bottomAnchor constant:ORKSpeechRecognitionContentRecordButtonVerticalSpacing],
        
        [_recordButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        
        [_useKeyboardButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_useKeyboardButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_useKeyboardButton.topAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:ORKSpeechRecognitionContentRecordButtonVerticalSpacing],
        [_useKeyboardButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-ORKSpeechRecognitionContentBottomLayoutMargin]
    ];
        
    [NSLayoutConstraint activateConstraints:self.constraints];
}

- (void)setShouldHideTranscript:(BOOL)shouldHideTranscript {
    _shouldHideTranscript = shouldHideTranscript;
    if (shouldHideTranscript) {
        _transcriptLabel.text = nil;
    }
}

- (void)updateGraphSamples {
    _graphView.samples = _samples;
}

- (void)addSample:(NSNumber *)sample {
    
    NSAssert(sample != nil, @"Sample should be non-nil");
    
    if (!_samples) {
        _samples = [NSMutableArray array];
    }
    [_samples addObject:sample];
    
    _samples = [ORKLastNSamples(_samples, 500) mutableCopy];
    
    [self updateGraphSamples];
}

- (void)updateRecognitionText:(NSString *)recognitionText {
    if (!_shouldHideTranscript) {
        _transcriptLabel.text = recognitionText;
    }
}

- (void)addRecognitionError:(NSString * _Nullable)errorMsg
{
    _transcriptLabel.textColor = [UIColor ork_redColor];
    _transcriptLabel.text = errorMsg;
}

- (void)removeAllSamples {
    _samples = nil;
    [self updateGraphSamples];
}

@end

