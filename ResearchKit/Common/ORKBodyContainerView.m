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
#import "ORKLearnMoreView.h"
#import "ORKLearnMoreInstructionStep.h"
#import "ORKTagLabel.h"


static const CGFloat ORKBodyToBulletPaddingStandard = 26.0;

static const CGFloat ORKBulletToBulletPaddingStandard = 22.0;
static const CGFloat ORKBodyToLearnMorePaddingStandard = 15.0;
static const CGFloat ORKTagLabelBottomPadding = 8.0;
static const CGFloat ORKHorizontalRulePadding = 22.0;

static const CGFloat ORKBodyTextToBodyDetailTextPaddingStandard = 6.0;
static const CGFloat ORKBodyTextToLearnMoreButtonPaddingStandard = 15.0;
static const CGFloat ORKBodyDetailTextToLearnMoreButtonPaddingStandard = 15.0;

static const CGFloat ORKBulletIconToBodyPadding = 14.0;
static const CGFloat ORKBulletIconWidthStandard = 10.0;

static const CGFloat ORKBulletIconDimension = 40.0;
static const CGFloat ORKCardStylePadding = 16.0;
static const CGFloat ORKCardStyleMediumTextPadding = 14.0;
static const CGFloat ORKCardStyleSmallTextPadding = 2.0;

static const CGFloat ORKCardStyleBuildInPostitionStart = 31.0;
static const CGFloat ORKCardStyleBuildInPostitionEnd = 26.0;

static NSString *ORKBulletUnicode = @"\u2981";

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
        [self setupBodyStyleView];
        
    }
    return self;
}

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem textAlignment:(NSTextAlignment)textAlignment {
    self = [super init];
    if (self) {
        self.bodyItem = bodyItem;
        self.textAlignment = textAlignment;
        [self setupBodyStyleView];
        
    }
    return self;
}

- (void)setupBodyStyleView {
    // FIXME:- remove cardStyle property, not using it anymore
    if (_bodyItem.useCardStyle == YES) {
        _cardView = [[UIView alloc] init];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:_cardView];
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
    }
}

+ (UIFont *)bodyTitleFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bodyTitleFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletIconFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    descriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitTightLeading | UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:descriptor size:0];
}

+ (UIFont *)bulletTextFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold | UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletBodyTextFontBold {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold | UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletDetailTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
    
}

- (void)setupBodyStyleHorizontalRule {
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFill;
    UIView *separator = [UIView new];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        separator.backgroundColor = UIColor.separatorColor;
    } else {
        separator.backgroundColor = UIColor.lightGrayColor;
    }
    [separator.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
    [self addArrangedSubview:separator];
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
        textLabel.font = _bodyItem.detailText == nil ? [ORKBodyItemView bodyTitleFont] : [ORKBodyItemView bodyTitleFontBold];
        textLabel.text = _bodyItem.text;
        textLabel.textAlignment = _textAlignment;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (_bodyItem.useCardStyle == YES) {
            [_cardView addSubview:textLabel];
            [textLabel.leadingAnchor constraintEqualToAnchor: _cardView.leadingAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            [textLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:ORKCardStylePadding].active = YES;
            [textLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding].active = YES;
            
            if (_bodyItem.detailText == nil) {
                [textLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStylePadding].active = YES;
            }
        } else {
            [self addArrangedSubview:textLabel];
        }
    }
    if (_bodyItem.detailText) {
        detailTextLabel = [UILabel new];
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.font = [ORKBodyItemView bodyTextFont];
        detailTextLabel.text = _bodyItem.detailText;
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (_bodyItem.useCardStyle == YES) {
            [_cardView addSubview:detailTextLabel];
            [detailTextLabel.leadingAnchor constraintEqualToAnchor: _cardView.leadingAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            [detailTextLabel.topAnchor constraintEqualToAnchor:textLabel.bottomAnchor constant:ORKCardStyleSmallTextPadding].active = YES;
            [detailTextLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-ORKCardStylePadding].active = YES;
            [detailTextLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-ORKCardStylePadding].active = YES;
        } else {
            [self addArrangedSubview:detailTextLabel];
            if (textLabel) {
                [self setCustomSpacing:ORKBodyTextToBodyDetailTextPaddingStandard afterView:textLabel];
            }
        }
    }
    if (_bodyItem.learnMoreItem) {
        ORKLearnMoreView *learnMoreView = _bodyItem.learnMoreItem.text ? [ORKLearnMoreView learnMoreCustomButtonViewWithText:_bodyItem.learnMoreItem.text LearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep] : [ORKLearnMoreView learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep];
        [learnMoreView setLearnMoreButtonFont:[ORKBodyItemView bodyTextFont]];
        [learnMoreView setLearnMoreButtonTextAlignment:_textAlignment];
        learnMoreView.delegate = self;
        learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:learnMoreView];
        if (detailTextLabel) {
            [self setCustomSpacing:ORKBodyDetailTextToLearnMoreButtonPaddingStandard afterView:detailTextLabel];
        }
        else if (textLabel) {
            [self setCustomSpacing:ORKBodyTextToLearnMoreButtonPaddingStandard afterView:textLabel];
        }
    }
}

