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

#import "ORKNavigationContainerView.h"
#import "ORKStepHeaderView.h"
#import "ORKVerticalContainerView_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


// Enable this define to see outlines and colors of all the views laid out at this level.
// #define LAYOUT_DEBUG

@interface ORKTableContainerView () <UIGestureRecognizerDelegate>

@end


@implementation ORKTableContainerView {
    UIView *_realFooterView;
    
    NSLayoutConstraint *_bottomConstraint;
    
    CGFloat _keyboardOverlap;
    BOOL _keyboardIsUp;
    
    UIScrollView *_scrollView;
    
    UITapGestureRecognizer *_tapOffGestureRecognizer;
}
    
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStyleGrouped];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:style];
        _tableView.backgroundColor = ORKColor(ORKBackgroundColorKey);
        _tableView.allowsSelection = YES;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        _tableView.preservesSuperviewLayoutMargins = YES;
        _tableView.clipsToBounds = NO; // Do not clip scroll indicators on iPad
        _tableView.scrollIndicatorInsets = ORKScrollIndicatorInsetsForScrollView(self);
        [self addSubview:_tableView];
        
        _scrollView = _tableView;
        
        _realFooterView = [UIView new];
        _realFooterView.layoutMargins = UIEdgeInsetsZero;
#ifdef LAYOUT_DEBUG
        _realFooterView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
#endif
        _tableView.tableFooterView = _realFooterView;
        
        _stepHeaderView = [ORKStepHeaderView new];
#ifdef LAYOUT_DEBUG
        _stepHeaderView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
#endif
        
        _continueSkipContainerView = [ORKNavigationContainerView new];
        _continueSkipContainerView.preservesSuperviewLayoutMargins = NO;
        _continueSkipContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        _continueSkipContainerView.topMargin = 20;
        _continueSkipContainerView.bottomMargin = 20;
#ifdef LAYOUT_DEBUG
        _continueSkipContainerView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
#endif
        [_realFooterView addSubview:_continueSkipContainerView];
        
        [self setUpConstraints];
        
        _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
        _tapOffGestureRecognizer.delegate = self;
        [_tableView addGestureRecognizer:_tapOffGestureRecognizer];
    }
    return self;
}

