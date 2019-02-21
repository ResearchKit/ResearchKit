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


#import "ORKVerticalContainerView.h"
#import "ORKVerticalContainerView_Internal.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTintedImageView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


// Enable this define to see outlines and colors of all the views laid out at this level.
// #define LAYOUT_DEBUG

/*
 view hierachy in ORKVerticalContainerView (from top to bottom):
 
 scrollContainer
    - container
        - customViewContainer
        - headerView
        - stepViewContainer
 */

@implementation ORKVerticalContainerView {
    UIView *_scrollContainer;
    UIView *_container;
    
    ORKTintedImageView *_imageView;

    NSMutableArray *_variableConstraints;
    
    NSLayoutConstraint *_headerMinimumHeightConstraint;
    NSLayoutConstraint *_illustrationHeightConstraint;
    NSLayoutConstraint *_stepViewCenterInStepViewContainerConstraint;
    NSLayoutConstraint *_topToIllustrationConstraint;
    NSLayoutConstraint *_scrollContainerHeightConstraint;
    
    CGFloat _keyboardOverlap;
    
    UIView *_stepViewContainer;
    
    BOOL _keyboardIsUp;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollContainerShouldCollapseNavbar = YES;
        _scrollContainer = [UIView new];
        [self addSubview:_scrollContainer];
        _container = [UIView new];
        [_scrollContainer addSubview:_container];
        
        {
            _headerView = [ORKStepHeaderView new];
            _headerView.layoutMargins = UIEdgeInsetsZero;
            _headerView.translatesAutoresizingMaskIntoConstraints = NO;
            [_container addSubview:_headerView];
        }
        
        {
            _stepViewContainer = [UIView new];
            _stepViewContainer.preservesSuperviewLayoutMargins = YES;
            [_container addSubview:_stepViewContainer];
        }
        
        {
            // Custom View
            _customViewContainer = [UIView new];
            [_container addSubview:self.customViewContainer];
        }
        
        ORKEnableAutoLayoutForViews(@[_scrollContainer, _container, _headerView, _stepViewContainer, _customViewContainer]);

        [self setUpStaticConstraints];
        [self setNeedsUpdateConstraints];
        
        UITapGestureRecognizer *tapOffRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
        [self addGestureRecognizer:tapOffRecognizer];
        
        UISwipeGestureRecognizer *swipeOffRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOffAction:)];
        swipeOffRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipeOffRecognizer];
    }
    return self;
}

- (void)setUpStaticConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_scrollContainer, _container);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollContainer]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollContainer]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    _scrollContainerHeightConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainer
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0
                                                                     constant:_scrollContainerShouldCollapseNavbar ? 0.3 : 0.0]; //anything less than 0.3 does not work for smaller devices.
    [constraints addObject: _scrollContainerHeightConstraint];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_scrollContainer
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    // This constraint is needed to get the scroll container not to size itself too large (we don't want scrolling if it's not needed)
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0.0];
    heightConstraint.priority = UILayoutPriorityDefaultLow;
    [constraints addObject:heightConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setScrollContainerShouldCollapseNavbar:(BOOL)scrollContainerShouldCollapseNavbar {
    if (!scrollContainerShouldCollapseNavbar) {
        _scrollContainerShouldCollapseNavbar = scrollContainerShouldCollapseNavbar;
        [NSLayoutConstraint deactivateConstraints:@[_scrollContainerHeightConstraint]];
        _scrollContainerHeightConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0.0];
        [_scrollContainerHeightConstraint setActive:YES];
        [self setNeedsUpdateConstraints];
    }
}

- (void)swipeOffAction:(UITapGestureRecognizer *)recognizer {
    [self endEditing:NO];
}

- (void)tapOffAction:(UITapGestureRecognizer *)recognizer {
    // On a tap, dismiss the keyboard if the tap was not inside a view that is first responder or a child of a first responder.
    CGPoint point = [recognizer locationInView:self];
    UIView *view = [self hitTest:point withEvent:nil];
    BOOL viewIsChildOfFirstResponder = NO;
    while (view) {
        if ([view isFirstResponder]) {
            viewIsChildOfFirstResponder = YES;
            break;
        }
        view = [view superview];
    }
    
    if (!viewIsChildOfFirstResponder) {
        [self endEditing:NO];
    }
}

- (void)dealloc {
    [self registerForKeyboardNotifications:NO];
}

