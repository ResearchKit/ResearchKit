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

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView.h"

#import "ORKTitleLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#import "ORKBodyItem.h"
#import "ORKBodyContainerView.h"


// Enable this define to see outlines and colors of all the views laid out at this level.
// #define LAYOUT_DEBUG

@interface ORKTableContainerView () <UIGestureRecognizerDelegate>

@end

static const CGFloat FooterViewHeightOffset = 20.0;

@implementation ORKTableContainerView {
    CGFloat _leftRightPadding;
    UIView *_footerView;
    NSLayoutConstraint *_bottomConstraint;
    NSLayoutConstraint *_tableViewTopConstraint;
    NSLayoutConstraint *_tableViewBottomConstraint;
    
    UIScrollView *_scrollView;
    
    UITapGestureRecognizer *_tapOffGestureRecognizer;
    NSMutableArray<NSLayoutConstraint *> *_navigationContainerConstraints;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped pinNavigationContainer:YES];
}

- (instancetype)initWithStyle:(UITableViewStyle)style pinNavigationContainer:(BOOL)pinNavigationContainer {
    self = [super init];
    if (self) {
        _leftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
        [self setupTableViewWithStyle:style];
        
        _scrollView = _tableView;
        self.isNavigationContainerScrollable = !pinNavigationContainer;
        
        [self addStepContentView];
        [self setupTableViewConstraints];

        [self placeNavigationContainerView];
        
        _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
        _tapOffGestureRecognizer.delegate = self;
        [_tableView addGestureRecognizer:_tapOffGestureRecognizer];
    }
    return self;
}

- (void)setupTableViewWithStyle:(UITableViewStyle)style {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    }
    
    _tableView.backgroundColor = ORKColor(ORKBackgroundColorKey);
    _tableView.allowsSelection = YES;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _tableView.preservesSuperviewLayoutMargins = YES;
    _tableView.layer.masksToBounds = YES;
    [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    _tableView.scrollIndicatorInsets = ORKScrollIndicatorInsetsForScrollView(self);
    [self addSubview:_tableView];
    [self setupFooterView];
}

- (void)placeNavigationContainerView {
    [self.navigationFooterView removeFromSuperview];
    if (_navigationContainerConstraints) {
        [NSLayoutConstraint deactivateConstraints:_navigationContainerConstraints];
        _navigationContainerConstraints = nil;
    }
    if (self.isNavigationContainerScrollable) {
        [_footerView addSubview:self.navigationFooterView];
    }
    else {
        [self removeFooterView];
        [self addSubview:self.navigationFooterView];
    }
    
    [self setupNavigationContainerViewConstraints];
    [self updateTableViewBottomConstraint];
}

