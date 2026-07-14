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


#import "ORKBodyContainerView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBodyItem.h"
#import "ORKBodyItem_Internal.h"
#import "ORKLearnMoreView.h"
#import "ORKLearnMoreInstructionStep.h"
#import "ORKTagLabel.h"
#import <ResearchKitUI/ResearchKitUI-Swift.h>

static const CGFloat ContentSizeExtraSmallScaleFactor = 1;
static const CGFloat ContentSizeMediumScaleFactor = 1.2;
static const CGFloat ContentSizeExtraLargeScaleFactor = 1.4;
static const CGFloat ContentSizeExtraExtraExtraLargeScaleFactor = 1.8;
static const CGFloat ContentSizeAccessibilityLargeScaleFactor = 2.0;

static const CGFloat ORKBodyTextToBodyDetailTextPaddingStandard = 6.0;
static const CGFloat ORKHeaderBottomMargin = -10.0;

CGFloat ORKBodyTextToLearnMoreButtonPaddingStandard(void);
CGFloat ORKBodyTextToLearnMoreButtonPaddingStandard(void) {
    return ORKLiquidGlassSupportEnabled() ? 20.0 : 15.0;
}
CGFloat ORKBodyDetailTextToLearnMoreButtonPaddingStandard(void);
CGFloat ORKBodyDetailTextToLearnMoreButtonPaddingStandard(void) {
    return ORKLiquidGlassSupportEnabled() ? 20.0 : 15.0;
}

CGFloat ORKBulletIconToBodyPadding(void);
CGFloat ORKBulletIconToBodyPadding(void) {
    if (ORKLiquidGlassSupportEnabled()) {
        return 16.0;
    } else {
        return 14.0;
    }
}
static const CGFloat ORKBulletIconWidthStandard = 10.0;

CGFloat ORKBulletIconDimension(void);
CGFloat ORKBulletIconDimension(void) {
    return 22.0;
}
static const CGFloat ORKCardStylePadding = 16.0;
static const CGFloat ORKCardStyleBottomPadding = 12.0;
static const CGFloat ORKCardStyleMediumTextPadding = 14.0;
static const CGFloat ORKCardStyleSmallTextPadding = 2.0;

static const CGFloat ORKCardStyleBuildInPostitionStart = 31.0;
static const CGFloat ORKCardStyleBuildInPostitionEnd = 26.0;

static NSString *ORKBulletUnicode = @"\u2981";

//static const CGFloat ORKBulletToBulletPaddingShort = 22.0;
//static const CGFloat ORKBulletToBulletPaddingGenerous = 36.0;
//static const CGFloat ORKBodyToBulletPaddingShort = 22.0;


@protocol ORKBodyItemViewDelegate <NSObject>

@required
- (void)bodyItemLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep;

@end

@interface ORKBodyItemView: UIStackView

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem;

@property (nonatomic, nonnull) ORKBodyItem *bodyItem;
@property (nonatomic, weak) id<ORKBodyItemViewDelegate> delegate;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *cardStyleAccessoryView;
@property (nonatomic, strong) UIImageView *cardImageView;

@end

@interface ORKBodyItemView()<ORKLearnMoreViewDelegate>
@property (nonatomic) NSTextAlignment textAlignment;
@end

@implementation ORKBodyItemView

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem {
    self = [super init];
    if (self) {
        self.bodyItem = bodyItem;
        self.textAlignment = NSTextAlignmentLeft;
        self.accessibilityIdentifier = bodyItem.accessibilityIdentifier;
        [self setupBodyStyleView];
        
    }
    return self;
}

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem textAlignment:(NSTextAlignment)textAlignment {
    self = [super init];
    if (self) {
        self.bodyItem = bodyItem;
        self.textAlignment = textAlignment;
        self.accessibilityIdentifier = bodyItem.accessibilityIdentifier;
        [self setupBodyStyleView];
        
    }
    return self;
}

