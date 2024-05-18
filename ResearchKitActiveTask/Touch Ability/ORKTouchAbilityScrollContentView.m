/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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

#import "ORKTouchAbilityScrollContentView.h"
#import "ORKTouchAbilityPinchGuideView.h"

@interface ORKTouchAbilityScrollContentView () <
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (nonatomic, assign) NSUInteger numberOfItems;
@property (nonatomic, assign) NSUInteger visibleItems;
@property (nonatomic, assign) NSUInteger initialItem;
@property (nonatomic, assign) NSUInteger targetItem;

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) CGPoint initialOffset;
@property (nonatomic, assign) CGPoint targetOffset;
@property (nonatomic, assign) CGPoint endDraggingOffset;
@property (nonatomic, assign) CGPoint endScrollingOffset;

@property (nonatomic, assign) NSTimeInterval timeIntervalBeforeStopDecelarating;

@property (nonatomic, strong) UIView *hintView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation ORKTouchAbilityScrollContentView

#pragma mark - Properties

- (void)setDirection:(ORKTouchAbilityScrollTrialDirection)direction {
    switch (direction) {
        case ORKTouchAbilityScrollTrialDirectionVertical:
            self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            break;
            
        case ORKTouchAbilityScrollTrialDirectionHorizontal:
            self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            break;
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0.0;
    }
    return _flowLayout;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.hintView = [[ORKTouchAbilityPinchGuideView alloc] init];
        
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.backgroundColor = UIColor.clearColor;
        self.collectionView.delaysContentTouches = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.collectionView];
        [self.contentView insertSubview:self.hintView atIndex:10000];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView);
        NSMutableArray *constraintsArray = [NSMutableArray array];
        
        [constraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
        
        [constraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
        
        [NSLayoutConstraint activateConstraints:constraintsArray];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.visibleItems == 0) {
        return;
    }
    
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat width = CGRectGetWidth(self.contentView.bounds) / self.visibleItems;
        CGFloat height = CGRectGetHeight(self.contentView.bounds);
        self.flowLayout.itemSize = CGSizeMake(width, height);
        
        if (self.targetItem < self.initialItem) {
            self.hintView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame) + width / 2,
                                             CGRectGetMinY(self.collectionView.frame),
                                             width,
                                             height);
        } else {
            self.hintView.frame = CGRectMake(CGRectGetMaxX(self.collectionView.frame) - width * 1.5,
                                             CGRectGetMinY(self.collectionView.frame),
                                             width,
                                             height);
        }
    } else {
        CGFloat width = CGRectGetWidth(self.contentView.bounds);
        CGFloat height = CGRectGetHeight(self.contentView.bounds) / self.visibleItems;
        self.flowLayout.itemSize = CGSizeMake(width, height);
        
        if (self.targetItem < self.initialItem) {
            self.hintView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                             CGRectGetMinY(self.collectionView.frame) + height / 2,
                                             width,
                                             height);
        } else {
            self.hintView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                             CGRectGetMaxY(self.collectionView.frame) - height * 1.5,
                                             width,
                                             height);
        }
    }
}


#pragma mark - ORKTouchAbilityContentView

+ (Class)trialClass {
    return [ORKTouchAbilityScrollTrial class];
}

- (ORKTouchAbilityTrial *)trial {
    
    ORKTouchAbilityScrollTrial *trial = (ORKTouchAbilityScrollTrial *)[super trial];
    
    trial.direction = self.direction;
    trial.initialOffset = self.initialOffset;
    trial.targetOffsetLowerBound = self.targetOffset;
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        trial.targetOffsetUpperBound = CGPointMake(self.targetOffset.x + self.flowLayout.itemSize.width, self.targetOffset.y);
    } else {
        trial.targetOffsetUpperBound = CGPointMake(self.targetOffset.x, self.targetOffset.y + self.flowLayout.itemSize.height);
    }
    trial.endDraggingOffset = self.endDraggingOffset;
    trial.endScrollingOffset = self.endScrollingOffset;
    
    return trial;
}

- (void)startTrial {
    [super startTrial];
    self.collectionView.userInteractionEnabled = YES;
    self.collectionView.scrollEnabled = YES;
}

- (void)endTrial {
    [super endTrial];
    self.collectionView.userInteractionEnabled = NO;
    self.collectionView.scrollEnabled = NO;
}

- (void)reloadData {
    [self resetTracks];
    
    self.success = NO;
    self.numberOfItems = [self.dataSource numberOfItemsInScrollContentView:self]        ?: 1;
    self.visibleItems  = [self.dataSource numberOfVisibleItemsInScrollContentView:self] ?: 1;
    self.initialItem   = [self.dataSource initialItemInScrollContentView:self]          ?: 0;
    self.targetItem    = [self.dataSource targetItemInScrollContentView:self]           ?: 0;
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    NSInteger indexDiff = self.targetItem - self.initialItem;
    
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        
        CGFloat width = CGRectGetWidth(self.collectionView.bounds) / self.visibleItems;
        CGFloat offsetX = width * ((self.numberOfItems / 2) - 2.5);
        CGFloat offsetY = self.collectionView.contentOffset.y;
        
        self.initialOffset = CGPointMake(offsetX, offsetY);
        self.targetOffset = CGPointMake(offsetX - indexDiff * width, offsetY);
        
    } else {
        
        CGFloat height = CGRectGetHeight(self.collectionView.bounds) / self.visibleItems;
        CGFloat offsetX = self.collectionView.contentOffset.x;
        CGFloat offsetY = height * ((self.numberOfItems / 2) - 2.5);
        
        self.initialOffset = CGPointMake(offsetX, offsetY);
        self.targetOffset = CGPointMake(offsetX, offsetY - indexDiff * height);
    }
    
    [self.collectionView setContentOffset:self.initialOffset animated:NO];
    
    self.endDraggingOffset = CGPointZero;
    self.endScrollingOffset = CGPointZero;

    self.timeIntervalBeforeStopDecelarating = 0.0;
}

- (void)touchTrackerDidBeginNewTrack:(ORKTouchAbilityTouchTracker *)touchTracker {
    self.timeIntervalBeforeStopDecelarating = 0.0;
    [super touchTrackerDidBeginNewTrack:touchTracker];
}

- (void)touchTrackerDidCompleteNewTracks:(ORKTouchAbilityTouchTracker *)touchTracker {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super touchTrackerDidCompleteNewTracks:touchTracker];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (![cell.contentView viewWithTag:10000]) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:42 weight:UIFontWeightBold];
        
        [cell.contentView addSubview:label];
        label.frame = cell.contentView.bounds;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.tag = 10000;
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:10000];
    label.text = [NSString stringWithFormat:@"%@", @(indexPath.item + 1)];
    
    
    if (indexPath.item == self.initialItem) {
        cell.contentView.backgroundColor = self.tintColor;
        label.textColor = [UIColor whiteColor];
    } else if (indexPath.item % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        label.textColor = [UIColor blackColor];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blackColor];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.targetItem) {
        self.success = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.targetItem) {
        self.success = NO;
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    self.endDraggingOffset = scrollView.contentOffset;
    self.endScrollingOffset = *targetContentOffset;
    
    CGFloat velocityX = fabs(velocity.x);
    CGFloat velocityY = fabs(velocity.y);
    
    CGFloat v = self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal ? velocityX : velocityY;

    if (v <= 0) {
        self.timeIntervalBeforeStopDecelarating = 0.0;
    } else {
        self.timeIntervalBeforeStopDecelarating = (log(v) * 0.5) + 2.3;
    }
}

@end
