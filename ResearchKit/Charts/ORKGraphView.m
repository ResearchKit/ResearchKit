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


#import "ORKGraphView.h"
#import "ORKGraphView_Internal.h"
#import "ORKSkin.h"
#import "ORKXAxisView.h"
#import "ORKCircleView.h"
#import "ORKRangedPoint.h"
#import "ORKDefines_Private.h"


const CGFloat ORKGraphViewLeftPadding = 10.0;
const CGFloat ORKGraphViewGrowAnimationDuration = 0.1;
const CGFloat ORKGraphViewPointAndLineSize = 8.0;
const CGFloat ORKGraphViewScrubberMoveAnimationDuration = 0.1;
const CGFloat ORKGraphViewAxisTickLength = 10.0;

static const CGFloat TopPadding = 0.0;
static const CGFloat XAxisHeight = 30.0;
static const CGFloat YAxisPaddingFactor = 0.12;
static const CGFloat FadeAnimationDuration = 0.2;
static const CGFloat PopAnimationDuration  = 0.3;
static const CGFloat SnappingClosenessFactor = 0.3;
static const CGSize ScrubberThumbSize = (CGSize){10.0, 10.0};
static const CGFloat ScrubberFadeAnimationDuration = 0.2;
static const CGFloat LayerAnimationDelay = 0.1;

ORKDefineStringKey(FadeAnimationKey);
ORKDefineStringKey(GrowAnimationKey);
ORKDefineStringKey(PopAnimationKey);


@interface ORKGraphView () <UIGestureRecognizerDelegate>

@end


@implementation ORKGraphView {
    UILabel *_noDataLabel;
    NSMutableArray *_circleViews;
    ORKXAxisView *_xAxisView;
    UIView *_yAxisView;
    BOOL _hasDataPoints;
    CGFloat _minimumValue;
    CGFloat _maximumValue;
    NSMutableArray *_referenceLines;
    NSMutableArray *_lineLayers;
    UILabel *_scrubberLabel;
    UIView *_scrubberThumbView;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _numberOfXAxisPoints = -1;
    _axisColor =  ORKColor(ORKGraphAxisColorKey);
    _axisTitleColor = ORKColor(ORKGraphAxisTitleColorKey);
    _referenceLineColor = ORKColor(ORKGraphReferenceLineColorKey);
    _scrubberLineColor = ORKColor(ORKGraphScrubberLineColorKey);
    _scrubberThumbColor = ORKColor(ORKGraphScrubberThumbColorKey);
    _axisTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    _showsVerticalReferenceLines = NO;
    _noDataText = ORKLocalizedString(@"CHART_NO_DATA_TEXT", nil);
    _dataPoints = [NSMutableArray new];
    _yAxisPoints = [NSMutableArray new];
    _referenceLines = [NSMutableArray new];
    _pathLines = [NSMutableArray new];
    _circleViews = [NSMutableArray new];
    _lineLayers = [NSMutableArray new];
    self.tintColor = [UIColor colorWithRed:244/255.f green:190/255.f blue:74/255.f alpha:1.f];
    _hasDataPoints = NO;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delaysTouchesBegan = YES;
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _shouldAnimate = NO;

    [self setUpViews];
}

- (void)setUpViews {
    _xAxisView = [[ORKXAxisView alloc] initWithParentGraphView:self];
    [self addSubview:_xAxisView];

    _plotView = [UIView new];
    _plotView.backgroundColor = [UIColor clearColor];
    [self addSubview:_plotView];
    
    _scrubberLine = [UIView new];
    _scrubberLine.backgroundColor = _scrubberLineColor;
    _scrubberLine.alpha = 0;
    [self addSubview:_scrubberLine];
    
    _scrubberLabel = [UILabel new];
    _scrubberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12.0f];
    _scrubberLabel.alpha = 0;
    _scrubberLabel.layer.cornerRadius = 2.0f;
    _scrubberLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _scrubberLabel.layer.borderWidth = 1.0f;
    _scrubberLabel.textAlignment = NSTextAlignmentCenter;
    _scrubberLabel.frame = CGRectMake(2, 0, 100, 20);
    _scrubberLabel.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.8];
    [self addSubview:_scrubberLabel];
    
    _scrubberThumbView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  ScrubberThumbSize.width,
                                                                  ScrubberThumbSize.height)];
    _scrubberThumbView.layer.borderWidth = 1.0;
    _scrubberThumbView.backgroundColor = _scrubberThumbColor;
    _scrubberThumbView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _scrubberThumbView.alpha = 0;
    [self addSubview:_scrubberThumbView];
}

