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


#import "ORKCountdownStepViewController.h"

#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKLabel.h"
#import "ORKSubheadlineLabel.h"
#import "ORKVerticalContainerView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKActiveStep.h"
#import "ORKResult.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"


@interface ORKCountDownViewLabel : ORKLabel

@end


@implementation ORKCountDownViewLabel
+ (UIFont *)defaultFont {
    return ORKThinFontWithSize(56);
}
@end


@interface ORKCountdownView : ORKActiveStepCustomView

@property (nonatomic, strong) ORKSubheadlineLabel *textLabel;
@property (nonatomic, strong) ORKCountDownViewLabel *timeLabel;
@property (nonatomic, strong) UIView *progressView;

- (void)startAnimateWithDuration:(NSTimeInterval)duration;

@end


@implementation ORKCountdownView {
    CAShapeLayer *_circleLayer;
}

static const CGFloat ProgressIndicatorDiameter = 104.0;
static const CGFloat ProgressIndicatorOuterMargin = 1.0;

- (instancetype)init {
    self = [super init];
    if (self) {
        _textLabel = [ORKSubheadlineLabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.text =  ORKLocalizedString(@"COUNTDOWN_LABEL", nil);
        [self addSubview:_textLabel];
        
        _timeLabel = [ORKCountDownViewLabel new];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLabel];
        
        _progressView = [UIView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressView];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setUpConstraints];
        
        _circleLayer = [CAShapeLayer layer];
        static const CGFloat ProgressIndicatorRadius = ProgressIndicatorDiameter / 2;
        _circleLayer.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(ProgressIndicatorRadius + ProgressIndicatorOuterMargin, ProgressIndicatorRadius + ProgressIndicatorOuterMargin)
                                                            radius:ProgressIndicatorRadius
                                                        startAngle:M_PI + M_PI_2
                                                          endAngle:-M_PI_2
                                                         clockwise:NO] CGPath];
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = self.tintColor.CGColor;
        _circleLayer.lineWidth = 1;
        
        [_progressView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [_progressView.layer addSublayer:_circleLayer];
        
        _textLabel.isAccessibilityElement = NO;
        _timeLabel.isAccessibilityElement = NO;
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *metrics = @{@"d": @(ProgressIndicatorDiameter + 2 * ProgressIndicatorOuterMargin)};
    NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel, _timeLabel, _progressView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]-(>=0)-[_progressView(==d)]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing | NSLayoutFormatAlignAllCenterX
                                                                             metrics:metrics
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_textLabel]-(>=0)-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_progressView(==d)]-(>=0)-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_progressView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_timeLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_progressView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    // Constant required in order to give appearance of vertical centering (compensating for leading on font)
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_timeLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_progressView
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:-3.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_progressView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_textLabel
                                                        attribute:NSLayoutAttributeLastBaseline
                                                       multiplier:1.0
                                                         constant:16.0 - ProgressIndicatorOuterMargin]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)tintColorDidChange {
    _circleLayer.strokeColor = self.tintColor.CGColor;
}

- (void)startAnimateWithDuration:(NSTimeInterval)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = duration * 2;
    animation.removedOnCompletion = YES;
    animation.values = @[ @(1.0), @(0.0), @(0.0) ];
    animation.keyTimes =  @[ @(0.0), @(0.5), @(1.0) ];
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_circleLayer addAnimation:animation forKey:@"drawCircleAnimation"];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return ORKAccessibilityStringForVariables(_textLabel.accessibilityLabel, _timeLabel.accessibilityLabel);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitUpdatesFrequently;
}

@end


@interface ORKCountdownStepViewController ()

@property (nonatomic, strong) ORKCountdownView *countdownView;

@end


@implementation ORKCountdownStepViewController {
    NSInteger _countDown;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = NO;
    }
    return self;
}

- (void)setStep:(ORKStep *)step {
    [super setStep:step];
    _countDown = round([(ORKActiveStep *)step stepDuration]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.learnMoreButtonItem = nil;
    
    _countdownView = [[ORKCountdownView alloc] init];
    _countdownView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _countdownView;
    
    [self updateCountdownLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @(_countDown).stringValue);
    [_countdownView startAnimateWithDuration:[(ORKActiveStep *)self.step stepDuration]];
}

- (void)updateCountdownLabel {
    _countdownView.timeLabel.text = ORKLocalizedStringFromNumber(@(_countDown));
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    _countDown = MAX((_countDown - 1), 0);
    [self updateCountdownLabel];
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] addObserverForName:UIAccessibilityAnnouncementDidFinishNotification
                                                              object:nil
                                                               queue:nil
                                                          usingBlock:^(NSNotification *note) {
                                                              [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
                                                              [super countDownTimerFired:timer finished:finished];
                                                          }];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, ORKLocalizedString(@"AX_ANNOUNCE_BEGIN_TASK", nil));
        } else {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @(_countDown).stringValue);
            [super countDownTimerFired:timer finished:finished];
        }
    } else {
        [super countDownTimerFired:timer finished:finished];
    }
}

@end
