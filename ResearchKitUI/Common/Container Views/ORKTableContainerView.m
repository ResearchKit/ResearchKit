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


#import "ORKTableContainerView.h"
#import "ORKStepContentView_Private.h"
#import "UIView+Additions.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView.h"

#import "ORKTitleLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#import "ORKBodyItem.h"
#import "ORKBodyContainerView.h"
#import <ResearchKit/ResearchKit-Swift.h>
#import <ResearchKitUI/ResearchKitUI-Swift.h>

const CGFloat tableHeaderBottomPadding = 32.0;

// Enable this define to see outlines and colors of all the views laid out at this level.
// #define LAYOUT_DEBUG

@interface ORKTableContainerView () <UIGestureRecognizerDelegate>

@property (nonnull, readwrite, nonatomic) UIStackView *contentView;
@property (assign) UITableViewStyle tableViewStyle;
@property (nonatomic, readwrite) UIScrollEdgeElementContainerInteraction *navigationFooterMagicPocketInteraction API_AVAILABLE(ios(26.0));
@property (nonatomic, assign) BOOL isFooterHidden;

@end

CGFloat automaticMinimumHeightForTableViewRow(CGFloat existingHeight) {
    CGFloat minimumTableViewRowHeight = 52.0;

    if (0 < existingHeight && existingHeight < minimumTableViewRowHeight) {
        return minimumTableViewRowHeight;
    } else {
        return UITableViewAutomaticDimension;
    }
}

@implementation ORKTableContainerView {
    UITableView *_tableView;
    UITapGestureRecognizer *_tapOffGestureRecognizer;
    
    UIView *_footerView;
    NSLayoutConstraint *_contentViewBottomConstraint;
    NSArray<NSLayoutConstraint *> *_pinnedFooterConstraints;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped pinNavigationContainer:YES];
}

- (instancetype)initWithStyle:(UITableViewStyle)style pinNavigationContainer:(BOOL)pinNavigationContainer {
    self = [super init];
    if (self) {
        _tableViewStyle = style;
        self.isNavigationContainerScrollable = !pinNavigationContainer;

        [self setupTableView];
        [self setupContentView];

        _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
        _tapOffGestureRecognizer.delegate = self;
        [self.tableView addGestureRecognizer:_tapOffGestureRecognizer];
    }
    return self;
}

- (void)setupContentView {
    UIView *contentView = self.contentView;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    
    // Store the bottom constraint so we can update it when footer is hidden
    _contentViewBottomConstraint = [self.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor];

    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        _contentViewBottomConstraint,
        [self.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
    ]];
    [self addMagicPocketIfNecessaryFor:self.tableView];
}

- (void)setIsFooterHidden:(BOOL)isFooterHidden {
    if (_isFooterHidden != isFooterHidden) {
        _isFooterHidden = isFooterHidden;

        // Update the bottom constraint based on whether footer is hidden
        if (_contentViewBottomConstraint) {
            [_contentViewBottomConstraint setActive:NO];

            if (isFooterHidden) {
                // When footer is hidden, use self.bottomAnchor to prevent empty space
                _contentViewBottomConstraint = [self.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor];
            } else {
                // When footer is visible, use safeAreaLayoutGuide to respect safe area
                _contentViewBottomConstraint = [self.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor];
            }

            [_contentViewBottomConstraint setActive:YES];
            [self setNeedsLayout];
        }
    }
}

- (void)setupTableView {
    if (self.isNavigationContainerScrollable) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        self.tableView.automaticallyAdjustsScrollIndicatorInsets = YES;
    } else {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.verticalScrollIndicatorInsets = UIEdgeInsetsZero;
}

- (UIScrollView *)scrollView {
    return self.tableView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:_tableViewStyle];

        [_tableView setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                    forAxis:UILayoutConstraintAxisVertical];
        [_tableView setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                    forAxis:UILayoutConstraintAxisHorizontal];
        _tableView.backgroundColor = ORKColor(ORKBackgroundColorKey);
        _tableView.allowsSelection = YES;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        _tableView.preservesSuperviewLayoutMargins = YES;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        _tableView.automaticallyAdjustsScrollIndicatorInsets = YES;
        _tableView.sectionHeaderTopPadding = 10;
    }
    return _tableView;
}