- (void)setDataSource:(id<ORKGraphViewDataSource>)dataSource {
    _dataSource = dataSource;
    _numberOfXAxisPoints = -1; // reset cached number of x axis points
    [self calculateMinimumAndMaximumValues];
    [self obtainDataPoints];
    [_xAxisView updateTitles];
    [self setNeedsLayout];
}

- (void)obtainDataPoints {
    [_dataPoints removeAllObjects];
    _hasDataPoints = NO;
    
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        
        [_dataPoints addObject:[NSMutableArray new]];
        NSInteger numberOfPoints = [_dataSource graphView:self numberOfPointsForPlotIndex:plotIndex];
        for (NSInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
            ORKRangedPoint *value = [_dataSource graphView:self pointForPointIndex:pointIndex plotIndex:plotIndex];
            [_dataPoints[plotIndex] addObject:value];
            if (!value.isUnset) {
                _hasDataPoints = YES;
            }
        }

        // Add dummy points for empty data points
        if (_dataPoints.count < self.numberOfXAxisPoints ) {
            ORKRangedPoint *dummyPoint = [[ORKRangedPoint alloc] init];
            for (NSInteger idx = 0; idx < self.numberOfXAxisPoints - _dataPoints.count; idx++) {
                [_dataPoints[plotIndex] addObject:dummyPoint];
            }
        }
        
    }
}

#pragma mark - Layout

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat yAxisPadding = CGRectGetWidth(self.frame) * YAxisPaddingFactor;
    
    // Basic Views
    _plotView.frame = CGRectMake(ORKGraphViewLeftPadding,
                                  TopPadding,
                                  CGRectGetWidth(self.frame) - yAxisPadding - ORKGraphViewLeftPadding,
                                  CGRectGetHeight(self.frame) - XAxisHeight - TopPadding);
    
    _xAxisView.frame = CGRectMake(CGRectGetMinX(_plotView.frame),
                                  CGRectGetMaxY(_plotView.frame),
                                  CGRectGetWidth(_plotView.frame),
                                  XAxisHeight);

    if (_noDataLabel) {
        _noDataLabel.frame = CGRectMake(ORKGraphViewLeftPadding,
                                       TopPadding,
                                       CGRectGetWidth(self.frame) - ORKGraphViewLeftPadding,
                                       CGRectGetHeight(self.frame) - XAxisHeight - TopPadding);
    }
    
    // Scrubber Views
    _scrubberLine.frame = CGRectMake(CGRectGetMinX(_scrubberLine.frame),
                                     TopPadding,
                                     1,
                                     CGRectGetHeight(_plotView.frame));
    _scrubberThumbView.frame = CGRectMake(CGRectGetMinX(_scrubberThumbView.frame),
                                          CGRectGetMinY(_scrubberThumbView.frame),
                                          ScrubberThumbSize.width,
                                          ScrubberThumbSize.height);
    _scrubberThumbView.layer.cornerRadius = _scrubberThumbView.bounds.size.height / 2;
    _scrubberLabel.font = [UIFont fontWithName:_scrubberLabel.font.familyName size:12.0f];
    
    [self refreshGraph];
}

#pragma mark - Drawing

