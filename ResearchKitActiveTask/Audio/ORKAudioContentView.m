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



#import "ORKAudioContentView.h"
#import "ORKAudioMeteringView.h"

#import "ORKHeadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKRecordButton.h"


// The central blue region.
static const CGFloat GraphViewBlueZoneHeight = 170;

// The two bands at top and bottom which are "loud" each have this height.
static const CGFloat GraphViewRedZoneHeight = 25;

@interface ORKAudioTimerLabel : ORKLabel

@end


@implementation ORKAudioTimerLabel

+ (UIFont *)defaultFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *alternativeDescriptor = ORKFontDescriptorForLightStylisticAlternative(descriptor);
    return [UIFont fontWithDescriptor:alternativeDescriptor size:[alternativeDescriptor pointSize] + 4];
}

@end

@interface ORKAudioContentView () <ORKRecordButtonDelegate>

@property (nonatomic, strong) UIView *alertLabelContainerView;
@property (nonatomic, strong) ORKHeadlineLabel *alertLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) ORKAudioMeteringView *graphView;
@property (nonatomic, strong) ORKRecordButton *recordButton;
@property (nonatomic, copy, nullable) ORKAudioStepContentViewEventHandler viewEventhandler;
@property (nonatomic, strong) UIStackView *graphStackView;
@property (nonatomic, strong) UIStackView *contentStackView;

@end


@implementation ORKAudioContentView {
    NSMutableArray *_constraints;
    NSMutableArray *_samples;
    UIColor *_keyColor;
    BOOL _checkAudioLevel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        _checkAudioLevel = YES;
        _useRecordButton = NO;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.alertColor = [UIColor ork_redColor];
        self.alertThreshold = GraphViewBlueZoneHeight / ((GraphViewRedZoneHeight * 2) + GraphViewBlueZoneHeight);
        
        [self updateGraphSamples];
        [self applyKeyColor];
        [self setUpConstraints];
    }
    return self;
}

- (void)tintColorDidChange {
    [self applyKeyColor];
}

- (void)setFailed:(BOOL)failed {
    _failed = failed;
    self.alertLabel.text = failed ? ORKLocalizedString(@"AUDIO_GENERIC_ERROR_LABEL", nil) : ORKLocalizedString(@"AUDIO_TOO_LOUD_LABEL", nil);
    [self updateAlertLabelHidden];
}

- (void)setFinished:(BOOL)finished {
    _finished = finished;
    [self updateAlertLabelHidden];
}

- (void)setUseRecordButton:(BOOL)useRecordButton {
    _useRecordButton = useRecordButton;
    [self.recordButton setHidden:!_useRecordButton];
}

- (void)applyKeyColor {
    UIColor *keyColor = [self keyColor];
    self.timerLabel.textColor = keyColor;
    self.graphView.meterColor = keyColor;
}

- (UIColor *)keyColor {
    return _keyColor ? : [self tintColor];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = keyColor;
    [self applyKeyColor];
}

- (void)setAlertColor:(UIColor *)alertColor {
    _alertColor = alertColor;
    self.alertLabel.textColor = alertColor;
    self.graphView.alertColor = alertColor;
}

- (UIStackView *)graphStackView {
    if (_graphStackView == nil) {
        _graphStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.graphView, self.timerLabel]];
        [_graphStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_graphStackView setAxis:UILayoutConstraintAxisHorizontal];
        [_graphStackView setDistribution:UIStackViewDistributionFill];
        const CGFloat innerMargin = 2;
        [_graphStackView setSpacing:innerMargin];
    }
    
    return _graphStackView;
}

- (UIStackView *)contentStackView {
    if (_contentStackView == nil) {
        _contentStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.graphStackView, self.alertLabelContainerView, self.recordButton]];
        [_contentStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_contentStackView setAxis:UILayoutConstraintAxisVertical];
        [_contentStackView setDistribution:UIStackViewDistributionFill];
        [_contentStackView setSpacing:20.0];
        
        [self addSubview:_contentStackView];
    }
    
    return _contentStackView;
}

- (void)setViewEventHandler:(ORKAudioStepContentViewEventHandler)handler {
    self.viewEventhandler = [handler copy];
}

- (void)invokeViewEventHandlerWithEvent:(ORKAudioContentViewEvent)event {
    if (self.viewEventhandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.viewEventhandler(event);
        });
    }
}

