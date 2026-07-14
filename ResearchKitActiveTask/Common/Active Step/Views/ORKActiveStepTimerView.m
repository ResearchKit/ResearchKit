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


#import "ORKActiveStepTimerView.h"

#import "ORKActiveStepTimer.h"
#import "ORKCountdownLabel.h"
#import "ORKTimerRingView.h"
#import "ORKSurveyAnswerCellForText.h"
#import "ORKSurveyAnswerCellForNumber.h"
#import "ORKTextButton.h"
#import "ORKVoiceEngine.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKActiveStep_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static void validateDuration(NSTimeInterval duration) {
    if (!(isfinite(duration) && duration > 0)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"duration must be a finite positive number, got %g", duration]
                                     userInfo:nil];
    }
}

// MARK: - ORKActiveStepTimerView

@implementation ORKActiveStepTimerView {
    BOOL _started;
    BOOL _registeredForNotifications;

    ORKActiveStepTimerViewStyle _style;
    ORKTimerRingView *_countDownTimerRing;
    ORKCountdownLabel *_countDownTimerLabel;

    NSLayoutConstraint *_countDownTimerLabelBottomToStartTimerButtonTopConstraint;
    NSLayoutConstraint *_countDownTimerLabelZeroHeightConstraint;
    NSLayoutConstraint *_startTimerButtonZeroHeightConstraint;
    NSLayoutConstraint *_startTimerButtonBottomConstraint;
    NSLayoutConstraint *_countDownTimerRingCenterYConstraint;
    NSLayoutConstraint *_countDownTimerRingSquareConstraint;
    NSLayoutConstraint *_startTimerButtonBelowRingConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Count Down
        {
            _countDownTimerLabel = [ORKCountdownLabel new];
            _countDownTimerLabel.textAlignment = NSTextAlignmentCenter;
            _countDownTimerLabel.text = @" ";
            
            [self addSubview:_countDownTimerLabel];
        }
        // Count down start button
        {
            _startTimerButton = [ORKTextButton new];
            [_startTimerButton setTitle:ORKLocalizedString(@"BUTTON_START_TIMER", nil) forState:UIControlStateNormal];
            [_startTimerButton addTarget:self action:@selector(startTimerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            _startTimerButton.exclusiveTouch = YES;
            
            [self addSubview:_startTimerButton];
        }
        
        _countDownTimerLabel.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setUpConstraints];
    }
    return self;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    ORKActiveStepViewController *viewController = self.activeStepViewController;
    if (viewController) {
        [self updateDisplay:viewController];
    }
}

