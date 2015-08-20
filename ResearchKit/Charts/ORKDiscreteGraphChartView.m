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

 
#import "ORKDiscreteGraphChartView.h"
#import "ORKGraphChartView_Internal.h"
#import "ORKHelpers.h"
#import "ORKRangedPoint.h"


@implementation ORKDiscreteGraphChartView

#pragma mark - Init

- (void)sharedInit {
    [super sharedInit];
    _drawsConnectedRanges = YES;
}

- (void)setDrawsConnectedRanges:(BOOL)drawsConnectedRanges {
    _drawsConnectedRanges = drawsConnectedRanges;
    [super updateLineLayers];
    [super updatePointLayers];
    [super layoutLineLayers];
    [super layoutPointLayers];
}

#pragma mark - Draw

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    return [self numberOfValidValuesForPlotIndex:plotIndex] > 0 && _drawsConnectedRanges;
}

- (void)updateLineLayersForPlotIndex:(NSInteger)plotIndex {
    for (NSUInteger i = 0; i < ((NSArray *)self.dataPoints[plotIndex]).count; i++) {
        ORKRangedPoint *dataPointValue = self.dataPoints[plotIndex][i];
        if (!dataPointValue.isUnset && !dataPointValue.hasEmptyRange) {
            CAShapeLayer *lineLayer = graphLineLayer();
            lineLayer.strokeColor = [self colorForplotIndex:plotIndex].CGColor;
            lineLayer.lineWidth = ORKGraphChartViewPointAndLineSize;
            
            [self.plotView.layer addSublayer:lineLayer];
            [self.lineLayers[plotIndex] addObject:lineLayer];
        }
    }
}

- (void)layoutLineLayersForPlotIndex:(NSInteger)plotIndex {
    NSUInteger lineLayerIndex = 0;
    CGFloat positionOnXAxis = ORKCGFloatInvalidValue;
    ORKRangedPoint *positionOnYAxis = nil;
    for (NSUInteger i = 0; i < ((NSArray *)self.yAxisPoints[plotIndex]).count; i++) {
        
        ORKRangedPoint *dataPointValue = self.dataPoints[plotIndex][i];
        
        if (!dataPointValue.isUnset && !dataPointValue.hasEmptyRange) {
            
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            
            positionOnXAxis = xAxisPoint(i, self.numberOfXAxisPoints, self.plotView.bounds.size.width);
            positionOnXAxis += [self offsetForPlotIndex:plotIndex];
            positionOnYAxis = ((ORKRangedPoint *)self.yAxisPoints[plotIndex][i]);
            
            [linePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
            [linePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue)];
            
            CAShapeLayer *lineLayer = self.lineLayers[plotIndex][lineLayerIndex];
            lineLayer.path = linePath.CGPath;
            lineLayerIndex++;
        }
    }
}

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex {
    CGFloat pointWidth = ORKGraphChartViewPointAndLineSize;
    
    NSInteger numberOfPlots = [self numberOfPlots];
    
    CGFloat offset = 0;
    
    if (numberOfPlots % 2 == 0) {
        // Even
        offset = (plotIndex - numberOfPlots / 2 + 0.5) * pointWidth;
    } else {
        // Odd
        offset = (plotIndex - numberOfPlots / 2) * pointWidth;
    }
    
    return offset;
}

#pragma mark - Graph Calculations

- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition {
    BOOL snapped = [self isXPositionSnapped:xPosition];
    CGFloat canvasYPosition = 0;
    if (snapped) {
        NSInteger positionIndex = [self yAxisPositionIndexForXPosition:xPosition];
        canvasYPosition = ((ORKRangedPoint *)self.yAxisPoints[0][positionIndex-1]).maximumValue;
    }
    return canvasYPosition;
}

#pragma mark - Animation

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition {
    CGFloat scrubbingValue = [self valueForCanvasXPosition:xPosition];
    if (scrubbingValue == ORKCGFloatInvalidValue) {
        [self setScrubberLineAccessoriesHidden:YES];
    }
    [UIView animateWithDuration:ORKGraphChartViewScrubberMoveAnimationDuration animations:^{
       self.scrubberLine.center = CGPointMake(xPosition + ORKGraphChartViewLeftPadding, self.scrubberLine.center.y);
    } completion:^(BOOL finished) {
       if (scrubbingValue != ORKCGFloatInvalidValue) {
           [self setScrubberLineAccessoriesHidden:NO];
           [self updateScrubberLineAccessories:xPosition];
        }
    }];
}

@end
