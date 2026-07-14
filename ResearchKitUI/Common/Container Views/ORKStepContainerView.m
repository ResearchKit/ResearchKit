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

#import <ResearchKitUI/ResearchKitUI-Swift.h>

#import "ORKStepView_Private.h"
#import "ORKStepContainerView_Private.h"
#import "ORKTitleLabel.h"
#import "ORKBodyItem.h"
#import "ORKStepContentView_Private.h"
#import "ORKBodyContainerView.h"
#import "ORKSkin.h"
#import "ORKActiveStep.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKTypes.h"
#import "ORKHelpers_Internal.h"
#import "ORKTableContainerView.h"
#import "UIView+Additions.h"

/*
 +-----------------------------------------+
 | +-------------------------------------+ |<---_stepContainerView
 | |        _topContentImageView         | |
 | |                                     | |
 | |                                     | |
 | |_____________________________________| |
 | +-------------------------------------+ |
 | |  +-------------------------------+  | |
 | |  |  +_________________________+  |  | |<-----_scrollView
 | |  |  |                         |  |  | |
 | |  |  |       +-------+         |  |<----------_scrollContainerView
 | |  |  |       | _icon |         |  |  | |
 | |  |  |       |       |         |  |  | |
 | |  |  |       +-------+         |<-------------_stepContentView
 | |  |  |                         |  |  | |
 | |  |  | +---------------------+ |  |  | |
 | |  |  | |    _titleLabel      | |  |  | |
 | |  |  | |_____________________| |  |  | |
 | |  |  | +---------------------+ |  |  | |
 | |  |  | |    _textLabel       | |  |  | |
 | |  |  | |_____________________| |  |  | |
 | |  |  | +---------------------+ |  |  | |
 | |  |  | |  _detailTextLabel   | |  |  | |
 | |  |  | |_____________________| |  |  | |
 | |  |  |                         |  |  | |
 | |  |  | +---------------------+ |  |  | |
 | |  |  | |                     |<-------------_bodyContainerView: UIstackView
 | |  |  | | +-----------------+ | |  |  | |
 | |  |  | | |                 | | |  |  | |
 | |  |  | | |--Title          | | |  |  | |
 | |  |  | | |--Text           |<-------------- BodyItemStyleText
 | |  |  | | |--LearnMore      | | |  |  | |
 | |  |  | | |_________________| | |  |  | |
 | |  |  | |                     | |  |  | |
 | |  |  | | +---+-------------+ | |  |  | |
 | |  |  | | |   |--Title      | | |  |  | |
 | |  |  | | | o |--Text       |<-------------- BodyItemStyleBullet
 | |  |  | | |   |--LearnMore  | | |  |  | |
 | |  |  | | |___|_____________| | |  |  | |
 | |  |  | |_____________________| |  |  | |
 | |  |  |                         |  |  | |
 | |  |  | +---------------------+ |  |  | |
 | |  |  | | _centeredVertically-| |  |  | |
 | |  |  | |     ImageView       | |  |  | |
 | |  |  | |_____________________| |  |  | |
 | |  |  |_________________________|  |  | |
 | |  |                               |  | |
 | |  |  +-------------------------+  |  | |
 | |  |  |    _CustomContentView   |  |  | |
 | |  |  |_________________________|  |  | |
 | |__|_______________________________|__| |
 |____|_______________________________|____|
      |                               |
      |                               |
      |  +-------------------------+  |
      |  |    _navigationFooter    |  |
      |  |_________________________|  |
      vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
 */

@interface ScrollView : UIScrollView {
@private
    CGSize _previousContentSize;
    CGSize _previousMinusOneContentSize;
}
@end

@implementation ScrollView

- (instancetype)init {
    self = [super init];
    if (self) {
        _previousContentSize = CGSizeZero;
        _previousMinusOneContentSize = CGSizeZero;
    }
    return self;
}

