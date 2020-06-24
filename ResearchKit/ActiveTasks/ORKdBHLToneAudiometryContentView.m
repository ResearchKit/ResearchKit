/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
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


#import "ORKdBHLToneAudiometryContentView.h"

#import "ORKRoundTappingButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat TopToProgressViewMinPadding = 10.0;

@interface TestingInProgressView : UIView

@property (nonatomic, assign, getter=isActive) BOOL active;

- (void)setProgress:(double)progress;

@end

@implementation TestingInProgressView
{
    CAShapeLayer *_indicatorLayer;
    UILabel *_textLabel;
    NSNumberFormatter *percentageFormatter;
}

static const CGFloat TestingInProgressIndicatorRadius = 6.0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    [self setupIndicatorLayer];
    [self setupTextLabel];
    
    percentageFormatter = [NSNumberFormatter new];
    percentageFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentageFormatter.roundingIncrement = @(10);
    percentageFormatter.roundingMode = NSNumberFormatterRoundHalfUp;
    percentageFormatter.locale = [NSLocale currentLocale];
}

#define PULSE_OPACITY 1
#define PULSE_SCALE 0
- (void)setActive:(BOOL)active
{
    _active = active;
    if (active)
    {
        const CFTimeInterval duration = 2.5;
        
#if PULSE_OPACITY
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.keyTimes = @[@(0), @(0.50), @(1.0)];
        opacityAnimation.values =   @[@(1), @(0.2), @(1)];
        opacityAnimation.duration = duration;
        opacityAnimation.repeatCount = CGFLOAT_MAX;
        [_indicatorLayer addAnimation:opacityAnimation forKey:@"opacity"];
        
#endif
        
#if PULSE_SCALE
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.xy"];
        scaleAnimation.keyTimes = @[@(0), @(0.50), @(1.0)];
        scaleAnimation.values =   @[@(1), @(0.4), @(1)];
        scaleAnimation.duration = duration;
        scaleAnimation.repeatCount = CGFLOAT_MAX;
        [_indicatorLayer addAnimation:scaleAnimation forKey:@"scale"];
#endif
    }
    else
    {
        [_indicatorLayer removeAllAnimations];
    }
}

- (void)setProgress:(double)progress
{
    _textLabel.text = [NSString stringWithFormat:ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TESTING_IN_PROGRESS_FMT", nil), [percentageFormatter stringFromNumber:@(progress)]];
}

- (void)setupTextLabel
{
    if (!_textLabel)
    {
        _textLabel = [[UILabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.textColor = [UIColor systemGrayColor];
        UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline
                                                                compatibleWithTraitCollection:self.traitCollection];
        _textLabel.font = [UIFont fontWithDescriptor:descriptor size:2 * TestingInProgressIndicatorRadius];
        _textLabel.text = ORKLocalizedString(@"dBHL_TONE_AUDIOMETRY_TESTING_IN_PROGRESS", nil);
        [self addSubview:_textLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_textLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:2 * TestingInProgressIndicatorRadius + 5.0],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
        ]];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Align the shape layer view to the edge of the
    if (_indicatorLayer)
    {
        // Set the anchor point to be the left most edge of the circle
        _indicatorLayer.position = CGPointMake(TestingInProgressIndicatorRadius, CGRectGetMidY(self.bounds));
    }
}

- (void)setupIndicatorLayer
{
    if (!_indicatorLayer)
    {
        _indicatorLayer = [self newCircleLayerWithRadius:TestingInProgressIndicatorRadius];
    }
    
    _indicatorLayer.fillColor = self.tintColor.CGColor;
    [self.layer addSublayer:_indicatorLayer];
}

// Make sure this method begins with create/new to avoid the compiler complaining about the potential leak.
- (CGPathRef)newCirclePathWithRadius:(CGFloat)radius
{
    CGPoint origin = CGPointZero;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, origin.x, origin.y, radius, 0, 2 * M_PI, YES);
    CGPathCloseSubpath(path);

    return path;
}

- (CAShapeLayer *)newCircleLayerWithRadius:(CGFloat)radius
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGPathRef path = [self newCirclePathWithRadius:radius];
    circle.path = path;
    CGPathRelease(path);
    return circle;
}

@end

@implementation ORKdBHLToneAudiometryButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.borderWidth = 15.0;
        self.layer.borderColor = UIColor.whiteColor.CGColor;
        self.layer.shadowRadius = 10.0;
        self.layer.shadowOpacity = 0.2;
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (void)updateBackgroundColor {
    [super updateBackgroundColor];
    self.layer.borderColor = UIColor.whiteColor.CGColor;
}

@end

@implementation ORKdBHLToneAudiometryContentView {
    NSLayoutConstraint *_topToProgressViewConstraint;
    UILabel *_progressLabel;
    TestingInProgressView *_progressView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _progressView = [[TestingInProgressView alloc] init];
        _progressView.active = NO;
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressView];
        _tapButton = [[ORKdBHLToneAudiometryButton alloc] init];
        [_tapButton setDiameter:150];
        _tapButton.translatesAutoresizingMaskIntoConstraints = NO;
        _tapButton.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitAllowsDirectInteraction;

        [self addSubview:_tapButton];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self setUpConstraints];
    }
    
    return self;
}

- (void)didMoveToWindow {
    if (self.window != nil && UIAccessibilityIsVoiceOverRunning()) {
        // Ensure that VoiceOver is aware of the direct touch area so that the first tap gets registered
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _tapButton);
    }
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (![_progressView isActive])
    {
        [_progressView setActive:YES];
    }
    
    [_progressView setProgress:progress];
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    [super finishStep:viewController];
    self.tapButton.enabled = NO;
}

- (void)setUpConstraints {
    NSArray<NSLayoutConstraint *> *constraints = @[
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:TopToProgressViewMinPadding],
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_progressView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_tapButton
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:_tapButton
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0
                                                                                 constant:0.0]
                                                   ];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
