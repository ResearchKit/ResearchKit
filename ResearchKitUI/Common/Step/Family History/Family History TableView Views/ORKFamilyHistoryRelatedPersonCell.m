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

#import "ORKFamilyHistoryRelatedPersonCell.h"

#import "ORKAccessibilityFunctions.h"

#import <ResearchKit/ORKHelpers_Internal.h>

static const CGFloat BackgroundViewBottomPadding = 18.0;
static const CGFloat CellLeftRightPadding = 12.0;
static const CGFloat CellTopBottomPadding = 12.0;
static const CGFloat CellBottomPadding = 8.0;
static const CGFloat CellLabelTopPadding = 8.0;
static const CGFloat CellBottomPaddingBeforeAddRelativeButton = 20.0;
static const CGFloat ContentLeftRightPadding = 16.0;
static const CGFloat DividerViewTopBottomPadding = 10.0;
static const CGFloat OptionsButtonWidth = 20.0;

typedef NS_ENUM(NSUInteger, ORKFamilyHistoryEditDeleteViewEvent) {
    ORKFamilyHistoryEditDeleteViewEventEdit = 0,
    ORKFamilyHistoryEditDeleteViewEventDelete,
};

typedef void (^ORKFamilyHistoryEditDeleteViewEventHandler)(ORKFamilyHistoryEditDeleteViewEvent);

@implementation ORKFamilyHistoryRelatedPersonCell {
    UIView *_backgroundView;
    UIView *_dividerView;
    UILabel *_titleLabel;
    UILabel *_conditionsLabel;
    UIButton *_optionsButton;
    
    NSArray<UILabel *> *_detailListLabels;
    NSArray<UILabel *> *_conditionListLabels;
    
    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (UIMenu *)optionsMenu  API_AVAILABLE(ios(13.0)) {
    ORKWeakTypeOf(self) weakSelf = self;
    // Edit Button
    UIImage *editImage = [UIImage systemImageNamed:@"pencil"];
    UIAction *editMenuItem = [UIAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_EDIT_ENTRY", @"")
                                                 image:editImage
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventEdit];
        }
    }];
    
    // Delete Button
    UIImage *deleteImage = [UIImage systemImageNamed:@"trash.fill"];
    UIAction *deleteMenuItem = [UIAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", @"")
                                                 image:deleteImage
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventDelete];
        }
    }];
    [deleteMenuItem setAttributes:UIMenuElementAttributesDestructive];
    
    NSArray<UIAction *> *menuChildren = @[
        editMenuItem,
        deleteMenuItem
    ];
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:menuChildren];
    return menu;
}

- (UIAlertController *)alertForOptionsMenu {
    ORKWeakTypeOf(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_EDIT_ENTRY", @"")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventEdit];
        }
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", @"")
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleContentViewEvent:ORKFamilyHistoryEditDeleteViewEventDelete];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", @"")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:editAction];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    return alert;
}

- (void)presentOptionsMenuAlert {
    UIAlertController *alert = [self alertForOptionsMenu];
    NSArray<UIWindow *> *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            [window.rootViewController presentViewController:alert animated:true completion:nil];
        }
    }
}

