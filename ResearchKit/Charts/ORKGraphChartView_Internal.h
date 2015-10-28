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


@class ORKXAxisView;

typedef NS_ENUM(NSUInteger, ORKGraphAnimationType) {
    ORkGraphAnimationTypeNone,
    ORKGraphAnimationTypeFade,
    ORKGraphAnimationTypeGrow,
    ORKGraphAnimationTypePop
};

extern const CGFloat ORKGraphChartViewLeftPadding;
extern const CGFloat ORKGraphChartViewPointAndLineSize;
extern const CGFloat ORKGraphChartViewScrubberMoveAnimationDuration;
extern const CGFloat ORKGraphChartViewAxisTickLength;
extern const CGFloat ORKGraphChartViewYAxisTickPadding;


inline static CAShapeLayer *graphLineLayer() {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.opacity = 1.0;
    return lineLayer;
}

static inline CGFloat xAxisPoint(NSInteger pointIndex, NSInteger numberOfXAxisPoints, CGFloat canvasWidth) {
    return round((canvasWidth / MAX(1, numberOfXAxisPoints - 1)) * pointIndex);
}


@interface ORKGraphChartView ()

@property (nonatomic) NSMutableArray<NSMutableArray<CAShapeLayer *> *> *lineLayers;

@property (nonatomic) NSInteger numberOfXAxisPoints;

@property (nonatomic) NSMutableArray<NSMutableArray<ORKRangedPoint *> *> *dataPoints; // Actual data

@property (nonatomic) NSMutableArray<NSMutableArray<ORKRangedPoint *> *> *yAxisPoints; // Normalized for the plot view height

@property (nonatomic) UIView *plotView; // Holds the plots

@property (nonatomic) UIView *scrubberLine;

@property (nonatomic) BOOL scrubberAccessoryViewsHidden;

- (void)sharedInit;

- (NSInteger)numberOfPlots;

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex;

- (NSInteger)numberOfValidValuesForPlotIndex:(NSInteger)plotIndex;

- (NSInteger)scrubbingPlotIndex;

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (NSInteger)pointIndexForXPosition:(CGFloat)xPosition;

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (void)updateScrubberLineAccessories:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex;

- (BOOL)isXPositionSnapped:(CGFloat)xPosition;

- (void)updatePlotColors;

- (void)updateLineLayers;

- (void)layoutLineLayers;

- (void)updatePointLayers;

- (void)layoutPointLayers;

- (UIColor *)colorForplotIndex:(NSInteger)plotIndex;

- (void)animateLayersSequentiallyWithDuration:(NSTimeInterval)duration;

- (void)animateLayer:(CALayer *)layer
             keyPath:(NSString *)keyPath
            duration:(CGFloat)duration
          startDelay:(CGFloat)startDelay
      timingFunction:(CAMediaTimingFunction *)timingFunction;

@end