- (void)setContentSize:(CGSize)contentSize {
    // Detect oscillation: if the new size matches what we saw two calls ago,
    // Auto Layout is switching between two values. Break the cycle by
    // picking the larger height to avoid clipping content.
    if (!CGSizeEqualToSize(_previousContentSize, CGSizeZero) &&
        fabs(contentSize.height - _previousContentSize.height) < 1.0) {
        CGFloat maxHeight = MAX(contentSize.height, _previousMinusOneContentSize.height);
        contentSize = CGSizeMake(contentSize.width, maxHeight);
    }

    _previousContentSize = _previousMinusOneContentSize;
    _previousMinusOneContentSize = contentSize;
    [super setContentSize:contentSize];
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    // Workarround to make VO scroll work when the scrollview is scrollable because the added contentInset.bottom
    if (self.contentInset.bottom > 0 && self.contentSize.height <= self.bounds.size.height) {
        switch (direction) {
            case UIAccessibilityScrollDirectionUp: {
                [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:YES];
                NSString *announceString = [NSString stringWithFormat:ORKLocalizedString(@"AX_PAGE_NUMBER_FORMAT", nil), 1, 2];
                UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, announceString);
                return YES;
            }
            case UIAccessibilityScrollDirectionDown: {
                CGFloat offsetY = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
                [self setContentOffset:CGPointMake(self.contentOffset.x, offsetY) animated:YES];
                
                NSString *announceString = [NSString stringWithFormat:ORKLocalizedString(@"AX_PAGE_NUMBER_FORMAT", nil), 2, 2];
                UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, announceString);
                return YES;
            }
            default:
                break;
        }
    }
    return NO;
}

@end

@interface ORKStepContainerView ()
@property (nonatomic, readonly) NSArray<NSLayoutConstraint *> *navigationFooterViewConstraints;
@property (nonatomic, readonly) UIScrollEdgeElementContainerInteraction *bottomScrollEdgeInteraction API_AVAILABLE(ios(26.0));
@property (nonatomic, readonly) UIStackView *containerView;
@property (nonatomic, readwrite) UIView *flexibleContentSpacer;
@property (nonatomic, readwrite) UIImageView *topContentImageView;
@property (nonatomic, readwrite) UIView *footerLayoutContainer;
@end

@implementation ORKStepContainerView {
    UIImageView *_topContentImageView;
    UIStackView *_containerView;
    UIStackView *_scrollContentView;
    ScrollView *_scrollView;
    
    BOOL _shouldAddFooterPadding;

    BOOL _topContentImageShouldScroll;
    CGFloat _customContentTopPadding;
    BOOL _showScrollIndicator;
    CGFloat _scrollViewCustomContentInset;
    NSLayoutConstraint *_contentViewHeightConstraint;

    NSLayoutConstraint *_spacerHeightConstraint;
    NSArray<NSLayoutConstraint *> *_navigationFooterViewConstraints;
    NSLayoutConstraint *_footerHeightConstraint;
    UIScrollEdgeElementContainerInteraction *_bottomScrollEdgeInteraction API_AVAILABLE(ios(26.0));
}