- (void)registerForKeyboardNotifications:(BOOL)shouldRegister {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (shouldRegister) {
        [notificationCenter addObserver:self
                selector:@selector(keyboardWillShow:)
                    name:UIKeyboardWillShowNotification object:nil];
        
        [notificationCenter addObserver:self
                selector:@selector(keyboardWillHide:)
                    name:UIKeyboardWillHideNotification object:nil];
        [notificationCenter addObserver:self
                selector:@selector(keyboardFrameWillChange:)
                    name:UIKeyboardWillChangeFrameNotification object:nil];
    } else {
        [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateLayoutMargins];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateLayoutMargins];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
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

- (void)animateLayoutForKeyboardNotification:(NSNotification *)notification {
    NSTimeInterval animationDuration = ((NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect bounds = self.bounds;
        CGSize contentSize = self.contentSize;
        
        CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
        CGFloat visibleHeight = bounds.size.height - intersectionSize.height;
        
        // Keep track of the keyboard overlap, so we can adjust the constraint properly.
        _keyboardOverlap = intersectionSize.height;
        
        // Trigger layout inside the animation block to get the constraint change to animate.
        [self layoutIfNeeded];
        
        if (_keyboardIsUp) {
            
            CGFloat contentMaxY = CGRectGetMaxY([self convertRect:_container.bounds fromView:_container]);
            
            // First compute the contentOffset.y that would make the continue and skip buttons visible
            CGFloat yOffset = MAX(contentMaxY - visibleHeight, 0);
            yOffset = MIN(yOffset, contentSize.height - visibleHeight);
            
            // If that yOffset would not make the stepView visible, override to align with the top of the stepView.
            CGRect potentialVisibleRect = (CGRect){{0,yOffset},{bounds.size.width,visibleHeight}};
            CGRect targetBounds = [self convertRect:_stepView.bounds fromView:_stepView];
            if (!CGRectContainsRect(potentialVisibleRect, targetBounds)) {
                yOffset = targetBounds.origin.y;
            }
            
            CGFloat keyboardOverlapWithActualContent = MAX(contentMaxY - (contentSize.height - intersectionSize.height), 0);
            UIEdgeInsets insets = (UIEdgeInsets){.bottom = keyboardOverlapWithActualContent };
            self.contentInset = insets;
        
            // Rather than setContentOffset, setBounds so that we get a smooth animation
            if (ABS(yOffset - bounds.origin.y) > 1) {
                bounds.origin.y = yOffset;
                [self setBounds:bounds];
            }
        }
    } completion:nil];
}

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
    
    // Assume the overlap is at the bottom of the view
    ORKUpdateScrollViewBottomInset(self, intersectionSize.height);
    
    _keyboardIsUp = YES;
    [self animateLayoutForKeyboardNotification:notification];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
    
    // Assume the overlap is at the bottom of the view
    ORKUpdateScrollViewBottomInset(self, intersectionSize.height);
    
    _keyboardIsUp = YES;
    [self animateLayoutForKeyboardNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    ORKUpdateScrollViewBottomInset(self, 0);
    
    _keyboardIsUp = NO;
    [self animateLayoutForKeyboardNotification:notification];
}

- (void)updateStepViewCenteringConstraint {
    BOOL hasIllustration = (_imageView.image != nil);
    BOOL hasCaption = _headerView.captionLabel.text.length > 0;
    BOOL hasInstruction = _headerView.instructionLabel.text.length > 0;
    BOOL hasLearnMore = (_headerView.learnMoreButton.alpha > 0);

    if (_stepViewCenterInStepViewContainerConstraint) {
        BOOL offsetCentering = !(hasIllustration || hasCaption || hasInstruction || hasLearnMore);
        _stepViewCenterInStepViewContainerConstraint.active = offsetCentering;
    }    
}

- (void)updateLayoutMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    UIEdgeInsets layoutMargins = (UIEdgeInsets){.left = margin, .right = margin};
    self.layoutMargins = layoutMargins;
    _scrollContainer.layoutMargins = layoutMargins;
    _container.layoutMargins = layoutMargins;
}

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {    
    {
        BOOL hasIllustration = (_imageView.image != nil);
        _headerView.hasContentAbove = hasIllustration;

        const CGFloat IllustrationHeight = ORKGetMetricForWindow(ORKScreenMetricIllustrationHeight, window);
        const CGFloat IllustrationTopMargin = ORKGetMetricForWindow(ORKScreenMetricTopToIllustration, window);
        
        _illustrationHeightConstraint.constant = (_imageView.image ? IllustrationHeight : 0);
        _topToIllustrationConstraint.constant = (_imageView.image ?IllustrationTopMargin : 0);
    }
    
    {
        _headerMinimumHeightConstraint.constant = _minimumStepHeaderHeight;
    }
}

