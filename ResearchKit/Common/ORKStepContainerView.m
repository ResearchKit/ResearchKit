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

static NSString *scrollContentChangedNotification = @"scrollContentChanged";

@interface ScrollView : UIScrollView

@end

@implementation ScrollView

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:scrollContentChangedNotification object:nil]];
}

@end

@implementation ORKStepContainerView {
    CGFloat _leftRightPadding;
    CGFloat _customContentLeftRightPadding;
    ScrollView *_scrollView;
    UIView *_scrollContainerView;
    BOOL _topContentImageShouldScroll;
    CGFloat _customContentTopPadding;
    CGFloat _highestContentPosition;
    BOOL _showScrollIndicator;
    CGFloat _scrollViewCustomContentInset;
    
    UIImageView *_topContentImageView;

//    variable constraints:
    NSLayoutConstraint *_scrollViewTopConstraint;
    NSLayoutConstraint *_scrollViewBottomConstraint;
    NSLayoutConstraint *_stepContentViewTopConstraint;
    NSLayoutConstraint *_customContentViewTopConstraint;
    
    NSArray<NSLayoutConstraint *> *_topContentImageViewConstraints;
    
    NSLayoutConstraint *_navigationContainerViewTopConstraint;
    NSArray<NSLayoutConstraint *> *_navigationContainerViewConstraints;
    NSLayoutConstraint *_customContentWidthConstraint;
    NSLayoutConstraint *_customContentHeightConstraint;
    NSMutableArray<NSLayoutConstraint *> *_updatedConstraints;
    NSLayoutConstraint *_scrollContentBottomConstraint;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _customContentLeftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
        _leftRightPadding = ORKStepContainerExtendedLeftRightPaddingForWindow(self.window);
        self.isNavigationContainerScrollable = NO;
        _highestContentPosition = 0.0;
        _scrollViewCustomContentInset = ORKCGFloatDefaultValue;
        [self setupScrollView];
        [self setupScrollContainerView];
        [self addStepContentView];
        [self setupConstraints];
        [self setupUpdatedConstraints];
        [self placeNavigationContainerView];
        _topContentImageShouldScroll = YES;
        _customContentTopPadding = ORKStepContainerTopCustomContentPaddingStandard;
        _pinNavigationContainer = YES; // Default behavior is to pin the navigation footer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollContentChanged) name:scrollContentChangedNotification object:nil];
    }
    return self;
}

- (void)setPinNavigationContainer:(BOOL)pinNavigationContainer {
    _pinNavigationContainer = pinNavigationContainer;
    [self placeNavigationContainerView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:scrollContentChangedNotification object:nil];
}

- (void)setStepTopContentImage:(UIImage *)stepTopContentImage {
    
    [super setStepTopContentImage:stepTopContentImage];
    if (_topContentImageShouldScroll) {
        [self.stepContentView setStepTopContentImage:stepTopContentImage];
    }
    else {
        //    1.) nil Image; updateConstraints
        if (!stepTopContentImage && _topContentImageView) {
            [_topContentImageView removeFromSuperview];
            _topContentImageView = nil;
            [self deactivateTopContentImageViewConstraints];
            [self updateScrollViewTopConstraint];
            [self setNeedsUpdateConstraints];
        }
        
        //    2.) First Image; updateConstraints
        if (stepTopContentImage && !_topContentImageView) {
            [self setupTopContentImageView];
            _topContentImageView.image = [self topContentAndAuxiliaryImage];
            [self updateScrollViewTopConstraint];
            [self setNeedsUpdateConstraints];
        }
        
        //    3.) >= second Image;
        if (stepTopContentImage && _topContentImageView) {
            _topContentImageView.image = [self topContentAndAuxiliaryImage];
        }
    }
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [[ScrollView alloc] init];
    }
    _scrollView.showsVerticalScrollIndicator = self.showScrollIndicator;
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
}

- (void)setShowScrollIndicator:(BOOL)showScrollIndicator {
    _showScrollIndicator = showScrollIndicator;
    _scrollView.showsVerticalScrollIndicator = showScrollIndicator;
}

- (BOOL)showScrollIndicator {
    return _showScrollIndicator;
}

- (void)setupScrollContainerView {
    if (!_scrollContainerView) {
        _scrollContainerView = [UIView new];
    }
    [_scrollView addSubview:_scrollContainerView];
}

- (void)setupUpdatedConstraints {
    _updatedConstraints = [[NSMutableArray alloc] init];
}

