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


#import "ORKHelpers.h"


@class ORKAxisView;

ORK_ENUM_AVAILABLE
typedef NS_ENUM(NSUInteger, ORKGraphAnimationType) {
    ORkGraphAnimationTypeNone,
    ORKGraphAnimationTypeFade,
    ORKGraphAnimationTypeGrow,
    ORKGraphAnimationTypePop
};

ORKDefineStringKey(FadeAnimationKey);
ORKDefineStringKey(GrowAnimationKey);

static CGFloat const ORKGraphTopPadding = 0.f;
static CGFloat const XAxisHeight = 30.f;
static CGFloat const YAxisPaddingFactor = 0.15f;
static CGFloat const ORKGraphLeftPadding = 10.f;
static CGFloat const AxisMarkingRulerLength = 8.0f;
static CGFloat const FadeAnimationDuration = 0.2;
static CGFloat const GrowAnimationDuration = 0.1;
static CGFloat const PopAnimationDuration  = 0.3;
static CGFloat const SnappingClosenessFactor = 0.3f;

@interface ORKGraphView ()

ORK_EXTERN NSString * const ORKGraphViewTriggerAnimationsNotification;
ORK_EXTERN NSString * const ORKGraphViewRefreshNotification;

@property (nonatomic, strong) NSMutableArray *dataPoints; // Actual data

@property (nonatomic, strong) NSMutableArray *xAxisPoints;

@property (nonatomic, strong) NSMutableArray *yAxisPoints; // Normalised for this view

@property (nonatomic, strong) UIView *plotsView; // Holds the plots

@property (nonatomic, strong) ORKAxisView *xAxisView;

@property (nonatomic, strong) UIView *yAxisView;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic) BOOL hasDataPoint;

@property (nonatomic, strong) UIView *scrubberLine;

@property (nonatomic, strong) UILabel *scrubberLabel;

@property (nonatomic, strong) UIView *scrubberThumbView;

@property (nonatomic, readwrite) CGFloat minimumValue;

@property (nonatomic, readwrite) CGFloat maximumValue;

@property (nonatomic, strong) NSMutableArray *xAxisTitles;

@property (nonatomic) NSInteger numberOfXAxisTitles;

@property (nonatomic, strong) NSMutableArray *referenceLines;

@property (nonatomic, strong) NSMutableArray *pathLines;

@property (nonatomic, strong) NSMutableArray *dots;

@property (nonatomic) BOOL shouldAnimate;

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex;

- (NSInteger)nextValidPositionIndexForPosition:(NSInteger)positionIndex;

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition;

- (NSInteger)numberOfValidValues;

- (NSInteger)yAxisPositionIndexForXPosition:(CGFloat)xPosition;

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path;

- (CGFloat)animateLayersSequentially;

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(ORKGraphAnimationType)animationType startDelay:(CGFloat)delay;

@end
