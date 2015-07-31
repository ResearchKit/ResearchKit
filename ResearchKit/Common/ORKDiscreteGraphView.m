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

 
#import "ORKDiscreteGraphView.h"
#import "ORKGraphView_Internal.h"
#import "ORKHelpers.h"
#import "ORKAxisView.h"
#import "ORKCircleView.h"


@implementation ORKDiscreteGraphView

#pragma mark - Init

- (void)sharedInit {
    [super sharedInit];
    self.shouldConnectRanges = YES;
}

#pragma mark - Draw

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    return [self numberOfValidValues] > 0 && self.shouldConnectRanges;
}

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path {
    CAShapeLayer *layer = [super plotLineLayerForPlotIndex:plotIndex withPath:path];
    layer.lineWidth = ORKGraphViewPointAndLineSize;
    return layer;
}

- (void)drawLinesForPlotIndex:(NSInteger)plotIndex {
    
    CGFloat positionOnXAxis = ORKCGFloatInvalidValue;
    ORKRangePoint *positionOnYAxis = nil;
    
    for (NSUInteger i=0; i<self.yAxisPoints.count; i++) {
        
        ORKRangePoint *dataPointVal = self.dataPoints[i];
        
        if (!dataPointVal.isEmpty && !dataPointVal.isRangeZero) {
            
            UIBezierPath *plotLinePath = [UIBezierPath bezierPath];
            
            positionOnXAxis = [self.xAxisPoints[i] floatValue];
            positionOnXAxis += [self offsetForPlotIndex:plotIndex];
            positionOnYAxis = ((ORKRangePoint *)self.yAxisPoints[i]);
            
            [plotLinePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
            [plotLinePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue)];
            
            CAShapeLayer *plotLineLayer = [self plotLineLayerForPlotIndex:plotIndex withPath:plotLinePath.CGPath];
            
            [self.plotsView.layer addSublayer:plotLineLayer];
            [self.pathLines addObject:plotLineLayer];
        }
    }
}

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex {
    CGFloat pointWidth = ORKGraphViewPointAndLineSize;
    
    NSInteger numberOfPlots = [self numberOfPlots];
    
    CGFloat offset = 0;
    
    if (numberOfPlots%2 == 0) {
        //Even
        offset = (plotIndex - numberOfPlots/2 + 0.5) * pointWidth;
    } else {
        //Odd
        offset = (plotIndex - numberOfPlots/2) * pointWidth;
    }
    
    return offset;
}

#pragma mark - Graph Calculations

- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition {
    BOOL snapped = [self.xAxisPoints containsObject:@(xPosition)];
    CGFloat canvasYPosition = 0;
    if (snapped) {
        NSInteger positionIndex = [self yAxisPositionIndexForXPosition:xPosition];
        canvasYPosition = ((ORKRangePoint *)self.yAxisPoints[positionIndex]).maximumValue;
    }
    return canvasYPosition;
}

#pragma mark - Animation

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition {
    CGFloat scrubbingValue = [self valueForCanvasXPosition:(xPosition)];
    if (scrubbingValue == ORKCGFloatInvalidValue) {
        [self setScrubberLineAccessoriesHidden: YES];
    }
    [UIView animateWithDuration:0.1 animations:^{
       self.scrubberLine.center = CGPointMake(xPosition + ORKGraphViewLeftPadding, self.scrubberLine.center.y);
    } completion:^(BOOL finished) {
       if (scrubbingValue != ORKCGFloatInvalidValue) {
           [self setScrubberLineAccessoriesHidden:NO];
           [self updateScrubberLineAccessories:xPosition];
        }
    }];
}

- (void)setScrubberLineAccessoriesHidden:(BOOL)hidden {
    self.scrubberLabel.hidden = hidden;
    self.scrubberThumbView.hidden = hidden;
}

@end
