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
#import "ORKHelpers.h"
#import "ORKTintedImageView.h"


ORKDefineStringKey(_TopToIllustrationConstraintKey);
ORKDefineStringKey(_IllustrationHeightConstraintKey);
ORKDefineStringKey(_StepViewToContinueKey);
ORKDefineStringKey(_StepViewToContinueMinimumKey);
ORKDefineStringKey(_HeaderMinimumHeightKey);
ORKDefineStringKey(_StepViewCenteringOnWholeViewKey);

static const CGFloat AssumedNavBarHeight = 44;
static const CGFloat AssumedStatusBarHeight = 20;

// Enable this define to see outlines and colors of all the views laid out at this level.
// #define LAYOUT_DEBUG

@implementation ORKVerticalContainerView {
    UIView *_scrollContainer;
    UIView *_container;
    
    ORKTintedImageView *_imageView;
    
    NSDictionary *_adjustableConstraints;
    
    NSLayoutConstraint *_continueAtBottomConstraint;
    NSLayoutConstraint *_continueInContentConstraint;
    
    CGFloat _keyboardOverlap;
    
    UIView *_stepViewContainer;
    
    BOOL _keyboardIsUp;
    
    NSArray *_customViewContainerConstraints;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIEdgeInsets layoutMargins = (UIEdgeInsets){.left=ORKStandardHorizMarginForView(self), .right=ORKStandardHorizMarginForView(self)};
        self.layoutMargins = layoutMargins;
        _screenType = ORKScreenTypeiPhone4;
        _scrollContainer = [UIView new];
        [self addSubview:_scrollContainer];
        _container = [UIView new];
        [_scrollContainer addSubview:_container];
        
        _scrollContainer.layoutMargins = layoutMargins;
        _container.layoutMargins = layoutMargins;
        
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
            // This lives in the scroll container, so it doesn't affect the vertical layout of the primary content
            // except through explicit constraints.
            _continueSkipContainer = [ORKNavigationContainerView new];
            _continueSkipContainer.bottomMargin = 20;
            _continueSkipContainer.translatesAutoresizingMaskIntoConstraints = NO;
            [_scrollContainer addSubview:_continueSkipContainer];
        }
        {
            // Custom View
            _customViewContainer = [UIView new];
            [_container addSubview:self.customViewContainer];
        }
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_scrollContainer, _container);
        _scrollContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _container.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollContainer]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollContainer]|" options:0 metrics:nil views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        // This constraint is needed to get the scroll container not to size itself too large (we don't want scrolling if it's not needed)
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainer
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1 constant:0];
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [self addConstraint:heightConstraint];
        
        UITapGestureRecognizer *tapOffRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffAction:)];
        
        [self addGestureRecognizer:tapOffRecognizer];
        
        UISwipeGestureRecognizer *swipeOffRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOffAction:)];
        swipeOffRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        
        [self addGestureRecognizer:swipeOffRecognizer];
    }
    return self;
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

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _screenType = ORKGetScreenTypeForWindow(newWindow);
    [self updateConstraintConstants];
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
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect bounds = self.bounds;
        CGSize contentSize = self.contentSize;
        
        CGSize intersectionSize = [self keyboardIntersectionSizeFromNotification:notification];
        CGFloat visibleHeight = bounds.size.height - intersectionSize.height;
        
        // Keep track of the keyboard overlap, so we can adjust the constraint properly.
        _keyboardOverlap = intersectionSize.height;
        
        [self updateContinueButtonConstraints];
        
        // Trigger layout inside the animation block to get the constraint change to animate.
        [self layoutIfNeeded];
        
        if (_keyboardIsUp) {
            // The content ends at the bottom of the continueSkipContainer.
            // We want to calculate new insets so it's possible to scroll it fully visible, but no more.
            // Made a little more complicated because the contentSize will still extend below the bottom of this container,
            // because we haven't changed our bounds.
            CGFloat contentMaxY = CGRectGetMaxY([self convertRect:_continueSkipContainer.bounds fromView:_continueSkipContainer]);
            
            // First compute the contentOffset.y that would make the continue and skip buttons visible
            CGFloat yOffset = MAX(contentMaxY - visibleHeight, 0);
            yOffset = MIN(yOffset, contentSize.height - visibleHeight);
            
            // If that yOffset would not make the stepView visible, override to align with the top of the stepView.
            CGRect potentialVisibleRect = (CGRect){{0,yOffset},{bounds.size.width,visibleHeight}};
            CGRect targetBounds = [self convertRect:[_stepView bounds] fromView:_stepView];
            if (! CGRectContainsRect(potentialVisibleRect, targetBounds)) {
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

- (void)updateContinueButtonConstraints {
    _continueAtBottomConstraint.active = !_continueHugsContent;
    _continueInContentConstraint.active = _continueHugsContent;
    
    if (_keyboardIsUp) {
        // Try to move up from the bottom to be above the keyboard.
        // This will go only so far - if we hit actual content, this will
        // be counteracted by the constraint to stay below the content.
        _continueAtBottomConstraint.constant = - _keyboardOverlap;
    } else {
        _continueAtBottomConstraint.constant = 0;
    }
}

- (void)updateConstraintConstants {
    ORKScreenType screenType = _screenType;
    
    const CGFloat StepViewBottomToContinueTop = ORKGetMetricForScreenType(ORKScreenMetricContinueButtonTopMargin, screenType);
    const CGFloat StepViewBottomToContinueTopForIntroStep = ORKGetMetricForScreenType(ORKScreenMetricContinueButtonTopMarginForIntroStep, screenType);
    
    BOOL hasIllustration = (_imageView.image != nil);
    
    _headerView.hasContentAbove = hasIllustration;
    
    {
        const CGFloat IllustrationHeight = ORKGetMetricForScreenType(ORKScreenMetricIllustrationHeight, screenType);
        const CGFloat IllustrationTopMargin = ORKGetMetricForScreenType(ORKScreenMetricTopToIllustration, screenType);
        
        NSLayoutConstraint *constraint = _adjustableConstraints[_IllustrationHeightConstraintKey];
        constraint.constant = (_imageView.image ? IllustrationHeight : 0);
        
        constraint = _adjustableConstraints[_TopToIllustrationConstraintKey];
        constraint.constant = (_imageView.image ?IllustrationTopMargin : 0);
    }
    
    BOOL haveCaption = [_headerView.captionLabel.text length] > 0;
    BOOL haveInstruction = [_headerView.instructionLabel.text length] > 0;
    BOOL haveLearnMore = (_headerView.learnMoreButton.alpha > 0);
    BOOL haveStepView = (_stepView != nil);
    BOOL haveContinueOrSkip = [_continueSkipContainer hasContinueOrSkip];
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_StepViewToContinueKey];
        NSLayoutConstraint *constraint2 = _adjustableConstraints[_StepViewToContinueMinimumKey];
        CGFloat continueSpacing = StepViewBottomToContinueTop;
        if (self.continueHugsContent && ! haveStepView) {
            continueSpacing = 0;
        }
        if (self.stepViewFillsAvailableSpace) {
            continueSpacing = StepViewBottomToContinueTopForIntroStep;
        }
        if (! haveContinueOrSkip) {
            // If we don't actually have continue or skip, we should not apply any space
            continueSpacing = 0;
        }
        CGFloat continueSpacing2 = MIN(10, continueSpacing);
        constraint.constant = continueSpacing;
        constraint2.constant = continueSpacing2;
    }
    
    {
        NSLayoutConstraint *stepViewCentering = _adjustableConstraints[_StepViewCenteringOnWholeViewKey];
        if (stepViewCentering) {
            BOOL offsetCentering = ! (hasIllustration || haveCaption || haveInstruction || haveLearnMore || haveContinueOrSkip);
            stepViewCentering.active = offsetCentering;
        }
    }
    
    {
        NSLayoutConstraint *minimumHeaderHeight = _adjustableConstraints[_HeaderMinimumHeightKey];
        minimumHeaderHeight.constant = _minimumStepHeaderHeight;
    }
    
    [self updateContinueButtonConstraints];
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
    [self updateConstraintConstants];
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:[_scrollContainer constraints]];
    [NSLayoutConstraint deactivateConstraints:[_container constraints]];
    [NSLayoutConstraint deactivateConstraints:[_stepViewContainer constraints]];
    [NSLayoutConstraint deactivateConstraints:[_customViewContainer constraints]];
    _continueInContentConstraint = nil;
    
    NSArray *views = @[_headerView, _customViewContainer, _continueSkipContainer, _stepViewContainer];
    ORKEnableAutoLayoutForViews(views);
    
    // Roughly center the container, but put it a little above the center if possible
    ORKEnableAutoLayoutForViews(@[_container, _scrollContainer]);
    if (_verticalCenteringEnabled) {
        NSLayoutConstraint *verticalCentering1 = [NSLayoutConstraint constraintWithItem:_container
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:_scrollContainer
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:0.8 constant:0];
        verticalCentering1.priority = UILayoutPriorityDefaultLow;
        NSLayoutConstraint *verticalCentering2 = [NSLayoutConstraint constraintWithItem:_container
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                 toItem:_scrollContainer
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.0 constant:0];
        verticalCentering2.priority = UILayoutPriorityDefaultHigh;
        NSLayoutConstraint *verticalCentering3 = [NSLayoutConstraint constraintWithItem:_container
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                 toItem:_scrollContainer
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0 constant:0];
        verticalCentering3.priority = UILayoutPriorityDefaultHigh;
        [_scrollContainer addConstraints:@[verticalCentering1, verticalCentering2, verticalCentering3]];
        
    } else {
        NSLayoutConstraint *verticalTop = [NSLayoutConstraint constraintWithItem:_container
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_scrollContainer
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0 constant:0];
        [_scrollContainer addConstraint:verticalTop];
    }
    
    // Don't let the container get too tall
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_container
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                                           toItem:_scrollContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1 constant:0];
    [_scrollContainer addConstraint:heightConstraint];
    
    [_scrollContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[c]|" options:0 metrics:nil views:@{@"c":_container}]];
#ifdef LAYOUT_DEBUG
    _container.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
#endif
#ifdef LAYOUT_DEBUG
    _scrollContainer.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
#endif

    // All items with constants are added to the -adjustableConstraintsTable.
    NSMutableDictionary *adjustableConstraintsTable = [NSMutableDictionary dictionary];
    NSMutableArray *otherConstraints = [NSMutableArray array];
    adjustableConstraintsTable[_IllustrationHeightConstraintKey] =
    [NSLayoutConstraint constraintWithItem:_customViewContainer
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1 constant:198];
    
    adjustableConstraintsTable[_TopToIllustrationConstraintKey] =
     [NSLayoutConstraint constraintWithItem:_customViewContainer
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_container
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1 constant:0];
    
    [otherConstraints addObject:
    [NSLayoutConstraint constraintWithItem:_headerView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_customViewContainer
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1 constant:0]];
    
    [otherConstraints addObject:
    [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_headerView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1 constant:0]];
    
    adjustableConstraintsTable[_HeaderMinimumHeightKey] = [NSLayoutConstraint constraintWithItem:_headerView
                                                                                       attribute:NSLayoutAttributeHeight
                                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                          toItem:nil
                                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                                      multiplier:1
                                                                                        constant:_minimumStepHeaderHeight];
    
    
    {
        // Normally we want extra space, but we don't want to sacrifice that to scrolling (if it makes a difference)
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_continueSkipContainer
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                toItem:_stepViewContainer
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1 constant:36];
        constraint.priority = UILayoutPriorityDefaultLow-2;
        adjustableConstraintsTable[_StepViewToContinueKey] = constraint;
        
        adjustableConstraintsTable[_StepViewToContinueMinimumKey] = [NSLayoutConstraint constraintWithItem:_continueSkipContainer
                                                                                                 attribute:NSLayoutAttributeTop
                                                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                                    toItem:_stepViewContainer
                                                                                                 attribute:NSLayoutAttributeBottom
                                                                                                multiplier:1 constant:0];
    }
    
    _continueAtBottomConstraint = [NSLayoutConstraint constraintWithItem:_continueSkipContainer
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_scrollContainer
                                                               attribute:NSLayoutAttributeBottomMargin
                                                              multiplier:1 constant:0];
    _continueAtBottomConstraint.priority = UILayoutPriorityRequired-1;
    [otherConstraints addObject:_continueAtBottomConstraint];
    
    // Force all to stay within the container's width.
    for (UIView *view in views) {
#ifdef LAYOUT_DEBUG
        v.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        v.layer.borderColor = [UIColor redColor].CGColor;
        v.layer.borderWidth = 1.0;
#endif
        if (view == _stepViewContainer) {
            [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:_container attribute:NSLayoutAttributeWidth
                                                                    multiplier:1
                                                                      constant:0]];
        } else {
            [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                        toItem:_container attribute:NSLayoutAttributeLeftMargin
                                                                    multiplier:1
                                                                      constant:0]];
            [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:_container attribute:NSLayoutAttributeRightMargin
                                                                    multiplier:1
                                                                      constant:0]];
        }
        [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_container
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
        
        NSLayoutConstraint *bottomnessConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                   toItem:_container
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1 constant:0];
        
        // Because the bottom items are not always present, we add individual "bottom" constraints
        // for all views to ensure the parent sizes large enough to contain everything.
        [otherConstraints addObject:bottomnessConstraint];
        
        if (view == _continueSkipContainer) {
            _continueInContentConstraint = bottomnessConstraint;
            continue;
        }
    }
    
    _adjustableConstraints = adjustableConstraintsTable;
    
    [_scrollContainer addConstraints:otherConstraints];
    [_scrollContainer addConstraints:[adjustableConstraintsTable allValues]];
    
    [self updateCustomViewContainerConstraints];
    [self updateStepViewContainerConstraints];
    [self updateConstraintConstants];
    
    [super updateConstraints];
}

