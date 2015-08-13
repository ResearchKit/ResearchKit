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


#import "ORKGraphView.h"
#import "ORKGraphView_Internal.h"
#import "ORKSkin.h"
#import "ORKAxisView.h"
#import "ORKCircleView.h"
#import "ORKRangedPoint.h"


const CGFloat ORKGraphViewLeftPadding = 10.0;
const CGFloat ORKGraphViewGrowAnimationDuration = 0.1;
const CGFloat ORKGraphViewPointAndLineSize = 8.0;
const CGFloat ORKGraphViewScrubberMoveAnimationDuration = 0.1;

ORKDefineStringKey(FadeAnimationKey);
ORKDefineStringKey(GrowAnimationKey);
ORKDefineStringKey(PopAnimationKey);

static const CGFloat TopPadding = 0.0;
static const CGFloat XAxisHeight = 30.0;
static const CGFloat YAxisPaddingFactor = 0.15;
static const CGFloat AxisMarkingRulerLength = 8.0;
static const CGFloat FadeAnimationDuration = 0.2;
static const CGFloat PopAnimationDuration  = 0.3;
static const CGFloat SnappingClosenessFactor = 0.3;
static const CGSize ScrubberThumbSize = (CGSize){10.0, 10.0};
static const CGFloat ScrubberFadeAnimationDuration = 0.2;
static const CGFloat LayerAnimationDelay = 0.1;

@interface ORKGraphView () <UIGestureRecognizerDelegate>

@end


@implementation ORKGraphView

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
    _axisColor =  ORKColor(ORKGraphAxisColorKey);
    _axisTitleColor = ORKColor(ORKGraphAxisTitleColorKey);
    _referenceLineColor = ORKColor(ORKGraphReferenceLineColorKey);
    _scrubberLineColor = ORKColor(ORKGraphScrubberLineColorKey);
    _scrubberThumbColor = ORKColor(ORKGraphScrubberThumbColorKey);
    _axisTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    _showsVerticalReferenceLines = NO;
    _noDataText = NSLocalizedString(@"BASE_GRAPH_VIEW_EMPTY_TEXT", nil);
    _dataPoints = [NSMutableArray new];
    _xAxisPoints = [NSMutableArray new];
    _yAxisPoints = [NSMutableArray new];
    _xAxisTitles = [NSMutableArray new];
    _referenceLines = [NSMutableArray new];
    _pathLines = [NSMutableArray new];
    _dots = [NSMutableArray new];
    self.tintColor = [UIColor colorWithRed:244/255.f green:190/255.f blue:74/255.f alpha:1.f];
    _shouldAnimate = YES;
    _hasDataPoints = NO;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delaysTouchesBegan = YES;
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    [self setUpViews];
}

- (void)setUpViews {
    _plotsView = [UIView new];
    _plotsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_plotsView];
    
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

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat yAxisPadding = CGRectGetWidth(self.frame) * YAxisPaddingFactor;
    
    // Basic Views
    _plotsView.frame = CGRectMake(ORKGraphViewLeftPadding,
                                  TopPadding,
                                  CGRectGetWidth(self.frame) - yAxisPadding - ORKGraphViewLeftPadding,
                                  CGRectGetHeight(self.frame) - XAxisHeight - TopPadding);
    if (_emptyLabel) {
        _emptyLabel.frame = CGRectMake(ORKGraphViewLeftPadding,
                                           TopPadding,
                                           CGRectGetWidth(self.frame) - ORKGraphViewLeftPadding,
                                           CGRectGetHeight(self.frame) - XAxisHeight - TopPadding);
    }
    
    // Scrubber Views
    _scrubberLine.frame = CGRectMake(CGRectGetMinX(_scrubberLine.frame),
                                     TopPadding,
                                     1,
                                     CGRectGetHeight(_plotsView.frame));
    _scrubberThumbView.frame = CGRectMake(CGRectGetMinX(_scrubberThumbView.frame),
                                          CGRectGetMinY(_scrubberThumbView.frame),
                                          ScrubberThumbSize.width,
                                          ScrubberThumbSize.height);
    _scrubberThumbView.layer.cornerRadius = _scrubberThumbView.bounds.size.height / 2;
    _scrubberLabel.font = [UIFont fontWithName:_scrubberLabel.font.familyName size:12.0f];
    
    [_xAxisView layoutSubviews];
}