- (void)setTapOffView:(UIView *)tapOffView {
    _tapOffView = tapOffView;
    
    [_tapOffGestureRecognizer.view removeGestureRecognizer:_tapOffGestureRecognizer];
    
    _tapOffGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
    _tapOffGestureRecognizer.delegate = self;
    [(tapOffView ? : _tableView) addGestureRecognizer:_tapOffGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    _tableView.frame = UIEdgeInsetsInsetRect(bounds, ORKStandardFullScreenLayoutMarginsForView(self));
    // make the contentSize to be correct after changing the frame
    [_tableView layoutIfNeeded];
    {
        _stepHeaderView.frame = (CGRect){{0,0},{_tableView.bounds.size.width,30}};
        _tableView.tableHeaderView = _stepHeaderView;
        // Do the layout with the view in the hierarchy; otherwise it won't
        // get the right margins.
        [_stepHeaderView setNeedsLayout];
        [_stepHeaderView layoutIfNeeded];
        CGSize headerSize = [_stepHeaderView systemLayoutSizeFittingSize:(CGSize){_tableView.bounds.size.width,0} withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
        _stepHeaderView.bounds = (CGRect){{0,0},headerSize};
        _tableView.tableHeaderView = nil;
        _tableView.tableHeaderView = _stepHeaderView;
    }
    
    {
        _tableView.tableFooterView = nil;
        [_realFooterView removeFromSuperview];
        CGSize footerSize = [_continueSkipContainerView systemLayoutSizeFittingSize:(CGSize){_tableView.bounds.size.width,0} withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
        CGRect footerBounds = (CGRect){{0,0},footerSize};
        
        CGFloat boundsHeightUnused = _tableView.bounds.size.height - _tableView.contentSize.height;
        if (boundsHeightUnused > footerBounds.size.height) {
            _tableView.scrollEnabled = YES;
            footerBounds.size.height = boundsHeightUnused;
        } else {
            _tableView.scrollEnabled = YES;
        }
        _realFooterView.frame = footerBounds;
        _tableView.tableFooterView = _realFooterView;
    }
}

- (void)updateBottomConstraintConstant {
    _bottomConstraint.constant = -_keyboardOverlap;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueSkipContainerView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:_realFooterView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueSkipContainerView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_realFooterView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueSkipContainerView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:_realFooterView
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    _bottomConstraint = [NSLayoutConstraint constraintWithItem:_continueSkipContainerView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_realFooterView
                                                     attribute:NSLayoutAttributeBottomMargin
                                                    multiplier:1.0
                                                      constant:0.0];
    _bottomConstraint.priority = UILayoutPriorityDefaultHigh - 1;
    [constraints addObject:_bottomConstraint];
    
    [self updateBottomConstraintConstant];
    [NSLayoutConstraint activateConstraints:constraints];
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

- (void)dealloc {
    [self registerForKeyboardNotifications:NO];
}

- (void)registerForKeyboardNotifications:(BOOL)shouldRegister {
    NSNotificationCenter *nfc = [NSNotificationCenter defaultCenter];
    if (shouldRegister) {
        [nfc addObserver:self
                selector:@selector(keyboardWillShow:)
                    name:UIKeyboardWillShowNotification object:nil];
        
        [nfc addObserver:self
                selector:@selector(keyboardWillHide:)
                    name:UIKeyboardWillHideNotification object:nil];
        [nfc addObserver:self
                selector:@selector(keyboardFrameWillChange:)
                    name:UIKeyboardWillChangeFrameNotification object:nil];
    } else {
        [nfc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [nfc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [nfc removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _continueSkipContainerView.topMargin = ORKGetMetricForWindow(ORKScreenMetricContinueButtonTopMargin, newWindow);
    if (newWindow) {
        [self registerForKeyboardNotifications:YES];
    } else {
        [self registerForKeyboardNotifications:NO];
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

- (void)animateLayoutForKeyboardNotification:(NSNotification *)notification {
    NSTimeInterval animationDuration = ((NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    
    UIScrollView *scrollView = _scrollView;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect bounds = scrollView.bounds;
        CGSize contentSize = scrollView.contentSize;
        
        CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
        
        // Keep track of the keyboard overlap, so we can adjust the constraint properly.
        _keyboardOverlap = intersectionSize.height;
        
        [self updateBottomConstraintConstant];
        
        // Trigger layout inside the animation block to get the constraint change to animate.
        [scrollView layoutIfNeeded];
        
        if (_keyboardIsUp) {
            // The content ends at the bottom of the continueSkipContainer.
            // We want to calculate new insets so it's possible to scroll it fully visible, but no more.
            // Made a little more complicated because the contentSize will still extend below the bottom of this container,
            // because we haven't changed our bounds.
            CGFloat contentMaxY = CGRectGetMaxY([scrollView convertRect:_continueSkipContainerView.bounds fromView:_continueSkipContainerView]) + _realFooterView.layoutMargins.bottom;
            
            CGFloat keyboardOverlapWithActualContent = MAX(contentMaxY - (contentSize.height - intersectionSize.height), 0);
            UIEdgeInsets insets = (UIEdgeInsets){.bottom = keyboardOverlapWithActualContent };
            scrollView.contentInset = insets;
            scrollView.bounds = bounds;
            
            // Make current first responder cell visible
            {
                [self scrollCellVisible:[self.delegate currentFirstResponderCellForTableContainerView:self] animated:NO];
            }
        }
    } completion:nil];
}

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
    
    // Assume the overlap is at the bottom of the view
    ORKUpdateScrollViewBottomInset(self.tableView, intersectionSize.height);
    
    _keyboardIsUp = YES;
    [self animateLayoutForKeyboardNotification:notification];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
    
    // Assume the overlap is at the bottom of the view
    ORKUpdateScrollViewBottomInset(self.tableView, intersectionSize.height);
    
    _keyboardIsUp = YES;
    [self animateLayoutForKeyboardNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    ORKUpdateScrollViewBottomInset(self.tableView, 0);
    
    _keyboardIsUp = NO;
    [self animateLayoutForKeyboardNotification:notification];
}

@end