- (void)setupBodyStyleView {
    if (_bodyItem.useCardStyle == YES) {
        _cardView = [[UIView alloc] init];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        _cardView.backgroundColor = UIColor.systemBackgroundColor;
        _cardView.layer.cornerRadius = ORKCardDefaultCornerRadii();
        _cardView.layer.cornerCurve = kCACornerCurveContinuous;
        _cardView.layer.borderWidth = 1.0;
        _cardView.layer.borderColor = UIColor.separatorColor.CGColor;
        _cardView.clipsToBounds = YES;
        [self addArrangedSubview:_cardView];
        NSLayoutConstraint *cardWidthConstraint = [_cardView.widthAnchor constraintEqualToAnchor:self.widthAnchor];
        cardWidthConstraint.priority = UILayoutPriorityRequired - 1;
        cardWidthConstraint.active = YES;

        // If there's a link included in the learn more item, set up the whole card to be tappable
        if (_bodyItem.learnMoreItem != nil) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardViewTapped)];
            [_cardView addGestureRecognizer:tapGesture];
        }
    }
    
    if ([_bodyItem isCustomButtonItemType])
    {
        [self setupCustomButtonViewWithConfigurationHandler:_bodyItem.customButtonConfigurationHandler];
    }
    
    if (_bodyItem.bodyItemStyle == ORKBodyItemStyleText) {
        [self setupBodyStyleTextView];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleImage) {
        [self setupBulletPointStackView];
        [self setupBodyStyleImage];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleBulletPoint) {
        [self setupBulletPointStackView];
        [self setupBodyStyleBulletPointView];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleHorizontalRule) {
        [self setupBodyStyleHorizontalRule];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleTag) {
        [self setupBodyStyleTag];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleHeader) {
        [self setupBodyStyleHeaderView];
    }
}

- (void)setupCustomButtonViewWithConfigurationHandler:(void(^)(UIButton *button))configurationHandler
{
    UIButton *button = [[UIButton alloc] init];
    configurationHandler(button);
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:button];
    [NSLayoutConstraint activateConstraints:@[
        [button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ORKStepContainerLeftRightPaddingForWindow(self.window)]
    ]];
}

- (void)setupBodyStyleHorizontalRule {
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFill;
    UIView *separator = [UIView new];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = UIColor.separatorColor;
    [separator.heightAnchor constraintEqualToConstant:(ORKLiquidGlassSupportEnabled() ? 1.0 : 1.0 / self.safeDisplayScale)].active = YES;
    [self addArrangedSubview:separator];
}

- (UIFont *)bodyStyleTextViewTextLabelFont {
    if (ORKLiquidGlassSupportEnabled()) {
        return _bodyItem.detailText == nil ? ORKBodyTextFont() : ORKBodyTextFontBold();
    } else {
        return _bodyItem.detailText == nil ? ORKBodyTitleFont() : ORKBodyTitleFontBold();
    }
}

- (void)setupBodyStyleTextView {
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFill;
    self.alignment = self.textAlignment == NSTextAlignmentCenter ? UIStackViewAlignmentCenter : UIStackViewAlignmentLeading;
    UILabel *textLabel;
    UILabel *detailTextLabel;
    
    if (_bodyItem.text) {
        
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [self bodyStyleTextViewTextLabelFont];
        textLabel.text = _bodyItem.text;
        textLabel.textAlignment = _textAlignment;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (ORKLiquidGlassSupportEnabled()) {
            textLabel.textColor = _bodyItem.detailText != nil ? UIColor.labelColor : UIColor.secondaryLabelColor;
        }
        
        if (_bodyItem.useCardStyle == YES) {
            [_cardView addSubview:textLabel];
            [textLabel.leadingAnchor constraintEqualToAnchor: _cardView.leadingAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            [textLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:ORKCardStylePadding].active = YES;
            [textLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding].active = YES;
            
            if (_bodyItem.detailText == nil) {
                [textLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStyleBottomPadding].active = YES;
            }
        } else {
            [self addArrangedSubview:textLabel];
        }
    }
    if (_bodyItem.detailText) {
        detailTextLabel = [UILabel new];
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.font = ORKBodyTextFont();
        detailTextLabel.text = _bodyItem.detailText;
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (ORKLiquidGlassSupportEnabled()) {
            detailTextLabel.textColor = UIColor.secondaryLabelColor;
        }

        if (_bodyItem.useCardStyle == YES) {
            [_cardView addSubview:detailTextLabel];
            [detailTextLabel.leadingAnchor constraintEqualToAnchor: _cardView.leadingAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            [detailTextLabel.topAnchor constraintEqualToAnchor:textLabel.bottomAnchor constant:ORKCardStyleSmallTextPadding].active = YES;
            [detailTextLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding].active = YES;
            [detailTextLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStyleBottomPadding].active = YES;
        } else {
            [self addArrangedSubview:detailTextLabel];
            if (textLabel) {
                [self setCustomSpacing:ORKBodyTextToBodyDetailTextPaddingStandard afterView:textLabel];
            }
        }
    }
    if (_bodyItem.learnMoreItem) {
        ORKLearnMoreView *learnMoreView = _bodyItem.learnMoreItem.text ? [ORKLearnMoreView learnMoreCustomButtonViewWithText:_bodyItem.learnMoreItem.text LearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep] : [ORKLearnMoreView learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep];
        [learnMoreView setLearnMoreButtonFont:ORKBodyTextFont()];
        [learnMoreView setLearnMoreButtonTextAlignment:_textAlignment];
        learnMoreView.delegate = _bodyItem.learnMoreItem.delegate ? : self;
        learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:learnMoreView];
        if (detailTextLabel) {
            [self setCustomSpacing:ORKBodyDetailTextToLearnMoreButtonPaddingStandard() afterView:detailTextLabel];
        }
        else if (textLabel) {
            [self setCustomSpacing:ORKBodyTextToLearnMoreButtonPaddingStandard() afterView:textLabel];
        }
    }
}

- (void)setupBodyStyleHeaderView {
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFill;
    self.alignment = UIStackViewAlignmentLeading;
    self.layoutMargins = UIEdgeInsetsMake(0, 0, ORKHeaderBottomMargin, 0);
    self.layoutMarginsRelativeArrangement = YES;

    if (_bodyItem.text) {
        UILabel *headerLabel = [UILabel new];
        headerLabel.numberOfLines = 0;
        headerLabel.font = ORKBodyTextFontBold();
        headerLabel.text = _bodyItem.text;
        headerLabel.textColor = UIColor.labelColor;
        headerLabel.adjustsFontForContentSizeCategory = YES;
        headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:headerLabel];
    }
}

