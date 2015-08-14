/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.

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

 
#import "ORKLineGraphView.h"
#import "ORKGraphView_Internal.h"
#import "ORKCircleView.h"
#import "ORKAxisView.h"
#import "ORKHelpers.h"
#import "ORKRangedPoint.h"


@implementation ORKLineGraphView {
    NSMutableArray *_fillLayers;
}

#pragma mark - Init

- (void)sharedInit {
    [super sharedInit];
    _fillLayers = [NSMutableArray new];
}

#pragma mark - Drawing

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    return [self numberOfValidValuesForPlotIndex:plotIndex] > 1;
}

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path {
    CAShapeLayer *layer = [super plotLineLayerForPlotIndex:plotIndex withPath:path];
    layer.lineWidth = 2.0;
    return layer;
}

- (void)drawLinesForPlotIndex:(NSInteger)plotIndex {
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    CGFloat positionOnXAxis = ORKCGFloatInvalidValue;
    ORKRangedPoint *positionOnYAxis = nil;
    BOOL emptyDataPresent = NO;
    
    for (NSUInteger i = 0; i < ((NSArray *)self.yAxisPoints[plotIndex]).count; i++) {
        if (((ORKRangedPoint *)self.dataPoints[plotIndex][i]).isUnset) {
            emptyDataPresent = YES;
            continue;
        }
            
        UIBezierPath *plotLinePath = [UIBezierPath bezierPath];
        
        if (positionOnXAxis != ORKCGFloatInvalidValue) {
            // Previous point exists.
            [plotLinePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
            if ([fillPath isEmpty]) {
                [fillPath moveToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotView.frame))];
            }
            [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        }
        
        positionOnXAxis = xAxisPoint(i, self.numberOfXAxisPoints, self.plotView.bounds.size.width);
        positionOnYAxis = (ORKRangedPoint *)self.yAxisPoints[plotIndex][i];
        
        if ([plotLinePath isEmpty]) {
            emptyDataPresent = NO;
            continue;
        }
        
        [plotLinePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        CAShapeLayer *plotLineLayer = [self plotLineLayerForPlotIndex:plotIndex withPath:plotLinePath.CGPath];
        
        if (emptyDataPresent) {
            plotLineLayer.lineDashPattern = @[@12, @6];
            emptyDataPresent = NO;
        }
        
        [self.plotView.layer addSublayer:plotLineLayer];
        [self.pathLines addObject:plotLineLayer];
    }
    
    [fillPath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotView.frame))];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = fillPath.CGPath;
    fillLayer.fillColor = (plotIndex == 0) ? [self.tintColor colorWithAlphaComponent:0.4].CGColor : [self.referenceLineColor colorWithAlphaComponent:0.2].CGColor;
    [self.plotView.layer addSublayer:fillLayer];
    
    [_fillLayers addObject:fillLayer];
    
    if (self.shouldAnimate) {
        fillLayer.opacity = 0;
    }
}

#pragma mark - Graph Calculations

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition {
    CGFloat value = [super valueForCanvasXPosition:xPosition];
    NSUInteger positionIndex = 0;
    
    CGFloat viewWidth = self.plotView.bounds.size.width;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;

    if (value == ORKCGFloatInvalidValue) {
        for (positionIndex = 0; positionIndex < (numberOfXAxisPoints - 1); positionIndex++) {
            CGFloat xAxisPointValue = xAxisPoint(positionIndex, numberOfXAxisPoints, viewWidth);
            if (xAxisPointValue > xPosition) {
                break;
            }
        }
        
        NSInteger previousValidIndex = [self previousValidPositionIndexForPosition:positionIndex];
        NSInteger nextValidIndex = [self nextValidPositionIndexForPosition:positionIndex];
        
        CGFloat x1 = xAxisPoint(previousValidIndex, numberOfXAxisPoints, viewWidth);
        CGFloat x2 = xAxisPoint(nextValidIndex, numberOfXAxisPoints, viewWidth);
        
        CGFloat y1 = ((ORKRangedPoint *)self.dataPoints[0][previousValidIndex]).minimumValue;
        CGFloat y2 = ((ORKRangedPoint *)self.dataPoints[0][nextValidIndex]).minimumValue;
        
        if (y1 == ORKCGFloatInvalidValue || y2 == ORKCGFloatInvalidValue) {
            return ORKCGFloatInvalidValue;
        }

        CGFloat slope = (y2 - y1)/(x2 - x1);
        
        //  (y2 - y3)/(x2 - x3) = m
        value = y2 - (slope * (x2 - xPosition));
    }
    return value;
}

- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition {
    NSUInteger positionIndex = [self yAxisPositionIndexForXPosition:xPosition];
    NSInteger nextValidIndex = [self nextValidPositionIndexForPosition:positionIndex];
    NSInteger previousValidIndex = [self previousValidPositionIndexForPosition:positionIndex];
    
    CGFloat viewWidth = self.plotView.bounds.size.width;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;

    CGFloat x1 = xAxisPoint(previousValidIndex, numberOfXAxisPoints, viewWidth);
    CGFloat x2 = xAxisPoint(nextValidIndex, numberOfXAxisPoints, viewWidth);
    
    CGFloat y1 = ((ORKRangedPoint *)self.yAxisPoints[0][previousValidIndex]).minimumValue;
    CGFloat y2 = ((ORKRangedPoint *)self.yAxisPoints[0][nextValidIndex]).minimumValue;
        
    CGFloat slope = (y2 - y1)/(x2 - x1);
    
    //  (y2 - y3)/(x2 - x3) = m
    CGFloat canvasYPosition = y2 - (slope * (x2 - xPosition));
    
    return canvasYPosition;
}


- (NSInteger)previousValidPositionIndexForPosition:(NSInteger)positionIndex {
    NSInteger validPosition = positionIndex - 1;
    while (validPosition > 0) {
        if (((ORKRangedPoint *)self.dataPoints[0][validPosition]).minimumValue != ORKCGFloatInvalidValue) {
            break;
        }
        validPosition--;
    }
    return validPosition;
}

#pragma mark - Animations

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition {
    [UIView animateWithDuration:ORKGraphViewScrubberMoveAnimationDuration animations:^{
        self.scrubberLine.center = CGPointMake(xPosition + ORKGraphViewLeftPadding, self.scrubberLine.center.y);
        [self updateScrubberLineAccessories:xPosition];
    }];
}

- (CGFloat)animateLayersSequentially {
    CGFloat delay = [super animateLayersSequentially];
    for (NSUInteger i = 0; i < _fillLayers.count; i++) {
        CAShapeLayer *layer = _fillLayers[i];
        [self animateLayer:layer withAnimationType:ORKGraphAnimationTypeFade startDelay:delay];
        delay += ORKGraphViewGrowAnimationDuration;
    }
    return delay;
}

@end