- (void)setupSubViews {
    _backgroundView = [UIView new];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.layer.cornerRadius = 12.0;
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:_backgroundView];
    
    _titleLabel = [self _primaryLabel];
    [_titleLabel setText:_title];
    [_backgroundView addSubview:_titleLabel];
    
    _optionsButton = [UIButton new];
    _optionsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _optionsButton.backgroundColor = [UIColor clearColor];
    _optionsButton.tintColor = [UIColor systemGrayColor];
    _optionsButton.accessibilityLabel = ORKLocalizedString(@"AX_FAMILY_HISTORY_EDIT_BUTTON", nil);
    _optionsButton.accessibilityHint = ORKLocalizedString(@"AX_FAMILY_HISTORY_EDIT_BUTTON", nil);
    _optionsButton.accessibilityTraits = UIAccessibilityTraitButton;
    if (@available(iOS 14.0, *)) {
        _optionsButton.menu = [self optionsMenu];
        _optionsButton.showsMenuAsPrimaryAction = YES;
    } else {
        [_optionsButton addTarget:self action:@selector(presentOptionsMenuAlert) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:ORKImageScaleToUse()];
    [_optionsButton setImage:[UIImage systemImageNamed:@"ellipsis.circle" withConfiguration:configuration] forState:UIControlStateNormal];
    [_optionsButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [_backgroundView addSubview:_optionsButton];
    
    _dividerView = [UIView new];
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    _dividerView.backgroundColor = [UIColor separatorColor];
    [_backgroundView addSubview:_dividerView];
    
    _conditionsLabel = [self _primaryLabel];
    _conditionsLabel.text = ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS", @"");
    [_backgroundView addSubview:_conditionsLabel];
    
    [self updateViewColors];
}

- (void)updateViewColors {
    _backgroundView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    _dividerView.backgroundColor = [UIColor separatorColor];
    _titleLabel.textColor = [UIColor labelColor];
    _conditionsLabel.textColor = [UIColor labelColor];
    _optionsButton.tintColor = [UIColor secondaryLabelColor];
    
    [self updateViewLabelsTextColor:[UIColor secondaryLabelColor]];
}

- (void)updateViewLabelsTextColor:(UIColor *)color {
    for (UILabel* detailLabel in _detailListLabels) {
        detailLabel.textColor = color;
    }
    for (UILabel* conditionLabel in _conditionListLabels) {
        conditionLabel.textColor = color;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateViewColors];
}

- (void)_clearActiveConstraints {
    if (_viewConstraints.count > 0) {
        [NSLayoutConstraint deactivateConstraints:_viewConstraints];
    }
    
    _viewConstraints = [NSMutableArray new];
    
    for (UILabel *label in _conditionListLabels) {
        [label removeFromSuperview];
    }
    _conditionListLabels = @[];
    
    for (UILabel *label in _detailListLabels) {
        [label removeFromSuperview];
    }
    _detailListLabels = @[];
}

- (NSArray<NSLayoutConstraint *> *)_backgroundViewContraints {
    CGFloat bottomPadding = _isLastItemBeforeAddRelativeButton ? -CellBottomPaddingBeforeAddRelativeButton : -CellBottomPadding;
    
    return @[
        [_backgroundView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [_backgroundView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:ContentLeftRightPadding],
        [_backgroundView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-ContentLeftRightPadding],
        [_backgroundView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:bottomPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_titleLabelConstraints {
    // _titleLabel becomes the first detailsLowerMostView, which sets `bottomAnchor` accordingly.
    return @[
        [_titleLabel.topAnchor constraintEqualToAnchor:_backgroundView.topAnchor constant:CellTopBottomPadding],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:_optionsButton.leadingAnchor constant:-CellLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_optionsButtonConstraints {
    // leadingAnchor: set in _titleLabelConstraints
    // bottomAnchor: ambiguous
    
    NSLayoutConstraint *widthConstraint = [_optionsButton.widthAnchor constraintEqualToConstant:OptionsButtonWidth];
    [widthConstraint setPriority:UILayoutPriorityDefaultLow];
    
    return @[
        [_optionsButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor],
        widthConstraint,
        [_optionsButton.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_dividerConstraintsFromView:(UIView *)referenceView {
    CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
    NSLayoutConstraint *heightConstraint = [_dividerView.heightAnchor constraintEqualToConstant:separatorHeight];
    [heightConstraint setPriority:UILayoutPriorityDefaultLow];
    return @[
        [_dividerView.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor],
        [_dividerView.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor],
        heightConstraint,
        [_dividerView.topAnchor constraintEqualToAnchor: referenceView.bottomAnchor constant:DividerViewTopBottomPadding],
        [_dividerView.bottomAnchor constraintEqualToAnchor:_conditionsLabel.topAnchor constant:-DividerViewTopBottomPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_conditionsLabelConstraints {
    return @[
        [_conditionsLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [_conditionsLabel.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding]
    ];
}

- (NSArray<NSLayoutConstraint *> *)_constraintsForLabel:(UILabel *)label relativeTo:(UIView *)referenceView {
    return @[
        [label.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:CellLeftRightPadding],
        [label.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-CellLeftRightPadding],
        [label.topAnchor constraintEqualToAnchor:referenceView.bottomAnchor constant:CellLabelTopPadding]
    ];
}

- (void)setupConstraints {
    [self _clearActiveConstraints];
    _viewConstraints = [NSMutableArray new];
    
    // backgroundView constraints
    [_viewConstraints addObjectsFromArray:[self _backgroundViewContraints]];
    
    // titleLabel constraints
    [_viewConstraints addObjectsFromArray:[self _titleLabelConstraints]];
    
    // optionsButton constraints
    [_viewConstraints addObjectsFromArray:[self _optionsButtonConstraints]];
    
    // find lower most view to constrain the dividerView to
    UIView *detailsLowerMostView = _titleLabel;
    
    _detailListLabels = [self getDetailLabels];
    
    for (UILabel *label in _detailListLabels) {
        [_backgroundView addSubview:label];
        [_viewConstraints addObjectsFromArray: [self _constraintsForLabel:label relativeTo:detailsLowerMostView]];
        detailsLowerMostView = label;
    }
    
    // dividerView constraints
    [_viewConstraints addObjectsFromArray: [self _dividerConstraintsFromView:detailsLowerMostView]];
    
    // conditionsLabel constraints
    [_viewConstraints addObjectsFromArray:[self _conditionsLabelConstraints]];
    
    // find lower most view to constrain the backgroundView to
    UIView *conditionsLowerMostView = _conditionsLabel;
    
    _conditionListLabels = [self getConditionLabels];
    
    for (UILabel *label in _conditionListLabels) {
        [_backgroundView addSubview:label];
        [_viewConstraints addObjectsFromArray: [self _constraintsForLabel:label relativeTo:conditionsLowerMostView]];
        conditionsLowerMostView = label;
    }
    
    // set backgroundView's bottom anchor to lower most UILabel
    NSLayoutConstraint *bottomConstraint = [conditionsLowerMostView.lastBaselineAnchor constraintEqualToAnchor:_backgroundView.bottomAnchor constant:-BackgroundViewBottomPadding];
    [bottomConstraint setPriority:UILayoutPriorityDefaultHigh];
    [_viewConstraints addObject:bottomConstraint];
    
    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

- (UILabel *)_baseLabel {
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentNatural;
    label.numberOfLines = 0;
    return label;
}

- (UILabel *)_primaryLabel {
    UILabel *label = [self _baseLabel];
    label.font = [self titleLabelFont];
    return label;
}

- (UILabel *)_secondaryLabel {
    UILabel *label = [self _baseLabel];
    label.font = [self conditionsLabelFont];
    label.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor lightGrayColor];
    return label;
}

- (NSArray<UILabel *> *)getDetailLabels {
    NSMutableArray<UILabel *> *labels = [NSMutableArray new];
    
    for (NSString *detailValue in _detailValues) {
        UILabel *label = [self _secondaryLabel];
        label.text = detailValue;
        [labels addObject:label];
    }
    
    return [labels copy];
}

- (NSArray<UILabel *> *)getConditionLabels {
    NSMutableArray<UILabel *> *labels = [NSMutableArray new];
    
    if (!_conditionValues || _conditionValues.count == 0) {
        UILabel *noneSelectedLabel = [self _secondaryLabel];
        noneSelectedLabel.text = @"";
        [labels addObject:noneSelectedLabel];
    } else {
        for (NSString *conditionValue in _conditionValues) {
            UILabel *label = [self _secondaryLabel];
            label.text = conditionValue;
            [labels addObject:label];
        }
    }
    
    return [labels copy];
}

- (void)handleContentViewEvent:(ORKFamilyHistoryEditDeleteViewEvent)event {
    switch (event) {
        case ORKFamilyHistoryEditDeleteViewEventEdit:
            [_delegate familyHistoryRelatedPersonCell:self tappedOption:ORKFamilyHistoryTooltipOptionEdit];
            break;
            
        case ORKFamilyHistoryEditDeleteViewEventDelete:
            [_delegate familyHistoryRelatedPersonCell:self tappedOption:ORKFamilyHistoryTooltipOptionDelete];
            break;
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)configureWithDetailValues:(NSArray<NSString *> *)detailValues
                 conditionsValues:(NSArray<NSString *> *)conditionsValues
isLastItemBeforeAddRelativeButton:(BOOL)isLastItemBeforeAddRelativeButton {
    _detailValues = detailValues;
    _conditionValues = conditionsValues;
    _isLastItemBeforeAddRelativeButton = isLastItemBeforeAddRelativeButton;
    
    [self setupSubViews];
    [self setupConstraints];
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)conditionsLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitUIOptimized)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)prepareForReuse {
    _title = @"";
    _relativeID = @"";
    
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
    
    [_conditionsLabel removeFromSuperview];
    _conditionsLabel = nil;
    
    [_optionsButton removeFromSuperview];
    _optionsButton = nil;
    
    [_dividerView removeFromSuperview];
    _dividerView = nil;
    
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
    
    [self _clearActiveConstraints];
    [super prepareForReuse];
}

@end