- (void)setupBulletPointStackView {
    self.axis = UILayoutConstraintAxisHorizontal;
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
        [self setCustomSpacing:ORKBulletIconToBodyPadding afterView:bulletIcon];
    }
    
    [self addSubStackView];
}

- (void)setupBodyStyleImage {
    UIImageView *imageView = [self imageView];
    self.alignment = UIStackViewAlignmentCenter;
    
    if (_bodyItem.useCardStyle == YES) {
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:imageView];
        [imageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor].active = YES;
        [imageView.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor].active = YES;
        _cardStyleAccessoryView = imageView;
    } else {
        [self addArrangedSubview:imageView];
        [self setCustomSpacing:ORKBulletIconToBodyPadding afterView:imageView];
    }
    
    [self addSubStackView];
}

- (UILabel *)bulletIcon {
    UILabel *bulletIconLabel = [UILabel new];
    bulletIconLabel.numberOfLines = 1;
    bulletIconLabel.font = [ORKBodyItemView bulletIconFont];
    if (@available(iOS 13.0, *)) {
        bulletIconLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        bulletIconLabel.textColor = [UIColor systemGrayColor];
    }
    [bulletIconLabel setText:ORKBulletUnicode];
    bulletIconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[bulletIconLabel.widthAnchor constraintGreaterThanOrEqualToConstant:ORKBulletIconWidthStandard] setActive:YES];
    
    return bulletIconLabel;
}

- (UIImageView *)imageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = self.bodyItem.image;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.bodyItem.useSecondaryColor) {
        imageView.tintColor = UIColor.grayColor;
    }
    if (@available(iOS 13.0, *)) {
        // To allow symbols to handle their own configuration
        if (imageView.image.isSymbolImage) {
            imageView.contentMode = UIViewContentModeCenter;
        } else {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }

    [imageView.heightAnchor constraintEqualToConstant:ORKBulletIconDimension].active = YES;
    [imageView.widthAnchor constraintEqualToConstant:ORKBulletIconDimension].active = YES;

    return imageView;
}