- (void)setContinueHugsContent:(BOOL)continueHugsContent {
    _continueHugsContent = continueHugsContent;
    [self setNeedsUpdateConstraints];
}

- (void)setVerticalCenteringEnabled:(BOOL)verticalCenteringEnabled {
    _verticalCenteringEnabled = verticalCenteringEnabled;
    [self setNeedsUpdateConstraints];
}

- (void)setStepViewFillsAvailableSpace:(BOOL)stepViewFillsAvailableSpace {
    _stepViewFillsAvailableSpace = stepViewFillsAvailableSpace;
    [self setNeedsUpdateConstraints];
}

- (void)setMinimumStepHeaderHeight:(CGFloat)minimumStepHeaderHeight {
    _minimumStepHeaderHeight = minimumStepHeaderHeight;
    [self updateConstraintConstantsForWindow:self.window];
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }

    NSArray *views = @[_headerView, _customViewContainer, _stepViewContainer];
    
    // Roughly center the container, but put it a little above the center if possible
    if (_verticalCenteringEnabled) {
        NSLayoutConstraint *verticalCentering1 = [NSLayoutConstraint constraintWithItem:_container
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:_scrollContainer
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:0.8
                                                                               constant:0.0];
        verticalCentering1.priority = UILayoutPriorityDefaultLow;
        [_variableConstraints addObject:verticalCentering1];
        
        NSLayoutConstraint *verticalCentering2 = [NSLayoutConstraint constraintWithItem:_container
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                 toItem:_scrollContainer
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.0
                                                                               constant:0.0];
        verticalCentering2.priority = UILayoutPriorityDefaultHigh;
        [_variableConstraints addObject:verticalCentering2];

        NSLayoutConstraint *verticalCentering3 = [NSLayoutConstraint constraintWithItem:_container
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                 toItem:_scrollContainer
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:0.0];
        verticalCentering3.priority = UILayoutPriorityDefaultHigh;
        [_variableConstraints addObject:verticalCentering3];
    } else {
        NSLayoutConstraint *verticalTop = [NSLayoutConstraint constraintWithItem:_container
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_scrollContainer
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:0.0];
        [_variableConstraints addObject:verticalTop];
    }
    
    // Don't let the container get too tall
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_container
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                                           toItem:_scrollContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0.0];
    [_variableConstraints addObject:heightConstraint];
    
    [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|"
                                                                                      options:(NSLayoutFormatOptions)0
                                                                                      metrics:nil
                                                                                        views:@{@"container":_container}]];
#ifdef LAYOUT_DEBUG
    _container.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    _scrollContainer.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
#endif

    // All items with constants use constraint ivars
    _illustrationHeightConstraint = [NSLayoutConstraint constraintWithItem:_customViewContainer
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:198.0];
    [_variableConstraints addObject:_illustrationHeightConstraint];
    
    _topToIllustrationConstraint = [NSLayoutConstraint constraintWithItem:_customViewContainer
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_container
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0];
    [_variableConstraints addObject:_topToIllustrationConstraint];

    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_headerView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_customViewContainer
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_headerView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    _headerMinimumHeightConstraint = [NSLayoutConstraint constraintWithItem:_headerView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:_minimumStepHeaderHeight];
    [_variableConstraints addObject:_headerMinimumHeightConstraint];
    
    // Force all to stay within the container's width.
    for (UIView *view in views) {
#ifdef LAYOUT_DEBUG
        view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        view.layer.borderColor = [UIColor redColor].CGColor;
        view.layer.borderWidth = 1.0;
#endif
        if (view == _stepViewContainer) {
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:_container
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0
                                                                          constant:0.0]];
        } else {
            
            NSLayoutRelation relation = NSLayoutRelationGreaterThanOrEqual;
            
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:relation
                                                                            toItem:_container
                                                                         attribute:NSLayoutAttributeLeftMargin
                                                                        multiplier:1.0
                                                                          constant:0.0]];
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:relation
                                                                            toItem:_container
                                                                         attribute:NSLayoutAttributeRightMargin
                                                                        multiplier:1.0
                                                                          constant:0.0]];
        }
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_container
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        NSLayoutConstraint *viewToContainerBottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                   toItem:_container
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:0.0];
        
        // Because the bottom items are not always present, we add individual "bottom" constraints
        // for all views to ensure the parent sizes large enough to contain everything.
        [_variableConstraints addObject:viewToContainerBottomConstraint];
    }
    
    [self prepareCustomViewContainerConstraints];
    [self prepareStepViewContainerConstraints];
    [NSLayoutConstraint activateConstraints:_variableConstraints];

    [self updateLayoutMargins];

    [self updateConstraintConstantsForWindow:self.window];
    [self updateStepViewCenteringConstraint];

    [super updateConstraints];
}