- (void)refreshGraph {
    // Clear subviews and sublayers
    [_plotView.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    [_plotView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self drawYAxis];
    
    [self drawHorizontalReferenceLines];
    
    if (_showsVerticalReferenceLines) {
        [self drawVerticalReferenceLines];
    }
    
    [_circleViews removeAllObjects];
    [_pathLines removeAllObjects];
    [_lineLayers removeAllObjects];

    [_yAxisPoints removeAllObjects];
    for (int plotIndex = 0; plotIndex < [self numberOfPlots]; plotIndex++) {
        if ([_dataSource graphView:self numberOfPointsForPlotIndex:plotIndex] <= 1) {
            break;
        } else {
            [_yAxisPoints addObject:[self normalizedCanvasPointsForPlotIndex:plotIndex canvasHeight:_plotView.bounds.size.height]];
            [self drawGraphForPlotIndex:plotIndex];
        }
    }
    
    if (!_hasDataPoints) {
        [self setupEmptyView];
    } else if (_noDataLabel) {
        [_noDataLabel removeFromSuperview];
    }
    
    if (_shouldAnimate) {
        [self animateLayersSequentially];
    }
}

- (void)drawGraphForPlotIndex:(NSInteger)plotIndex {
    if ([self shouldDrawLinesForPlotIndex:plotIndex]) {
        [self drawLinesForPlotIndex:plotIndex];
    }
    [self drawPointCirclesForPlotIndex:plotIndex];
}

- (void)drawPointCirclesForPlotIndex:(NSInteger)plotIndex {
    CGFloat pointSize = ORKGraphViewPointAndLineSize;
    
    for (NSUInteger i = 0; i < ((NSArray *)_yAxisPoints[plotIndex]).count; i++) {
        ORKRangedPoint *dataPointValue = (ORKRangedPoint *)_dataPoints[plotIndex][i];
        CGFloat positionOnXAxis = xAxisPoint(i, self.numberOfXAxisPoints, _plotView.bounds.size.width);
        positionOnXAxis += [self offsetForPlotIndex:plotIndex];
        
        if (!dataPointValue.isUnset) {
            ORKRangedPoint *positionOnYAxis = (ORKRangedPoint *)_yAxisPoints[plotIndex][i];
            ORKCircleView *circleView = [[ORKCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
            circleView.tintColor = (plotIndex == 0) ? self.tintColor : _referenceLineColor;
            circleView.center = CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue);
            [_plotView.layer addSublayer:circleView.layer];
            [_circleViews addObject:circleView];
            if (_shouldAnimate) {
                circleView.alpha = 0;
            }
            
            if (!positionOnYAxis.hasEmptyRange) {
                ORKCircleView *circleView = [[ORKCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
                circleView.tintColor = (plotIndex == 0) ? self.tintColor : _referenceLineColor;
                circleView.center = CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue);
                [_plotView.layer addSublayer:circleView.layer];
                [_circleViews addObject:circleView];
                if (_shouldAnimate) {
                    circleView.alpha = 0;
                }
            }
        }
    }
}

- (void)drawYAxis {
    if (_yAxisView) {
        [_yAxisView removeFromSuperview];
        _yAxisView = nil;
    }
    
    CGFloat axisViewXPosition = CGRectGetWidth(self.frame) * (1 - YAxisPaddingFactor);
    CGFloat axisViewWidth = CGRectGetWidth(self.frame)*YAxisPaddingFactor;
    
    _yAxisView = [[UIView alloc] initWithFrame:CGRectMake(axisViewXPosition,
                                                          TopPadding,
                                                          axisViewWidth,
                                                          CGRectGetHeight(_plotView.frame))];
    [self addSubview:_yAxisView];
    CGFloat rulerXPosition = CGRectGetWidth(_yAxisView.bounds) - ORKGraphViewAxisTickLength + 2;
    
    if (_maximumValueImage && _minimumValueImage) {
        // Use image icons as legends
        CGFloat width = CGRectGetWidth(_yAxisView.frame) / 2;
        CGFloat verticalPadding = 3.f;
        
        UIImageView *maxImageView = [[UIImageView alloc] initWithImage:_maximumValueImage];
        maxImageView.contentMode = UIViewContentModeScaleAspectFit;
        maxImageView.frame = CGRectMake(CGRectGetWidth(_yAxisView.bounds) - width, -width/2, width, width);
        [_yAxisView addSubview:maxImageView];
        
        UIImageView *minImageView = [[UIImageView alloc] initWithImage:_minimumValueImage];
        minImageView.contentMode = UIViewContentModeScaleAspectFit;
        minImageView.frame = CGRectMake(CGRectGetWidth(_yAxisView.bounds) - width, CGRectGetMaxY(_yAxisView.bounds) - width - verticalPadding, width, width);
        [_yAxisView addSubview:minImageView];
        
    } else {
        
        NSArray *yAxisLabelFactors;
        
        if (_minimumValue == _maximumValue) {
            yAxisLabelFactors = @[@0.5f];
        } else {
            yAxisLabelFactors = @[@0.2f, @1.0f];
        }
        
        for (NSUInteger i = 0; i < [yAxisLabelFactors count]; i++) {
            
            CGFloat factor = [yAxisLabelFactors[i] floatValue];
            CGFloat positionOnYAxis = CGRectGetHeight(_plotView.frame) * (1 - factor);
            
            UIBezierPath *rulerPath = [UIBezierPath bezierPath];
            [rulerPath moveToPoint:CGPointMake(rulerXPosition, positionOnYAxis)];
            [rulerPath addLineToPoint:CGPointMake(CGRectGetMaxX(_yAxisView.bounds), positionOnYAxis)];
            
            CAShapeLayer *rulerLayer = [CAShapeLayer layer];
            rulerLayer.strokeColor = _axisColor.CGColor;
            rulerLayer.path = rulerPath.CGPath;
            [_yAxisView.layer addSublayer:rulerLayer];
            
            CGFloat labelHeight = 20;
            CGFloat labelYPosition = positionOnYAxis - labelHeight/2;
            
            CGFloat yValue = _minimumValue + (_maximumValue - _minimumValue)*factor;
            
            UILabel *axisTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYPosition, CGRectGetWidth(_yAxisView.frame) - ORKGraphViewAxisTickLength, labelHeight)];
            
            if (yValue != 0) {
                axisTitleLabel.text = [NSString stringWithFormat:@"%0.0f", yValue];
            }
            axisTitleLabel.backgroundColor = [UIColor clearColor];
            axisTitleLabel.textColor = _axisTitleColor;
            axisTitleLabel.textAlignment = NSTextAlignmentRight;
            axisTitleLabel.font = _axisTitleFont;
            axisTitleLabel.minimumScaleFactor = 0.8;
            [_yAxisView addSubview:axisTitleLabel];
        }
    }
}

- (void)drawHorizontalReferenceLines {
    [_referenceLines removeAllObjects];
    
    UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
    [referenceLinePath moveToPoint:CGPointMake(ORKGraphViewLeftPadding, TopPadding + CGRectGetHeight(_plotView.frame)/2)];
    [referenceLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), TopPadding + CGRectGetHeight(_plotView.frame)/2)];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = _referenceLineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineDashPattern = @[@6, @4];
    [_plotView.layer addSublayer:referenceLineLayer];
    
    [_referenceLines addObject:referenceLineLayer];
}