- (void)updateStepViewContainerConstraints {
    [NSLayoutConstraint deactivateConstraints:[_stepViewContainer constraints]];
    
    if (_stepView) {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute multiplier:1
                                                                            constant:ORKScreenMetricMaxDimension];
        widthConstraint.priority = UILayoutPriorityFittingSizeLevel;
        [_stepViewContainer addConstraint:widthConstraint];
        
        [_stepViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:_stepView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_stepViewContainer
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0]];
        
        NSLayoutConstraint *stepViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_stepView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:_stepViewContainer
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                  multiplier:1
                                                                                    constant:0];
        stepViewWidthConstraint.priority = UILayoutPriorityRequired;
        [_stepViewContainer addConstraint:stepViewWidthConstraint];
        
        if (_stepViewFillsAvailableSpace) {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1
                                                                           constant:ORKScreenMetricMaxDimension];
            constraint.priority = UILayoutPriorityFittingSizeLevel;
            [_stepViewContainer addConstraint:constraint];

            NSLayoutConstraint *verticalCentering = [NSLayoutConstraint constraintWithItem:_stepView
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:_stepViewContainer
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                multiplier:1
                                                                                  constant:0];
            verticalCentering.priority = UILayoutPriorityRequired-2;
            [_stepViewContainer addConstraint:verticalCentering];
            
            {
                NSMutableDictionary *adjustable = [_adjustableConstraints mutableCopy];
                NSLayoutConstraint *verticalCentering2 = [NSLayoutConstraint constraintWithItem:_stepView
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:_stepViewContainer
                                                                                      attribute:NSLayoutAttributeCenterY
                                                                                     multiplier:1
                                                                                       constant:-(AssumedNavBarHeight + AssumedStatusBarHeight)/2];
                verticalCentering2.priority = UILayoutPriorityRequired-1;
                [_stepViewContainer addConstraint:verticalCentering2];
                adjustable[_StepViewCenteringOnWholeViewKey] = verticalCentering2;
                _adjustableConstraints = adjustable;
            }
            
            [_stepViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:_stepView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationLessThanOrEqual
                                                                              toItem:_stepViewContainer
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1
                                                                            constant:0]];
        } else {
            [_stepViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[c]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:@{@"c":_stepView}]];
        }
    } else {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:0];
        widthConstraint.priority = UILayoutPriorityFittingSizeLevel;
        [_stepViewContainer addConstraint:widthConstraint];
        [_stepViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:_stepViewContainer
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:0]];
    }
}