- (void)setDefaults {
    _minimumValue = MAXFLOAT;
    _maximumValue = -MAXFLOAT;
}

#pragma mark - Drawing

- (void)refreshGraph {
    // Clear subviews and sublayers
    [_plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    [_plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self drawXAxis];
    [self drawYAxis];
    
    [self drawHorizontalReferenceLines];
    
    if (_showsVerticalReferenceLines) {
        [self drawVerticalReferenceLines];
    }
    
    [self calculateXAxisPoints];
    [_dots removeAllObjects];
    [_pathLines removeAllObjects];
    
    for (int i = 0; i < [self numberOfPlots]; i++) {
        if ([_dataSource graphView:self numberOfPointsForPlotIndex:i] <= 1) {
            return;
        } else {
            [self drawGraphForPlotIndex:i];
        }
    }
    
    if (!_hasDataPoints) {
        [self setupEmptyView];
    } else {
        if (_emptyLabel) {
            [_emptyLabel removeFromSuperview];
        }
    }
    
    [self animateLayersSequentially];
}

- (void)prepareDataForPlotIndex:(NSInteger)plotIndex {
    [_dataPoints removeAllObjects];
    [_yAxisPoints removeAllObjects];
    _hasDataPoints = NO;
    
    NSInteger numberOfPoints = [_dataSource graphView:self numberOfPointsForPlotIndex:plotIndex];
    for (int i = 0; i < numberOfPoints; i++) {
        ORKRangedPoint *value = [_dataSource graphView:self pointForPointIndex:i plotIndex:plotIndex];
        [_dataPoints addObject:value];
        if (!value.isUnset) {
            _hasDataPoints = YES;
        }
    }
    [_yAxisPoints addObjectsFromArray:[self normalizeCanvasPointsForRect:_plotsView.frame.size]];
}

- (void)drawGraphForPlotIndex:(NSInteger)plotIndex {
    [self prepareDataForPlotIndex:plotIndex];
    if ([self shouldDrawLinesForPlotIndex:plotIndex]) {
        [self drawLinesForPlotIndex:plotIndex];
    }
    [self drawPointCirclesForPlotIndex:plotIndex];
}

- (void)drawPointCirclesForPlotIndex:(NSInteger)plotIndex {
    CGFloat pointSize = ORKGraphViewPointAndLineSize;
    
    for (NSUInteger i = 0; i < [_yAxisPoints count]; i++) {
        ORKRangedPoint *dataPointVal = (ORKRangedPoint *)_dataPoints[i];
        CGFloat positionOnXAxis = [_xAxisPoints[i] floatValue];
        positionOnXAxis += [self offsetForPlotIndex:plotIndex];
        
        if (!dataPointVal.isUnset) {
            ORKRangedPoint *positionOnYAxis = (ORKRangedPoint *)_yAxisPoints[i];
            ORKCircleView *point = [[ORKCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
            point.tintColor = (plotIndex == 0) ? self.tintColor : _referenceLineColor;
            point.center = CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue);
            [_plotsView.layer addSublayer:point.layer];
            
            if (_shouldAnimate) {
                point.alpha = 0;
            }
            
            [_dots addObject:point];
            
            if (!positionOnYAxis.hasEmptyRange) {
                ORKCircleView *point = [[ORKCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
                point.tintColor = (plotIndex == 0) ? self.tintColor : _referenceLineColor;
                point.center = CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue);
                [_plotsView.layer addSublayer:point.layer];
                
                if (_shouldAnimate) {
                    point.alpha = 0;
                }
                
                [_dots addObject:point];
            }
        }
    }
}

- (void)drawXAxis {
    // Add Title Labels
    [_xAxisTitles removeAllObjects];
    
    for (int i = 0; i < _numberOfXAxisTitles; i++) {
        if ([_dataSource respondsToSelector:@selector(graphView:titleForXAxisAtIndex:)]) {
            NSString *title = [_dataSource graphView:self titleForXAxisAtIndex:i];
            
            [_xAxisTitles addObject:title];
        }
    }
    
    if (_xAxisView) {
        [_xAxisView removeFromSuperview];
        _xAxisView = nil;
    }
    
    _xAxisView = [[ORKAxisView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_plotsView.frame),
                                                                   CGRectGetMaxY(_plotsView.frame),
                                                                   CGRectGetWidth(_plotsView.frame),
                                                                   XAxisHeight)];
    _xAxisView.tintColor = self.tintColor;
    [_xAxisView setUpTitles:_xAxisTitles];
    [self addSubview:_xAxisView];
    
    UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
    [xAxisPath moveToPoint:CGPointMake(0, 0)];
    [xAxisPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    
    CAShapeLayer *xAxisLineLayer = [CAShapeLayer layer];
    xAxisLineLayer.strokeColor = _axisColor.CGColor;
    xAxisLineLayer.path = xAxisPath.CGPath;
    [_xAxisView.layer addSublayer:xAxisLineLayer];
    
    for (NSUInteger i = 0; i < [_xAxisTitles count]; i++) {
        CGFloat positionOnXAxis = ((CGRectGetWidth(_plotsView.frame) / (_numberOfXAxisTitles - 1)) * i);
        
        UIBezierPath *rulerPath = [UIBezierPath bezierPath];
        [rulerPath moveToPoint:CGPointMake(positionOnXAxis, - AxisMarkingRulerLength)];
        [rulerPath addLineToPoint:CGPointMake(positionOnXAxis, 0)];
        
        CAShapeLayer *rulerLayer = [CAShapeLayer layer];
        rulerLayer.strokeColor = _axisColor.CGColor;
        rulerLayer.path = rulerPath.CGPath;
        [_xAxisView.layer addSublayer:rulerLayer];
    }
}

- (void)drawYAxis {
    [self prepareDataForPlotIndex:0];
    
    if (_yAxisView) {
        [_yAxisView removeFromSuperview];
        _yAxisView = nil;
    }
    
    CGFloat axisViewXPosition = CGRectGetWidth(self.frame) * (1 - YAxisPaddingFactor);
    CGFloat axisViewWidth = CGRectGetWidth(self.frame)*YAxisPaddingFactor;
    
    _yAxisView = [[UIView alloc] initWithFrame:CGRectMake(axisViewXPosition,
                                                              TopPadding,
                                                              axisViewWidth,
                                                              CGRectGetHeight(_plotsView.frame))];
    [self addSubview:_yAxisView];
    CGFloat rulerXPosition = CGRectGetWidth(_yAxisView.bounds) - AxisMarkingRulerLength + 2;
    
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
            CGFloat positionOnYAxis = CGRectGetHeight(_plotsView.frame) * (1 - factor);
            
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
            
            UILabel *axisTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYPosition, CGRectGetWidth(_yAxisView.frame) - AxisMarkingRulerLength, labelHeight)];
            
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
    [referenceLinePath moveToPoint:CGPointMake(ORKGraphViewLeftPadding, TopPadding + CGRectGetHeight(_plotsView.frame)/2)];
    [referenceLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), TopPadding + CGRectGetHeight(_plotsView.frame)/2)];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = _referenceLineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineDashPattern = @[@6, @4];
    [_plotsView.layer addSublayer:referenceLineLayer];
    
    [_referenceLines addObject:referenceLineLayer];
}