- (void)setupNavigationContainerViewConstraints {
    self.navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationContainerConstraints = [[NSMutableArray alloc] init];
    if (self.isNavigationContainerScrollable) {
        
        NSLayoutConstraint *_footerWidthConstraint = [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                                  attribute:NSLayoutAttributeWidth
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:_footerView
                                                                                  attribute:NSLayoutAttributeWidth
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
        
        _footerWidthConstraint.priority = UILayoutPriorityRequired-1;
        [_navigationContainerConstraints addObject:_footerWidthConstraint];
        
        [_navigationContainerConstraints addObject:[NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                   toItem:_footerView
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:0.0]];
        
        _bottomConstraint = [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_footerView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0];
        _bottomConstraint.priority = UILayoutPriorityDefaultHigh - 1;
        [_navigationContainerConstraints addObject:_bottomConstraint];
    }
    else {
        [_navigationContainerConstraints addObjectsFromArray:@[
                                                               [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                                            attribute:NSLayoutAttributeLeft
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                               toItem:self
                                                                                            attribute:NSLayoutAttributeLeft
                                                                                           multiplier:1.0
                                                                                             constant:0.0],
                                                               [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                                            attribute:NSLayoutAttributeRight
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                               toItem:self
                                                                                            attribute:NSLayoutAttributeRight
                                                                                           multiplier:1.0
                                                                                             constant:0.0],
                                                               [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                                            attribute:NSLayoutAttributeBottom
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                               toItem:self
                                                                                            attribute:NSLayoutAttributeBottom
                                                                                           multiplier:1.0
                                                                                             constant:0.0]
                                                               ]];
    }
    [NSLayoutConstraint activateConstraints:_navigationContainerConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeFooterToFit];
    [self updateTableViewBottomConstraint];
}

- (void)addStepContentView {
    _tableView.tableHeaderView = self.stepContentView;
}

- (void)setupFooterView {
    if (!_footerView) {
        _footerView = [UIView new];
    }
    _footerView.layoutMargins = UIEdgeInsetsZero;
    _tableView.tableFooterView = _footerView;
}

- (void)removeFooterView {
    if (_footerView) {
        [_footerView removeFromSuperview];
        _footerView = nil;
    }
    _tableView.tableFooterView = nil;
}

- (void)resizeFooterToFit {
    //     This method would resize the tableFooterView, so that navigationContainerView can have appropriate height.
    if (self.isNavigationContainerScrollable && _tableView.bounds.size.height > 0 && self.navigationFooterView.bounds.size.height > 0 && ![self.navigationFooterView wasContinueOrSkipButtonJustPressed]) {
        CGFloat minHeight = self.navigationFooterView.bounds.size.height;
        _tableView.tableFooterView = nil;
        [_tableView layoutIfNeeded];
        CGFloat tableViewHeight = self.tableView.bounds.size.height;
        CGFloat newHeight = tableViewHeight - self.tableView.contentSize.height + FooterViewHeightOffset;
        CGRect footerBounds = newHeight < minHeight ? CGRectMake(0.0, 0.0, _tableView.bounds.size.width, minHeight) : CGRectMake(0.0, 0.0, _tableView.bounds.size.width, newHeight);

        [_footerView setBounds:footerBounds];
        _tableView.tableFooterView = _footerView;
    }
}

- (void)sizeHeaderToFit {
    CGFloat width = self.stepContentView.bounds.size.width > CGFLOAT_MIN ? self.stepContentView.bounds.size.width : self.bounds.size.width;
    CGFloat padding = [[self stepContentView] useExtendedPadding] ? ORKStepContainerExtendedLeftRightPaddingForWindow(self.window) : ORKStepContainerLeftRightPaddingForWindow(self.window);
    
    CGFloat preferredWidth = (width - (padding * 2));
    [self.stepContentView.titleLabel setPreferredMaxLayoutWidth:preferredWidth];
    [self.stepContentView.textLabel setPreferredMaxLayoutWidth:preferredWidth];
    [self.stepContentView.detailTextLabel setPreferredMaxLayoutWidth:preferredWidth];
    
    CGFloat estimatedHeight = [self.stepContentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect bounds = CGRectMake(0.0, 0.0, self.stepContentView.bounds.size.width, self.stepContentView.bounds.size.height);
    bounds.size.height = estimatedHeight;
    [self.stepContentView setBounds:bounds];
}

- (void)setTapOffView:(UIView *)tapOffView {
    _tapOffView = tapOffView;
    
    [_tapOffGestureRecognizer.view removeGestureRecognizer:_tapOffGestureRecognizer];
    
    _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
    _tapOffGestureRecognizer.delegate = self;
    [(tapOffView ? : _tableView) addGestureRecognizer:_tapOffGestureRecognizer];
}

- (void)setupTableViewConstraints {
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stepContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setTableViewTopConstraint];
    [self setTableViewBottomConstraint];
    [NSLayoutConstraint activateConstraints:@[
                                              _tableViewTopConstraint,
                                              [NSLayoutConstraint constraintWithItem:_tableView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_tableView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.stepContentView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_tableView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.stepContentView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_tableView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0
                                                                            constant:0.0]
                                              ]];
}

- (void)setTableViewTopConstraint {
    _tableViewTopConstraint = [NSLayoutConstraint constraintWithItem:_tableView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.stepTopContentImage ? self : self.safeAreaLayoutGuide
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];
}

- (void)updateTableViewTopConstraint {
    if (_tableViewTopConstraint && _tableViewTopConstraint.isActive) {
        [NSLayoutConstraint deactivateConstraints:@[_tableViewTopConstraint]];
    }
    [self setTableViewTopConstraint];
    [NSLayoutConstraint activateConstraints:@[_tableViewTopConstraint]];
}

- (void)stepContentViewImageChanged:(NSNotification *)notification {
    [super stepContentViewImageChanged:notification];
    [self updateTableViewTopConstraint];
}

- (void)setTableViewBottomConstraint {
    CGFloat bottomConstant = (self.isNavigationContainerScrollable == YES) ? 0 : -self.navigationFooterView.frame.size.height;
    _tableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_tableView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:bottomConstant];
}

- (void)updateTableViewBottomConstraint {
    if (_tableViewBottomConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_tableViewBottomConstraint]];
    }
    [self setTableViewBottomConstraint];
    [NSLayoutConstraint activateConstraints:@[_tableViewBottomConstraint]];
}

- (BOOL)view:(UIView *)view hasFirstResponderOrTableViewCellContainingPoint:(CGPoint)point {
    UIView *subview = [_tableView hitTest:point withEvent:nil];
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
    BOOL shouldReceiveTouch = [self view:_tableView hasFirstResponderOrTableViewCellContainingPoint:[touch locationInView:_tableView]];
    return !shouldReceiveTouch;
}

- (void)tapOffAction:(UITapGestureRecognizer *)recognizer {
    // On a tap, dismiss the keyboard if the tap was not inside a view that is first responder or a child of a first responder.
    BOOL viewIsChildOfFirstResponder = [self view:_tableView hasFirstResponderOrTableViewCellContainingPoint:[recognizer locationInView:_tableView]];
    
    if (!viewIsChildOfFirstResponder) {
        [_tableView endEditing:NO];
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
    
    UIScrollView *scrollView = _scrollView;
    
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
