/*
 Copyright (c) 2015, James Cox. All rights reserved.

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


#import "ORKGraphChartView.h"
#import "ORKHelpers.h"
#import "ORKChartTypes.h"


@class ORKXAxisView;

typedef NS_ENUM(NSUInteger, ORKGraphAnimationType) {
    ORkGraphAnimationTypeNone,
    ORKGraphAnimationTypeFade,
    ORKGraphAnimationTypeGrow,
    ORKGraphAnimationTypePop
};

extern const CGFloat ORKGraphChartViewLeftPadding;
extern const CGFloat ORKGraphChartViewPointAndLineWidth;
extern const CGFloat ORKGraphChartViewScrubberMoveAnimationDuration;
extern const CGFloat ORKGraphChartViewAxisTickLength;
extern const CGFloat ORKGraphChartViewYAxisTickPadding;


ORK_INLINE CGFloat scalePixelAdjustment() {
    return (1.0 / [UIScreen mainScreen].scale);
}

ORK_INLINE CAShapeLayer *graphLineLayer() {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.opacity = 1.0;
    return lineLayer;
}

ORK_INLINE CGFloat xAxisPoint(NSInteger pointIndex, NSInteger numberOfXAxisPoints, CGFloat canvasWidth) {
    return floor((canvasWidth / MAX(1, numberOfXAxisPoints - 1)) * pointIndex);
}

ORK_INLINE UIColor *opaqueColorWithReducedAlphaFromBaseColor(UIColor *baseColor, NSUInteger colorIndex, NSUInteger totalColors) {
    UIColor *color = baseColor;
    if (totalColors > 1) {
        CGFloat red = 0.0;
        CGFloat green = 0.0;
        CGFloat blue = 0.0;
        CGFloat alpha = 0.0;
        if ([baseColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
            // Avoid a pure transparent color (alpha = 0)
            CGFloat targetAlphaFactor = ((1.0 / totalColors) * colorIndex);
            return [UIColor colorWithRed:red + ((1.0 - red) * targetAlphaFactor)
                                   green:green + ((1.0 - green) * targetAlphaFactor)
                                    blue:blue + ((1.0 - blue) * targetAlphaFactor)
                                   alpha:alpha];
        }
    }
    return color;
}

ORK_INLINE CGFloat xOffsetForPlotIndex(NSInteger plotIndex, NSInteger numberOfPlots, CGFloat plotWidth) {
    CGFloat offset = 0;
    if (numberOfPlots % 2 == 0) {
        // Even
        offset = (plotIndex - numberOfPlots / 2 + 0.5) * plotWidth;
    } else {
        // Odd
        offset = (plotIndex - numberOfPlots / 2) * plotWidth;
    }
    return offset;
}

#if TARGET_INTERFACE_BUILDER
@interface ORKIBSampleDiscreteGraphDataSource : NSObject <ORKGraphChartViewDataSource>
@property (nonatomic, strong, nullable) NSArray <NSArray *> *plotPoints;
@end

@interface ORKIBSampleLineGraphDataSource : NSObject <ORKGraphChartViewDataSource>
@property (nonatomic, strong, nullable) NSArray <NSArray *> *plotPoints;
@end
#endif

@interface ORKGraphChartView ()

@property (nonatomic) NSMutableArray<NSMutableArray<NSMutableArray<CAShapeLayer *> *> *> *lineLayers;

@property (nonatomic) NSInteger numberOfXAxisPoints;

@property (nonatomic) NSMutableArray<NSMutableArray<NSObject<ORKValueCollectionType> *> *> *dataPoints; // Actual data

@property (nonatomic) NSMutableArray<NSMutableArray<NSObject<ORKValueCollectionType> *> *> *yAxisPoints; // Normalized for the plot view height

@property (nonatomic) UIView *plotView; // Holds the plots

@property (nonatomic) UIView *scrubberLine;

@property (nonatomic) BOOL scrubberAccessoryViewsHidden;

@property (nonatomic) BOOL hasDataPoints;

@property (nonatomic) double minimumValue;

@property (nonatomic) double maximumValue;

- (void)sharedInit;

- (void)calculateMinAndMaxValues;

- (NSMutableArray<NSObject<ORKValueCollectionType> *> *)normalizedCanvasDataPointsForPlotIndex:(NSInteger)plotIndex canvasHeight:(CGFloat)viewHeight;

- (NSInteger)numberOfPlots;

- (NSInteger)numberOfValidValuesForPlotIndex:(NSInteger)plotIndex;

- (NSInteger)scrubbingPlotIndex;

- (double)scrubbingValueForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex;

- (double)scrubbingYAxisPointForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex;

- (double)scrubbingLabelValueForCanvasXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (NSInteger)pointIndexForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (void)updateScrubberLineAccessories:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (CGFloat)snappedXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (BOOL)isXPositionSnapped:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (void)updatePlotColors;

- (void)updateLineLayers;

- (void)layoutLineLayers;

- (UIColor *)colorForPlotIndex:(NSInteger)plotIndex subpointIndex:(NSInteger)subpointIndex totalSubpoints:(NSInteger)totalSubpoints;

- (UIColor *)colorForPlotIndex:(NSInteger)plotIndex;

- (void)prepareAnimationsForPlotIndex:(NSInteger)plotIndex;

- (void)animateLayersSequentiallyWithDuration:(NSTimeInterval)duration plotIndex:(NSInteger)plotIndex;

- (void)animateLayer:(CALayer *)layer
             keyPath:(NSString *)keyPath
            duration:(CGFloat)duration
          startDelay:(CGFloat)startDelay
      timingFunction:(CAMediaTimingFunction *)timingFunction;

@end


// Abstract base class for ORKDiscreteGraphChartView and ORKLineGraphChartView
@interface ORKValueRangeGraphChartView ()

@property (nonatomic) NSMutableArray<NSMutableArray<ORKValueRange *> *> *dataPoints; // Actual data

@property (nonatomic) NSMutableArray<NSMutableArray<ORKValueRange *> *> *yAxisPoints; // Normalized for the plot view height

- (void)updatePointLayers;

- (void)layoutPointLayers;

@end