- (void)prepareStepViewContainerConstraints {
    if (_stepView) {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:ORKScreenMetricMaxDimension];
        widthConstraint.priority = UILayoutPriorityFittingSizeLevel;
        [_variableConstraints addObject:widthConstraint];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_stepView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_stepViewContainer
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        NSLayoutConstraint *stepViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_stepView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:_stepViewContainer
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                  multiplier:1.0
                                                                                    constant:0.0];
        stepViewWidthConstraint.priority = UILayoutPriorityRequired;
        [_variableConstraints addObject:stepViewWidthConstraint];
        
        if (_stepViewFillsAvailableSpace) {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:ORKScreenMetricMaxDimension];
            constraint.priority = UILayoutPriorityFittingSizeLevel;
            [_variableConstraints addObject:constraint];

            NSLayoutConstraint *verticalCentering = [NSLayoutConstraint constraintWithItem:_stepView
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:_stepViewContainer
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                multiplier:1.0
                                                                                  constant:0.0];
            verticalCentering.priority = UILayoutPriorityRequired - 2;
            [_variableConstraints addObject:verticalCentering];
            
            {
                NSLayoutConstraint *verticalCentering2 = [NSLayoutConstraint constraintWithItem:_stepView
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:_stepViewContainer
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                     multiplier:1.0
                                                                                       constant:0.0];
                verticalCentering2.priority = UILayoutPriorityRequired - 1;
                [_variableConstraints addObject:verticalCentering2];
                _stepViewCenterInStepViewContainerConstraint = verticalCentering2;
            }
            
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_stepView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:_stepViewContainer
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:0.0]];
        } else {
            [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stepView]|"
                                                                                              options:(NSLayoutFormatOptions)0
                                                                                              metrics:nil
                                                                                                views:@{@"stepView": _stepView}]];
        }
    } else {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:0.0];
        widthConstraint.priority = UILayoutPriorityFittingSizeLevel;
        [_variableConstraints addObject:widthConstraint];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:0.0]];
    }
}

- (void)prepareCustomViewContainerConstraints {
    if (_customView) {
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
                                                                                          options:(NSLayoutFormatOptions)0
                                                                                          metrics:nil
                                                                                            views:@{@"customView": _customView}]];
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
                                                                                          options:(NSLayoutFormatOptions)0
                                                                                          metrics:nil
                                                                                            views:@{@"customView": _customView}]];
    }
    if (_imageView) {
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:_customViewContainer
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_customViewContainer
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_customViewContainer
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0.0]];
    }
}

- (void)setCustomView:(UIView *)customView {
    [_customView removeFromSuperview];
    _customView = customView;
    [_customViewContainer addSubview:_customView];
    
    if (_customView && [_customView constraints].count == 0) {
        [_customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        CGSize requiredSize = [_customView sizeThatFits:(CGSize){self.bounds.size.width, CGFLOAT_MAX}];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_customView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:requiredSize.width];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_customView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:requiredSize.height];
        
        widthConstraint.priority = UILayoutPriorityDefaultLow;
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [NSLayoutConstraint activateConstraints:@[widthConstraint, heightConstraint]];
    }
    [self setNeedsUpdateConstraints];
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[ORKTintedImageView alloc] init];
        [_customViewContainer addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        [self setNeedsUpdateConstraints];
    }
    return _imageView;
}

- (void)setStepView:(ORKActiveStepCustomView *)customView {
    [_stepView removeFromSuperview];
    _stepView = customView;
    [_stepViewContainer addSubview:_stepView];
    [self setNeedsUpdateConstraints];
}

@end
