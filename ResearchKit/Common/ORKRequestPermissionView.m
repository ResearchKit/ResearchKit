/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKRequestPermissionView.h"
#import "ORKStepContainerView_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKRequestPermissionButton.h"

ORKRequestPermissionsNotification const ORKRequestPermissionsNotificationCardViewStatusChanged = @"ORKRequestPermissionsNotificationCardViewStatusChanged";

static const CGFloat StandardPadding = 15.0;
static const CGFloat IconImageViewWidthHeight = 40.0;
static const CGFloat IconImageViewBottomPadding = 10.0;
static const CGFloat TitleTextLabelBottomPadding = 6.0;
static const CGFloat DetailTextLabelBottomPadding = 12;
static const CGFloat ContentStackViewBottomPadding = 12;
static const CGFloat CornerRadius = 10.0;
static const CGFloat ButtonWidth = 150;

@implementation ORKRequestPermissionView {
    NSMutableArray *_constraints;
    
    UIImage *_iconImage;
    UIImageView *_iconImageView;
    
    NSString *_title;
    NSString *_detailText;
    
    UILabel *_titleLabel;
    UILabel *_detailTextLabel;

    UIStackView *_contentStackView;

    NSLayoutConstraint *_buttonWidthConstraint;
}

- (instancetype)initWithIconImage:(nullable UIImage *)iconImage title:(NSString *)title detailText:(NSString *)detailText {
    self = [self initWithFrame:CGRectZero];

    if (self) {
        _iconImage = iconImage;
        _title = title;
        _detailText = detailText;
        _enableContinueButton = YES;
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    if (@available(iOS 13.0, *)) {
        self.layer.borderColor = [[UIColor separatorColor] CGColor];
        [self setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        self.layer.borderColor = [[UIColor ork_midGrayTintColor] CGColor];
        [self setBackgroundColor:[UIColor whiteColor]];
    }

    self.clipsToBounds = false;
    self.layer.cornerRadius = CornerRadius;

    [self setupSubviews];
    [self setUpConstraints];
}

- (void)setupSubviews {
    [self setupIconImageView];
    [self setUpTitleLabel];
    [self setUpDetailTextLabel];
    [self setupRequestDataButton];
    [self setupContentStackView];

    [self updateFonts];
}

- (void)setupContentStackView {
    if (!_contentStackView) {
        _contentStackView = [UIStackView new];

        if (_iconImageView) {
            [_contentStackView addArrangedSubview:_iconImageView];
            [_contentStackView setCustomSpacing:IconImageViewBottomPadding afterView:_iconImageView];
        }

        if (_titleLabel) {
            [_contentStackView addArrangedSubview:_titleLabel];
            [_contentStackView setCustomSpacing:TitleTextLabelBottomPadding afterView:_titleLabel];
        }

        if (_detailTextLabel) {
            [_contentStackView addArrangedSubview:_detailTextLabel];
            [_contentStackView setCustomSpacing:DetailTextLabelBottomPadding afterView:_detailTextLabel];
        }

        if (_requestPermissionButton) {
            [_contentStackView addArrangedSubview:_requestPermissionButton];
        }

        _contentStackView.alignment = UIStackViewAlignmentCenter;
        _contentStackView.axis = UILayoutConstraintAxisVertical;
        [self addSubview:_contentStackView];
    }
}

- (void)setupIconImageView {
    if (_iconImage) {
        _iconImageView = [[UIImageView alloc] initWithImage:_iconImage];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)setUpTitleLabel {
    if (_title) {
        _titleLabel = [self makeMultilineLabel];
        _titleLabel.text = _title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)setUpDetailTextLabel {
    if (_detailText) {
        _detailTextLabel = [self makeMultilineLabel];
        _detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _detailTextLabel.text = _detailText;

        [_detailTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        _detailTextLabel.adjustsFontForContentSizeCategory = true;
    }
}

- (void)setupRequestDataButton {
    if (!_requestPermissionButton) {
        _requestPermissionButton = [ORKRequestPermissionButton new];

        // The button's corner radius should match the corner radius of the parent.
        // Equation: r_inner = r_inner - d
        // r_inner = corner radius of the inner view
        // r_outer = corner radius of the outer view
        // d = Distance between the inner and outer view in pixels
        _requestPermissionButton.clipsToBounds = false;
        _requestPermissionButton.layer.cornerRadius =
            CornerRadius -
            (ContentStackViewBottomPadding / [[UIScreen mainScreen] scale]);
    }
}

- (UILabel *)makeMultilineLabel {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentNatural;
    return label;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
        [self updateFonts];

        // Scale the button width for the AX size
        _buttonWidthConstraint.constant = [[UIFontMetrics defaultMetrics] scaledValueForValue:ButtonWidth];
    }
}

- (void)updateFonts {
    if (_titleLabel) {
        _titleLabel.font = [self fontWithTextStyle:UIFontTextStyleBody weight:UIFontWeightBold];
    }
}

- (UIFont *)fontWithTextStyle:(UIFontTextStyle)textStyle weight:(UIFontWeight)weight {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
    return [UIFont systemFontOfSize:descriptor.pointSize weight:weight];
}

- (void)setUpConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }

    _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _requestPermissionButton.translatesAutoresizingMaskIntoConstraints = NO;

    _constraints = [NSMutableArray array];

    if (@available(iOS 13.0, *)) {
        [_iconImageView setPreferredSymbolConfiguration:[UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleLargeTitle]];
    } else {
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_constraints addObjectsFromArray:@[
            [_iconImageView.widthAnchor constraintEqualToConstant:IconImageViewWidthHeight],
            [_iconImageView.heightAnchor constraintEqualToConstant:IconImageViewWidthHeight]
        ]];
    }

    // Note, the button width is updated when the AX size changes
    _buttonWidthConstraint = [_requestPermissionButton.widthAnchor constraintGreaterThanOrEqualToConstant:ButtonWidth];
    // Lower the priority in case the width is too large for the screen
    _buttonWidthConstraint.priority = UILayoutPriorityDefaultLow;

    [_constraints addObjectsFromArray:@[
        _buttonWidthConstraint,
        [_contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:StandardPadding],
        [_contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-StandardPadding],
        [_contentStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:StandardPadding],
        [_contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-ContentStackViewBottomPadding]
    ]];

    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)updateIconTintColor:(UIColor *)iconTintColor {
    if (_iconImageView) {
        [_iconImageView setTintColor:iconTintColor];
    }
}

- (void)setEnableContinueButton:(BOOL)enableContinueButton {
    _enableContinueButton = enableContinueButton;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKRequestPermissionsNotificationCardViewStatusChanged object:self];
}

@end