- (void)drawVerticalReferenceLines {
    for (int i = 1; i < _numberOfXAxisTitles; i++) {
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(_plotsView.frame) / (_numberOfXAxisTitles - 1)) * i);
        
        UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
        [referenceLinePath moveToPoint:CGPointMake(positionOnXAxis, 0)];
        [referenceLinePath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(_plotsView.frame))];
        
        CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
        referenceLineLayer.strokeColor = _referenceLineColor.CGColor;
        referenceLineLayer.path = referenceLinePath.CGPath;
        referenceLineLayer.lineDashPattern = @[@6, @4];
        [_plotsView.layer addSublayer:referenceLineLayer];
        
        [_referenceLines addObject:referenceLineLayer];
    }
}

- (void)setupEmptyView {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(ORKGraphViewLeftPadding,
                                                                    TopPadding,
                                                                    CGRectGetWidth(self.frame) - ORKGraphViewLeftPadding,
                                                                    CGRectGetHeight(self.frame) - XAxisHeight - TopPadding)];
        _emptyLabel.text = _noDataText;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
        _emptyLabel.textColor = [UIColor lightGrayColor];
    }
    
    [self addSubview:_emptyLabel];
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

- (NSInteger)numberOfXAxisTitles {
    NSInteger numberOfXAxisTitles = 0;
    
    if ([_dataSource respondsToSelector:@selector(numberOfDivisionsInXAxisForGraphView:)]) {
        numberOfXAxisTitles = [_dataSource numberOfDivisionsInXAxisForGraphView:self];
    } else {
        numberOfXAxisTitles = [_dataSource graphView:self numberOfPointsForPlotIndex:0];
    }
    
    return numberOfXAxisTitles;
}