- (UIStackView *)contentView {
    if (!_contentView) {
        _contentView = [[UIStackView alloc] initWithArrangedSubviews:@[self.tableView]];
        _contentView.axis = UILayoutConstraintAxisVertical;
        _contentView.alignment = UIStackViewAlignmentFill;
        _contentView.distribution = UIStackViewDistributionFill;
        _contentView.spacing = 2;
    }
    return _contentView;
}

- (UIScrollEdgeElementContainerInteraction *)navigationFooterMagicPocketInteraction {
    if (_navigationFooterMagicPocketInteraction == nil) {
        _navigationFooterMagicPocketInteraction = [self magicPocketFor:self.tableView edge:UIRectEdgeBottom];
    }
    return _navigationFooterMagicPocketInteraction;
}

- (UIView *)layoutContainerFor:(UIView *)contentView {
    UIView *layoutContainer = [[UIView alloc] initWithFrame:contentView.bounds];
    layoutContainer.directionalLayoutMargins = ORKLargeContentLayoutMargins;

    [layoutContainer addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:layoutContainer.topAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:layoutContainer.bottomAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:layoutContainer.layoutMarginsGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:layoutContainer.layoutMarginsGuide.trailingAnchor]
    ]];
    [layoutContainer setNeedsLayout];
    return layoutContainer;
}

- (void)placeTableHeaderContent {
    if (self.tableView.tableHeaderView == nil) {
        NSDirectionalEdgeInsets margins = ORKLargeContentLayoutMargins;
        margins.bottom = tableHeaderBottomPadding;
        self.tableView.tableHeaderView = [UIView layoutContainerFor:self.stepContentView margins:margins];
    }
}

