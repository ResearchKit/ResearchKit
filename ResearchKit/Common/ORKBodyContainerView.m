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



static const CGFloat ORKBodyToBulletPaddingStandard = 37.0;

static const CGFloat ORKBulletToBulletPaddingStandard = 26.0;

static const CGFloat ORKBodyTextToBodyDetailTextPaddingStandard = 6.0;
static const CGFloat ORKBodyTextToLearnMoreButtonPaddingStandard = 15.0;
static const CGFloat ORKBodyDetailTextToLearnMoreButtonPaddingStandard = 15.0;

static const CGFloat ORKBulletIconToBodyPadding = 14.0;
static const CGFloat ORKBulletIconWidthStandard = 10.0;
static const CGFloat ORKBulletStackLeftRightPadding = 10.0;

static const CGFloat ORKBulletIconDimension = 40.0;

static NSString *ORKBulletUnicode = @"\u2981";

//  FIXME: Short and Compact paddings
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

@end

@interface ORKBodyItemView()<ORKLearnMoreViewDelegate>

@end

@implementation ORKBodyItemView

- (instancetype)initWithBodyItem:(ORKBodyItem *)bodyItem {
    self = [super init];
    if (self) {
        self.bodyItem = bodyItem;
        [self setupBodyStyleView];
        
    }
    return self;
}

- (void)setupBodyStyleView {
    if (_bodyItem.bodyItemStyle == ORKBodyItemStyleText) {
        [self setupBodyStyleTextView];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleImage) {
        [self setupBulletPointStackView];
        [self setupBodyStyleImage];
    } else if (_bodyItem.bodyItemStyle == ORKBodyItemStyleBulletPoint) {
        [self setupBulletPointStackView];
        [self setupBodyStyleBulletPointView];
    }
}

+ (UIFont *)bodyTitleFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
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

+ (UIFont *)bulletTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold | UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

+ (UIFont *)bulletDetailTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitLooseLeading)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
    
}

- (void)setupBodyStyleTextView {
    self.axis = UILayoutConstraintAxisVertical;
    self.distribution = UIStackViewDistributionFill;
    self.alignment = UIStackViewAlignmentLeading;
    UILabel *textLabel;
    UILabel *detailTextLabel;
    
    if (_bodyItem.text) {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [ORKBodyItemView bodyTitleFont];
        textLabel.text = _bodyItem.text;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:textLabel];
    }
    if (_bodyItem.detailText) {
        detailTextLabel = [UILabel new];
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.font = [ORKBodyItemView bodyTextFont];
        detailTextLabel.text = _bodyItem.detailText;
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:detailTextLabel];
        if (textLabel) {
            [self setCustomSpacing:ORKBodyTextToBodyDetailTextPaddingStandard afterView:textLabel];
        }
    }
    if (_bodyItem.learnMoreItem) {
        ORKLearnMoreView *learnMoreView = _bodyItem.learnMoreItem.text ? [ORKLearnMoreView learnMoreCustomButtonViewWithText:_bodyItem.learnMoreItem.text LearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep] : [ORKLearnMoreView learnMoreDetailDisclosureButtonViewWithLearnMoreInstructionStep:_bodyItem.learnMoreItem.learnMoreInstructionStep];
        [learnMoreView setLearnMoreButtonFont:[ORKBodyItemView bodyTextFont]];
        learnMoreView.delegate = self;
        learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:learnMoreView];
        if (detailTextLabel) {
            [self setCustomSpacing:ORKBodyDetailTextToLearnMoreButtonPaddingStandard afterView:detailTextLabel];
        }
        else if (textLabel) {
            [self setCustomSpacing:ORKBodyTextToLearnMoreButtonPaddingStandard afterView:detailTextLabel];
        }
    }
}

- (void)setupBulletPointStackView {
    self.axis = UILayoutConstraintAxisHorizontal;
    self.layoutMargins = UIEdgeInsetsMake(0.0, ORKBulletStackLeftRightPadding, 0.0, ORKBulletStackLeftRightPadding);
    [self setLayoutMarginsRelativeArrangement:YES];
}