- (void)setRegisteredForNotifications:(BOOL)registered {
    if (registered == _registeredForNotifications) {
        return;
    }

    registered = _registeredForNotifications;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (registered) {
        [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    } else {
        [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)didMoveToWindow {
    [self setRegisteredForNotifications:(self.window != nil)];
}

- (void)setStep:(ORKActiveStep *)step {
    validateDuration(step.stepDuration);
    _step = step;

    if (_style == ORKActiveStepTimerViewStyleRing) {
        _countDownTimerLabel.hidden = YES;
        BOOL hasTimerButton = (_step.hasCountDown && _step.shouldStartTimerAutomatically == NO);
        _startTimerButton.hidden = !hasTimerButton;
        _startTimerButton.alpha = 1;
        _countDownTimerRing.duration = step.stepDuration;
        _countDownTimerRing.timeLeft = step.stepDuration;
    } else {
        _countDownTimerLabel.hidden = !(_step.hasCountDown);
        BOOL hasTimerButton = (_step.hasCountDown && _step.shouldStartTimerAutomatically == NO);
        _startTimerButton.hidden = !hasTimerButton;
        _startTimerButton.alpha = 1;
    }

    [_countDownTimerLabel setCountDownValue:(NSInteger)[_step stepDuration]];

    [self setNeedsUpdateConstraints];
}

- (void)startTimerButtonTapped:(id)sender {
    [self.activeStepViewController start];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _countDownTimerLabel);
}

- (void)updateDisplay:(ORKActiveStepViewController *)viewController {
    NSInteger countDownValue = (NSInteger)round(viewController.timeRemaining);
    [_countDownTimerLabel setCountDownValue:countDownValue];
    if (_style == ORKActiveStepTimerViewStyleRing) {
        _countDownTimerRing.timeLeft = viewController.timeRemaining;
    }
}

- (void)resetStep:(ORKActiveStepViewController *)viewController {
    self.step = (ORKActiveStep *)viewController.step;
}

- (void)startStep:(ORKActiveStepViewController *)viewController {
    _startTimerButton.alpha = 0;
}

- (void)suspendStep:(ORKActiveStepViewController *)viewController {
}

- (void)resumeStep:(ORKActiveStepViewController *)viewController {
    self.step = (ORKActiveStep *)viewController.step;
    if ([viewController timerActive]) {
        _startTimerButton.alpha = 0;
        [self updateDisplay:viewController];
    }
}

- (void)finishStep:(ORKActiveStepViewController *)viewController {
    if (_style == ORKActiveStepTimerViewStyleRing) {
        _countDownTimerRing.labelHidden = YES;
    }
}

- (void)setImage:(UIImage *)image {
    _countDownTimerRing.image = image;
}

- (UIImage *)image {
    return _countDownTimerRing.image;
}

- (void)setLabelHidden:(BOOL)labelHidden {
    _countDownTimerRing.labelHidden = labelHidden;
}

- (BOOL)labelHidden {
    return _countDownTimerRing.labelHidden;
}

static const CGFloat CountDownLabelToButtonMargin = 2.0;
static const CGFloat StartButtonInsetFromRingBottom = 60.0;

- (void)setUpConstraints {
    NSDictionary *views = NSDictionaryOfVariableBindings(_countDownTimerLabel, _startTimerButton);
    ORKEnableAutoLayoutForViews(views.allValues);
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    for (UIView *view in views.allValues) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0.0]];
    }
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_countDownTimerLabel
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0.0]];

    _countDownTimerLabelBottomToStartTimerButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_startTimerButton
                                                                                        attribute:NSLayoutAttributeTop
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:_countDownTimerLabel
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                       multiplier:1.0
                                                                                         constant:CountDownLabelToButtonMargin];
    [constraints addObject:_countDownTimerLabelBottomToStartTimerButtonTopConstraint];

    _startTimerButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:_startTimerButton
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [constraints addObject:_startTimerButtonBottomConstraint];

    [NSLayoutConstraint activateConstraints:constraints];
    
    _countDownTimerLabelZeroHeightConstraint = [NSLayoutConstraint constraintWithItem:_countDownTimerLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:0.0];
    _startTimerButtonZeroHeightConstraint = [NSLayoutConstraint constraintWithItem:_startTimerButton
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    _countDownTimerLabelZeroHeightConstraint.active = _countDownTimerLabel.hidden;
    _startTimerButtonZeroHeightConstraint.active = _startTimerButton.hidden;
    _countDownTimerLabelBottomToStartTimerButtonTopConstraint.constant =
    (_countDownTimerLabel.hidden || _startTimerButton.hidden) ? 0.0 : CountDownLabelToButtonMargin;
    [super updateConstraints];
}

- (void)setStyle:(ORKActiveStepTimerViewStyle)style {
    if (_style == style) {
        return;
    }
    _style = style;

    if (_style == ORKActiveStepTimerViewStyleRing && _countDownTimerRing == nil) {
        _countDownTimerRing = [[ORKTimerRingView alloc] initWithDuration:_step.stepDuration];
        _countDownTimerRing.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_countDownTimerRing];
        [self bringSubviewToFront:_startTimerButton];

        _countDownTimerRingCenterYConstraint = [NSLayoutConstraint constraintWithItem:_countDownTimerRing
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:0.8
                                                                          constant:0];
        _countDownTimerRingSquareConstraint = [_countDownTimerRing.heightAnchor constraintEqualToAnchor:_countDownTimerRing.widthAnchor];
        _startTimerButtonBelowRingConstraint = [_startTimerButton.topAnchor constraintEqualToAnchor:_countDownTimerRing.bottomAnchor constant:-StartButtonInsetFromRingBottom];
        [NSLayoutConstraint activateConstraints:@[
            _countDownTimerRingCenterYConstraint,
            _countDownTimerRingSquareConstraint,
            [_countDownTimerRing.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_countDownTimerRing.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            _startTimerButtonBelowRingConstraint,
        ]];
    }

    BOOL isRing = (_style == ORKActiveStepTimerViewStyleRing);
    _countDownTimerRing.hidden = !isRing;
    _countDownTimerLabelBottomToStartTimerButtonTopConstraint.active = !isRing;
    _startTimerButtonBottomConstraint.active = !isRing;
    _countDownTimerRingCenterYConstraint.active = isRing;
    _startTimerButtonBelowRingConstraint.active = isRing;

    if (_step) {
        [self setStep:_step];
    }
    [self setNeedsUpdateConstraints];
}

- (void)hideStartTimerButton {
    _startTimerButton.hidden = YES;
    [self setNeedsUpdateConstraints];
}

@end