- (void)placeTableFooterContent {
    // Skip footer placement if the footer has been explicitly removed
    if (self.isFooterHidden) {
        return;
    }

    if (!_footerView) {
        NSDirectionalEdgeInsets margins;
        if (ORKLiquidGlassSupportEnabled()) {
            margins = ORKLargeContentLayoutMargins;
        } else {
            margins = NSDirectionalEdgeInsetsZero;
        }
        
        _footerView = [UIView layoutContainerFor:self.navigationFooterView margins:margins];
    }
    
    if ([self shouldPinNavigationFooterToBottom]) {
        self.tableView.tableFooterView = nil;

        _footerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_footerView];

        // Position footer at bottom of self
        _pinnedFooterConstraints = @[
            [_footerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_footerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_footerView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor]
        ];
        [NSLayoutConstraint activateConstraints:_pinnedFooterConstraints];
        
        if (@available(iOS 26.0, *)) {
            self.navigationFooterView.backgroundColor = [UIColor clearColor];
            [self.navigationFooterView addInteraction:self.navigationFooterMagicPocketInteraction];
        }
        
        // Add bottom inset so content isn't hidden behind the footer
        CGSize footerSize = [self minimumNavigationFooterSize];
        if (footerSize.height > 0) {
            UIEdgeInsets currentInset = self.tableView.contentInset;
            self.tableView.contentInset = UIEdgeInsetsMake(currentInset.top, currentInset.left, footerSize.height, currentInset.right);
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
    }
    else {
        // Footer should scroll with content - add to table footer
        if (_pinnedFooterConstraints) {
            [NSLayoutConstraint deactivateConstraints:_pinnedFooterConstraints];
            _pinnedFooterConstraints = nil;
            [_footerView removeFromSuperview];

            // Reset content inset
            self.tableView.contentInset = UIEdgeInsetsZero;
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
        }

        if (@available(iOS 26.0, *)) {
            [self.navigationFooterView removeInteraction:self.navigationFooterMagicPocketInteraction];
        }
        
        _footerView.translatesAutoresizingMaskIntoConstraints = YES;
        self.tableView.tableFooterView = _footerView;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    
    [self placeTableHeaderContent];
    [self placeTableFooterContent];

    [self layoutTableHeaderIfNeeded];
    [self layoutTableFooterIfNeeded];
}

- (void)removeFooterView {
    self.isFooterHidden = YES;
    self.tableView.tableFooterView = nil;

    // Remove pinned footer constraints if they exist
    if (_pinnedFooterConstraints) {
        [NSLayoutConstraint deactivateConstraints:_pinnedFooterConstraints];
        _pinnedFooterConstraints = nil;
    }

    // Reset content inset
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;

    if (_footerView) {
        [self.contentView removeArrangedSubview:_footerView];
        [_footerView removeFromSuperview];
        _footerView = nil;
    }

    [self removeNavigationFooterView];
}

- (void)removeNavigationFooterView {
    [self.contentView removeArrangedSubview:self.navigationFooterView];
}

- (CGSize)tableFittingSize:(UIView *)view {
    CGSize targetSize = CGSizeMake(self.tableView.bounds.size.width,
                                   UILayoutFittingCompressedSize.height);
    CGSize fittingSize = [view systemLayoutSizeFittingSize:targetSize
                             withHorizontalFittingPriority:UILayoutPriorityRequired
                                   verticalFittingPriority:UILayoutPriorityFittingSizeLevel];

    return fittingSize;
}

- (void)layoutTableHeaderIfNeeded {
    UIView *header = self.tableView.tableHeaderView;
    if (header == nil || [[header constraints] count] == 0) {
        return;
    }
    self.tableView.tableHeaderView = nil;

    NSLayoutConstraint *widthConstraint = [self minimumWidthConstraintForView:header];
    [widthConstraint setActive:YES];

    CGSize fittingSize;
    if (self.stepContentView.subviews.count == 0) {
        fittingSize = CGSizeZero;
    } else {
        fittingSize = [self tableFittingSize:header];
    }
    CGRect headerFrame = [header bounds];
    headerFrame.size = fittingSize;
    [header setBounds:headerFrame];

    self.tableView.tableHeaderView = header;
}

- (void)layoutTableFooterIfNeeded {
    UIView *footer = self.tableView.tableFooterView;
    if (footer == nil || [[footer constraints] count] == 0) {
        return;
    }

    NSLayoutConstraint *widthConstraint = [self minimumWidthConstraintForView:footer];
    [widthConstraint setActive:YES];

    CGSize fittingSize = [self tableFittingSize:footer];
    CGRect footerFrame = [footer bounds];
    footerFrame.size = fittingSize;
    [footer setBounds:footerFrame];

    self.tableView.tableFooterView = footer;
}

- (NSLayoutConstraint *) minimumWidthConstraintForView:(UIView *)view {
    CGFloat widthValue = self.bounds.size.width;
    NSLayoutConstraint *widthConstraint;
    if (widthValue > 0)  {
        widthConstraint = [view.widthAnchor constraintGreaterThanOrEqualToConstant:widthValue];
        widthConstraint.priority = UILayoutPriorityRequired - 1;
    }

    return widthConstraint;
}

- (CGSize)visibleContentSize {
    UIScrollView *view = self.tableView;

    CGSize visibleSize = view.bounds.size;
    CGFloat contentHeight = view.contentSize.height;
    UIEdgeInsets adjustedInsets = view.adjustedContentInset;

    CGFloat visibleHeight = contentHeight - adjustedInsets.top - adjustedInsets.bottom;
    return CGSizeMake(visibleSize.width, visibleHeight);
}

- (CGSize)minimumNavigationFooterSize {
    CGSize footerTargetSize = CGSizeMake(self.bounds.size.width,
                                         UILayoutFittingCompressedSize.height);
    return [self.navigationFooterView systemLayoutSizeFittingSize:footerTargetSize];
}

- (BOOL)shouldPinNavigationFooterToBottom {
    if (self.tableView.bounds.size.height == 0) {
        return YES;
    }
    UIEdgeInsets contentInsets = self.tableView.adjustedContentInset;
    CGFloat tableHeight = self.tableView.bounds.size.height - contentInsets.top - contentInsets.bottom;
    CGSize visibleSize = [self visibleContentSize];
    CGSize navigationFooterSize = [self minimumNavigationFooterSize];
    
    BOOL contentAndNavigationNeedsScrolling = visibleSize.height + navigationFooterSize.height > tableHeight;

    if (self.isNavigationContainerScrollable && contentAndNavigationNeedsScrolling) {
        return NO;
    }
    return YES;
}

- (void)resizeFooterToFit {
    // Ensure tableView contentSize is up to date before checking if footer should pin
    [self.tableView layoutIfNeeded];
    [self placeTableFooterContent];
    [self layoutTableFooterIfNeeded];
}

- (void)setTapOffView:(UIView *)tapOffView {
    _tapOffView = tapOffView;
    
    [_tapOffGestureRecognizer.view removeGestureRecognizer:_tapOffGestureRecognizer];
    
    _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
    _tapOffGestureRecognizer.delegate = self;
    [(tapOffView ? : self.tableView) addGestureRecognizer:_tapOffGestureRecognizer];
}

- (void)stepContentViewImageChanged:(NSNotification *)notification {
    [super stepContentViewImageChanged:notification];
    [self layoutTableHeaderIfNeeded];
}

- (BOOL)view:(UIView *)view hasFirstResponderOrTableViewCellContainingPoint:(CGPoint)point {
    UIView *subview = [self.tableView hitTest:point withEvent:nil];
    BOOL viewIsChildOfFirstResponder = NO;
    while (subview) {
        // Ignore table view cells, since first responder will be manually managed for taps on them
        if ([subview isFirstResponder] || [subview isKindOfClass:[UITableViewCell class]]) {
            viewIsChildOfFirstResponder = YES;
            break;
        }
        subview = [subview superview];
    }
    return viewIsChildOfFirstResponder;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = [self view:self.tableView hasFirstResponderOrTableViewCellContainingPoint:[touch locationInView:self.tableView]];
    return !shouldReceiveTouch;
}

- (void)tapOffAction:(UITapGestureRecognizer *)recognizer {
    // On a tap, dismiss the keyboard if the tap was not inside a view that is first responder or a child of a first responder.
    BOOL viewIsChildOfFirstResponder = [self view:self.tableView hasFirstResponderOrTableViewCellContainingPoint:[recognizer locationInView:self.tableView]];
    
    if (!viewIsChildOfFirstResponder) {
        [self.tableView endEditing:NO];
    }
}

- (CGSize)keyboardIntersectionSizeFromNotification:(NSNotification *)notification {
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self convertRect:keyboardFrame fromView:nil];
    
    CGRect scrollFrame = self.bounds;
    
    // The origin of this is in our superview's coordinate system, but I don't think
    // we actually use the origin - so just return the size.
    CGRect intersectionFrame = CGRectIntersection(scrollFrame, keyboardFrame);
    return intersectionFrame.size;
}