- (NSArray<NSLayoutConstraint *> *)navigationFooterViewConstraints {
    if (!_navigationFooterViewConstraints) {
        _navigationFooterViewConstraints = @[
            [self.navigationFooterView.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
            [self.navigationFooterView.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
            [self.navigationFooterView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor]
        ];
    }
    return _navigationFooterViewConstraints;
}

- (UIScrollEdgeElementContainerInteraction *)bottomScrollEdgeInteraction API_AVAILABLE(ios(26.0)) {
    if (!_bottomScrollEdgeInteraction) {
        _bottomScrollEdgeInteraction = [self magicPocketFor:_scrollView edge:UIRectEdgeBottom];
    }
    return _bottomScrollEdgeInteraction;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.directionalLayoutMargins = ORKLargeContentLayoutMargins;
        self.contentLayoutMargins = NSDirectionalEdgeInsetsZero;
        self.isNavigationContainerScrollable = NO;
        _pinNavigationContainer = YES;
        _topContentImageShouldScroll = YES;
        _customContentTopPadding = ORKStepContainerTopCustomContentPaddingStandard;
    }
    return self;
}

- (NSArray<UIView *> *)canonicalContentViewOrder {
    // Build the list conditionally: properties like customContentView and
    // footerLayoutContainer are nil until externally set, and NSArray literals
    // crash on nil elements.
    NSMutableArray<UIView *> *order = [NSMutableArray array];
    addViewIfNotNil(order, self.stepContentView);
    addViewIfNotNil(order, self.stepContentViewLayoutContainer);
    addViewIfNotNil(order, self.customContentView);
    addViewIfNotNil(order, self.flexibleContentSpacer);
    addViewIfNotNil(order, self.footerLayoutContainer);
    addViewIfNotNil(order, self.navigationFooterView);
    return order;
}


static void addViewIfNotNil(NSMutableArray<UIView *> *viewArray, UIView *view) {
    if (viewArray && view) {
        [viewArray addObject:view];
    }
}

- (void)arrangeContentViews {
    UIStackView *stackView = self.scrollContentView;
    NSArray<UIView *> *canonical = [self canonicalContentViewOrder];
    NSArray *sorted = [stackView.arrangedSubviews sortedArrayUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
        NSUInteger aIdx = [canonical indexOfObject:a];
        NSUInteger bIdx = [canonical indexOfObject:b];
        if (aIdx == NSNotFound) { aIdx = NSUIntegerMax; }
        if (bIdx == NSNotFound) { bIdx = NSUIntegerMax; }
        if (aIdx < bIdx) { return NSOrderedAscending; }
        if (aIdx > bIdx) { return NSOrderedDescending; }
        return NSOrderedSame;
    }];
    for (UIView *subview in sorted) {
        [stackView removeArrangedSubview:subview];
        [stackView addArrangedSubview:subview];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    [[self.scrollContentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor] setActive:YES];

    self.stepContentView.hidden = [[self.stepContentView subviews] count] == 0;
    self.stepContentViewLayoutContainer.hidden = self.stepContentView.hidden;

    [self.stepContentViewLayoutContainer setContentHuggingPriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisVertical];

    [self.scrollContentView setCustomSpacing:_customContentTopPadding afterView:self.stepContentView];

    // Set a minimum height for the scroll content view to prevent ambiguity
    [self.scrollContentView removeConstraint:_contentViewHeightConstraint];
    _contentViewHeightConstraint = [self.scrollContentView.heightAnchor constraintGreaterThanOrEqualToAnchor:self.scrollView.frameLayoutGuide.heightAnchor];
    _contentViewHeightConstraint.priority = UILayoutPriorityDefaultHigh;
    [_contentViewHeightConstraint setActive:YES];

    if (_pinNavigationContainer || [self isScrollViewContentScrollable]) {
        CGSize navigationFooterSize = [self.navigationFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

        [_spacerHeightConstraint setActive:NO];
        _spacerHeightConstraint = [self.flexibleContentSpacer.heightAnchor constraintGreaterThanOrEqualToConstant:navigationFooterSize.height];
        _spacerHeightConstraint.priority = UILayoutPriorityDefaultLow;
        [_spacerHeightConstraint setActive:YES];
    }
}

- (void)setupContainerView {
    [self addSubview:self.containerView];
    [NSLayoutConstraint activateConstraints:@[
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

- (void)setupScrollContentView {
    [self.scrollView addSubview:self.scrollContentView];

    UILayoutGuide *contentGuide = self.scrollView.contentLayoutGuide;
    NSLayoutYAxisAnchor *topAnchor = self.scrollView.contentLayoutGuide.topAnchor;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollContentView.topAnchor constraintEqualToAnchor:topAnchor],
        [self.scrollContentView.leadingAnchor constraintEqualToAnchor:contentGuide.leadingAnchor],
        [self.scrollContentView.trailingAnchor constraintEqualToAnchor:contentGuide.trailingAnchor],
        [self.scrollContentView.bottomAnchor constraintEqualToAnchor:contentGuide.bottomAnchor],
    ]];
}

- (void)setPinNavigationContainer:(BOOL)pinNavigationContainer {
    _pinNavigationContainer = pinNavigationContainer;
    [self placeNavigationContainerView];
}

- (void)setStepTopContentImage:(UIImage *)stepTopContentImage {
    
    [super setStepTopContentImage:stepTopContentImage];
    if (_topContentImageShouldScroll) {
        self.topContentImageView.hidden = YES;
        [self.stepContentView setStepTopContentImage:stepTopContentImage];
    }
    else {
        //    1.) nil Image
        if (!stepTopContentImage) {
            self.topContentImageView.hidden = YES;
        }
        
        //    2.) First Image
        if (stepTopContentImage) {
            self.topContentImageView.image = [self topContentAndAuxiliaryImage];
            self.topContentImageView.hidden = NO;
        }
    }
}

- (UIStackView *)containerView {
    if (!_containerView) {
        _containerView = [[UIStackView alloc] initWithArrangedSubviews:@[
            self.topContentImageView,
            self.scrollView
        ]];
        _containerView.axis = UILayoutConstraintAxisVertical;
        _containerView.distribution = UIStackViewDistributionFill;
        _containerView.alignment = UIStackViewAlignmentFill;
        _containerView.spacing = 0;
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _containerView;
}

- (ScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[ScrollView alloc] init];
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        _scrollView.showsVerticalScrollIndicator = self.showScrollIndicator;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollView.directionalLayoutMargins = NSDirectionalEdgeInsetsZero;
        [_scrollView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisVertical];
    }
    return _scrollView;
}

- (UIView *)scrollContentView {
    if (!_scrollContentView) {
        _scrollContentView = [[UIStackView alloc] init];
        _scrollContentView.axis = UILayoutConstraintAxisVertical;
        _scrollContentView.distribution = UIStackViewDistributionFill;
        _scrollContentView.alignment = UIStackViewAlignmentFill;
        _scrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollContentView.layoutMarginsRelativeArrangement = YES;
        _scrollContentView.directionalLayoutMargins = ORKSmallContentLayoutMargins;
    }
    return _scrollContentView;
}

- (NSDirectionalEdgeInsets) scrollContentLayoutMargins {
    return self.scrollContentView.directionalLayoutMargins;
}

- (void)setScrollContentLayoutMargins:(NSDirectionalEdgeInsets)contentLayoutMargins {
    self.scrollContentView.directionalLayoutMargins = contentLayoutMargins;
}

- (void)setContentLayoutMargins:(NSDirectionalEdgeInsets)contentLayoutMargins {
    _contentLayoutMargins = contentLayoutMargins;
    self.stepContentView.directionalLayoutMargins = contentLayoutMargins;
}

- (UIImageView *)topContentImageView {
    if (!_topContentImageView) {
        _topContentImageView = [UIImageView new];
        _topContentImageView.hidden = YES;
        _topContentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_topContentImageView setBackgroundColor:ORKColor(ORKTopContentImageViewBackgroundColorKey)];
    }
    return _topContentImageView;
}

