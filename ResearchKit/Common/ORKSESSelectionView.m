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

#import "ORKSESSelectionView.h"
#import "ORKAnswerFormat.h"
#import "ORKCheckmarkView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

/*
 
 |-(UILabel)-(UIImageView)-(UILabel)-(ORKCheckmarkView)-|

                             __
                          __| <---rungIndex0
                       __|
                    __|
                 __|
              __|
           __|
        __|
     __|
  __|
 | <---rungIndex9
 */

static const int defaultNumberOfRungs = 10;
static const CGFloat rungHeight = 36.0;
static const CGFloat rungWidth = 40.0;
static const CGFloat labelToRungPadding = 20.0;
static const CGFloat labelToCheckmarkPadding = 8.0;
static const CGFloat rungToRungPadding = 6.0;
static const CGFloat rungButtonPadding = 10.0;

@interface ORKSESRungView : UIView

- (instancetype)initWithRungAtIndex:(NSUInteger)rungIndex text:(nullable NSString *)text;

- (void)setText:(NSString *)text;

- (void)setChecked:(BOOL)checked;

@end

@implementation ORKSESRungView {
    UILabel *_frontLabel;
    UILabel *_rearLabel;
    UIImageView *_rungImageView;
    ORKCheckmarkView *_checkmarkView;
    CGFloat _paddingMultiplier;
    NSUInteger _rungIndex;
    NSLayoutConstraint *_labelToRungConstraint;
    NSLayoutConstraint *_rungToLabelConstraint;
}

