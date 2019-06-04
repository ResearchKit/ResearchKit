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
#import "ORKNavigationContainerView_Internal.h"

/**
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

static const CGFloat ORKStepContainerTopCustomContentPaddingStandard = 20.0;
static const CGFloat ORKStepContainerNavigationFooterTopPaddingStandard = 10.0;

@implementation ORKStepContainerView {
    CGFloat _leftRightPadding;
    CGFloat _customContentLeftRightPadding;
    UIScrollView *_scrollView;
    UIView *_scrollContainerView;
    BOOL _topContentImageShouldScroll;
    
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
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _leftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
        _customContentLeftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
        [self setupScrollView];
        [self setupScrollContainerView];
        [self addStepContentView];
        [self setupConstraints];
        [self setupUpdatedConstraints];
        [self placeNavigationContainerView];
        _topContentImageShouldScroll = YES;
    }
    return self;
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
        _scrollView = [[UIScrollView alloc] init];
    }
    _scrollView.showsVerticalScrollIndicator = self.showScrollIndicator;
    [self addSubview:_scrollView];
}

- (void)setShowScrollIndicator:(BOOL)showScrollIndicator {
    self.showScrollIndicator = showScrollIndicator;
    _scrollView.showsVerticalScrollIndicator = showScrollIndicator;
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
    if (self.isNavigationContainerScrollable) {
        [_scrollContainerView addSubview:self.navigationFooterView];
    }
    else {
        [self addSubview:self.navigationFooterView];
    }
    [self setupNavigationContainerViewConstraints];
}

- (void)setupNavigationContainerViewConstraints {
    self.navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _navigationContainerViewConstraints = @[
                                              [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.isNavigationContainerScrollable ? _scrollContainerView.safeAreaLayoutGuide : self.safeAreaLayoutGuide
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.isNavigationContainerScrollable ? _scrollContainerView : self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:_leftRightPadding],
                                              [NSLayoutConstraint constraintWithItem:self.navigationFooterView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.isNavigationContainerScrollable ? _scrollContainerView : self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:-_leftRightPadding]];
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
                                                                      toItem:self.navigationFooterView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0.0];
        [_updatedConstraints addObject:_scrollViewBottomConstraint];
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)setupNavigationContainerViewTopConstraint {
    if (self.navigationFooterView && self.isNavigationContainerScrollable) {
        
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
    if (self.navigationFooterView && self.isNavigationContainerScrollable) {
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
        _customContentHeightConstraint = [NSLayoutConstraint constraintWithItem:_customContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:_customContentFillsAvailableSpace ? NSLayoutRelationEqual : NSLayoutRelationLessThanOrEqual
                                                                         toItem:self.isNavigationContainerScrollable ? self.navigationFooterView : _scrollContainerView
                                                                      attribute:self.isNavigationContainerScrollable ? NSLayoutAttributeTop : NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:self.isNavigationContainerScrollable ? -ORKStepContainerNavigationFooterTopPaddingStandard : 0.0];
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
        _customContentWidthConstraint = [NSLayoutConstraint constraintWithItem:_customContentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_scrollContainerView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:-2*_customContentLeftRightPadding];
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
                                                                    constant:ORKStepContainerTopCustomContentPaddingStandard];
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
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeCenterX
                                         multiplier:1.0
                                           constant:0.0],
             [NSLayoutConstraint constraintWithItem:_scrollContainerView
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                             toItem:_scrollView
                                          attribute:NSLayoutAttributeHeight
                                         multiplier:1.0
                                           constant:0.0]
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

@end
