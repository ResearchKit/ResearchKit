/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKFamilyHistoryTableFooterView.h"
#import "ORKFormItem_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import <ResearchKit/ResearchKit-Swift.h>

static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopCollapsedPadding = 10.0;
static const CGFloat CellBottomCollapsedPadding = 30.0;

static const CGFloat CellTopExpandedPadding = 0.0;
static const CGFloat CellBottomExpandedPadding = 20.0;

static const CGFloat ViewButtonTopBottomPadding = 16.0;

@implementation ORKFamilyHistoryTableFooterView {
    NSString *_relativeGroupIdentifier;
    NSString *_title;
    
    UILabel *_titleLabel;
    UIImageView *_iconImageview;
    
    UIButton *_viewButton;
    
    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
    NSLayoutConstraint *topConstraint;
    NSLayoutConstraint *bottomConstraint;
    __weak id<ORKFamilyHistoryTableFooterViewDelegate> _delegate;
}

- (instancetype)initWithTitle:(NSString *)title relativeGroupIdentifier:(NSString *)relativeGroupIdentifier delegate:(id<ORKFamilyHistoryTableFooterViewDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _title = [title copy];
        _relativeGroupIdentifier = [relativeGroupIdentifier copy];
        _delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        self.directionalLayoutMargins = NSDirectionalEdgeInsetsZero;

        [self setupSubviews];
        [self setupConstraints];
        [self enableAccessibilitySupport];

        [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class] withHandler:^(ORKFamilyHistoryTableFooterView *traitChangeView, UITraitCollection *previousTraitCollection) {
            [traitChangeView updateViewColors];
        }];
    }
    return self;
}

- (void)setExpanded:(BOOL)isExpanded {
    topConstraint.constant = isExpanded ? -CellTopExpandedPadding : -CellTopCollapsedPadding;
    bottomConstraint.constant = isExpanded ? CellBottomCollapsedPadding : CellBottomExpandedPadding;
    [self setNeedsUpdateConstraints];
}

- (void)setupPrimaryButton {
    if (@available(iOS 26.0, *)) {
        UIButtonConfiguration *buttonConfiguration = [UIButtonConfiguration glassButtonConfiguration];
        buttonConfiguration.baseForegroundColor = [UIColor systemBlueColor];
        buttonConfiguration.buttonSize = UIButtonConfigurationSizeLarge;
        buttonConfiguration.titleAlignment = UIButtonConfigurationTitleAlignmentLeading;
        buttonConfiguration.imagePlacement = NSDirectionalRectEdgeTrailing;
        buttonConfiguration.cornerStyle = UIButtonConfigurationCornerStyleDynamic;
        NSDirectionalEdgeInsets contentInsets = buttonConfiguration.contentInsets;
        contentInsets.leading = ORKSmallContentLayoutMargins.leading;
        contentInsets.trailing = ORKSmallContentLayoutMargins.trailing;
        buttonConfiguration.contentInsets = contentInsets;

        _viewButton = [UIButton buttonWithConfiguration:buttonConfiguration primaryAction:nil];
        [_viewButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        _viewButton.translatesAutoresizingMaskIntoConstraints = NO;
        _viewButton.clipsToBounds = YES;
        [_viewButton addTarget:self action:@selector(buttonWasPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_viewButton];

        UIImage *image = [UIImage systemImageNamed:@"plus.circle.fill"];

        UIImageSymbolConfiguration *symbolConfiguration = [UIImageSymbolConfiguration configurationWithPaletteColors:@[
            [UIColor systemBackgroundColor],
            [UIColor systemBlueColor]]
        ];

        image = [image imageByApplyingSymbolConfiguration:symbolConfiguration];

        [_viewButton setTitle:_title forState:UIControlStateNormal];
        [_viewButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)setupSubviews {
    if (ORKLiquidGlassSupportEnabled()) {
        [self setupPrimaryButton];
    } else {
        [self legacySetupSubviews];
    }
}

- (void)legacySetupSubviews {
    _viewButton = [UIButton new];
    _viewButton.translatesAutoresizingMaskIntoConstraints = NO;
    _viewButton.clipsToBounds = YES;
    _viewButton.layer.cornerRadius = 10.0;
    [_viewButton addTarget:self action:@selector(buttonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_viewButton];
    
    _titleLabel = [UILabel new];
    _titleLabel.text = [_title copy];
    _titleLabel.numberOfLines = 0;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [self titleLabelFont];
    
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_viewButton addSubview:_titleLabel];
    
    _iconImageview = [UIImageView new];
    _iconImageview.image = [UIImage systemImageNamed:@"plus.circle.fill"];
    _iconImageview.translatesAutoresizingMaskIntoConstraints = NO;
    _iconImageview.backgroundColor = [UIColor clearColor];
    _iconImageview.tintColor = [UIColor systemBlueColor];
    [_viewButton addSubview:_iconImageview];
    
    [self updateViewColors];
}

- (void)updateViewColors {
    _viewButton.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    if (ORKLiquidGlassSupportEnabled()) {
    [_viewButton setTintColor:self.tintColor];
    } else {
        _titleLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : self.tintColor;
    }
}

- (void)enableAccessibilitySupport {
    self.isAccessibilityElement = true;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.accessibilityLabel = [_title copy];
    self.accessibilityHint = [_title copy];
}

- (void)setupConstraints {
    if (_viewConstraints.count > 0) {
        [NSLayoutConstraint deactivateConstraints:_viewConstraints];
    }

    topConstraint = [self.topAnchor constraintEqualToAnchor:_viewButton.topAnchor constant:-CellTopCollapsedPadding];
    bottomConstraint = [self.bottomAnchor constraintEqualToAnchor:_viewButton.bottomAnchor constant:CellBottomCollapsedPadding];

    _viewConstraints = [NSMutableArray arrayWithArray: @[
        [_viewButton.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_viewButton.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        topConstraint,
        bottomConstraint
    ]];

    if (!ORKLiquidGlassSupportEnabled()) {
        [_viewConstraints addObjectsFromArray:@[
            [_titleLabel.centerYAnchor constraintEqualToAnchor:_viewButton.centerYAnchor],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:_viewButton.leadingAnchor constant:CellLeftRightPadding],
            [_titleLabel.topAnchor constraintEqualToAnchor:_viewButton.topAnchor constant:ViewButtonTopBottomPadding],
            [_titleLabel.bottomAnchor constraintEqualToAnchor:_viewButton.bottomAnchor constant:-ViewButtonTopBottomPadding],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:_iconImageview.leadingAnchor],
            [_iconImageview.centerYAnchor constraintEqualToAnchor:_viewButton.centerYAnchor],
            [_iconImageview.trailingAnchor constraintEqualToAnchor:_viewButton.trailingAnchor constant:-CellLeftRightPadding],
            [_iconImageview.widthAnchor constraintEqualToAnchor:_iconImageview.heightAnchor]
        ]];
    }

    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitUIOptimized)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)buttonWasPressed {
    [_delegate ORKFamilyHistoryTableFooterView:self didSelectFooterForRelativeGroup:_relativeGroupIdentifier];
}

@end