- (void)setupTopContentImageView {
    if (!_topContentImageView) {
        _topContentImageView = [UIImageView new];
    }
    _topContentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_topContentImageView setBackgroundColor:ORKColor(ORKTopContentImageViewBackgroundColorKey)];
    [self addSubview:_topContentImageView];
    [self setTopContentImageViewConstraints];
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
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
    }
}

- (void)addStepContentView {
    [_scrollContainerView addSubview:self.stepContentView];
}

- (void)stepContentViewImageChanged:(NSNotification *)notification {
    [super stepContentViewImageChanged:notification];
    [self updateStepContentViewTopConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)setStepContentViewConstraints {
    self.stepContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setStepContentViewTopConstraint];
    
    [NSLayoutConstraint activateConstraints:@[
                                              _stepContentViewTopConstraint,
                                              [NSLayoutConstraint constraintWithItem:self.stepContentView
                                                                                   attribute:NSLayoutAttributeLeft
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:_scrollContainerView
                                                                                   attribute:NSLayoutAttributeLeft
                                                                                  multiplier:1.0
                                                                                    constant:0.0],
                                                      [NSLayoutConstraint constraintWithItem:self.stepContentView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:_scrollContainerView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                  multiplier:1.0
                                                                                    constant:0.0]
                                              ]];
}

- (void)setStepContentViewTopConstraint {
    _stepContentViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.stepContentView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.stepContentView.topContentImageView.image ? _scrollContainerView : _scrollContainerView.safeAreaLayoutGuide
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0.0];
}

- (void)updateStepContentViewTopConstraint {
    if (_stepContentViewTopConstraint && _stepContentViewTopConstraint.isActive) {
        [NSLayoutConstraint deactivateConstraints:@[_stepContentViewTopConstraint]];
    }
    if ([_updatedConstraints containsObject:_stepContentViewTopConstraint]) {
        [_updatedConstraints removeObject:_stepContentViewTopConstraint];
    }
    [self setStepContentViewTopConstraint];
    if (_stepContentViewTopConstraint) {
        [_updatedConstraints addObject:_stepContentViewTopConstraint];
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
    _customContentView = customContentView;
    [_scrollContainerView addSubview:_customContentView];
    [self setupCustomContentViewConstraints];
    [self updateNavigationContainerViewTopConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)removeNavigationFooterView {
    [self.navigationFooterView removeFromSuperview];
    if (_navigationContainerViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_navigationContainerViewConstraints];
        for (NSLayoutConstraint *constraint in _navigationContainerViewConstraints) {
            if ([_updatedConstraints containsObject:constraint]) {
                [_updatedConstraints removeObject:constraint];
            }
        }
        _navigationContainerViewConstraints = nil;
    }
}

- (void)placeNavigationContainerView {
    [self removeNavigationFooterView];
    
    if (!_pinNavigationContainer) {
        [_scrollView addSubview:self.navigationFooterView];
    } else if (self.isNavigationContainerScrollable) {
        [_scrollContainerView addSubview:self.navigationFooterView];
    } else {
        [self addSubview:self.navigationFooterView];
    }
    [self setupNavigationContainerViewConstraints];
}

- (void)placeNavigationContainerInsideScrollView {
    self.isNavigationContainerScrollable = YES;
    [self setupConstraints];
    [self placeNavigationContainerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateScrollContentConstraints];
    // dispatching on main thread to prevent the blur view from popping-up after transition is complete
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateEffectViewStylingAndAnimate:NO checkCurrentValue:NO];
        if (_scrollViewCustomContentInset != ORKCGFloatDefaultValue) {
            [self updateScrollViewCustomContentInset];
        }
    });
}

- (void)updateScrollContentConstraints {
    if (_scrollContentBottomConstraint != nil) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollContentBottomConstraint]];
    }
    _scrollContentBottomConstraint = [NSLayoutConstraint constraintWithItem:self.stepContentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:_scrollContainerView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    [NSLayoutConstraint activateConstraints:@[_scrollContentBottomConstraint]];
}

