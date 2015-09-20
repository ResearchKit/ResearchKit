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

 
#import "ORKLineGraphChartView.h"
#import "ORKGraphChartView_Internal.h"
#import "ORKHelpers.h"
#import "ORKRangedPoint.h"


const CGFloat FillColorAlpha = 0.4;

@implementation ORKLineGraphChartView {
    NSMutableDictionary *_fillLayers;
}

#pragma mark - Init

- (void)sharedInit {
    [super sharedInit];
    _fillLayers = [NSMutableDictionary new];
}

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    return [self numberOfValidValuesForPlotIndex:plotIndex] > 1;
}

#pragma mark - Drawing

- (void)updatePlotColors {
    [super updatePlotColors];
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSUInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        UIColor *fillColor = [[self colorForplotIndex:plotIndex] colorWithAlphaComponent:FillColorAlpha];
        CAShapeLayer *fillLayer = _fillLayers[@(plotIndex)];
        fillLayer.fillColor = fillColor.CGColor;
    }
}

- (void)updateLineLayers {
    [_fillLayers.allValues makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_fillLayers removeAllObjects];
    [super updateLineLayers];
}

- (void)updateLineLayersForPlotIndex:(NSInteger)plotIndex {
    BOOL previousPointExists = NO;
    BOOL emptyDataPresent = NO;
    NSUInteger pointCount = self.dataPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        if (self.dataPoints[plotIndex][pointIndex].isUnset) {
            emptyDataPresent = YES;
            continue;
        }
        
        if (!previousPointExists) {
            previousPointExists = YES;
            emptyDataPresent = NO;
            continue;
        }
        
        CAShapeLayer *lineLayer = graphLineLayer();
        lineLayer.strokeColor = [self colorForplotIndex:plotIndex].CGColor;
        lineLayer.lineWidth = 2.0;
        
        if (emptyDataPresent) {
            lineLayer.lineDashPattern = @[@12, @6];
            emptyDataPresent = NO;
        }
        
        [self.plotView.layer addSublayer:lineLayer];
        [self.lineLayers[plotIndex] addObject:lineLayer];
    }
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.fillColor = [[self colorForplotIndex:plotIndex] colorWithAlphaComponent:0.4].CGColor;
    
    [self.plotView.layer addSublayer:fillLayer];
    _fillLayers[@(plotIndex)] = fillLayer;
}

- (void)layoutLineLayersForPlotIndex:(NSInteger)plotIndex {
    CAShapeLayer *fillLayer = _fillLayers[@(plotIndex)];
    
    if (fillLayer == nil) {
        // Skip for a nil fillLayer
        return;
    }
    
    NSUInteger lineLayerIndex = 0;
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    CGFloat positionOnXAxis = ORKCGFloatInvalidValue;
    ORKRangedPoint *positionOnYAxis = nil;
    BOOL previousPointExists = NO;
    NSUInteger pointCount = self.yAxisPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        if (self.dataPoints[plotIndex][pointIndex].isUnset) {
            continue;
        }
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        
        if (positionOnXAxis != ORKCGFloatInvalidValue) {
            previousPointExists = YES;
            [linePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
            if ([fillPath isEmpty]) {
                [fillPath moveToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotView.frame))];
            }
            [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        }
        
        positionOnXAxis = xAxisPoint(pointIndex, self.numberOfXAxisPoints, self.plotView.bounds.size.width);
        positionOnYAxis = self.yAxisPoints[plotIndex][pointIndex];
        
        if (!previousPointExists) {
            continue;
        }
        
        [linePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        
        CAShapeLayer *lineLayer = self.lineLayers[plotIndex][lineLayerIndex];
        lineLayer.path = linePath.CGPath;
        lineLayerIndex++;
    }
    
    [fillPath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotView.frame))];
        
    fillLayer.path = fillPath.CGPath;
}