- (void)drawVerticalReferenceLines {
    for (int i = 1; i < [self numberOfXAxisPoints]; i++) {
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(_plotView.frame) / ([self numberOfXAxisPoints] - 1)) * i);
        
        UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
        [referenceLinePath moveToPoint:CGPointMake(positionOnXAxis, 0)];
        [referenceLinePath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(_plotView.frame))];
        
        CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
        referenceLineLayer.strokeColor = _referenceLineColor.CGColor;
        referenceLineLayer.path = referenceLinePath.CGPath;
        referenceLineLayer.lineDashPattern = @[@6, @4];
        [_plotView.layer addSublayer:referenceLineLayer];
        
        [_referenceLines addObject:referenceLineLayer];
    }
}

- (void)setupEmptyView {
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(ORKGraphViewLeftPadding,
                                                                 TopPadding,
                                                                 CGRectGetWidth(self.frame) - ORKGraphViewLeftPadding,
                                                                 CGRectGetHeight(self.frame) - XAxisHeight - TopPadding)];
        _noDataLabel.text = _noDataText;
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
        _noDataLabel.textColor = [UIColor lightGrayColor];
    }
    
    [self addSubview:_noDataLabel];
}

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex {
    return 0;
}

#pragma mark - Plotting Points

- (NSInteger)numberOfPlots {
    NSInteger numberOfPlots = 1;
    
    if ([_dataSource respondsToSelector:@selector(numberOfPlotsInGraphView:)]) {
        numberOfPlots = [_dataSource numberOfPlotsInGraphView:self];
    }
    
    return numberOfPlots;
}

- (NSInteger)numberOfXAxisPoints {
    if (_numberOfXAxisPoints != -1) {
        return _numberOfXAxisPoints;
    }
    
    _numberOfXAxisPoints = 0;
    
    if ([_dataSource respondsToSelector:@selector(numberOfDivisionsInXAxisForGraphView:)]) {
        _numberOfXAxisPoints = [_dataSource numberOfDivisionsInXAxisForGraphView:self];
    }
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger idx = 0; idx < numberOfPlots; idx++) {
        NSInteger numberOfPlotPoints = [_dataSource graphView:self numberOfPointsForPlotIndex:idx];
        if (_numberOfXAxisPoints < numberOfPlotPoints) {
            _numberOfXAxisPoints = numberOfPlotPoints;
        }
    }
    
    return _numberOfXAxisPoints;
}

