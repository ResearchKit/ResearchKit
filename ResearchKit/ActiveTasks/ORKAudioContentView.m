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

#import "ORKHeadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


// The central blue region.
static const CGFloat GraphViewBlueZoneHeight = 170;

// The two bands at top and bottom which are "loud" each have this height.
static const CGFloat GraphViewRedZoneHeight = 25;


@interface ORKAudioGraphView : UIView

@property (nonatomic, strong) UIColor *keyColor;
@property (nonatomic, strong) UIColor *alertColor;

@property (nonatomic, copy) NSArray *values;

@property (nonatomic) CGFloat alertThreshold;

@end


static const CGFloat ValueLineWidth = 4.5;
static const CGFloat ValueLineMargin = 1.5;

@implementation ORKAudioGraphView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpConstraints];
        
#if TARGET_IPHONE_SIMULATOR
        _values = @[@(0.2),@(0.6),@(0.55), @(0.1), @(0.75), @(0.7)];
#endif
    }
    return self;
}

- (void)setUpConstraints {
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:CGFLOAT_MAX];
    heightConstraint.priority = UILayoutPriorityFittingSizeLevel;
    
    [NSLayoutConstraint activateConstraints:@[heightConstraint]];
}

- (void)setValues:(NSArray *)values {
    _values = [values copy];
    [self setNeedsDisplay];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = [keyColor copy];
    [self setNeedsDisplay];
}

- (void)setAlertColor:(UIColor *)alertColor {
    _alertColor = [alertColor copy];
    [self setNeedsDisplay];
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, bounds);
    
    CGFloat scale = self.window.screen.scale;
    
    CGFloat midY = CGRectGetMidY(bounds);
    CGFloat maxX = CGRectGetMaxX(bounds);
    CGFloat halfHeight = bounds.size.height / 2;
    CGContextSaveGState(context);
    {
        UIBezierPath *centerLine = [UIBezierPath new];
        [centerLine moveToPoint:(CGPoint){.x = 0, .y = midY}];
        [centerLine addLineToPoint:(CGPoint){.x = maxX, .y = midY}];
        
        CGContextSetLineWidth(context, 1.0 / scale);
        [_keyColor setStroke];
        CGFloat lengths[2] = {3, 3};
        CGContextSetLineDash(context, 0, lengths, 2);
        
        [centerLine stroke];
    }
    CGContextRestoreGState(context);
    
    CGFloat lineStep = ValueLineMargin + ValueLineWidth;
    
    CGContextSaveGState(context);
    {
        CGFloat x = maxX - lineStep / 2;
        CGContextSetLineWidth(context, ValueLineWidth);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        UIBezierPath *path1 = [UIBezierPath new];
        path1.lineCapStyle = kCGLineCapRound;
        path1.lineWidth = ValueLineWidth;
        UIBezierPath *path2 = [path1 copy];
        
        for (NSNumber *value in [_values reverseObjectEnumerator]) {
            CGFloat floatValue = value.doubleValue;
            
            UIBezierPath *path = nil;
            if (floatValue > _alertThreshold) {
                path = path1;
                [_alertColor setStroke];
            } else {
                path = path2;
                [_keyColor setStroke];
            }
            [path moveToPoint:(CGPoint){.x = x, .y = midY - floatValue*halfHeight}];
            [path addLineToPoint:(CGPoint){.x = x, .y = midY + floatValue*halfHeight}];
            
            x -= lineStep;
            
            if (x < 0) {
                break;
            }
            
        }
        
        [_alertColor setStroke];
        [path1 stroke];
        
        [_keyColor setStroke];
        [path2 stroke];
        
    }
    CGContextRestoreGState(context);
}

@end


@interface ORKAudioTimerLabel : ORKLabel

@end


@implementation ORKAudioTimerLabel

+ (UIFont *)defaultFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *alternativeDescriptor = ORKFontDescriptorForLightStylisticAlternative(descriptor);
    return [UIFont fontWithDescriptor:alternativeDescriptor size:[alternativeDescriptor pointSize] + 4];
}

@end


@interface ORKAudioContentView ()

@property (nonatomic, strong) ORKHeadlineLabel *alertLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) ORKAudioGraphView *graphView;

@end


@implementation ORKAudioContentView {
    NSMutableArray *_samples;
    UIColor *_keyColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        
        self.alertLabel = [ORKHeadlineLabel new];
        _alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.timerLabel = [ORKAudioTimerLabel new];
        _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timerLabel.textAlignment = NSTextAlignmentRight;
        self.graphView = [ORKAudioGraphView new];
        _graphView.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.alertColor = [UIColor ork_redColor];
        
        [self addSubview:_alertLabel];
        [self addSubview:_timerLabel];
        [self addSubview:_graphView];
        
        _timerLabel.text = @"06:00";
        _alertLabel.text = ORKLocalizedString(@"AUDIO_TOO_LOUD_LABEL", nil);
        
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

- (void)applyKeyColor {
    UIColor *keyColor = [self keyColor];
    _timerLabel.textColor = keyColor;
    _graphView.keyColor = keyColor;
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

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[_graphView]-innerMargin-[_timerLabel]-sideMargin-|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:@{@"sideMargin": @(sideMargin), @"innerMargin": @(innerMargin)}
                                               views:views]];
    
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
        NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    });
    
    NSString *string = [formatter stringFromTimeInterval:MAX(round(_timeLeft),0)];
    _timerLabel.text = string;
    _timerLabel.hidden = (string == nil);    
}

- (void)updateGraphSamples {
    _graphView.values = _samples;
    [self updateAlertLabelHidden];
}

- (void)updateAlertLabelHidden {
    NSNumber *sample = _samples.lastObject;
    BOOL show = (!_finished && (sample.doubleValue > _alertThreshold)) || _failed;
    
    if (_alertLabel.hidden && show) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, _alertLabel.text);
    }
    _alertLabel.hidden = !show;
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
