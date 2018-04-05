/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
 
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

#import "ORKPieChartLegendCell.h"
#import "ORKPieChartLegendCollectionViewLayout.h"
#import "ORKPieChartView_Internal.h"

#import "ORKHelpers_Internal.h"


static const CGFloat MinimumInteritemSpacing = 10.0;
static const CGFloat MinimumLineSpacing = 6.0;
static NSString *const CellIdentifier = @"ORKPieChartLegendCell";

@implementation ORKPieChartLegendView {
    __weak ORKPieChartView *_parentPieChartView;
    ORKPieChartLegendCell *_sizingCell;
    CGFloat _sumOfValues;
}

- (instancetype)initWithFrame:(CGRect)frame
         collectionViewLayout:(UICollectionViewLayout *)collectionViewLayout {
    ORKThrowMethodUnavailableException();
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    ORKThrowMethodUnavailableException();
}
#pragma clang diagnostic pop

- (instancetype)initWithParentPieChartView:(ORKPieChartView *)parentPieChartView {
    ORKPieChartLegendCollectionViewLayout *pieChartLegendCollectionViewLayout = [[ORKPieChartLegendCollectionViewLayout alloc] init];
    pieChartLegendCollectionViewLayout.minimumInteritemSpacing = MinimumInteritemSpacing;
    pieChartLegendCollectionViewLayout.minimumLineSpacing = MinimumLineSpacing;
    pieChartLegendCollectionViewLayout.estimatedItemSize = CGSizeMake(100.0, 30.0);
    self = [super initWithFrame:CGRectZero collectionViewLayout:pieChartLegendCollectionViewLayout];
    if (self) {
        [self registerClass:[ORKPieChartLegendCell class] forCellWithReuseIdentifier:CellIdentifier];
        _sizingCell = [[ORKPieChartLegendCell alloc] initWithFrame:CGRectZero];
        
        _parentPieChartView = parentPieChartView;
        _sumOfValues = 0;
        NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
        for (NSInteger index = 0; index < numberOfSegments; index++) {
            // Numerical value
            CGFloat value = [_parentPieChartView.dataSource pieChartView:_parentPieChartView valueForSegmentAtIndex:index];
            _sumOfValues += value;
        }
        [self cacheCellSizes];

        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.dataSource = self;
        self.delegate = self;
        
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
    }
    return self;
}

- (NSArray<NSNumber *> *)_validIndexesWithReportedSegmentCount:(NSInteger)reportedSegmentCount {
    NSMutableArray<NSNumber *> *validIndexes = [NSMutableArray new];
    for (NSInteger currentIndex = 0; currentIndex < reportedSegmentCount; currentIndex++) {
        NSString *title = [_parentPieChartView.dataSource pieChartView:_parentPieChartView titleForSegmentAtIndex:currentIndex];
        if (title) {
            [validIndexes addObject:@(currentIndex)];
        }
    }
    return [validIndexes copy];
}

- (void)cacheCellSizes {
    _cellSizes = [NSMutableArray new];
    _totalCellWidth = 0;
    NSArray<NSNumber *> *validIndexes = [self _validIndexesWithReportedSegmentCount:[_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView]];
    for (NSNumber *indexNumber in validIndexes) {
        NSInteger index = indexNumber.integerValue;
        _sizingCell.titleLabel.text = [_parentPieChartView.dataSource pieChartView:_parentPieChartView titleForSegmentAtIndex:index];
        CGSize size = [_sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [_cellSizes addObject:[NSValue valueWithCGSize:size]];
        _totalCellWidth += size.width;
        if (index != validIndexes.count - 1) {
            _totalCellWidth += MinimumInteritemSpacing;
        }
    }
}

- (void)setLabelFont:(UIFont *)labelFont {
    _labelFont = labelFont;
    _sizingCell.titleLabel.font = _labelFont;
    [self cacheCellSizes];
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
    for (NSUInteger index = 0; index < cellCount; index++) {
        UICollectionViewCell *cell = sortedCells[index];
        cell.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:singleAnimationDuration
                              delay:interAnimationDelay * index
                            options:(UIViewAnimationOptions)0
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;
                         } completion:nil];
    }
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section == 0, @"Section cannot be non-zero on an ORKPieChartView.");
    
    NSArray<NSNumber *> *validIndexes = [self _validIndexesWithReportedSegmentCount:[_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView]];
    
    NSAssert(validIndexes.count > indexPath.item, @"A valid index path has not been found for item: %ld", (long)indexPath.item);
    
    NSInteger correctedIndex = validIndexes[indexPath.item].integerValue;
    NSString *title = [_parentPieChartView.dataSource pieChartView:_parentPieChartView titleForSegmentAtIndex:correctedIndex];
    CGFloat value = [_parentPieChartView.dataSource pieChartView:_parentPieChartView valueForSegmentAtIndex:correctedIndex];
    ORKPieChartLegendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.tag = correctedIndex;
    cell.titleLabel.text = title;
    cell.titleLabel.font = _labelFont;
    cell.dotView.backgroundColor = [_parentPieChartView colorForSegmentAtIndex:correctedIndex];
    
    cell.accessibilityLabel = title;
    cell.accessibilityValue = [NSString stringWithFormat:@"%0.0f%%", (value < .01) ? 1 : value / _sumOfValues * 100];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfReportedCells = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
    return (NSInteger)[self _validIndexesWithReportedSegmentCount:numberOfReportedCells].count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = _cellSizes[indexPath.row].CGSizeValue;
    return size;
}

@end