#pragma Mark - Scrubbing / UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:self];
    if (fabs(translation.x) > fabs(translation.y)) {
        return YES;
    }
    return NO;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (([_dataPoints count] > 0) && ([_dataPoints[0] count] > 0) && [self numberOfValidValuesForPlotIndex:0] > 0) {
        
        CGPoint location = [gestureRecognizer locationInView:_plotView];
        CGFloat maxX = round(CGRectGetWidth(_plotView.bounds));
        CGFloat normalizedX = MAX(MIN(location.x, maxX), 0);
        location = CGPointMake(normalizedX, location.y);
        CGFloat snappedXPosition = [self snappedXPosition:location.x];
        [self updateScrubberViewForXPosition:snappedXPosition];
        
        if ([_delegate respondsToSelector:@selector(graphView:touchesMovedToXPosition:)]) {
            [_delegate graphView:self touchesMovedToXPosition:snappedXPosition];
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setScrubberViewsHidden:NO animated:YES];
            if ([_delegate respondsToSelector:@selector(graphViewTouchesBegan:)]) {
                [_delegate graphViewTouchesBegan:self];
            }
        }
        
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self setScrubberViewsHidden:YES animated:YES];
            if ([_delegate respondsToSelector:@selector(graphViewTouchesEnded:)]) {
                [_delegate graphViewTouchesEnded:self];
            }
        }
    }
}

- (void)setScrubberLineAccessoriesHidden:(BOOL)hidden {
    _scrubberLabel.hidden = hidden;
    _scrubberThumbView.hidden = hidden;
}

- (void)updateScrubberLineAccessories:(CGFloat)xPosition {
    CGFloat scrubberYPosition = [self canvasYPointForXPosition:xPosition];
    CGFloat scrubbingValue = [self valueForCanvasXPosition:xPosition];
    if (scrubbingValue == ORKCGFloatInvalidValue) {
        [self setScrubberLineAccessoriesHidden:YES];
        return;
    }
    [self setScrubberLineAccessoriesHidden:NO];
    [_scrubberThumbView setCenter:CGPointMake(xPosition + ORKGraphViewLeftPadding, scrubberYPosition + TopPadding)];
    _scrubberLabel.text = [NSString stringWithFormat:@"%.0f", scrubbingValue];
    CGSize textSize = [_scrubberLabel.text boundingRectWithSize:CGSizeMake(320, CGRectGetHeight(_scrubberLabel.bounds))
                                                        options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName:_scrubberLabel.font}
                                                        context:nil].size;
    [_scrubberLabel setFrame:CGRectMake(CGRectGetMaxX(_scrubberLine.frame) + 6, CGRectGetMinY(_scrubberLine.frame), textSize.width + 8, CGRectGetHeight(_scrubberLabel.frame))];
}

- (CGFloat)snappedXPosition:(CGFloat)xPosition {
    CGFloat numberOfXAxisPoints = self.numberOfXAxisPoints;
    CGFloat widthBetweenPoints = CGRectGetWidth(_plotView.frame) / numberOfXAxisPoints;
    for (NSUInteger positionIndex = 0; positionIndex < ((NSMutableArray *)_dataPoints[0]).count; positionIndex++) {
        
        CGFloat dataPointValue = ((ORKRangedPoint *)_dataPoints[0][positionIndex]).maximumValue;
        
        if (dataPointValue != ORKCGFloatInvalidValue) {
            CGFloat value = xAxisPoint(positionIndex, numberOfXAxisPoints, _plotView.bounds.size.width);
            
            if (fabs(value - xPosition) < (widthBetweenPoints * SnappingClosenessFactor)) {
                xPosition = value;
            }
        }
    }
    return xPosition;
}

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition {
    BOOL snapped = [self isXPositionSnapped:xPosition];
    CGFloat value = ORKCGFloatInvalidValue;
    NSUInteger positionIndex = 0;
    if (snapped) {
        CGFloat numberOfXAxisPoints = self.numberOfXAxisPoints;
        for (positionIndex = 0; positionIndex < (numberOfXAxisPoints - 1); positionIndex++) {
            CGFloat xAxisPointValue = xAxisPoint(positionIndex, numberOfXAxisPoints, _plotView.bounds.size.width);
            if (xAxisPointValue == xPosition) {
                break;
            }
        }
        value = ((ORKRangedPoint *)_dataPoints[0][positionIndex]).maximumValue;
    }
    return value;
}

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated {
    if ([self numberOfValidValuesForPlotIndex:0] > 0) {
        
        void (^updateAlpha)(BOOL) = ^(BOOL hidden) {
            CGFloat alpha = hidden ? 0.0 : 1.0;
            _scrubberThumbView.alpha = alpha;
            _scrubberLine.alpha = alpha;
            _scrubberLabel.alpha = alpha;
        };
        
        if (animated) {
            [UIView animateWithDuration:ScrubberFadeAnimationDuration animations:^{
                updateAlpha(hidden);
            }];
        } else {
            updateAlpha(hidden);
        }
    }
}

