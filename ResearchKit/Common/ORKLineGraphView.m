/*
  ORKLineGraphView.m 
  ORKAppCore 
 
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

 
#import "ORKLineGraphView.h"
#import "ORKGraphView_Internal.h"
#import <ResearchKit/ORKCircleView.h>
#import <ResearchKit/ORKAxisView.h>
#import "ORKHelpers.h"


@interface ORKLineGraphView ()

@property (nonatomic, strong) NSMutableArray *fillLayers;

@end


@implementation ORKLineGraphView

#pragma mark - Init

- (void)sharedInit {
    [super sharedInit];
    self.fillLayers = [NSMutableArray new];
}

#pragma mark - Drawing

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    return [self numberOfValidValues] > 1;
}

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path {
    CAShapeLayer *layer = [super plotLineLayerForPlotIndex:plotIndex withPath:path];
    layer.lineWidth = self.isLandscapeMode ? 3.0 : 2.0;
    return layer;
}

- (void)drawLinesForPlotIndex:(NSInteger)plotIndex {
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    CGFloat positionOnXAxis = CGFLOAT_MAX;
    ORKRangePoint *positionOnYAxis = nil;
    BOOL emptyDataPresent = NO;
    
    for (NSUInteger i=0; i<self.yAxisPoints.count; i++) {
        
        if ([self.dataPoints[i] isEmpty]) {
            emptyDataPresent = YES;
            continue;
        }
            
        UIBezierPath *plotLinePath = [UIBezierPath bezierPath];
        
        if (positionOnXAxis != CGFLOAT_MAX) {
            // Previous point exists.
            [plotLinePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
            if ([fillPath isEmpty]) {
                [fillPath moveToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotsView.frame))];
            }
            [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        }
        
        positionOnXAxis = [self.xAxisPoints[i] floatValue];
        positionOnYAxis = (ORKRangePoint *)self.yAxisPoints[i];
        
        if ([plotLinePath isEmpty]) {
            emptyDataPresent = NO;
            continue;
        }
        
        [plotLinePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
        CAShapeLayer *plotLineLayer = [self plotLineLayerForPlotIndex:plotIndex withPath:plotLinePath.CGPath];
        
        if (emptyDataPresent) {
            plotLineLayer.lineDashPattern = self.isLandscapeMode ? @[@12, @7] : @[@12, @6];
            emptyDataPresent = NO;
        }
        
        [self.plotsView.layer addSublayer:plotLineLayer];
        [self.pathLines addObject:plotLineLayer];
    }
    
    [fillPath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotsView.frame))];
    
    CAShapeLayer *fillPathLayer = [CAShapeLayer layer];
    fillPathLayer.path = fillPath.CGPath;
    fillPathLayer.fillColor = (plotIndex == 0) ? [self.tintColor colorWithAlphaComponent:0.4].CGColor : [self.referenceLineColor colorWithAlphaComponent:0.2].CGColor;
    [self.plotsView.layer addSublayer:fillPathLayer];
    
    if (self.shouldAnimate) {
        fillPathLayer.opacity = 0;
    }
    
    [self.fillLayers addObject:fillPathLayer];
}

#pragma mark - Graph Calculations

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition {
    CGFloat value = [super valueForCanvasXPosition:xPosition];
    NSUInteger positionIndex = 0;
    
    if (value == NSNotFound){
        for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
            CGFloat xAxisPointVal = [self.xAxisPoints[positionIndex] floatValue];
            if (xAxisPointVal > xPosition) {
                break;
            }
        }
        
        NSInteger nextValidIndex = [self nextValidPositionIndexForPosition:positionIndex];
        NSInteger prevValidIndex = [self previousValidPositionIndexForPosition:positionIndex];
        
        CGFloat x1 = [(NSNumber *)self.xAxisPoints[prevValidIndex] floatValue];
        CGFloat x2 = [(NSNumber *)self.xAxisPoints[nextValidIndex] floatValue];
        
        CGFloat y1 = [(ORKRangePoint *)self.dataPoints[prevValidIndex] minimumValue];
        CGFloat y2 = [(ORKRangePoint *)self.dataPoints[nextValidIndex] minimumValue];
        
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
    
    CGFloat x1 = [self.xAxisPoints[previousValidIndex] floatValue];
    CGFloat x2 = [self.xAxisPoints[nextValidIndex] floatValue];
    
    CGFloat y1 = [(ORKRangePoint *)self.yAxisPoints[previousValidIndex] minimumValue];
    CGFloat y2 = [(ORKRangePoint *)self.yAxisPoints[nextValidIndex] minimumValue];
    
    CGFloat slope = (y2 - y1)/(x2 - x1);
    
    //  (y2 - y3)/(x2 - x3) = m
    CGFloat canvasYPosition = y2 - (slope * (x2 - xPosition));
    
    return canvasYPosition;
}


- (NSInteger)previousValidPositionIndexForPosition:(NSInteger)positionIndex {
    NSInteger validPosition = positionIndex - 1;
    while (validPosition > 0) {
        if ([(ORKRangePoint *)self.dataPoints[validPosition] minimumValue] != NSNotFound) {
            break;
        }
        validPosition --;
    }
    return validPosition;
}

#pragma mark - Animations

- (CGFloat)animateLayersSequentially {
    CGFloat delay = [super animateLayersSequentially];
    for (NSUInteger i=0; i<self.fillLayers.count; i++) {
        CAShapeLayer *layer = self.fillLayers[i];
        [self animateLayer:layer withAnimationType:ORKGraphAnimationTypeFade startDelay:delay];
        delay += GrowAnimationDuration;
    }
    return delay;
}

@end
