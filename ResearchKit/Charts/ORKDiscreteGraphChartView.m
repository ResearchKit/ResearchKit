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

#import "ORKChartTypes.h"
#import "ORKGraphChartView_Internal.h"

#import "ORKHelpers_Internal.h"


#if TARGET_INTERFACE_BUILDER

@interface ORKIBDiscreteGraphChartViewDataSource : ORKIBValueRangeGraphChartViewDataSource

+ (instancetype)sharedInstance;

@end


@implementation ORKIBDiscreteGraphChartViewDataSource

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self class] new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.plotPoints = @[
                            @[
                                [[ORKValueRange alloc] initWithMinimumValue:0 maximumValue: 2],
                                [[ORKValueRange alloc] initWithMinimumValue:1 maximumValue: 4],
                                [[ORKValueRange alloc] initWithMinimumValue:2 maximumValue: 6],
                                [[ORKValueRange alloc] initWithMinimumValue:3 maximumValue: 8],
                                [[ORKValueRange alloc] initWithMinimumValue:5 maximumValue:10],
                                [[ORKValueRange alloc] initWithMinimumValue:8 maximumValue:13]
                              ],
                            @[
                                [[ORKValueRange alloc] initWithValue:1],
                                [[ORKValueRange alloc] initWithMinimumValue:2 maximumValue:6],
                                [[ORKValueRange alloc] initWithMinimumValue:3 maximumValue:10],
                                [[ORKValueRange alloc] initWithMinimumValue:5 maximumValue:11],
                                [[ORKValueRange alloc] initWithMinimumValue:7 maximumValue:13],
                                [[ORKValueRange alloc] initWithMinimumValue:10 maximumValue:13]
                              ]
                            ];
    }
    return self;
}

@end

#endif


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
    NSUInteger pointCount = self.dataPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        ORKValueRange *dataPointValue = self.dataPoints[plotIndex][pointIndex];
        if (!dataPointValue.isUnset && !dataPointValue.isEmptyRange) {
            CAShapeLayer *lineLayer = graphLineLayer();
            lineLayer.strokeColor = [self colorForPlotIndex:plotIndex].CGColor;
            lineLayer.lineWidth = ORKGraphChartViewPointAndLineWidth;
            
            [self.plotView.layer addSublayer:lineLayer];
            [self.lineLayers[plotIndex] addObject:[NSMutableArray arrayWithObject:lineLayer]];
        }
    }
}

- (void)layoutLineLayersForPlotIndex:(NSInteger)plotIndex {
    NSUInteger lineLayerIndex = 0;
    CGFloat positionOnXAxis = ORKCGFloatInvalidValue;
    ORKValueRange *positionOnYAxis = nil;
    NSUInteger pointCount = self.yAxisPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        
        ORKValueRange *dataPointValue = self.dataPoints[plotIndex][pointIndex];
        
        if (!dataPointValue.isUnset && !dataPointValue.isEmptyRange) {
            
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            
            positionOnXAxis = xAxisPoint(pointIndex, self.numberOfXAxisPoints, self.plotView.bounds.size.width);
            positionOnXAxis += [self xOffsetForPlotIndex:plotIndex];
            positionOnYAxis = self.yAxisPoints[plotIndex][pointIndex];
            
            [linePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue)];
            [linePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue)];
            
            CAShapeLayer *lineLayer = self.lineLayers[plotIndex][lineLayerIndex][0];
            lineLayer.path = linePath.CGPath;
            lineLayerIndex++;
        }
    }
}

- (CGFloat)xOffsetForPlotIndex:(NSInteger)plotIndex {
    return xOffsetForPlotIndex(plotIndex, [self numberOfPlots], ORKGraphChartViewPointAndLineWidth);
}
    
- (CGFloat)snappedXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    return [super snappedXPosition:xPosition plotIndex:plotIndex] + [self xOffsetForPlotIndex:plotIndex];
}
    
- (NSInteger)pointIndexForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    return [super pointIndexForXPosition:xPosition - [self xOffsetForPlotIndex:plotIndex] plotIndex:plotIndex];
    }
    
- (BOOL)isXPositionSnapped:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    return [super isXPositionSnapped:xPosition - [self xOffsetForPlotIndex:plotIndex] plotIndex:plotIndex];
}

#pragma mark - Interface Builder designable

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
#if TARGET_INTERFACE_BUILDER
    self.dataSource = [ORKIBDiscreteGraphChartViewDataSource sharedInstance];
#endif
}

@end
