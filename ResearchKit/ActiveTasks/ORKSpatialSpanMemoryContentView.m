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


#import "ORKSpatialSpanMemoryContentView.h"

#import "ORKActiveStepQuantityView.h"
#import "ORKNavigationContainerView.h"
#import "ORKSpatialSpanTargetView.h"
#import "ORKVerticalContainerView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


// #define LAYOUT_DEBUG 1

@implementation ORKSpatialSpanMemoryGameView

#pragma mark Primary interface

- (void)setGridSize:(ORKGridSize)gridSize {
    _gridSize = gridSize;
#if LAYOUT_DEBUG
    self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
#endif
    [self resetTilesAnimated:NO];
}

- (NSInteger)numberOfTiles {
    return _gridSize.width * _gridSize.height;
}

- (ORKSpatialSpanTargetView *)makeTargetView {
    ORKSpatialSpanTargetView *targetView = [[ORKSpatialSpanTargetView alloc] init];
    targetView.customTargetImage = _customTargetImage;
    return targetView;
}

- (void)resetTilesAnimated:(BOOL)animated {
    NSArray *currentViews = _tileViews;
    NSInteger numberOfTilesOld = _tileViews.count;
    NSInteger numberOfTilesNew = _gridSize.width * _gridSize.height;
    NSMutableArray *newViews = [NSMutableArray arrayWithCapacity:numberOfTilesNew];
    NSArray *viewsToRemove = nil;
    if (numberOfTilesOld <= numberOfTilesNew) {
        [newViews addObjectsFromArray:currentViews];
        NSInteger tilesToAdd = numberOfTilesNew - numberOfTilesOld;
        for (NSInteger idx = 0; idx < tilesToAdd; idx++) {
            [newViews addObject:[self makeTargetView]];
        }
    } else {
        [newViews addObjectsFromArray:[currentViews subarrayWithRange:(NSRange){0,numberOfTilesNew}]];
        viewsToRemove = [currentViews subarrayWithRange:(NSRange){numberOfTilesNew, numberOfTilesOld-numberOfTilesNew}];
    }
    
    void(^resetBlock)(void) = ^(void) {
        for (ORKSpatialSpanTargetView *view in viewsToRemove) {
            view.delegate = nil;
            [view removeFromSuperview];
        }
        if (numberOfTilesNew > numberOfTilesOld) {
            NSArray *addedViews = [newViews subarrayWithRange:(NSRange){numberOfTilesOld,numberOfTilesNew-numberOfTilesOld}];
            for (ORKSpatialSpanTargetView *view in addedViews) {
                view.delegate = self;
                [self addSubview:view];
            }
        }
        
        _tileViews = newViews;
        for (ORKSpatialSpanTargetView *view in _tileViews) {
            [view setState:ORKSpatialSpanTargetStateQuiescent];
        }
        
        [self layoutSubviews];
    };
    
    if (animated) {
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:resetBlock completion:NULL];
    } else {
        resetBlock();
    }
    
}

- (void)setCustomTargetImage:(UIImage *)customTargetImage {
    _customTargetImage = customTargetImage;
    for (ORKSpatialSpanTargetView *view in _tileViews) {
        view.customTargetImage = _customTargetImage;
    }
}