- (void)setupBulletPointStackView {
    self.axis = UILayoutConstraintAxisHorizontal;
    self.alignment = UIStackViewAlignmentTop;
    self.layoutMargins = UIEdgeInsetsZero;
    [self setLayoutMarginsRelativeArrangement:YES];
}

- (void)setupBodyStyleBulletPointView {
    UILabel *bulletIcon = [self bulletIcon];
    
    if (_bodyItem.useCardStyle == YES) {
        bulletIcon.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:bulletIcon];
        [bulletIcon.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor].active = YES;
        [bulletIcon.topAnchor constraintEqualToAnchor:_cardView.topAnchor].active = YES;
        _cardStyleAccessoryView = bulletIcon;
    } else {
        [self addArrangedSubview:bulletIcon]; // Stack this in substack for vertical bullet icon.
        [self setCustomSpacing:ORKBulletIconToBodyPadding() afterView:bulletIcon];
    }
    
    [self addSubStackView];
}

- (void)setupBodyStyleImage {
    UIImageView *imageView = [self imageView];
    self.alignment = _bodyItem.alignImageToTop ? UIStackViewAlignmentTop : UIStackViewAlignmentCenter;
    
    if (_bodyItem.useCardStyle == YES) {
        _cardImageView = [[UIImageView alloc] initWithImage:_bodyItem.image];
        _cardImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _cardImageView.contentMode = UIViewContentModeScaleAspectFill;
        _cardImageView.clipsToBounds = YES;
        [_cardView addSubview:_cardImageView];
        CGSize imageSize = _bodyItem.image.size;
        CGFloat aspectRatio = (imageSize.width > 0 && imageSize.height > 0) ? (imageSize.height / imageSize.width) : (9.0 / 16.0);
        [NSLayoutConstraint activateConstraints:@[
            [_cardImageView.topAnchor constraintEqualToAnchor:_cardView.topAnchor],
            [_cardImageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor],
            [_cardImageView.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor],
            [_cardImageView.heightAnchor constraintEqualToAnchor:_cardImageView.widthAnchor multiplier:aspectRatio]
        ]];
    } else {

        [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [imageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [self addArrangedSubview:imageView];
        [self setCustomSpacing:ORKBulletIconToBodyPadding() afterView:imageView];
    }
    
    [self addSubStackView];
}

- (UILabel *)bulletIcon {
    UILabel *bulletIconLabel = [UILabel new];
    bulletIconLabel.numberOfLines = 1;
    bulletIconLabel.font = ORKBulletIconFont();
    bulletIconLabel.textColor = [UIColor secondaryLabelColor];
    [bulletIconLabel setText:ORKBulletUnicode];
    bulletIconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[bulletIconLabel.widthAnchor constraintGreaterThanOrEqualToConstant:ORKBulletIconWidthStandard] setActive:YES];
    [bulletIconLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [bulletIconLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return bulletIconLabel;
}

- (UIImageView *)imageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = self.bodyItem.image;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.bodyItem.useSecondaryColor) {
        imageView.tintColor = UIColor.grayColor;
    }
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    int scaleFactor = [self _intrinsicContentSizeScaleFactor];
    NSLayoutConstraint *heightConstraint = [imageView.heightAnchor constraintEqualToConstant:ORKBulletIconDimension() * scaleFactor];
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    heightConstraint.active = YES;
    NSLayoutConstraint *widthConstraint = [imageView.widthAnchor constraintEqualToConstant:ORKBulletIconDimension() * scaleFactor];
    widthConstraint.priority = UILayoutPriorityRequired;
    widthConstraint.active = YES;

    [imageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return imageView;
}

- (void)setupBodyStyleTag {
    UIView *container = [UIView new];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    ORKTagLabel *tagLabel = [ORKTagLabel new];
    tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (_bodyItem.image != nil) {
        NSMutableAttributedString *iconText = [self icon:_bodyItem.image withText:_bodyItem.text font:tagLabel.font color:tagLabel.textColor];
        if (iconText != nil) {
            tagLabel.attributedText = iconText;
        } else {
            tagLabel.attributedText = makeHyphenatedAttributedTextFromText(_bodyItem.text ?: @"", NSLineBreakByWordWrapping);
        }
    } else {
        tagLabel.attributedText = makeHyphenatedAttributedTextFromText(_bodyItem.text ?: @"", NSLineBreakByWordWrapping);
    }
    
    [container addSubview:tagLabel];
    
    [tagLabel.topAnchor constraintEqualToAnchor:container.topAnchor].active = YES;
    [tagLabel.leadingAnchor constraintEqualToAnchor:container.leadingAnchor].active = YES;
    [tagLabel.bottomAnchor constraintEqualToAnchor:container.bottomAnchor].active = YES;
    [tagLabel.trailingAnchor constraintLessThanOrEqualToAnchor:container.trailingAnchor].active = YES;

    [self addArrangedSubview:container];
}

- (void)addSubStackView {
    UILabel *textLabel;
    UILabel *detailTextLabel;
    UIStackView *subStackView = [[UIStackView alloc] init];
    
    if (_bodyItem.useCardStyle == NO) {
        subStackView.axis = UILayoutConstraintAxisVertical;
        subStackView.distribution = UIStackViewDistributionFill;
        subStackView.alignment = UIStackViewAlignmentFill;
        subStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:subStackView];
    }
    
    if (_bodyItem.text) {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.text = _bodyItem.text;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (_bodyItem.useCardStyle == YES) {
            textLabel.font = ORKBulletBodyTextFontBold();

            [_cardView addSubview:textLabel];
            [textLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:ORKCardStylePadding].active = YES;
            UIView *topAnchorView = _cardStyleAccessoryView ?: _cardImageView;
            if (topAnchorView != nil) {
                [textLabel.topAnchor constraintEqualToAnchor:topAnchorView.bottomAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            } else {
                [textLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:ORKCardStylePadding].active = YES;
            }
            NSLayoutConstraint *textTrailing = [textLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding];
            textTrailing.active = YES;

            BOOL hasLearnMoreLink = _bodyItem.learnMoreItem != nil && _bodyItem.learnMoreItem.text.length > 0;
            if (_bodyItem.detailText == nil && !hasLearnMoreLink) {
                [textLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStyleBottomPadding].active = YES;
            }
        } else {
            textLabel.font = _bodyItem.detailText ? ORKBulletTextFontBold() : ORKBulletTextFont();
            textLabel.textColor = UIColor.secondaryLabelColor;
            [subStackView addArrangedSubview:textLabel];
        }
    }
    if (_bodyItem.detailText) {
        detailTextLabel = [UILabel new];
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.font = ORKBulletDetailTextFont();
        detailTextLabel.text = _bodyItem.detailText;
        if (_bodyItem.useCardStyle == YES) {
            [detailTextLabel setTextColor:[UIColor labelColor]];
        } else {
            [detailTextLabel setTextColor:[UIColor secondaryLabelColor]];
        }
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;

        if (_bodyItem.useCardStyle == YES) {
            [_cardView addSubview:detailTextLabel];
            [detailTextLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:ORKCardStylePadding].active = YES;
            [detailTextLabel.topAnchor constraintEqualToAnchor:textLabel.bottomAnchor constant:ORKCardStyleSmallTextPadding].active = YES;
            NSLayoutConstraint *detailTrailing = [detailTextLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding];
            detailTrailing.active = YES;
            BOOL hasLearnMoreLink = _bodyItem.learnMoreItem != nil && _bodyItem.learnMoreItem.text.length > 0;
            if (!hasLearnMoreLink) {
                [detailTextLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStyleBottomPadding].active = YES;
            }
        } else {
            [subStackView addArrangedSubview:detailTextLabel];
        }
    }
    if (_bodyItem.learnMoreItem) {
        // Card style only renders a learn-more button when it has custom text.
        // Disclosure buttons (learnMoreItem.text == nil) are not supported in card style and are omitted.
        if (_bodyItem.useCardStyle == YES && _bodyItem.learnMoreItem.text.length > 0) {
            ORKLearnMoreView *learnMoreView = [ORKLearnMoreView learnMoreCustomButtonViewWithText:_bodyItem.learnMoreItem.text LearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep];
            learnMoreView.delegate = self;
            learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
            [_cardView addSubview:learnMoreView];
            [learnMoreView setLearnMoreButtonFont:ORKBodyTextFont()];
            UIView *anchorView = detailTextLabel ?: textLabel;
            [learnMoreView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:ORKCardStylePadding].active = YES;
            [learnMoreView.topAnchor constraintEqualToAnchor:anchorView.bottomAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            NSLayoutConstraint *learnMoreTrailing = [learnMoreView.trailingAnchor constraintLessThanOrEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding];
            learnMoreTrailing.active = YES;
            [learnMoreView.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStyleBottomPadding].active = YES;
        } else if (_bodyItem.useCardStyle == NO) {
            BOOL hasCustomText = _bodyItem.learnMoreItem.text.length > 0;
            ORKLearnMoreView *learnMoreView = hasCustomText ? [ORKLearnMoreView learnMoreCustomButtonViewWithText:_bodyItem.learnMoreItem.text LearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep] : [ORKLearnMoreView learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep];
            learnMoreView.delegate = self;
            learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
            UIView *lastTextView = detailTextLabel ?: textLabel;
            if (!hasCustomText && lastTextView) {
                // Detail disclosure (ⓘ) button: inline with the last text element rather than on its own row.
                [subStackView removeArrangedSubview:lastTextView];
                [lastTextView removeFromSuperview];
                UIStackView *inlineRow = [[UIStackView alloc] init];
                inlineRow.axis = UILayoutConstraintAxisHorizontal;
                // Center rather than FirstBaseline: the disclosure button is an icon with no text
                // title, so firstBaselineAnchor falls back to its bottom edge and misaligns it.
                inlineRow.alignment = UIStackViewAlignmentCenter;
                inlineRow.translatesAutoresizingMaskIntoConstraints = NO;
                [inlineRow addArrangedSubview:lastTextView];
                [lastTextView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
                [learnMoreView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
                [learnMoreView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
                [inlineRow addArrangedSubview:learnMoreView];
                [subStackView addArrangedSubview:inlineRow];
            } else if (!hasCustomText) {
                // A disclosure button with no associated text label has no context for the user.
                // This is a misconfigured body item; log a warning and skip it.
                ORK_Log_Debug("[ORKBodyContainerView] Disclosure button on a body item with no text or detailText - skipping. Set text or detailText, or use a custom button with learnMoreItem.text.");
            } else {
                [subStackView addArrangedSubview:learnMoreView];
            }
        }
    }
}

- (NSMutableAttributedString *)icon:(UIImage *)image withText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    NSString *textString = [[NSString alloc] initWithFormat:@" %@", text];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:textString];
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];

    UIImage *iconImage = image;
    if (iconImage.isSymbolImage) {
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:font];
        iconImage = [[image imageWithConfiguration:configuration] imageWithTintColor:color];
    }
    imageAttachment.image = iconImage;
    NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    [attributedText insertAttributedString:imageString atIndex:0];
    
    return attributedText;
}

- (int)_intrinsicContentSizeScaleFactor {
    int multiple = ContentSizeExtraSmallScaleFactor;
    
    UIContentSizeCategory contentSizeCategory = [UIApplication.sharedApplication preferredContentSizeCategory];
  
    if ([contentSizeCategory isEqualToString:UIContentSizeCategoryMedium] ||
             [contentSizeCategory isEqualToString:UIContentSizeCategoryLarge]) {
        multiple = ContentSizeMediumScaleFactor;
    }
    else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraLarge] ||
             [contentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
        multiple = ContentSizeExtraLargeScaleFactor;
    }
    else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge] ||
             [contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityMedium]) {
        multiple = ContentSizeExtraExtraExtraLargeScaleFactor;
    }
    else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityLarge] ||
             [contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge] ||
             [contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge] ||
             [contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge]) {
        multiple = ContentSizeAccessibilityLargeScaleFactor;
    }
    
    return multiple;
}