- (ORKAudioMeteringView *)graphView {
    if (_graphView == nil) {
        _graphView = [[ORKAudioMeteringView alloc] init];
        _graphView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _graphView;
}

- (UILabel *)timerLabel {
    if (_timerLabel == nil) {
        _timerLabel = [ORKAudioTimerLabel new];
        _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timerLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _timerLabel;
}

- (UIView *)alertLabelContainerView {
    if (_alertLabelContainerView == nil) {
        _alertLabelContainerView = [UIView new];
        [_alertLabelContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_alertLabelContainerView setBackgroundColor:[UIColor clearColor]];
        
        [_alertLabelContainerView addSubview:self.alertLabel];
    }
    
    return _alertLabelContainerView;
}

- (ORKHeadlineLabel *)alertLabel {
    if (_alertLabel == nil) {
        _alertLabel = [ORKHeadlineLabel new];
        _alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _alertLabel.text = ORKLocalizedString(@"AUDIO_TOO_LOUD_LABEL", nil);
    }
    
    return _alertLabel;
}

- (ORKRecordButton *)recordButton {
    if (_recordButton == nil) {
        _recordButton = [[ORKRecordButton alloc] init];
        _recordButton.delegate = self;
        _recordButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_recordButton setHidden:YES];
        [_recordButton setButtonType:ORKRecordButtonTypeRecord];
    }
    
    return _recordButton;
}

- (void)setUpConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray array];
    
    const CGFloat sideMargin = self.layoutMargins.left + (2 * ORKStandardLeftMarginForTableViewCell(self));
    
    // content stack view constraints
    [_constraints addObject:[self.contentStackView.topAnchor constraintEqualToAnchor:self.topAnchor]];
    [_constraints addObject:[self.contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-sideMargin]];
    [_constraints addObject:[self.contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:sideMargin]];
    [_constraints addObject:[self.bottomAnchor constraintEqualToAnchor:_contentStackView.bottomAnchor]];
    
    // alert label + alert label container view constraints
    [_constraints addObject:[self.alertLabel.centerXAnchor constraintEqualToAnchor:self.alertLabelContainerView.centerXAnchor]];
    [_constraints addObject:[self.alertLabel.centerYAnchor constraintEqualToAnchor:self.alertLabelContainerView.centerYAnchor]];
    [_constraints addObject:[self.alertLabel.topAnchor constraintEqualToAnchor:self.alertLabelContainerView.topAnchor]];
    [_constraints addObject:[self.alertLabel.bottomAnchor constraintEqualToAnchor:self.alertLabelContainerView.bottomAnchor]];
    
    // graph view constraints
    [_constraints addObject:[NSLayoutConstraint constraintWithItem:self.graphView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:(GraphViewBlueZoneHeight + GraphViewRedZoneHeight * 2)]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)buttonPressed:(ORKRecordButton *)recordButton {
    switch (recordButton.buttonType) {
        case ORKRecordButtonTypeRecord:
            [self invokeViewEventHandlerWithEvent:ORKAudioContentViewEventStartRecording];
            
            if (_timeLeft > 0) {
                // if step duration is set, hide the button and allow the timer to end the recording.
                [self.recordButton setHidden:YES];
            } else {
                [self.recordButton setButtonType:ORKRecordButtonTypeStop];
            }
           
            break;
        default:
            [self invokeViewEventHandlerWithEvent:ORKAudioContentViewEventStopRecording];
            [self.recordButton setButtonState:ORKRecordButtonStateDisabled];
            break;
    }
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    self.graphView.alertThreshold = alertThreshold;
    [self updateGraphSamples];
}

- (void)setTimeLeft:(NSTimeInterval)timeLeft {
    _timeLeft = timeLeft;
    
    // if timeLeft is 0 and timerLabel's text hasn't been set, the timerLabel isn't intended to be used.
    if (_timeLeft == 0 && self.timerLabel.text == nil) {
        [self.timerLabel setHidden:YES];
        return;
    }
    
    [self updateTimerLabel];
}

- (void)updateTimerLabel {
    static NSDateComponentsFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateComponentsFormatter new];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    });
    
    NSString *string = [formatter stringFromTimeInterval:MAX(round(_timeLeft),0)];
    self.timerLabel.text = string;
    self.timerLabel.hidden = (string == nil);
}

- (void)updateGraphSamples {
    self.graphView.samples = _samples;
    [self updateAlertLabelHidden];
}

- (void)updateAlertLabelHidden {
    NSNumber *sample = _samples.lastObject;
    
    if (_checkAudioLevel) {
        BOOL show = (!_finished && (sample.doubleValue > _alertThreshold)) || _failed;
        
        if (self.alertLabel.hidden && show) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.alertLabel.text);
        }
        self.alertLabel.hidden = !show;
    }
}

- (void)setSamples:(NSArray *)samples {
    _samples = [samples mutableCopy];
    [self updateGraphSamples];
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

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    // Set this to NO in order to prevent voiceover from ignoring it's subviews
    return NO;
}

- (NSString *)accessibilityLabel {
    NSString *timerAxString = self.timerLabel.isHidden ? nil : self.timerLabel.accessibilityLabel;
    NSString *alertAxString = self.alertLabel.isHidden ? nil : self.alertLabel.accessibilityLabel;
    return ORKAccessibilityStringForVariables(ORKLocalizedString(@"AX_AUDIO_BAR_GRAPH", nil), timerAxString, alertAxString);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitUpdatesFrequently;
}

@end