- (void)setShowScrollIndicator:(BOOL)showScrollIndicator {
    _showScrollIndicator = showScrollIndicator;
    _scrollView.showsVerticalScrollIndicator = showScrollIndicator;
}

- (BOOL)showScrollIndicator {
    return _showScrollIndicator;
}

- (void)setStepTopContentImageContentMode:(UIViewContentMode)stepTopContentImageContentMode {
    [super setStepTopContentImageContentMode:stepTopContentImageContentMode];
    if (_topContentImageView) {
        _topContentImageView.contentMode = stepTopContentImageContentMode;
    }
}

- (void)setAuxiliaryImage:(UIImage *)auxiliaryImage {
    [super setAuxiliaryImage:auxiliaryImage];
    if (self.stepTopContentImage) {
        self.topContentImageView.image = [self topContentAndAuxiliaryImage];
        self.topContentImageView.hidden = NO;
    }
}

- (void)setScrollViewCustomContentInset:(CGFloat)scrollViewCustomContentInset {
    _scrollViewCustomContentInset = scrollViewCustomContentInset;
    [self updateScrollViewCustomContentInset];
}

- (void)updateScrollViewCustomContentInset {
    if (_scrollViewCustomContentInset == ORKCGFloatDefaultValue) { return; }
    
    if (self.contentHeight > self.frame.size.height) {
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, _scrollViewCustomContentInset, 0);
    } else {
        _scrollView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)setCustomContentView:(UIView *)customContentView {
    if (_customContentView) {
        [_customContentView removeFromSuperview];
    }
    _customContentView = customContentView;
    [self.scrollContentView addArrangedSubview:_customContentView];
    [self arrangeContentViews];

//  Since a new view was added, make sure it gets rendered on the next render pass
    [self setNeedsLayout];
}

- (void)removeNavigationFooterView {
    if (_navigationFooterViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_navigationFooterViewConstraints];
    }
    
    [self.footerLayoutContainer removeFromSuperview];
    [self.navigationFooterView removeFromSuperview];
}

- (UIView *)flexibleContentSpacer {
    if (!_flexibleContentSpacer) {
        _flexibleContentSpacer = [[UIView alloc] initWithFrame:CGRectZero];
        [_flexibleContentSpacer setContentHuggingPriority:UILayoutPriorityDefaultLow - 1
                                                              forAxis:UILayoutConstraintAxisVertical];
    }
    return _flexibleContentSpacer;
}