- (void)calculateXAxisPoints {
    [_xAxisPoints removeAllObjects];
    
    for (int i = 0; i < [self numberOfXAxisTitles]; i++) {
        CGFloat positionOnXAxis = ((CGRectGetWidth(_plotsView.frame) / ([_yAxisPoints count] - 1)) * i);
        positionOnXAxis = round(positionOnXAxis);
        [_xAxisPoints addObject:@(positionOnXAxis)];
    }
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
    if (([_dataPoints count] > 0) && [self numberOfValidValues] > 0) {
        
        CGPoint location = [gestureRecognizer locationInView:_plotsView];
        CGFloat maxX = round(CGRectGetWidth(_plotsView.bounds));
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

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition {
    [UIView animateWithDuration:ORKGraphViewScrubberMoveAnimationDuration animations:^{
        _scrubberLine.center = CGPointMake(xPosition + ORKGraphViewLeftPadding, _scrubberLine.center.y);
        [self updateScrubberLineAccessories:xPosition];
    }];
}

- (void)updateScrubberLineAccessories:(CGFloat)xPosition {
    CGFloat scrubberYPos = [self canvasYPointForXPosition:xPosition];
    CGFloat scrubbingVal = [self valueForCanvasXPosition:(xPosition)];
    [_scrubberThumbView setCenter:CGPointMake(xPosition + ORKGraphViewLeftPadding, scrubberYPos + TopPadding)];
    _scrubberLabel.text = [NSString stringWithFormat:@"%.0f", scrubbingVal];
    CGSize textSize = [_scrubberLabel.text boundingRectWithSize:CGSizeMake(320, CGRectGetHeight(_scrubberLabel.bounds))
                                                        options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName:_scrubberLabel.font}
                                                        context:nil].size;
    [_scrubberLabel setFrame:CGRectMake(CGRectGetMaxX(_scrubberLine.frame) + 6, CGRectGetMinY(_scrubberLine.frame), textSize.width + 8, CGRectGetHeight(_scrubberLabel.frame))];
}

- (CGFloat)snappedXPosition:(CGFloat)xPosition {
    CGFloat widthBetweenPoints = CGRectGetWidth(_plotsView.frame) / [_xAxisPoints count];
    NSUInteger positionIndex;
    for (positionIndex = 0; positionIndex < [_xAxisPoints count]; positionIndex++) {
        
        CGFloat dataPointValue = ((ORKRangedPoint *)_dataPoints[positionIndex]).maximumValue;
        
        if (dataPointValue != ORKCGFloatInvalidValue) {
            CGFloat value = [_xAxisPoints[positionIndex] floatValue];
            
            if (fabs(value - xPosition) < (widthBetweenPoints * SnappingClosenessFactor)) {
                xPosition = value;
            }
        }
    }
    return xPosition;
}

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition {
    BOOL snapped = [_xAxisPoints containsObject:@(xPosition)];
    CGFloat value = ORKCGFloatInvalidValue;
    NSUInteger positionIndex = 0;
    if (snapped) {
        for (positionIndex = 0; positionIndex < ([_xAxisPoints count] - 1); positionIndex++) {
            CGFloat xAxisPointVal = [_xAxisPoints[positionIndex] floatValue];
            if (xAxisPointVal == xPosition) {
                break;
            }
        }
        value = ((ORKRangedPoint *)_dataPoints[positionIndex]).maximumValue;
    }
    return value;
}

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated {
    if ([self numberOfValidValues] > 0) {
        
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
    for (positionIndex = 0; positionIndex < ([_xAxisPoints count] - 1); positionIndex++) {
        CGFloat xAxisPointVal = [_xAxisPoints[positionIndex] floatValue];
        if (xAxisPointVal > xPosition) {
            break;
        }
    }
    return positionIndex;
}

#pragma Mark - Animation

- (CGFloat)animateLayersSequentially {
    //    NSLog(@"animate: %@", self);
    //
    CGFloat delay = LayerAnimationDelay;
    
    for (NSUInteger i = 0; i < [_dots count]; i++) {
        CAShapeLayer *layer = [_dots[i] shapeLayer];
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

- (NSInteger)numberOfValidValues {
    NSInteger count = 0;
    
    for (ORKRangedPoint *rangePoint in _dataPoints) {
        if (!rangePoint.isUnset) {
            count++;
        }
    }
    return count;
}

- (NSArray *)normalizeCanvasPointsForRect:(CGSize)canvasSize {
    [self calculateMinAndMaxPoints];
    
    NSMutableArray *normalizedPoints = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < [_dataPoints count]; i++) {
        
        ORKRangedPoint *normalizedRangePoint = [ORKRangedPoint new];
        ORKRangedPoint *dataPointValue = (ORKRangedPoint *)_dataPoints[i];
        
        if (dataPointValue.isUnset) {
            normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = canvasSize.height;
        } else if (_minimumValue == _maximumValue) {
            normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = canvasSize.height / 2;
        } else {
            CGFloat range = _maximumValue - _minimumValue;
            CGFloat normalizedMinimumValue = (dataPointValue.minimumValue - _minimumValue) / range * canvasSize.height;
            CGFloat normalizedMaximumValue = (dataPointValue.maximumValue - _minimumValue) / range * canvasSize.height;
            
            normalizedRangePoint.minimumValue = canvasSize.height - normalizedMinimumValue;
            normalizedRangePoint.maximumValue = canvasSize.height - normalizedMaximumValue;
        }
        [normalizedPoints addObject:normalizedRangePoint];
    }
    
    return [NSArray arrayWithArray:normalizedPoints];
}

- (NSInteger)nextValidPositionIndexForPosition:(NSInteger)positionIndex {
    NSUInteger validPosition = positionIndex;
    
    while (validPosition < ([_dataPoints count] - 1)) {
        if (((ORKRangedPoint *)_dataPoints[validPosition]).maximumValue != ORKCGFloatInvalidValue) {
            break;
        }
        validPosition ++;
    }
    
    return validPosition;
}

- (void)calculateMinAndMaxPoints {
    [self setDefaults];
    
    // Minimum
    if ([_dataSource respondsToSelector:@selector(minimumValueForGraphView:)]) {
        _minimumValue = [_dataSource minimumValueForGraphView:self];
    } else {
        
        if ([_dataPoints count]) {
            _minimumValue = ((ORKRangedPoint *)_dataPoints[0]).minimumValue;
            
            for (NSUInteger i = 1; i < [_dataPoints count]; i++) {
                CGFloat value = ((ORKRangedPoint *)_dataPoints[i]).minimumValue;
                if ((_minimumValue == ORKCGFloatInvalidValue) || (value < _minimumValue)) {
                    _minimumValue = value;
                }
            }
        }
    }
    
    // Maximum
    if ([_dataSource respondsToSelector:@selector(maximumValueForGraphView:)]) {
        _maximumValue = [_dataSource maximumValueForGraphView:self];
    } else {
        if ([_dataPoints count]) {
            _maximumValue = ((ORKRangedPoint *)_dataPoints[0]).maximumValue;
            
            for (NSUInteger i = 1; i < [_dataPoints count]; i++) {
                CGFloat value = ((ORKRangedPoint *)_dataPoints[i]).maximumValue;
                if (((value != ORKCGFloatInvalidValue) && (value > _maximumValue)) || (_maximumValue == ORKCGFloatInvalidValue)) {
                    _maximumValue = value;
                }
            }
        }
    }
}

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = (plotIndex == 0) ? self.tintColor.CGColor : _referenceLineColor.CGColor;
    layer.lineJoin = kCALineJoinRound;
    layer.lineCap = kCALineCapRound;
    layer.opacity = 1.0;
    if (_shouldAnimate) {
        layer.strokeEnd = 0;
    }
    return layer;
}

#pragma mark - Abstract

- (void)throwOverrideException {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
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
    return true;
}

@end