- (instancetype)initWithRungAtIndex:(NSUInteger)rungIndex text:(nullable NSString *)text {
    self = [super init];
    if (self) {
        _rungIndex = rungIndex;
        [self setupLabels];
        [self setText:text];
        [self setupCheckmarkView];
        [self setupRungImageView];
        [self setupVariableConstraints];
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (_rungIndex == defaultNumberOfRungs-1) {
        _rearLabel.text = text;
    }
    else if (_rungIndex == 0) {
        _frontLabel.text = text;
    }
}

- (void)setupCheckmarkView {
    if (!_checkmarkView) {
        _checkmarkView = [[ORKCheckmarkView alloc] initWithDefaults];
    }
    [_checkmarkView setChecked:NO];
    [self addSubview:_checkmarkView];
    _checkmarkView.contentMode = UIViewContentModeScaleAspectFill;
    _checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupRungImageView {
    if (!_rungImageView) {
        _rungImageView = [UIImageView new];
    }
    _rungImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _rungImageView.contentMode = UIViewContentModeScaleAspectFit;
    _rungImageView.image = [[UIImage imageNamed:@"socioEconomicLadderRung" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _rungImageView.tintColor = self.tintColor;
    [self addSubview:_rungImageView];
}

- (void)setupLabels {
    _frontLabel = [UILabel new];
    _rearLabel = [UILabel new];
    for (UILabel *label in @[_frontLabel, _rearLabel]) {
        label.numberOfLines = 1;
        label.font = [self bodyTextFont];
        label.textColor = [UIColor grayColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:label];
    }
    _frontLabel.textAlignment = NSTextAlignmentRight;
    _rearLabel.textAlignment = NSTextAlignmentLeft;
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)setupVariableConstraints {
    [[_checkmarkView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-rungButtonPadding] setActive:YES];
    [[_checkmarkView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    
    [[_rearLabel.trailingAnchor constraintEqualToAnchor:_checkmarkView.leadingAnchor constant:-labelToCheckmarkPadding] setActive:YES];
    [[_rearLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    
    [[_rungImageView.heightAnchor constraintEqualToConstant:rungHeight] setActive:YES];
    [[_rungImageView.widthAnchor constraintEqualToConstant:rungWidth] setActive:YES];
    [[_rungImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    [[_rearLabel.leadingAnchor constraintEqualToAnchor:_rungImageView.trailingAnchor constant:_rearLabel.text ? labelToRungPadding : 0.0] setActive:YES];
    
    [[_frontLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:rungButtonPadding] setActive:YES];
    [[_frontLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    [[_frontLabel.trailingAnchor constraintEqualToAnchor:_rungImageView.leadingAnchor constant:_frontLabel.text ? -labelToRungPadding : 0.0] setActive:YES];
    
    CGFloat unavialableConstantSpace = rungButtonPadding + CheckmarkViewDimension + labelToCheckmarkPadding + (_rearLabel.text ? labelToRungPadding : 0.0) + rungWidth;
    
    CGFloat multiplier = ((CGFloat)_rungIndex)/(CGFloat)defaultNumberOfRungs;
    
    [[_rearLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:multiplier constant:-multiplier*unavialableConstantSpace] setActive:YES];
    [[self.bottomAnchor constraintEqualToAnchor:_rungImageView.bottomAnchor] setActive:YES];
}

- (void)setChecked:(BOOL)checked {
    [_checkmarkView setChecked:checked];
}

@end

@interface ORKSESRungButton : UIButton

@property (nonatomic) NSUInteger rungIndex;

- (instancetype)initTopRungButtonWithText:(NSString *)text;
- (instancetype)initBottomRungButtonWithText:(NSString *)text;
- (instancetype)initWithRungAtIndex:(NSUInteger)rungIndex;
- (void)setSelected:(BOOL)selected highlight:(BOOL)highlight;

@end

@implementation ORKSESRungButton {
    ORKSESRungView *_rungView;
    UIColor *_fillColor;
}

- (instancetype)initWithRungAtIndex:(NSUInteger)rungIndex
                               text:(nullable NSString *)text {
    self = [super init];
    if (self) {
        _rungIndex = rungIndex;
        _rungView = [[ORKSESRungView alloc] initWithRungAtIndex:rungIndex text:text];
        [_rungView setUserInteractionEnabled:NO];
        [self setupRungView];
        self.tag = _rungIndex;
        [self updateFillColor];
        self.layer.backgroundColor = _fillColor.CGColor;
    }
    return self;
}

- (void)setupRungView {
    if (_rungView) {
        _rungView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rungView];
        [[_rungView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
        [[_rungView.leftAnchor constraintEqualToAnchor:self.leftAnchor] setActive:YES];
        [[_rungView.rightAnchor constraintEqualToAnchor:self.rightAnchor] setActive:YES];
        [[self.bottomAnchor constraintEqualToAnchor:_rungView.bottomAnchor] setActive:YES];
    }
}

- (instancetype)initTopRungButtonWithText:(NSString *)text {
    return [self initWithRungAtIndex:0 text:text];
}

- (instancetype)initBottomRungButtonWithText:(NSString *)text {
    return [self initWithRungAtIndex:defaultNumberOfRungs-1 text:text];
}

- (instancetype)initWithRungAtIndex:(NSUInteger)rungIndex {
    return [self initWithRungAtIndex:rungIndex text:nil];
}

- (void)setSelected:(BOOL)selected highlight:(BOOL)highlight {
    [super setSelected:selected];
    [_rungView setChecked:selected];
    if (highlight) {
        [self tapAnimation];
    }
}

- (void)tapAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    if (@available(iOS 13.0, *)) {
        animation.fromValue = (__bridge id _Nullable)(UIColor.systemGray5Color.CGColor);
    } else {
        animation.fromValue = (__bridge id _Nullable)([UIColor colorWithRed:0.282 green:0.282 blue:0.235 alpha:1.0].CGColor);
    }
    animation.toValue = (__bridge id _Nullable)(_fillColor.CGColor);
    animation.beginTime = 0.0;
    animation.duration = 0.45;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:@"backgroundColor"];
    self.layer.backgroundColor = _fillColor.CGColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateFillColor];
}

- (void)updateFillColor {
    if (@available(iOS 13.0, *)) {
        _fillColor = [UIColor secondarySystemGroupedBackgroundColor];
        // FIXME:- dark mode color displays solid black after animation ends if the views are stacked
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            _fillColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.180 alpha:1.0];
        }
    } else {
        _fillColor = [UIColor ork_borderGrayColor];
    }
    self.layer.backgroundColor = _fillColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (@available(iOS 13.0, *)) {
            self.layer.backgroundColor = UIColor.systemGray5Color.CGColor;
        } else {
            self.layer.backgroundColor = [UIColor colorWithRed:0.282 green:0.282 blue:0.235 alpha:1.0].CGColor;
        }
    }
    else {
        self.layer.backgroundColor = _fillColor.CGColor;
    }
}

@end

@implementation ORKSESSelectionView {
    NSMutableArray<ORKSESRungButton *> *_buttons;
    ORKSESAnswerFormat *_answerFormat;
}

- (instancetype)initWithAnswerFormat:(ORKSESAnswerFormat *)answerFormat answer:(nullable id)answer {
    self = [super init];
    if (self) {
        _answerFormat = answerFormat;
        _answer = answer;
        [self addRungButtonsWithTopRungText:_answerFormat.topRungText bottomRungText:_answerFormat.bottomRungText];
    }
    return self;
}

- (instancetype)initWithAnswerFormat:(ORKSESAnswerFormat *)answerFormat {
    self = [self initWithAnswerFormat:answerFormat answer:nil];
    return self;
}

- (void)addRungButtonsWithTopRungText:(NSString *)topRungText bottomRungText:(NSString *)bottomRungText {
    _buttons = [[NSMutableArray alloc] init];
    ORKSESRungButton *topButton = [[ORKSESRungButton alloc] initTopRungButtonWithText:topRungText];
    [_buttons addObject:topButton];
    for (int rungIndex = 1; rungIndex < defaultNumberOfRungs-1; rungIndex++) {
        ORKSESRungButton *button = [[ORKSESRungButton alloc] initWithRungAtIndex:rungIndex];
        [_buttons addObject:button];
    }
    ORKSESRungButton *bottomButton = [[ORKSESRungButton alloc] initBottomRungButtonWithText:bottomRungText];
    [_buttons addObject:bottomButton];

    for (int i = 0; i < _buttons.count; i++) {
        ORKSESRungButton *rungButton = _buttons[i];
        rungButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:rungButton];
        [rungButton addTarget:self action:@selector(rungButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [[rungButton.leftAnchor constraintEqualToAnchor:self.leftAnchor] setActive:YES];
        [[rungButton.rightAnchor constraintEqualToAnchor:self.rightAnchor] setActive:YES];
        [[rungButton.topAnchor constraintEqualToAnchor:(i==0) ? self.topAnchor : _buttons[i-1].bottomAnchor constant:(i==0) ? rungButtonPadding : rungToRungPadding] setActive:YES];
        if (i==_buttons.count-1) {
            [[self.bottomAnchor constraintGreaterThanOrEqualToAnchor:rungButton.bottomAnchor constant:rungButtonPadding] setActive:YES];
        }
        
        if (self.answer && ![self.answer isEqual:[NSNull null]]) {
            // calling intValue on NSNull will cause a crash
            if ([self.answer intValue] == i) {
                [rungButton setSelected:YES highlight:NO];
            } else {
                [rungButton setSelected:NO highlight:NO];
            }
        } else {
            [rungButton setSelected:NO highlight:NO];
        }
        
        float percentage = (((double)i + 1) / _buttons.count) * 100;
        bool isTopPercentile = percentage <= 50.0;
        NSString *topOrBottomText = isTopPercentile ? ORKLocalizedString(@"AX_SES_TOP", nil) : ORKLocalizedString(@"AX_SES_BOTTOM", nil);
        int buttonPercentageRange = isTopPercentile ? (int)percentage : (int)(100.0 - percentage + (100.0 / _buttons.count));
        
        rungButton.accessibilityLabel = [NSString stringWithFormat:@"%@ %d %@", topOrBottomText, buttonPercentageRange, ORKLocalizedString(@"AX_SES_PERCENT", nil)];
    }
}

- (void)rungButtonPressed:(id)sender {
    ORKSESRungButton *buttonPressed = (ORKSESRungButton *)sender;
    [buttonPressed setSelected:YES highlight:YES];
    for (ORKSESRungButton *button in _buttons) {
        if (buttonPressed.tag != button.tag) {
            [button setSelected:NO highlight:NO];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonPressedAtIndex:)]) {
        [self.delegate buttonPressedAtIndex:buttonPressed.tag];
    }
}

@end