- (void)setupBodyStyleBulletPointView {
    UILabel *bulletIcon = [self bulletIcon];
    [self addArrangedSubview:bulletIcon]; // Stack this in substack for vertical bullet icon.
    [self setCustomSpacing:ORKBulletIconToBodyPadding afterView:bulletIcon];
    [self addSubStackView];
}

- (void)setupBodyStyleImage {
    UIImageView *imageView = [self imageView];
    [self addArrangedSubview:imageView];
    [self setCustomSpacing:ORKBulletIconToBodyPadding afterView:imageView];
    [self addSubStackView];
}

- (UILabel *)bulletIcon {
    UILabel *bulletIconLabel = [UILabel new];
    bulletIconLabel.numberOfLines = 1;
    bulletIconLabel.font = [ORKBodyItemView bulletIconFont];
    [bulletIconLabel setText:ORKBulletUnicode];
    bulletIconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:bulletIconLabel
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:ORKBulletIconWidthStandard]
                                              ]];
    return bulletIconLabel;
}

- (UIImageView *)imageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = self.bodyItem.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView.heightAnchor constraintEqualToConstant:ORKBulletIconDimension].active = YES;
    [imageView.widthAnchor constraintEqualToConstant:ORKBulletIconDimension].active = YES;
    return imageView;
}

- (void)addSubStackView {
    UIStackView *subStackView = [[UIStackView alloc] init];
    subStackView.axis = UILayoutConstraintAxisVertical;
    subStackView.distribution = UIStackViewDistributionFill;
    subStackView.alignment = UIStackViewAlignmentLeading;
    subStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:subStackView];
    UILabel *textLabel;
    UILabel *detailTextLabel;
    
    if (_bodyItem.text) {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [ORKBodyItemView bulletTextFont];
        textLabel.text = _bodyItem.text;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [subStackView addArrangedSubview:textLabel];
    }
    if (_bodyItem.detailText) {
        detailTextLabel = [UILabel new];
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.font = [ORKBodyItemView bulletDetailTextFont];
        detailTextLabel.text = _bodyItem.detailText;
        [detailTextLabel setTextColor:ORKColor(ORKBulletItemTextColorKey)];
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [subStackView addArrangedSubview:detailTextLabel];
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

@end

@implementation ORKBodyContainerView

- (instancetype)initWithBodyItems:(NSArray<ORKBodyItem *> *)bodyItems delegate:(nonnull id<ORKBodyContainerViewDelegate>)delegate {
    self.delegate = delegate;
    if (bodyItems && bodyItems.count <= 0) {
        NSAssert(NO, @"Body Items array cannot be empty");
    }
    self = [super init];
    if (self) {
        self.bodyItems = bodyItems;
        self.axis = UILayoutConstraintAxisVertical;
        self.distribution = UIStackViewDistributionFill;
        [self addBodyItemViews];
    }
    return self;
}

- (void)addBodyItemViews {
    NSArray<ORKBodyItemView *> *views = [ORKBodyContainerView bodyItemViewsWithBodyItems:_bodyItems];
    for (NSInteger i = 0; i < views.count; i++) {
        [self addArrangedSubview:views[i]];
        views[i].delegate = self;
        if (i < views.count - 1) {
            
            CGFloat padding = [self spacingWithAboveStyle:_bodyItems[i].bodyItemStyle belowStyle:_bodyItems[i + 1].bodyItemStyle];
            
            [self setCustomSpacing:padding afterView:views[i]];
        }
    }
}

- (CGFloat)spacingWithAboveStyle:(ORKBodyItemStyle )aboveStyle belowStyle:(ORKBodyItemStyle )belowStyle {
    if (aboveStyle == ORKBodyItemStyleText) {
        return belowStyle == ORKBodyItemStyleText ? ORKBodyToBodyPaddingStandard : ORKBodyToBulletPaddingStandard;
    }
    else {
        return belowStyle == ORKBodyItemStyleText ? ORKBodyToBulletPaddingStandard : ORKBulletToBulletPaddingStandard;
    }
}

+ (NSArray<ORKBodyItemView *> *)bodyItemViewsWithBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    NSMutableArray<ORKBodyItemView *> *viewsArray = [[NSMutableArray alloc] init];
    [bodyItems enumerateObjectsUsingBlock:^(ORKBodyItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ORKBodyItemView *itemView = [[ORKBodyItemView alloc] initWithBodyItem:obj];
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