- (void)targetView:(ORKSpatialSpanTargetView *)targetView recognizer:(UITapGestureRecognizer *)recognizer {
    [_delegate gameView:self
    didTapTileWithIndex:[_tileViews indexOfObject:targetView]
         recognizer:recognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat gridItemEdgeLength =  ORKFloorToViewScale(MIN(bounds.size.width / _gridSize.width, bounds.size.height / _gridSize.height), self);
    
    gridItemEdgeLength = MIN(gridItemEdgeLength, 114);
    CGSize gridItemSize = (CGSize){gridItemEdgeLength, gridItemEdgeLength};
    
    CGPoint centeringOffset = CGPointZero;
    centeringOffset.x = 0.5 * (bounds.size.width - (gridItemSize.width * _gridSize.width));
    centeringOffset.y = 0.5 * (bounds.size.height - (gridItemSize.height * _gridSize.height));
    
    NSInteger tileIndex = 0;
    for (NSInteger x = 0; x < _gridSize.width; x++) {
        for (NSInteger y = 0; y < _gridSize.height; y++) {
            ORKSpatialSpanTargetView *targetView = _tileViews[tileIndex];
            
            CGPoint origin = (CGPoint){.x = ORKFloorToViewScale(centeringOffset.x + x * gridItemSize.width, self),
                .y = ORKFloorToViewScale(centeringOffset.y + y * gridItemSize.height, self)};
            targetView.frame = (CGRect){.origin=origin, .size=gridItemSize};
            
            tileIndex ++;
        }
    }
}

- (void)setState:(ORKSpatialSpanTargetState)state forTileIndex:(NSInteger)tileIndex animated:(BOOL)animated {
    ORKSpatialSpanTargetView *view = _tileViews[tileIndex];
    [view setState:state animated:animated];
}

- (ORKSpatialSpanTargetState)stateForTileIndex:(NSInteger)tileIndex {
    return [(ORKSpatialSpanTargetView *)_tileViews[tileIndex] state];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

@end


@implementation ORKSpatialSpanMemoryContentView {
    ORKQuantityPairView *_quantityPairView;
    ORKNavigationContainerView *_continueView;
}

- (ORKActiveStepQuantityView *)countView {
    return [_quantityPairView leftView];
}

- (ORKActiveStepQuantityView *)scoreView {
    return [_quantityPairView rightView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gameView = [ORKSpatialSpanMemoryGameView new];
        _gameView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_gameView];
        
        _quantityPairView = [ORKQuantityPairView new];
        _quantityPairView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_quantityPairView];
        
        _continueView = [ORKNavigationContainerView new];
        _continueView.translatesAutoresizingMaskIntoConstraints = NO;
        _continueView.continueEnabled = YES;
        _continueView.bottomMargin = 20;
        [self addSubview:_continueView];
        
        ORKActiveStepQuantityView *countView = [self countView];
        ORKActiveStepQuantityView *scoreView = [self scoreView];
        
        _capitalizedPluralItemDescription = [ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_STANDALONE", nil) capitalizedStringWithLocale:[NSLocale currentLocale]];
        
        countView.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"MEMORY_GAME_ITEM_COUNT_TITLE_%@", nil), _capitalizedPluralItemDescription];
        scoreView.title = ORKLocalizedString(@"MEMORY_GAME_SCORE_TITLE", nil);
        countView.enabled = YES;
        scoreView.enabled = YES;
        
        self.numberOfItems = 0;
        self.score = 0;
        
        [self updateMargins];
        
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        _gameView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        _continueView.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        _quantityPairView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        [self scoreView].backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.2];
        [self countView].backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.2];
#endif
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setCapitalizedPluralItemDescription:(NSString *)capitalizedPluralItemDescription {
    _capitalizedPluralItemDescription = capitalizedPluralItemDescription;
    [self countView].title = [NSString localizedStringWithFormat:ORKLocalizedString(@"MEMORY_GAME_ITEM_COUNT_TITLE_%@", nil), _capitalizedPluralItemDescription];
}

- (void)setNumberOfItems:(NSInteger)numberOfItems {
    ORKActiveStepQuantityView *countView = [self countView];
    countView.value = [NSString stringWithFormat:@"%ld", (long)numberOfItems];
}


- (void)setScore:(NSInteger)score {
    ORKActiveStepQuantityView *scoreView = [self scoreView];
    scoreView.value = [NSString stringWithFormat:@"%ld", (long)score];
}

- (void)updateFooterHidden {
    _quantityPairView.hidden = (_footerHidden || (_buttonItem != nil));
}

- (void)setFooterHidden:(BOOL)footerHidden {
    _footerHidden = footerHidden;
    [self updateFooterHidden];
}

- (void)setButtonItem:(UIBarButtonItem *)buttonItem {
    _buttonItem = buttonItem;
    _continueView.continueButtonItem = buttonItem;
    _continueView.hidden = (buttonItem == nil);
    [self updateFooterHidden];
}

- (void)updateMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin, .right = margin};
    _quantityPairView.layoutMargins = self.layoutMargins;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateMargins];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateMargins];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_gameView, _quantityPairView, _continueView);
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_gameView][_quantityPairView]|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    NSLayoutConstraint *gameViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_gameView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:ORKScreenMetricMaxDimension];
    gameViewHeightConstraint.priority = UILayoutPriorityDefaultLow - 1;
    [constraints addObject:gameViewHeightConstraint];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_gameView]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_quantityPairView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_quantityPairView
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:_quantityPairView
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    NSLayoutConstraint *maxWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:ORKScreenMetricMaxDimension];
    maxWidthConstraint.priority = UILayoutPriorityRequired - 1;
    [constraints addObject:maxWidthConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