- (void)updateCustomViewContainerConstraints {
    if ([_customViewContainerConstraints count]) {
        [NSLayoutConstraint deactivateConstraints:_customViewContainerConstraints];
    }
    NSMutableArray *constraints = [NSMutableArray array];
    if (_customView) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[c]|" options:(NSLayoutFormatOptions)0 metrics:nil views:@{@"c":_customView}]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[c]|" options:(NSLayoutFormatOptions)0 metrics:nil views:@{@"c":_customView}]];
    }
    if (_imageView) {
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1 constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:_customViewContainer
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_customViewContainer
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_customViewContainer
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1 constant:0]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
    _customViewContainerConstraints = constraints;
}

- (void)setCustomView:(UIView *)customView {
    [_customView removeFromSuperview];
    _customView = customView;
    [_customViewContainer addSubview:_customView];
    
    if (_customView && ! [[_customView constraints] count]) {
        [_customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        CGSize requiredSize = [_customView sizeThatFits:(CGSize){self.bounds.size.width,CGFLOAT_MAX}];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_customView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:requiredSize.width];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_customView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:requiredSize.height];
        
        widthConstraint.priority = UILayoutPriorityDefaultLow;
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [_customView addConstraints:@[widthConstraint, heightConstraint]];
    }
    [self setNeedsUpdateConstraints];
}

- (UIImageView *)imageView {
    if(_imageView == nil) {
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