#pragma mark - Graph Calculations

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    CGFloat value = [super valueForCanvasXPosition:xPosition plotIndex:plotIndex];
    
    CGFloat viewWidth = self.plotView.bounds.size.width;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;

    if (value == ORKCGFloatInvalidValue) {
        NSInteger pointIndex = 0;
        for (pointIndex = 0; pointIndex < (numberOfXAxisPoints - 1); pointIndex++) {
            CGFloat xAxisPointValue = xAxisPoint(pointIndex, numberOfXAxisPoints, viewWidth);
            if (xAxisPointValue > xPosition) {
                break;
            }
        }
        
        NSInteger previousValidIndex = [self previousValidPointIndexForPointIndex:pointIndex plotIndex:plotIndex];
        NSInteger nextValidIndex = [self nextValidPointIndexForPointIndex:pointIndex plotIndex:plotIndex];
        
        CGFloat x1 = xAxisPoint(previousValidIndex, numberOfXAxisPoints, viewWidth);
        CGFloat x2 = xAxisPoint(nextValidIndex, numberOfXAxisPoints, viewWidth);
        
        CGFloat y1 = self.dataPoints[plotIndex][previousValidIndex].minimumValue;
        CGFloat y2 = self.dataPoints[plotIndex][nextValidIndex].minimumValue;
        
        if (y1 == ORKCGFloatInvalidValue || y2 == ORKCGFloatInvalidValue) {
            return ORKCGFloatInvalidValue;
        }

        CGFloat slope = (y2 - y1)/(x2 - x1);
        
        //  (y2 - y3)/(x2 - x3) = m
        value = y2 - (slope * (x2 - xPosition));
    }
    return value;
}

- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    NSInteger pointIndex = [self pointIndexForXPosition:xPosition];
    NSInteger nextValidIndex = [self nextValidPointIndexForPointIndex:pointIndex plotIndex:plotIndex];
    NSInteger previousValidIndex = [self previousValidPointIndexForPointIndex:pointIndex plotIndex:plotIndex];
    
    CGFloat viewWidth = self.plotView.bounds.size.width;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;

    CGFloat x1 = xAxisPoint(previousValidIndex, numberOfXAxisPoints, viewWidth);
    CGFloat x2 = xAxisPoint(nextValidIndex, numberOfXAxisPoints, viewWidth);
    
    CGFloat y1 = self.yAxisPoints[plotIndex][previousValidIndex].minimumValue;
    CGFloat y2 = self.yAxisPoints[plotIndex][nextValidIndex].minimumValue;
        
    CGFloat slope = (y2 - y1)/(x2 - x1);
    
    //  (y2 - y3)/(x2 - x3) = m
    CGFloat canvasYPosition = y2 - (slope * (x2 - xPosition));
    
    return canvasYPosition;
}

- (NSInteger)nextValidPointIndexForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    NSUInteger validPosition = pointIndex;
    
    NSUInteger pointCountMinusOne = (self.dataPoints[plotIndex].count - 1);
    while (validPosition < pointCountMinusOne) {
        if (self.dataPoints[plotIndex][validPosition].maximumValue != ORKCGFloatInvalidValue) {
            break;
        }
        validPosition++;
    }
    
    return validPosition;
}

- (NSInteger)previousValidPointIndexForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    NSInteger validPosition = pointIndex - 1;
    while (validPosition > 0) {
        if (self.dataPoints[plotIndex][validPosition].minimumValue != ORKCGFloatInvalidValue) {
            break;
        }
        validPosition--;
    }
    return validPosition;
}

#pragma mark - Animations

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    [_fillLayers enumerateKeysAndObjectsUsingBlock:^(id key, CAShapeLayer *fillLayer, BOOL *stop) {
        [fillLayer removeAllAnimations];
        fillLayer.opacity = 0;
    }];
    
    [super animateWithDuration:animationDuration];
}

- (void)animateLayersSequentiallyWithDuration:(NSTimeInterval)duration {
    [super animateLayersSequentiallyWithDuration:duration];
    
    [_fillLayers enumerateKeysAndObjectsUsingBlock:^(id key, CAShapeLayer *layer, BOOL *stop) {
        [self animateLayer:layer
                   keyPath:@"opacity"
                  duration:duration * (1.0 / 3.0)
                startDelay:duration * (2.0 / 3.0)
            timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    }];
}

@end
