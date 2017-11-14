/*
 Copyright (c) 2015, James Cox. All rights reserved.
 Copyright (c) 2016, Ricardo Sánchez-Sáez.

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


#import "ORKPieChartLegendCollectionViewLayout.h"

#import "ORKPieChartLegendView.h"


@interface ORKPieChartLegendCollectionViewLayout ()

@property (nonatomic, readonly) ORKPieChartLegendView *collectionView;

@end


@implementation ORKPieChartLegendCollectionViewLayout

@dynamic collectionView;

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *attributesArray = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        attributes.frame = [self layoutAttributesForItemAtIndexPath:attributes.indexPath].frame;
    }
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *currentItemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    NSInteger numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section];
    
    // Spread items evenly between rows
    NSInteger numberOfRows = ceil(self.collectionView.totalCellWidth / self.collectionView.bounds.size.width);
    NSInteger numberOfItemsPerRow = ceil((float)numberOfItems / numberOfRows);
    
    // Calculate the row in which the current item sits
    NSInteger currentItemIndex = indexPath.row;
    NSInteger currentItemRow = currentItemIndex / numberOfItemsPerRow;
    
    // Adjust the Y position of the current item to the corresponding row
    CGRect currentItemFrame = currentItemAttributes.frame;
    currentItemFrame.origin.y = currentItemRow * (currentItemFrame.size.height + self.minimumLineSpacing); // Assume all items have the same height
    
    // Calculate the X position of the current item according to the width of preceding items in the same row
    CGFloat xPosition = 0;
    NSInteger currentRowItemIndex = currentItemRow * numberOfItemsPerRow;
    NSInteger currentRowLastItemIndex = MIN(currentRowItemIndex + numberOfItemsPerRow - 1, numberOfItems - 1);
    while (currentRowItemIndex < currentItemIndex) {
        xPosition += self.collectionView.cellSizes[currentRowItemIndex].CGSizeValue.width + self.minimumInteritemSpacing;
        currentRowItemIndex++;
    }
    currentItemFrame.origin.x = xPosition;
    
    // Adjust the frame according to the trailing padding of the current rown so all the items gather around the center
    while (currentRowItemIndex < currentRowLastItemIndex) {
        xPosition += self.collectionView.cellSizes[currentRowItemIndex].CGSizeValue.width + self.minimumInteritemSpacing;
        currentRowItemIndex++;
    }
    CGFloat currentRowLastItemMaxXPosition = xPosition + self.collectionView.cellSizes[currentRowItemIndex].CGSizeValue.width;
    CGFloat currentRowTrailingPadding = self.collectionView.bounds.size.width - currentRowLastItemMaxXPosition;
    currentItemFrame = CGRectOffset(currentItemFrame, currentRowTrailingPadding * 0.5, 0);
    
    currentItemAttributes.frame = currentItemFrame;

    return currentItemAttributes;
}

@end