- (void)setupNavigationContainerViewConstraints {
    self.navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    BOOL useScrollableItem = (self.isNavigationContainerScrollable || !_pinNavigationContainer);
    id boundaryView = useScrollableItem ? _scrollContainerView : self;
    _navigationContainerViewConstraints = @[
                                              [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:boundaryView
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:boundaryView
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:boundaryView
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0.0]];
    
    [_updatedConstraints addObjectsFromArray:_navigationContainerViewConstraints];
    [self updateNavigationContainerViewTopConstraint];

    if (!self.isNavigationContainerScrollable) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollViewBottomConstraint]];
        if ([_updatedConstraints containsObject:_scrollViewBottomConstraint]) {
            [_updatedConstraints removeObject:_scrollViewBottomConstraint];
        }
        
        _scrollViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0.0];
        [_updatedConstraints addObject:_scrollViewBottomConstraint];
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)setupNavigationContainerViewTopConstraint {
    BOOL shouldScrollNavigationContainer = (self.isNavigationContainerScrollable || !_pinNavigationContainer);
    if (self.navigationFooterView && shouldScrollNavigationContainer) {
        
        id topItem;
        NSLayoutAttribute topItemAttribute;
        if (_customContentView) {
            topItem = _customContentView;
            topItemAttribute = NSLayoutAttributeBottom;
        }
        else if(self.stepContentView) {
            topItem = self.stepContentView;
            topItemAttribute = NSLayoutAttributeBottom;
        }
        else {
            topItem = _scrollContainerView;
            topItemAttribute = NSLayoutAttributeTop;
        }
        
        _navigationContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                toItem:topItem
                                                                             attribute:topItemAttribute
                                                                            multiplier:1.0
                                                                              constant:ORKStepContainerNavigationFooterTopPaddingStandard];
    }
}

- (void)updateNavigationContainerViewTopConstraint {
    BOOL shouldScrollNavigationContainer = (self.isNavigationContainerScrollable || !_pinNavigationContainer);
    if (self.navigationFooterView && shouldScrollNavigationContainer) {
        if (_navigationContainerViewTopConstraint) {
            [NSLayoutConstraint deactivateConstraints:@[_navigationContainerViewTopConstraint]];
            if ([_updatedConstraints containsObject:_navigationContainerViewTopConstraint]) {
                [_updatedConstraints removeObject:_navigationContainerViewTopConstraint];
            }
        }
        [self setupNavigationContainerViewTopConstraint];
        [_updatedConstraints addObject:_navigationContainerViewTopConstraint];
    }
}

- (void)setupCustomContentViewConstraints {
    _customContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setCustomContentViewTopConstraint];
    [self setCustomContentWidthConstraint];
    [_updatedConstraints addObjectsFromArray:@[
                                               _customContentViewTopConstraint,
                                               [NSLayoutConstraint constraintWithItem:_customContentView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_scrollContainerView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0.0],
                                               _customContentWidthConstraint
                                               ]];
    [self updateCustomContentHeightConstraint];
    [self setNeedsUpdateConstraints];
    
   
}

- (void)setCustomContentFillsAvailableSpace:(BOOL)customContentFillsAvailableSpace {
    _customContentFillsAvailableSpace = customContentFillsAvailableSpace;
    [self updateCustomContentHeightConstraint];
}

- (void)setCustomContentHeightConstraint {
    if (_customContentView) {
        if ([_customContentView isKindOfClass:[UIImageView class]]) {
            _customContentHeightConstraint = [_customContentView.heightAnchor constraintLessThanOrEqualToConstant:ImageViewMaxHeightAndWidth];
        } else {
            _customContentHeightConstraint = [NSLayoutConstraint constraintWithItem:_customContentView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:_customContentFillsAvailableSpace ? NSLayoutRelationEqual : NSLayoutRelationLessThanOrEqual
                                                                             toItem:self.isNavigationContainerScrollable ? self.navigationFooterView : _scrollContainerView
                                                                          attribute:self.isNavigationContainerScrollable ? NSLayoutAttributeTop : NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:self.isNavigationContainerScrollable ? -ORKStepContainerNavigationFooterTopPaddingStandard : 0.0];
        }
    }
}

- (void)updateCustomContentHeightConstraint {
    if (_customContentView) {
        if (_customContentHeightConstraint && _customContentHeightConstraint.isActive) {
            [NSLayoutConstraint deactivateConstraints:@[_customContentHeightConstraint]];
        }
        if ([_updatedConstraints containsObject:_customContentHeightConstraint]) {
            [_updatedConstraints removeObject:_customContentHeightConstraint];
        }
        [self setCustomContentHeightConstraint];
        if (_customContentHeightConstraint) {
            [_updatedConstraints addObject:_customContentHeightConstraint];
        }
    }
}

- (void)setCustomContentWidthConstraint {
    if (_customContentView) {
        if ([_customContentView isKindOfClass:[UIImageView class]]) {
            _customContentWidthConstraint = [_customContentView.widthAnchor constraintLessThanOrEqualToConstant:ImageViewMaxHeightAndWidth];
        } else {
            _customContentWidthConstraint = [NSLayoutConstraint constraintWithItem:_customContentView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_scrollContainerView
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0
                                                                          constant:-2*_customContentLeftRightPadding];
        }
    }
}