- (void)cardViewTapped {
    [_delegate bodyItemLearnMoreButtonPressed:_bodyItem.learnMoreItem.learnMoreInstructionStep];
}

#pragma mark - ORKLearnMoreViewDelegate

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate bodyItemLearnMoreButtonPressed:learnMoreStep];
}

@end

@interface ORKBodyContainerView()<ORKBodyItemViewDelegate>
@property (nonatomic, strong) NSArray<ORKBodyItemView *> *views;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSUInteger currentBodyItemIndex;
@end

@implementation ORKBodyContainerView

- (instancetype)initWithBodyItems:(NSArray<ORKBodyItem *> *)bodyItems
                    textAlignment:(NSTextAlignment)textAlignment
                         delegate:(nonnull id<ORKBodyContainerViewDelegate>)delegate {
    self.delegate = delegate;
    if (bodyItems && bodyItems.count <= 0) {
        NSAssert(NO, @"Body Items array cannot be empty");
    }
    self = [super init];
    if (self) {
        self.bodyItems = bodyItems;
        self.textAlignment = textAlignment;
        self.axis = UILayoutConstraintAxisVertical;
        self.distribution = UIStackViewDistributionFillProportionally;
        self.spacing = 20;
        [self addBodyItemViews];
    }
    return self;
}

