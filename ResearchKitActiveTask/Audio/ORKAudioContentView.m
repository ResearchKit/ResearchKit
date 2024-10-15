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

static const CGFloat ORKAudioStepContentRecordButtonVerticalSpacing = 20.0;

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

@property (nonatomic, strong) ORKHeadlineLabel *alertLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) ORKAudioMeteringView *graphView;
@property (nonatomic, copy, nullable) ORKAudioStepContentViewEventHandler viewEventhandler;

@end


@implementation ORKAudioContentView {
    NSMutableArray *_samples;
    UIColor *_keyColor;
    ORKRecordButton *_recordButton;
    BOOL _checkAudioLevel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        _checkAudioLevel = YES;
        _useRecordButton = NO;
        
        self.alertLabel = [ORKHeadlineLabel new];
        _alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.timerLabel = [ORKAudioTimerLabel new];
        _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timerLabel.textAlignment = NSTextAlignmentRight;
        self.graphView = [[ORKAudioMeteringView alloc] init];
        _graphView.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.alertColor = [UIColor ork_redColor];
        
        [self addSubview:_alertLabel];
        [self addSubview:_timerLabel];
        [self addSubview:_graphView];
        
        _alertLabel.text = ORKLocalizedString(@"AUDIO_TOO_LOUD_LABEL", nil);
        // _timerLabel.text set in -updateTimerLabel:
        
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
    _alertLabel.text = failed ? ORKLocalizedString(@"AUDIO_GENERIC_ERROR_LABEL", nil) : ORKLocalizedString(@"AUDIO_TOO_LOUD_LABEL", nil);
    [self updateAlertLabelHidden];
}

- (void)setFinished:(BOOL)finished {
    _finished = finished;
    [self updateAlertLabelHidden];
}

- (void)setUseRecordButton:(BOOL)useRecordButton {
    _useRecordButton = useRecordButton;
    
    if (_useRecordButton) {
        _checkAudioLevel = NO;
        [_timerLabel setHidden: YES];
        
        [self setupRecordButton];
        [self setUpConstraints];
    }
}

- (void)applyKeyColor {
    UIColor *keyColor = [self keyColor];
    _timerLabel.textColor = keyColor;
    _graphView.meterColor = keyColor;
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
    _alertLabel.textColor = alertColor;
    _graphView.alertColor = alertColor;
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

- (void)buttonPressed:(ORKRecordButton *)recordButton {
    switch (recordButton.buttonType) {
        case ORKRecordButtonTypeRecord:
            [self invokeViewEventHandlerWithEvent:ORKAudioContentViewEventStartRecording];
            [_recordButton setButtonType:ORKRecordButtonTypeStop];
            break;
        default:
            [self invokeViewEventHandlerWithEvent:ORKAudioContentViewEventStopRecording];
            [_recordButton setButtonState:ORKRecordButtonStateDisabled];
            break;
    }
}

- (void)setupRecordButton {
    if (!_recordButton) {
        _recordButton = [[ORKRecordButton alloc] init];
        _recordButton.delegate = self;
        _recordButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_recordButton setButtonType:ORKRecordButtonTypeRecord];
        
        [self addSubview:_recordButton];
    }
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_timerLabel, _alertLabel, _graphView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_graphView]-[_alertLabel]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_alertLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    const CGFloat sideMargin = self.layoutMargins.left + (2 * ORKStandardLeftMarginForTableViewCell(self));
    const CGFloat innerMargin = 2;
    
    if (_useRecordButton) {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[_graphView]-sideMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY
                                                 metrics:@{@"sideMargin": @(sideMargin)}
                                                   views:views]];
        
        [constraints addObject:[_recordButton.topAnchor constraintEqualToAnchor:_graphView.bottomAnchor constant:ORKAudioStepContentRecordButtonVerticalSpacing]];
        [constraints addObject:[_recordButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    } else {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[_graphView]-innerMargin-[_timerLabel]-sideMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY
                                                 metrics:@{@"sideMargin": @(sideMargin), @"innerMargin": @(innerMargin)}
                                                   views:views]];
    }
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_graphView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:(GraphViewBlueZoneHeight + GraphViewRedZoneHeight * 2)]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    _graphView.alertThreshold = alertThreshold;
    [self updateGraphSamples];
}

- (void)setTimeLeft:(NSTimeInterval)timeLeft {
    _timeLeft = timeLeft;
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
    _timerLabel.text = string;
    _timerLabel.hidden = (string == nil);    
}

- (void)updateGraphSamples {
    _graphView.samples = _samples;
    [self updateAlertLabelHidden];
}

- (void)updateAlertLabelHidden {
    NSNumber *sample = _samples.lastObject;
    
    if (_checkAudioLevel) {
        BOOL show = (!_finished && (sample.doubleValue > _alertThreshold)) || _failed;
        
        if (_alertLabel.hidden && show) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, _alertLabel.text);
        }
        _alertLabel.hidden = !show;
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
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *timerAxString = _timerLabel.isHidden ? nil : _timerLabel.accessibilityLabel;
    NSString *alertAxString = _alertLabel.isHidden ? nil : _alertLabel.accessibilityLabel;
    return ORKAccessibilityStringForVariables(ORKLocalizedString(@"AX_AUDIO_BAR_GRAPH", nil), timerAxString, alertAxString);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitUpdatesFrequently;
}

@end