- (void)scrollCellVisible:(UITableViewCell *)cell animated:(BOOL)animated {
    if (cell == nil) {
        return;
    }
    
    UIScrollView *scrollView = self.scrollView;

    CGFloat visibleHeight = (scrollView.bounds.size.height - scrollView.contentInset.bottom);
    CGRect visibleRect = CGRectMake(0, scrollView.contentOffset.y, scrollView.bounds.size.width, visibleHeight);
    CGRect desiredRect = [scrollView convertRect:cell.bounds fromView:cell];
    
    CGRect bounds = scrollView.bounds;
    CGFloat offsetY = bounds.origin.y;
    BOOL containByVisibleRect = CGRectContainsRect(visibleRect, desiredRect);
    
    if (containByVisibleRect == NO) {
        if (CGRectGetHeight(desiredRect) > CGRectGetHeight(visibleRect)) {
            CGFloat desiredCenterY = CGRectGetMidY(desiredRect);
            offsetY = desiredCenterY - visibleRect.size.height * 0.5;
        } else {
            if (CGRectGetMinY(desiredRect) < CGRectGetMinY(visibleRect)) {
                offsetY = CGRectGetMinY(desiredRect);
            } else {
                offsetY = CGRectGetMinY(desiredRect) - (CGRectGetHeight(visibleRect) - CGRectGetHeight(desiredRect));
            }
        }
        offsetY = MAX(offsetY, 0);
    }
    
    // If there's room, we'd like to leave space below so you can tap on the next cell
    // Only go 3/4 of a cell extra; otherwise user might think they tapped the wrong cell
    CGFloat desiredExtraSpace  = floor(ORKGetMetricForWindow(ORKScreenMetricTextFieldCellHeight, self.window) * (3 / 4.0));
    CGFloat visibleSpaceAboveDesiredRect = CGRectGetMinY(desiredRect) - offsetY;
    CGFloat visibleSpaceBelowDesiredRect = offsetY + visibleHeight - CGRectGetMaxY(desiredRect);
    if ((visibleSpaceAboveDesiredRect > 0) && (visibleSpaceBelowDesiredRect < desiredExtraSpace)) {
        CGFloat additionalOffset = MIN(visibleSpaceAboveDesiredRect, desiredExtraSpace - visibleSpaceBelowDesiredRect);
        offsetY += additionalOffset;
        offsetY = MAX(offsetY, 0);
    }
    
    if (offsetY != bounds.origin.y) {
        bounds.origin.y = offsetY;
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                scrollView.bounds = bounds;
            }];
        } else {
            scrollView.bounds = bounds;
        }
    }
}

@end