- (void)setupBodyStyleTag {
    UIView *container = [UIView new];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    ORKTagLabel *tagLabel = [ORKTagLabel new];
    tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tagLabel.text = _bodyItem.text;
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
        subStackView.alignment = UIStackViewAlignmentLeading;
        subStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:subStackView];
    }
    
    if (_bodyItem.text) {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.text = _bodyItem.text;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (_bodyItem.useCardStyle == YES) {
            textLabel.font = [ORKBodyItemView bulletBodyTextFontBold];
            
            [_cardStyleAccessoryView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            
            [_cardView addSubview:textLabel];
            [textLabel.leadingAnchor constraintEqualToAnchor: _cardStyleAccessoryView.trailingAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            [textLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:0].active = YES;
            [textLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor].active = YES;
            [textLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            
            if (_bodyItem.detailText == nil) {
                [textLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor].active = YES;
            }
        } else {
            textLabel.font = _bodyItem.detailText ? [ORKBodyItemView bulletTextFontBold] : [ORKBodyItemView bulletTextFont];
            [subStackView addArrangedSubview:textLabel];
        }
    }
    if (_bodyItem.detailText) {
        detailTextLabel = [UILabel new];
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.font = [ORKBodyItemView bulletDetailTextFont];
        detailTextLabel.text = _bodyItem.detailText;
        if (_bodyItem.useCardStyle == YES) {
            if (@available(iOS 13.0, *)) {
                [detailTextLabel setTextColor:[UIColor labelColor]];
            } else{
                [detailTextLabel setTextColor:ORKColor(ORKBulletItemTextColorKey)];
            }
        } else {
            [detailTextLabel setTextColor:ORKColor(ORKBulletItemTextColorKey)];
        }
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (_bodyItem.useCardStyle == YES) {
            [_cardView addSubview:detailTextLabel];
            [detailTextLabel.leadingAnchor constraintEqualToAnchor: _cardStyleAccessoryView.trailingAnchor constant:ORKCardStyleMediumTextPadding].active = YES;
            [detailTextLabel.topAnchor constraintEqualToAnchor:textLabel.bottomAnchor constant:ORKCardStyleSmallTextPadding].active = YES;
            [detailTextLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor].active = YES;
            [detailTextLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor].active = YES;
        } else {
            [subStackView addArrangedSubview:detailTextLabel];
        }
    }
    if (_bodyItem.learnMoreItem) {
        ORKLearnMoreView *learnMoreView = _bodyItem.learnMoreItem.text ? [ORKLearnMoreView learnMoreCustomButtonViewWithText:_bodyItem.learnMoreItem.text LearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep] : [ORKLearnMoreView learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep];
        [learnMoreView setLearnMoreButtonFont:[ORKBodyItemView bulletDetailTextFont]];
        learnMoreView.delegate = self;
        learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
        [subStackView addArrangedSubview:learnMoreView];
    }
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
        self.distribution = UIStackViewDistributionFill;
        [self addBodyItemViews];
    }
    return self;
}

- (void)addBodyItemViews {
    _views = [ORKBodyContainerView bodyItemViewsWithBodyItems:_bodyItems textAlignment:_textAlignment];
    for (NSInteger i = 0; i < _views.count; i++) {
        [self addArrangedSubview:_views[i]];
        _views[i].delegate = self;
        
        if (i < _views.count - 1) {
            CGFloat padding = [self spacingWithAboveStyle:_bodyItems[i].bodyItemStyle belowStyle:_bodyItems[i + 1].bodyItemStyle belowIsLearnMore:(_bodyItems[i + 1].learnMoreItem != nil) belowItemIndex:i+1];
            [self setCustomSpacing:padding afterView:_views[i]];
        }
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

- (CGFloat)spacingWithAboveStyle:(ORKBodyItemStyle)aboveStyle belowStyle:(ORKBodyItemStyle )belowStyle belowIsLearnMore:(BOOL)belowIsLearnMore belowItemIndex:(NSInteger)belowItemIndex {
    if (aboveStyle == ORKBodyItemStyleHorizontalRule || belowStyle == ORKBodyItemStyleHorizontalRule) {
        return ORKHorizontalRulePadding;
    } else if (belowIsLearnMore == YES) {
        return ORKBodyToLearnMorePaddingStandard;
    } else if (aboveStyle == ORKBodyItemStyleText) {
        return belowStyle == ORKBodyItemStyleText ? (_bodyItems[belowItemIndex].text ? ORKBodyToBodyParagraphPaddingStandard : ORKBodyToBodyPaddingStandard) : ORKBodyToBulletPaddingStandard;
    } else if (aboveStyle == ORKBodyItemStyleTag) {
        return ORKTagLabelBottomPadding;
    } else {
        return belowStyle == ORKBodyItemStyleText ? ORKBodyToBulletPaddingStandard : ORKBulletToBulletPaddingStandard;
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