- (void)removeCustomContentPadding {
    _customContentLeftRightPadding = 0.0;
    if (_customContentWidthConstraint) {
        _customContentWidthConstraint.constant = _customContentLeftRightPadding;
    }
}

- (void)setCustomContentViewTopConstraint {
    id topItem;
    NSLayoutAttribute attribute;
    
    if (self.stepContentView) {
        topItem = self.stepContentView;
        attribute = NSLayoutAttributeBottom;
    }
    else {
        topItem = _scrollContainerView;
        attribute = NSLayoutAttributeTop;
    }
    
    _customContentViewTopConstraint = [NSLayoutConstraint constraintWithItem:_customContentView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:topItem
                                                                   attribute:attribute
                                                                  multiplier:1.0
                                                                    constant:_customContentTopPadding];
}

- (void)setCustomContentView:(UIView *)customContentView withTopPadding:(CGFloat)topPadding {
    [self setCustomContentView:customContentView withTopPadding:topPadding sidePadding:_customContentLeftRightPadding];
}

- (void)setCustomContentView:(UIView *)customContentView withTopPadding:(CGFloat)topPadding sidePadding:(CGFloat)sidePadding {
    _customContentTopPadding = topPadding;
    _customContentLeftRightPadding = sidePadding;
    [self setCustomContentView:customContentView];
}

- (void)updateCustomContentViewTopConstraint {
    if (_customContentView) {
        if (_customContentViewTopConstraint && _customContentViewTopConstraint.isActive) {
            [NSLayoutConstraint deactivateConstraints:@[_customContentViewTopConstraint]];
        }
        if ([_updatedConstraints containsObject:_customContentViewTopConstraint]) {
            [_updatedConstraints removeObject:_customContentViewTopConstraint];
        }
        [self setCustomContentViewTopConstraint];
        if (_customContentViewTopConstraint) {
            [_updatedConstraints addObject:_customContentViewTopConstraint];
        }
    }
}

- (NSArray<NSLayoutConstraint *> *)scrollViewStaticConstraints {
    _scrollViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:0.0];
    return @[
             [NSLayoutConstraint constraintWithItem:_scrollView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:0.0],
             _scrollViewBottomConstraint
             ];
}

- (NSArray<NSLayoutConstraint *> *)scrollContainerStaticConstraints {

    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_scrollView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0];
    heightConstraint.priority = UILayoutPriorityDefaultLow;

    return @[
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeRight
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeWidth
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeWidth
                                         multiplier:1.0
                                           constant:0.0],
             heightConstraint
             ];
}

- (void)setScrollViewTopConstraint {
    _scrollViewTopConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_topContentImageView ? : self
                                                                     attribute:_topContentImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0];
    [_updatedConstraints addObject:_scrollViewTopConstraint];
}

- (void)updateScrollViewTopConstraint {
    if (_scrollViewTopConstraint) {
        [NSLayoutConstraint deactivateConstraints:@[_scrollViewTopConstraint]];
    }
    if ([_updatedConstraints containsObject:_scrollViewTopConstraint]) {
        [_updatedConstraints removeObject:_scrollViewTopConstraint];
    }
    [self setScrollViewTopConstraint];
}

- (void)setTopContentImageViewConstraints {
    _topContentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _topContentImageViewConstraints = @[
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:ORKStepContainerTopContentHeightForWindow(self.window)]
                                        ];
    [_updatedConstraints addObjectsFromArray:_topContentImageViewConstraints];
}

- (void)deactivateTopContentImageViewConstraints {
    if (_topContentImageViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_topContentImageViewConstraints];
        for (NSLayoutConstraint *constraint in _topContentImageViewConstraints) {
            if ([_updatedConstraints containsObject:constraint]) {
                [_updatedConstraints removeObject:constraint];
            }
        }
    }
    _topContentImageViewConstraints = nil;
}

- (void)setupConstraints {
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setScrollViewTopConstraint];
    NSMutableArray<NSLayoutConstraint *> *staticConstraints = [[NSMutableArray alloc] initWithArray:[self scrollViewStaticConstraints]];
    [staticConstraints addObject:_scrollViewTopConstraint];
    [staticConstraints addObjectsFromArray:[self scrollContainerStaticConstraints]];
    [NSLayoutConstraint activateConstraints:staticConstraints];
    [self setStepContentViewConstraints];
}

- (void)updateContainerConstraints {
    [NSLayoutConstraint activateConstraints:_updatedConstraints];
    [_updatedConstraints removeAllObjects];
}