- (NSInteger)yAxisPositionIndexForXPosition:(CGFloat)xPosition {
    NSUInteger positionIndex = 0;
    CGFloat numberOfXAxisPoints = self.numberOfXAxisPoints;
    for (positionIndex = 0; positionIndex < (numberOfXAxisPoints - 1); positionIndex++) {
        CGFloat xAxisPointValue = xAxisPoint(positionIndex, numberOfXAxisPoints, _plotView.bounds.size.width);
        if (xAxisPointValue > xPosition) {
            break;
        }
    }
    return positionIndex;
}

#pragma Mark - Animation

- (CGFloat)animateLayersSequentially {
    CGFloat delay = LayerAnimationDelay;
    
    for (NSUInteger i = 0; i < [_circleViews count]; i++) {
        CAShapeLayer *layer = [_circleViews[i] shapeLayer];
        [self animateLayer:layer withAnimationType:ORKGraphAnimationTypeFade startDelay:delay];
        delay += LayerAnimationDelay;
    }
    
    for (NSUInteger i = 0; i < [_pathLines count]; i++) {
        CAShapeLayer *layer = _pathLines[i];
        [self animateLayer:layer withAnimationType:ORKGraphAnimationTypeGrow startDelay:delay];
        delay += ORKGraphViewGrowAnimationDuration;
    }
    return delay;
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(ORKGraphAnimationType)animationType {
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:1.0];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(ORKGraphAnimationType)animationType toValue:(CGFloat)toValue {
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:toValue startDelay:0.0];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(ORKGraphAnimationType)animationType startDelay:(CGFloat)delay {
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:1.0 startDelay:delay];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(ORKGraphAnimationType)animationType toValue:(CGFloat)toValue startDelay:(CGFloat)delay {
    
    NSString *animationKeyPath = nil;
    CGFloat animationDuration = 0.0;
    NSString *animationKey = nil;
    if (animationType == ORKGraphAnimationTypeFade) {
        animationKeyPath = @"opacity";
        animationDuration = FadeAnimationDuration;
        animationKey = FadeAnimationKey;
    } else if (animationType == ORKGraphAnimationTypeGrow) {
        animationKeyPath = @"strokeEnd";
        animationDuration = ORKGraphViewGrowAnimationDuration;
        animationKey = GrowAnimationKey;
    } else if (animationType == ORKGraphAnimationTypePop) {
        animationKeyPath = @"transform.scale";
        animationDuration = PopAnimationDuration;
        animationKey = PopAnimationKey;
    }
    NSAssert(animationKeyPath && animationKey && animationDuration > 0.0, @"");
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:animationKeyPath];
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.fromValue = @0;
    animation.toValue = @(toValue);
    animation.duration = animationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [shapeLayer addAnimation:animation forKey:animationKey];
}

- (NSInteger)numberOfValidValuesForPlotIndex:(NSInteger)plotIndex {
    NSInteger count = 0;
    
    for (ORKRangedPoint *rangePoint in _dataPoints[plotIndex]) {
        if (!rangePoint.isUnset) {
            count++;
        }
    }
    return count;
}