- (void)setNavigationFooterViewHidden:(BOOL)hidden {
    [self.footerLayoutContainer setHidden:hidden];
    [self.navigationFooterView setHidden:hidden];

    /* The flexible spacer is useful when there is a view above and below in it the stackview.
     This allows the stackview to adjust the size of the space from 0 to whatever height is needed
     to let the top content be top aligned with variable empty space down to the footer view. However,
     when the footer is completely hidden. the spacer is then not allowing the top view to take all
     the visible space in the stack view, which is generally the main reason the footer is hidden.
     */
    if (!self.customContentView.hidden && hidden) {
        [self.scrollContentView removeArrangedSubview:self.flexibleContentSpacer];
    } else if (![self.scrollContentView.arrangedSubviews containsObject:self.flexibleContentSpacer]) {
        // Only add if not already present to avoid moving it during layout
        [self.scrollContentView addArrangedSubview:self.flexibleContentSpacer];
        [self arrangeContentViews];
    }
    
    [self.footerLayoutContainer removeFromSuperview];
    [self.navigationFooterView removeFromSuperview];
}

- (void)placeNavigationContainerView {
    if (ORKLiquidGlassSupportEnabled()) {
        if (_pinNavigationContainer || [self isScrollViewContentScrollable]) {
            [self removeNavigationFooterView];
            
            if (@available(iOS 26.0, *)) {
                [self.navigationFooterView addInteraction:self.bottomScrollEdgeInteraction];
            }

            self.navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;

            [self addSubview:self.navigationFooterView];
            [NSLayoutConstraint activateConstraints:self.navigationFooterViewConstraints];
        } else if (![self isScrollViewContentScrollable]) {
            [self removeNavigationFooterView];
            
            if (_bottomScrollEdgeInteraction) {
                [self.navigationFooterView removeInteraction:_bottomScrollEdgeInteraction];
            }
            
            [self placeNavigationViewInContainer:self.scrollContentView embedInLayoutContainer:YES shouldAddFooterPadding:_shouldAddFooterPadding];
        }
    } else {
        // Non-Liquid Glass: Only place footer once - check if it's already in the right container
        BOOL footerAlreadyPlaced = (self.footerLayoutContainer.superview == _containerView) ||
                                    (self.footerLayoutContainer.superview == _scrollContentView);

        if (!footerAlreadyPlaced) {
            [self removeNavigationFooterView];

            if (_pinNavigationContainer) {
                [self placeNavigationViewInContainer:self.containerView embedInLayoutContainer:YES];
            } else {
                [self placeNavigationViewInContainer:self.scrollContentView
                              embedInLayoutContainer:NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(NSDirectionalEdgeInsetsZero, self.contentLayoutMargins)];
            }
        }
    }
}

- (void)placeNavigationViewInContainer:(UIStackView *)container embedInLayoutContainer:(BOOL)embedFooterInLayoutContainer {
    [self placeNavigationViewInContainer:container embedInLayoutContainer:embedFooterInLayoutContainer shouldAddFooterPadding:YES];
}

- (void)placeNavigationViewInContainer:(UIStackView *)container embedInLayoutContainer:(BOOL)embedFooterInLayoutContainer shouldAddFooterPadding:(BOOL)shouldAddFooterPadding {
    // Remove old footer height constraint if it exists
    if (_footerHeightConstraint) {
        [_footerHeightConstraint setActive:NO];
        _footerHeightConstraint = nil;
    }

    // Only add spacer when placing footer in scrollContentView, not in containerView
    BOOL isAddingToContainerView = (container == _containerView);
    
    if (embedFooterInLayoutContainer) {
        self.footerLayoutContainer = [UIView layoutContainerFor:self.navigationFooterView shouldAddFooterPadding:shouldAddFooterPadding];

        if (isAddingToContainerView) {
            // iOS 18 pinned footer: Use explicit height constraint to prevent stretching in stack
            CGSize footerSize = [self.navigationFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            _footerHeightConstraint = [self.footerLayoutContainer.heightAnchor constraintEqualToConstant:footerSize.height];
            _footerHeightConstraint.priority = UILayoutPriorityRequired - 1;
            [_footerHeightConstraint setActive:YES];
        } else {
            // iOS 26 or iOS 18 non-pinned: Use content hugging priority
            [self.footerLayoutContainer setContentHuggingPriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisVertical];
        }
        [container addArrangedSubview:self.footerLayoutContainer];
    } else {
        [container addArrangedSubview:self.navigationFooterView];
    }
}

- (void)placeNavigationContainerInsideScrollView {
    self.isNavigationContainerScrollable = YES;
    [self placeNavigationContainerView];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) { return; }

	[self setupContainerView];
	[self setupScrollContentView];

    [self.scrollContentView addArrangedSubview:self.stepContentView];
    [self.scrollContentView addArrangedSubview:self.flexibleContentSpacer];

    [self arrangeContentViews];
}