- (void)updateConstraints {
    [self updateContainerConstraints];
    [super updateConstraints];
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
    CGPoint pointInScrollView = [bodyItem.superview convertPoint:bodyItem.frame.origin toView:_scrollView];
    CGFloat bottomOfView = pointInScrollView.y + bodyItem.frame.size.height;
    CGFloat bottomOfScrollView = _scrollView.frame.size.height - [self navigationFooterView].frame.size.height;

    // TODO:- update ORKBodyItemScrollPadding depending on device size
    if (bottomOfView > bottomOfScrollView) {
        [_scrollView setContentOffset:CGPointMake(0, (bottomOfView - bottomOfScrollView) + ORKBodyItemScrollPadding) animated:YES];
    }
}

- (CGFloat)contentHeight {
    CGFloat height = 0.0;
    for (UIView *view in _scrollContainerView.subviews) {
        height += view.frame.size.height;
    }
    
    return height;
}

- (void)updateEffectViewStylingAndAnimate:(BOOL)animated checkCurrentValue:(BOOL)checkCurrentValue {
    CGFloat startOfFooter = self.navigationFooterView.frame.origin.y;
    CGFloat endOfFooter = self.navigationFooterView.frame.origin.y + self.navigationFooterView.frame.size.height;
    
    // calculating height of all subviews in _scrollContainerView
    CGFloat height = [self contentHeight];
    if (!self.isNavigationContainerScrollable) {
        CGFloat contentPosition = (height - _scrollView.contentOffset.y);
        CGFloat newOpacity = (contentPosition < startOfFooter) ? ORKEffectViewOpacityHidden : ORKEffectViewOpacityVisible;
        [self updateEffectStyleWithNewOpacity:newOpacity animated:animated checkCurrentValue:checkCurrentValue];

        // This check is to guard against scenarios when the view can be dragged down even if the content size doesn't allow for scrolling behavior
        if (contentPosition > _highestContentPosition && (_scrollView.contentOffset.y >= _scrollView.contentInset.top)) {
            _highestContentPosition = contentPosition;
            // add contentInset if the contentPosition extends beyond the footerView
            if ((contentPosition > startOfFooter) && (!self.navigationFooterView.isHidden)) {
                // Only need to calculate the offset based on content position if the end of the content sits between
                // the top and the bottom of the navigation footer view
                if (contentPosition < endOfFooter) {
                    CGFloat offset = contentPosition - startOfFooter;
                    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, offset + ORKContentBottomPadding, 0);
                } else {
                    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationFooterView.frame.size.height + ORKContentBottomPadding, 0);
                }
            }
        }
    } else if ([self.navigationFooterView effectViewOpacity] != ORKEffectViewOpacityHidden) {
        [self updateEffectStyleWithNewOpacity:ORKEffectViewOpacityHidden animated:NO checkCurrentValue:NO];
    }
}

- (void)updateEffectViewStylingAndAnimate:(BOOL)animated checkCurrentValue:(BOOL)checkCurrentValue customView:(UIView *)customView {
    CGFloat startOfFooter = self.navigationFooterView.frame.origin.y;
    CGPoint newPoint = [customView convertPoint:customView.frame.origin toView:_scrollView];
    CGFloat endOfContent = newPoint.y + customView.frame.size.height;
    CGFloat newOpacity = (endOfContent < startOfFooter) ? ORKEffectViewOpacityHidden : ORKEffectViewOpacityVisible;
    [self updateEffectStyleWithNewOpacity:newOpacity animated:animated checkCurrentValue:checkCurrentValue];
}

- (void)updateEffectStyleWithNewOpacity:(CGFloat)newOpacity animated:(BOOL)animated checkCurrentValue:(BOOL)checkCurrentValue {
    CGFloat currentOpacity = [self.navigationFooterView effectViewOpacity];
    if (!checkCurrentValue || (newOpacity != currentOpacity)) {
        // Don't animate transition from hidden to visible as text appears behind during animation
        if (currentOpacity == ORKEffectViewOpacityHidden) { animated = NO; }
        [self.navigationFooterView setStylingOpactity:newOpacity animated:animated];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [_scrollView setScrollEnabled:scrollEnabled];
}

- (BOOL)isScrollEnabled {
    return _scrollView.scrollEnabled;
}

- (void)setScrollViewInset:(UIEdgeInsets)inset {
    [_scrollView setContentInset:inset];
}

- (void)scrollToPoint:(CGPoint)point {
    [_scrollView setContentOffset:point animated:YES];
}

// MARK: ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateEffectViewStylingAndAnimate:YES checkCurrentValue:YES];
}

- (void)scrollContentChanged {
    [self updateEffectViewStylingAndAnimate:NO checkCurrentValue:NO];
}

@end