- (void)addBodyItemViews {
    _views = [ORKBodyContainerView bodyItemViewsWithBodyItems:_bodyItems textAlignment:_textAlignment];
    for (NSInteger i = 0; i < _views.count; i++) {
        [self addArrangedSubview:_views[i]];
        _views[i].delegate = self;
    }
}

- (void)setBuildsInBodyItems:(BOOL)buildsInBodyItems {
    _buildsInBodyItems = buildsInBodyItems;
    if (buildsInBodyItems == YES) {
        for (NSInteger i = 0; i < _views.count; i++) {
            [self setCustomSpacing:ORKCardStyleBuildInPostitionStart afterView:_views[i]];
            if ((_buildsInBodyItems == YES) && (i != 0)) {
                _views[i].alpha = 0;
            }
        }
        
        _currentBodyItemIndex = 0;
    }
}

- (void)updateBodyItemViews {
    if (_buildsInBodyItems == NO) { return; }
    
    NSUInteger indexToShow = _currentBodyItemIndex + 1;
    for (NSInteger i = 0; i < _views.count; i++) {
        if (i == indexToShow) {
            [UIView transitionWithView:_views[i] duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^ {
                [self setCustomSpacing:ORKCardStyleBuildInPostitionEnd afterView:_views[i - 1]];
                _views[i].alpha = 1;
            } completion:nil];
        }
    }
    
    _currentBodyItemIndex++;
}

- (BOOL)hasShownAllBodyItem {
    return (_currentBodyItemIndex == (_views.count - 1));
}

- (UIView *)lastVisibleBodyItem {
    return _views[_currentBodyItemIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([_bodyItemDelegate respondsToSelector:@selector(bodyContainerViewDidLoadBodyItems)]) {
        [_bodyItemDelegate bodyContainerViewDidLoadBodyItems];
    }
}

+ (NSArray<ORKBodyItemView *> *)bodyItemViewsWithBodyItems:(NSArray<ORKBodyItem *> *)bodyItems textAlignment:(NSTextAlignment)textAlignment {
    NSMutableArray<ORKBodyItemView *> *viewsArray = [[NSMutableArray alloc] init];
    [bodyItems enumerateObjectsUsingBlock:^(ORKBodyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ORKBodyItemView *itemView = [[ORKBodyItemView alloc] initWithBodyItem:obj textAlignment:textAlignment];
        itemView.translatesAutoresizingMaskIntoConstraints = NO;
        [viewsArray addObject:itemView];
    }];
    return [viewsArray copy];
}

#pragma mark - ORKBodyItemViewDelegate

- (void)bodyItemLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate bodyContainerLearnMoreButtonPressed:learnMoreStep];
}

@end