- (BOOL)isScrollViewContentScrollable {
    return self.scrollContentView.bounds.size.height > self.scrollView.bounds.size.height;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self placeNavigationContainerView];
}

- (void)setCustomContentFillsAvailableSpace:(BOOL)customContentFillsAvailableSpace {
    _customContentFillsAvailableSpace = customContentFillsAvailableSpace;

    // When content fills available space, remove the spacer so it doesn't compete for space
    if (customContentFillsAvailableSpace) {
        [self.scrollContentView removeArrangedSubview:self.flexibleContentSpacer];
    }
}

- (void)setCustomContentView:(UIView *)customContentView withPadding:(NSDirectionalEdgeInsets)padding {
    [self setCustomContentView:customContentView withPadding:padding shouldAddFooterPadding:YES];
}

- (void)setCustomContentView:(UIView *)customContentView withPadding:(NSDirectionalEdgeInsets)padding shouldAddFooterPadding:(BOOL)shouldAddFooterPadding {
    _shouldAddFooterPadding = shouldAddFooterPadding;
    
    self.navigationFooterView.shouldAddFooterPadding = shouldAddFooterPadding;
    
    _customContentTopPadding = padding.top;
    [self.stepContentView setCustomTopPadding:[NSNumber numberWithFloat:padding.top]];

    NSDirectionalEdgeInsets currentMargins = self.scrollContentView.directionalLayoutMargins;

    self.scrollContentView.directionalLayoutMargins =
        NSDirectionalEdgeInsetsMake(
            currentMargins.top,
            padding.leading > 0 ? padding.leading : currentMargins.leading,
            0,
            padding.trailing > 0 ? padding.trailing : currentMargins.trailing
        );

    NSDirectionalEdgeInsets superViewLayoutMargins = [self.superview directionalLayoutMargins];
    if (NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(superViewLayoutMargins, ORKLargeContentLayoutMargins)) {
        [self setCustomContentView:customContentView];
    } else {
        UIView *contentViewLayoutContainer = [UIView layoutContainerFor:customContentView margins:currentMargins];
        [self setCustomContentView:contentViewLayoutContainer];
    }
    [self setNeedsLayout];
}

- (void)topContentImageShouldStickToTop {
    if (self.stepTopContentImage) {
        UIImage *stepTopContentImage = self.stepTopContentImage;
        [self setStepTopContentImage:nil];
        _topContentImageShouldScroll = NO;
        [self setStepTopContentImage:stepTopContentImage];
    }
    _topContentImageShouldScroll = NO;
}

- (void)updatePaddingConstraints {
    [self.stepContentView setUseExtendedPadding:[self useExtendedPadding]];
    [self.navigationFooterView setUseExtendedPadding:[self useExtendedPadding]];
}

- (void)setUseExtendedPadding:(BOOL)useExtendedPadding {
    [super setUseExtendedPadding:useExtendedPadding];
    [self updatePaddingConstraints];
}

- (void)scrollToBodyItem:(UIView *)bodyItem {
    CGPoint pointInScrollView = [bodyItem.superview convertPoint:bodyItem.frame.origin toView:self.scrollView];
    CGFloat bottomOfView = pointInScrollView.y + bodyItem.frame.size.height;
    CGFloat bottomOfScrollView = self.scrollView.frame.size.height - [self navigationFooterView].frame.size.height;

    if (bottomOfView > bottomOfScrollView) {
        [self.scrollView setContentOffset:CGPointMake(0, (bottomOfView - bottomOfScrollView) + ORKBodyItemScrollPadding) animated:YES];
    }
}

- (CGFloat)contentHeight {
    return self.scrollView.contentSize.height;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [_scrollView setScrollEnabled:scrollEnabled];
}

- (BOOL)isScrollEnabled {
    return _scrollView.scrollEnabled;
}

- (UIEdgeInsets)scrollViewInset {
    return _scrollView.contentInset;
}

- (void)setScrollViewInset:(UIEdgeInsets)scrollViewInset {
    [_scrollView setContentInset:scrollViewInset];
}

- (void)resetScrollViewInset {
    if (_pinNavigationContainer) {
        CGFloat offset = [self contentHeight] - self.navigationFooterView.frame.origin.y;
        self.scrollViewInset = UIEdgeInsetsMake(0.0, 0.0, offset + ORKContentBottomPadding, 0.0);
    } else {
        self.scrollViewInset = UIEdgeInsetsZero;
    }
}

- (void)scrollToPoint:(CGPoint)point {
    [_scrollView setContentOffset:point animated:YES];
}

@end
