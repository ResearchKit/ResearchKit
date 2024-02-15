/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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


#import "ORKLearnMoreView.h"
#import "ORKLearnMoreItem.h"
#import "ORKHelpers_Internal.h"
#import "ORKBodyItem.h"

ORK_CLASS_AVAILABLE
@interface ORKLearnMoreButton : UIButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;

+ (instancetype)learnMoreCustomButtonWithText:(NSString *)text;

+ (instancetype)learnMoreDetailDisclosureButton;


@end


@implementation ORKLearnMoreButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    ORKThrowMethodUnavailableException();
}

+ (instancetype)learnMoreCustomButtonWithText:(NSString *)text {
    ORKLearnMoreButton *button = [super buttonWithType:UIButtonTypeCustom];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [button setContentEdgeInsets:UIEdgeInsetsMake(CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN)];
    return button;
}

+ (instancetype)learnMoreDetailDisclosureButton {
    ORKLearnMoreButton *button = [super buttonWithType:UIButtonTypeDetailDisclosure];
    return button;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self.titleLabel invalidateIntrinsicContentSize];
}

@end

@interface ORKLearnMoreView()

@property (nonatomic, nonnull) ORKLearnMoreButton *learnMoreButton;

@end

@implementation ORKLearnMoreView {
    ORKLearnMoreButton *_learnMoreButton;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    ORKThrowMethodUnavailableException();
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithLearnMoreStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    self = [super init];
    if (self) {
        self.learnMoreInstructionStep = learnMoreInstructionStep;
    }
    return self;
}

+ (instancetype)learnMoreCustomButtonViewWithText:(NSString *)text LearnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    ORKLearnMoreView *learnMoreView = [[ORKLearnMoreView alloc] initWithLearnMoreStep:learnMoreInstructionStep];
    [learnMoreView setupCustomButtonWithText:text];
    return learnMoreView;
}

+ (instancetype)learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    ORKLearnMoreView *learnMoreView = [[ORKLearnMoreView alloc] initWithLearnMoreStep:learnMoreInstructionStep];
    [learnMoreView setupDetailDisclosureButton];
    return learnMoreView;
}

+ (instancetype)learnMoreViewWithItem:(ORKLearnMoreItem *)learnMoreItem {
    return learnMoreItem.text ? [ORKLearnMoreView learnMoreCustomButtonViewWithText:learnMoreItem.text LearnMoreInstructionStep:learnMoreItem.learnMoreInstructionStep] : [ORKLearnMoreView learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:learnMoreItem.learnMoreInstructionStep];
}

- (void)setupCustomButtonWithText:(NSString *)text {
    if (!_learnMoreButton) {
        _learnMoreButton = [ORKLearnMoreButton learnMoreCustomButtonWithText:text];
    }
    [self addSubview:_learnMoreButton];
    [_learnMoreButton addTarget:self action:@selector(presentLearnMoreViewController) forControlEvents:UIControlEventTouchUpInside];
    [self setupConstraints];
}

- (void)setupDetailDisclosureButton {
    if (!_learnMoreButton) {
        _learnMoreButton = [ORKLearnMoreButton learnMoreDetailDisclosureButton];
    }
    [self addSubview:_learnMoreButton];
    [_learnMoreButton addTarget:self action:@selector(presentLearnMoreViewController) forControlEvents:UIControlEventTouchUpInside];
    [self setupConstraints];
}

- (void)setLearnMoreButtonFont: (UIFont *)font {
    if (_learnMoreButton) {
        [_learnMoreButton.titleLabel setFont:font];
    }
}

- (void)setLearnMoreButtonTextAlignment:(NSTextAlignment)textAlignment {
    if (textAlignment == NSTextAlignmentLeft) {
        [_learnMoreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    } else {
        _learnMoreButton.titleLabel.textAlignment = textAlignment;
    }
}

- (BOOL)isTextLink {
    return _learnMoreButton.titleLabel.text.length > 0;
}

- (void)setupConstraints {
    _learnMoreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_learnMoreButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    NSArray<NSLayoutConstraint *> *constraints = @[
                                                   [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:_learnMoreButton
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:_learnMoreButton
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:_learnMoreButton
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0
                                                                                 constant:0.0],
                                                   [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:_learnMoreButton
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:0.0]
                                                   ];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)presentLearnMoreViewController {
    NSAssert(_delegate, @"Learn More View requires a delegate");
    [_delegate learnMoreButtonPressedWithStep:_learnMoreInstructionStep];
}

@end
