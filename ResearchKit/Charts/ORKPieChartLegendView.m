/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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


#import "ORKPieChartLegendView.h"
#import "ORKPieChartView_Internal.h"
#import "ORKPieChartLegendCell.h"
#import "ORKCenteredCollectionViewLayout.h"
#import "ORKHelpers.h"


@implementation ORKPieChartLegendView {
    __weak ORKPieChartView *_parentPieChartView;
    ORKPieChartLegendCell *_sizingCell;
    CGFloat _sumOfValues;
}

- (instancetype)initWithFrame:(CGRect)frame
         collectionViewLayout:(UICollectionViewLayout *)collectionViewLayout {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithParentPieChartView:nil];
    return self;
}

- (instancetype)initWithParentPieChartView:(ORKPieChartView *)parentPieChartView {
    ORKCenteredCollectionViewLayout *centeredCollectionViewLayout = [[ORKCenteredCollectionViewLayout alloc] init];
    centeredCollectionViewLayout.estimatedItemSize = CGSizeMake(100.0, 30.0);
    self = [super initWithFrame:CGRectZero collectionViewLayout:centeredCollectionViewLayout];
    if (self) {
        _parentPieChartView = parentPieChartView;
        _sumOfValues = 0;
        NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
        for (NSInteger idx = 0; idx < numberOfSegments; idx++) {
            CGFloat value = [_parentPieChartView.dataSource pieChartView:_parentPieChartView valueForSegmentAtIndex:idx];
            _sumOfValues += value;
        }
        
        [self registerClass:[ORKPieChartLegendCell class] forCellWithReuseIdentifier:@"cell"];

        _sizingCell = [[ORKPieChartLegendCell alloc] initWithFrame:CGRectZero];

        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.dataSource = self;
        self.delegate = self;
        
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
    }
    return self;
}

- (void)setLabelFont:(UIFont *)labelFont {
    _labelFont = labelFont;
    _sizingCell.titleLabel.font = _labelFont;
    [self reloadData];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeMake(UIViewNoIntrinsicMetric, [self.collectionViewLayout collectionViewContentSize].height);
    return size;
}

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    NSArray<UICollectionViewCell *> *sortedCells = [self.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *cell1, UICollectionViewCell *cell2) {
        return cell1.tag > cell2.tag;
    }];
    NSUInteger cellCount = sortedCells.count;
    NSTimeInterval interAnimationDelay = 0.05;
    NSTimeInterval singleAnimationDuration = animationDuration - (interAnimationDelay * (cellCount - 1));
    if (singleAnimationDuration < 0) {
        interAnimationDelay = 0;
        singleAnimationDuration = animationDuration;
    }
    for (NSUInteger idx = 0; idx < cellCount; idx++) {
        UICollectionViewCell *cell = sortedCells[idx];
        cell.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:singleAnimationDuration
                              delay:interAnimationDelay * idx
                            options:(UIViewAnimationOptions)0
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;
                         } completion:nil];
    }
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat value = [_parentPieChartView.dataSource pieChartView:_parentPieChartView valueForSegmentAtIndex:indexPath.item];
    NSString *title = [_parentPieChartView.dataSource pieChartView:_parentPieChartView titleForSegmentAtIndex:indexPath.item];
    
    ORKPieChartLegendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.titleLabel.text = title;
    cell.titleLabel.font = _labelFont;
    cell.dotView.backgroundColor = [_parentPieChartView colorForSegmentAtIndex:indexPath.item];
    
    cell.accessibilityLabel = title;
    cell.accessibilityValue = [NSString stringWithFormat:@"%0.0f%%", (value < .01) ? 1 : value / _sumOfValues * 100];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    _sizingCell.titleLabel.text = [_parentPieChartView.dataSource pieChartView:_parentPieChartView titleForSegmentAtIndex:indexPath.item];
    CGSize size = [_sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6.0;
}

@end
