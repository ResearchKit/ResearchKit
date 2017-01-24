/*
 Copyright (c) 2015, Ramsundar Shandilya.
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


#import "ORKBarGraphChartView.h"

#import "ORKGraphChartView_Internal.h"

#import "ORKHelpers_Internal.h"


#if TARGET_INTERFACE_BUILDER

@interface ORKIBBarGraphChartViewDataSource : ORKIBGraphChartViewDataSource <ORKValueStackGraphChartViewDataSource>

+ (instancetype)sharedInstance;

@end


@implementation ORKIBBarGraphChartViewDataSource

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
                                [[ORKValueStack alloc] initWithStackedValues:@[@4, @6]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@2, @4, @4]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@2, @6, @3, @6]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@3, @8, @10, @12]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@5, @10, @12, @8]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@8, @13, @18]],
                                ],
                            @[
                                [[ORKValueStack alloc] initWithStackedValues:@[@14]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@6, @6]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@3, @10, @12]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@5, @11, @14]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@7, @13, @20]],
                                [[ORKValueStack alloc] initWithStackedValues:@[@10, @13, @25]],
                                ]
                            ];
    }
    return self;
}

- (ORKValueStack *)graphChartView:(ORKGraphChartView *)graphChartView dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    return self.plotPoints[plotIndex][pointIndex];
}

@end

#endif

static const CGFloat BarWidth = 10.0;


@interface ORKBarGraphChartView ()

@property (nonatomic) NSMutableArray<NSMutableArray<ORKValueStack *> *> *dataPoints; // Actual data

@property (nonatomic) NSMutableArray<NSMutableArray<ORKValueStack *> *> *yAxisPoints; // Normalized for the plot view height

@end


@implementation ORKBarGraphChartView

@dynamic dataSource;
@dynamic dataPoints;
@dynamic yAxisPoints;

#pragma mark - Draw

- (ORKValueStack *)dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    return [self.dataSource graphChartView:self dataPointForPointIndex:pointIndex plotIndex:plotIndex];
}

- (ORKValueStack *)dummyPoint {
    return [ORKValueStack new];
}

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    return YES;
}

- (NSMutableArray<ORKValueStack *> *)normalizedCanvasDataPointsForPlotIndex:(NSInteger)plotIndex canvasHeight:(CGFloat)viewHeight {
    NSMutableArray<ORKValueStack *> *normalizedDataPoints = [NSMutableArray new];
    
    if (plotIndex < self.dataPoints.count) {
        NSUInteger pointCount = self.dataPoints[plotIndex].count;
        for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
            
            NSMutableArray *normalizedDoubleStackValues = [NSMutableArray new];
            ORKValueStack *dataPointValue = self.dataPoints[plotIndex][pointIndex];
            
            if (!dataPointValue.isUnset) {
                double range = self.maximumValue - self.minimumValue;
                double sum = 0;
                for (NSNumber *value in dataPointValue.stackedValues) {
                    // normalizedDoubleStackValues holds absolute canvas y-positions corresponding to each point
                    // (rather than incremental y-positions as the dataPoints valueStacks hold).
                    // E.g. (canvas height = 100)
                    //      dataPoint valueStack = {10, 10, 20}
                    //        ->
                    //      normalized valueStack = {25, 50, 100}
                    sum += value.doubleValue;
                    double normalizedValue = (sum - self.minimumValue) / range * viewHeight;
                    normalizedValue = floor(viewHeight - normalizedValue);
                    
                    [normalizedDoubleStackValues addObject:@(normalizedValue)];
                }
            }
            [normalizedDataPoints addObject:[[ORKValueStack alloc] initWithStackedValues:normalizedDoubleStackValues]];
        }
    }
    
    return normalizedDataPoints;
}

- (void)calculateMinAndMaxValues {
    self.minimumValue = ORKDoubleInvalidValue;
    self.maximumValue = ORKDoubleInvalidValue;
    
    BOOL maximumValueProvided = NO;
    
    if ([self.dataSource respondsToSelector:@selector(minimumValueForGraphChartView:)]) {
        self.minimumValue = [self.dataSource minimumValueForGraphChartView:self];
    } else {
        self.minimumValue = 0;
    }
    
    if ([self.dataSource respondsToSelector:@selector(maximumValueForGraphChartView:)]) {
        self.maximumValue = [self.dataSource maximumValueForGraphChartView:self];
        maximumValueProvided = YES;
    }
    
    if (!maximumValueProvided) {
        NSInteger numberOfPlots = [self numberOfPlots];
        for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
            NSInteger numberOfPlotPoints = self.dataPoints[plotIndex].count;
            for (NSInteger pointIndex = 0; pointIndex < numberOfPlotPoints; pointIndex++) {
                ORKValueStack *point = self.dataPoints[plotIndex][pointIndex];
                if (!maximumValueProvided &&
                    point.totalValue != ORKDoubleInvalidValue &&
                    ((self.maximumValue == ORKDoubleInvalidValue) || (point.totalValue > self.maximumValue))) {
                    self.maximumValue = point.totalValue;
                }
            }
        }
    }
    
    if (self.maximumValue == ORKDoubleInvalidValue) {
        self.maximumValue = 0;
    }
}

- (UIColor *)colorForPlotIndex:(NSInteger)plotIndex subpointIndex:(NSInteger)subpointIndex totalSubpoints:(NSInteger)totalSubpoints {
    return ORKOpaqueColorWithReducedAlphaFromBaseColor([super colorForPlotIndex:plotIndex subpointIndex:subpointIndex totalSubpoints:(NSInteger)totalSubpoints], subpointIndex, totalSubpoints);
}

- (void)updateLineLayersForPlotIndex:(NSInteger)plotIndex {
    NSUInteger pointCount = self.dataPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        ORKValueStack *dataPointValue = self.dataPoints[plotIndex][pointIndex];
        NSMutableArray *lineLayers = [NSMutableArray new];
        if (!dataPointValue.isUnset) {
            NSUInteger numberOfStackedValues = dataPointValue.stackedValues.count;
            for (NSUInteger index = 0; index < numberOfStackedValues; index++) {
                CAShapeLayer *lineLayer = [CAShapeLayer layer];
                lineLayer.strokeColor = [self colorForPlotIndex:plotIndex subpointIndex:index totalSubpoints:numberOfStackedValues].CGColor;
                lineLayer.lineWidth = BarWidth;
                [self.plotView.layer addSublayer:lineLayer];
                [lineLayers addObject:lineLayer];
            }
        }
        [self.lineLayers[plotIndex] addObject:lineLayers];
    }
}

- (void)layoutLineLayersForPlotIndex:(NSInteger)plotIndex {
    NSUInteger lineLayerIndex = 0;
    double positionOnXAxis = ORKDoubleInvalidValue;
    ORKValueStack *positionsOnYAxis = nil;
    NSUInteger pointCount = self.yAxisPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        float previousYValue = self.plotView.bounds.size.height;

        ORKValueStack *dataPointValue = self.dataPoints[plotIndex][pointIndex];
        positionsOnYAxis = self.yAxisPoints[plotIndex][pointIndex];

        if (!dataPointValue.isUnset) {
            NSUInteger numberOfSubpoints = positionsOnYAxis.stackedValues.count;
            for (NSUInteger subpointIndex = 0; subpointIndex < numberOfSubpoints; subpointIndex++) {
                double positionOnYAxis = positionsOnYAxis.stackedValues[subpointIndex].doubleValue;
                UIBezierPath *linePath = [UIBezierPath bezierPath];
                
                double barHeight = fabs(positionOnYAxis - previousYValue);

                positionOnXAxis = xAxisPoint(pointIndex, self.numberOfXAxisPoints, self.plotView.bounds.size.width);
                positionOnXAxis += [self xOffsetForPlotIndex:plotIndex];
                
                [linePath moveToPoint:CGPointMake(positionOnXAxis, previousYValue + scalePixelAdjustment())];
                [linePath addLineToPoint:CGPointMake(positionOnXAxis, previousYValue + scalePixelAdjustment() - barHeight)];
                
                previousYValue = positionOnYAxis;
                
                CAShapeLayer *lineLayer = self.lineLayers[plotIndex][pointIndex][subpointIndex];
                lineLayer.path = linePath.CGPath;
                lineLayerIndex++;
            }
        }
    }
}

#pragma mark - Scrubbing

- (double)scrubbingValueForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex {
    return self.dataPoints[plotIndex][pointIndex].totalValue;
}

- (double)scrubbingYAxisPointForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex {
    return self.yAxisPoints[plotIndex][pointIndex].stackedValues.lastObject.doubleValue; // totalValue is not normalized to canvas coordinates
}

- (CGFloat)xOffsetForPlotIndex:(NSInteger)plotIndex {
    return xOffsetForPlotIndex(plotIndex, [self numberOfPlots], BarWidth);
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
    self.dataSource = [ORKIBBarGraphChartViewDataSource sharedInstance];
#endif
}


@end