- (NSArray *)normalizedCanvasPointsForPlotIndex:(NSInteger)plotIndex canvasHeight:(CGFloat)viewHeight {
    NSMutableArray *normalizedPoints = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < ((NSMutableArray *)_dataPoints[plotIndex]).count; i++) {
        
        ORKRangedPoint *normalizedRangePoint = [ORKRangedPoint new];
        ORKRangedPoint *dataPointValue = (ORKRangedPoint *)_dataPoints[plotIndex][i];
        
        if (dataPointValue.isUnset) {
            normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = viewHeight;
        } else if (_minimumValue == _maximumValue) {
            normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = viewHeight / 2;
        } else {
            CGFloat range = _maximumValue - _minimumValue;
            CGFloat normalizedMinimumValue = (dataPointValue.minimumValue - _minimumValue) / range * viewHeight;
            CGFloat normalizedMaximumValue = (dataPointValue.maximumValue - _minimumValue) / range * viewHeight;
            
            normalizedRangePoint.minimumValue = viewHeight - normalizedMinimumValue;
            normalizedRangePoint.maximumValue = viewHeight - normalizedMaximumValue;
        }
        [normalizedPoints addObject:normalizedRangePoint];
    }
    
    return [normalizedPoints copy];
}

- (NSInteger)nextValidPositionIndexForPosition:(NSInteger)positionIndex {
    NSUInteger validPosition = positionIndex;
    
    while (validPosition < (((NSMutableArray *)_dataPoints[0]).count - 1)) {
        if (((ORKRangedPoint *)_dataPoints[0][validPosition]).maximumValue != ORKCGFloatInvalidValue) {
            break;
        }
        validPosition ++;
    }
    
    return validPosition;
}

- (void)calculateMinimumAndMaximumValues {
    _minimumValue = ORKCGFloatInvalidValue;
    _maximumValue = ORKCGFloatInvalidValue;
    
    BOOL minimumValueProvided = NO;
    BOOL maximumValueProvided = NO;
    
    if ([_dataSource respondsToSelector:@selector(minimumValueForGraphView:)]) {
        _minimumValue = [_dataSource minimumValueForGraphView:self];
        minimumValueProvided = YES;
    }
    
    if ([_dataSource respondsToSelector:@selector(maximumValueForGraphView:)]) {
        _maximumValue = [_dataSource maximumValueForGraphView:self];
        maximumValueProvided = YES;
    }
    
    if (!minimumValueProvided || !maximumValueProvided) {
        NSInteger numberOfPlots = [self numberOfPlots];
        for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
            NSInteger numberOfPlotPoints = [_dataSource graphView:self numberOfPointsForPlotIndex:plotIndex];
            for (NSInteger pointIndex = 0; pointIndex < numberOfPlotPoints; pointIndex++) {
                ORKRangedPoint *point = [_dataSource graphView:self pointForPointIndex:pointIndex plotIndex:plotIndex];
                if (!minimumValueProvided &&
                    ((_minimumValue == ORKCGFloatInvalidValue) || (point.minimumValue < _minimumValue))) {
                    _minimumValue = point.minimumValue;
                }
                if (!maximumValueProvided &&
                    ((_maximumValue == ORKCGFloatInvalidValue) || (point.maximumValue > _maximumValue))) {
                    _maximumValue = point.maximumValue;
                }
            }
        }
    }
    
    if (_minimumValue == ORKCGFloatInvalidValue) {
        _minimumValue = 0;
    }
    if (_maximumValue == ORKCGFloatInvalidValue) {
        _maximumValue = 0;
    }
}

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = path;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.strokeColor = (plotIndex == 0) ? self.tintColor.CGColor : _referenceLineColor.CGColor;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.opacity = 1.0;
    [_lineLayers addObject:lineLayer];
    if (_shouldAnimate) {
        lineLayer.strokeEnd = 0;
    }
    return lineLayer;
}

- (BOOL)isXPositionSnapped:(CGFloat)xPosition {
    BOOL snapped = NO;
    CGFloat viewWidth = _plotView.bounds.size.width;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;
    for (NSInteger idx = 0; idx < numberOfXAxisPoints; idx++) {
        if (xPosition == xAxisPoint(idx, numberOfXAxisPoints, viewWidth)) {
            snapped = YES;
        }
    }
    return snapped;
}

#pragma mark - Abstract

- (void)throwOverrideException {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition {
    [self throwOverrideException];
}

- (void)scrubReferenceLineForXPosition:(CGFloat) __unused xPosition {
    [self throwOverrideException];
}

- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition {
    [self throwOverrideException];
    return 0;
}

- (void)drawLinesForPlotIndex:(NSInteger)plotIndex {
    [self throwOverrideException];
}

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    [self throwOverrideException];
    return NO;
}

@end
