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


#import "ORKGraphChartView.h"
#import "ORKGraphChartView_Internal.h"
#import "ORKSkin.h"
#import "ORKXAxisView.h"
#import "ORKYAxisView.h"
#import "ORKRangedPoint.h"
#import "ORKDefines_Private.h"
#import "ORKAccessibility.h"


const CGFloat ORKGraphChartViewLeftPadding = 10.0;
const CGFloat ORKGraphChartViewPointAndLineSize = 8.0;
const CGFloat ORKGraphChartViewScrubberMoveAnimationDuration = 0.1;
const CGFloat ORKGraphChartViewAxisTickLength = 12.0;
const CGFloat ORKGraphChartViewYAxisTickPadding = 2.0;

static const CGFloat TopPadding = 7.0;
static const CGFloat XAxisViewHeight = 30.0;
static const CGFloat YAxisViewWidthFactor = 0.12;
static const CGFloat SnappingClosenessFactor = 0.3;
static const CGSize ScrubberThumbSize = (CGSize){10.0, 10.0};
static const CGFloat ScrubberFadeAnimationDuration = 0.2;
static const CGFloat ScrubberLineToLabelPadding = 6.0;
static const CGFloat ScrubberLabelCornerRadius = 4.0;
static const CGFloat ScrubberLabelHorizontalPadding = 12.0;
static const CGFloat ScrubberLabelVerticalPadding = 4.0;
#define ScrubberLabelColor ([UIColor colorWithWhite:0.98 alpha:0.8])

@interface ORKGraphChartView () <UIGestureRecognizerDelegate>

@end


@implementation ORKGraphChartView {
    UIView *_referenceLinesView;
    UILabel *_noDataLabel;
    ORKXAxisView *_xAxisView;
    ORKYAxisView *_yAxisView;
    BOOL _hasDataPoints;
    CAShapeLayer *_horizontalReferenceLineLayer;
    NSMutableArray *_verticalReferenceLineLayers;
    NSMutableArray *_pointLayers;
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

- (void)setDataSource:(id<ORKGraphChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    _numberOfXAxisPoints = -1; // reset cached number of x axis points
    [self obtainDataPoints];
    [self calculateMinAndMaxValues];
    [_xAxisView updateTitles];
    [_yAxisView updateTicksAndLabels];
    [self updateLineLayers];
    [self updatePointLayers];
    [self updateNoDataLabel];
    
    [self setNeedsLayout];
}

- (void)setAxisColor:(UIColor *)axisColor {
    _axisColor = axisColor;
    _xAxisView.axisColor = _axisColor;
    _yAxisView.axisColor = _axisColor;
}

- (void)setAxisTitleColor:(UIColor *)axisTitleColor {
    _axisTitleColor = axisTitleColor;
    _yAxisView.titleColor = _axisTitleColor;
}

- (void)setReferenceLineColor:(UIColor *)referenceLineColor {
    _referenceLineColor = referenceLineColor;
    _horizontalReferenceLineLayer.strokeColor = referenceLineColor.CGColor;
    [self updateAndLayoutVerticalReferenceLineLayers];
    [self updatePlotColors];
}

- (void)setScrubberLineColor:(UIColor *)scrubberLineColor {
    _scrubberLineColor = scrubberLineColor;
    _scrubberLine.backgroundColor = _scrubberLineColor;
    _scrubberThumbView.layer.borderColor = _scrubberLineColor.CGColor;
    _scrubberLabel.layer.borderColor = _scrubberLineColor.CGColor;
}

- (void)setScrubberThumbColor:(UIColor *)scrubberThumbColor {
    _scrubberThumbColor = scrubberThumbColor;
    _scrubberThumbView.backgroundColor = _scrubberThumbColor;
}

- (void)setNoDataText:(NSString *)noDataText {
    _noDataText = [noDataText copy];
    _noDataLabel.text = _noDataText;
}

- (void)setMaximumValueImage:(UIImage *)maximumValueImage {
    _maximumValueImage = maximumValueImage;
    [_yAxisView updateTicksAndLabels];
}

- (void)setMinimumValueImage:(UIImage *)minimumValueImage {
    _minimumValueImage = minimumValueImage;
    [_yAxisView updateTicksAndLabels];
}

- (void)setShowsHorizontalReferenceLines:(BOOL)showsHorizontalReferenceLines {
    _showsHorizontalReferenceLines = showsHorizontalReferenceLines;
    [self updateHorizontalReferenceLines];
    [self layoutHorizontalReferenceLineLayers];
}

- (void)setShowsVerticalReferenceLines:(BOOL)showsVerticalReferenceLines {
    _showsVerticalReferenceLines = showsVerticalReferenceLines;
    [self updateAndLayoutVerticalReferenceLineLayers];
}

- (void)sharedInit {
    _numberOfXAxisPoints = -1;
    _axisColor =  ORKColor(ORKGraphAxisColorKey);
    _axisTitleColor = ORKColor(ORKGraphAxisTitleColorKey);
    _referenceLineColor = ORKColor(ORKGraphReferenceLineColorKey);
    _scrubberLineColor = ORKColor(ORKGraphScrubberLineColorKey);
    _scrubberThumbColor = ORKColor(ORKGraphScrubberThumbColorKey);
    _showsHorizontalReferenceLines = NO;
    _showsVerticalReferenceLines = NO;
    _noDataText = ORKLocalizedString(@"CHART_NO_DATA_TEXT", nil);
    _dataPoints = [NSMutableArray new];
    _yAxisPoints = [NSMutableArray new];
    _pointLayers = [NSMutableArray new];
    _lineLayers = [NSMutableArray new];
    _hasDataPoints = NO;
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delaysTouchesBegan = YES;
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    [self setUpViews];
    
    [self updateContentSizeCategoryFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContentSizeCategoryFonts)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_axVoiceOverStatusChanged:)
                                                 name:UIAccessibilityVoiceOverStatusChanged
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tintColorDidChange {
    [self updatePlotColors];
}

- (void)updatePlotColors {
    for (NSUInteger plotIndex = 0; plotIndex < _lineLayers.count; plotIndex++) {
        UIColor *color = (plotIndex == 0) ? self.tintColor : _referenceLineColor;
        for (NSUInteger pointIndex = 0; pointIndex < ((NSArray *)_lineLayers[plotIndex]).count; pointIndex++) {
            CAShapeLayer *lineLayer = _lineLayers[plotIndex][pointIndex];
            lineLayer.strokeColor = color.CGColor;
        }
        for (NSUInteger pointIndex = 0; pointIndex < ((NSArray *)_pointLayers[plotIndex]).count; pointIndex++) {
            CAShapeLayer *pointLayer = _pointLayers[plotIndex][pointIndex];
            pointLayer.contents = (__bridge id)(graphPointLayerImageWithTintColor(color).CGImage);
        }
    }
}

- (void)updateContentSizeCategoryFonts {
    _xAxisView.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _yAxisView.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    _scrubberLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _noDataLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (void)setUpViews {
    _referenceLinesView = [UIView new];
    [self addSubview:_referenceLinesView];
    
    _xAxisView = [[ORKXAxisView alloc] initWithParentGraphChartView:self];
    [self addSubview:_xAxisView];

    _yAxisView = [[ORKYAxisView alloc] initWithParentGraphChartView:self];
    [self addSubview:_yAxisView];
    
    _plotView = [UIView new];
    _plotView.backgroundColor = [UIColor clearColor];
    [self addSubview:_plotView];
    
    [self updateHorizontalReferenceLines];
    
    _scrubberLine = [UIView new];
    _scrubberLine.backgroundColor = _scrubberLineColor;
    _scrubberLine.alpha = 0;
    [self addSubview:_scrubberLine];
    
    _scrubberLabel = [UILabel new];
    _scrubberLabel.alpha = 0;
    _scrubberLabel.layer.cornerRadius = ScrubberLabelCornerRadius;
    _scrubberLabel.layer.borderColor = _scrubberLineColor.CGColor;
    _scrubberLabel.layer.borderWidth = 1.0f;
    _scrubberLabel.textColor = [UIColor darkGrayColor];
    _scrubberLabel.textAlignment = NSTextAlignmentCenter;
    _scrubberLabel.backgroundColor = ScrubberLabelColor;
    [self addSubview:_scrubberLabel];
    
    _scrubberThumbView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  ScrubberThumbSize.width,
                                                                  ScrubberThumbSize.height)];
    _scrubberThumbView.layer.cornerRadius = _scrubberThumbView.bounds.size.height / 2;
    _scrubberThumbView.layer.borderWidth = 1.0;
    _scrubberThumbView.backgroundColor = _scrubberThumbColor;
    _scrubberThumbView.layer.borderColor = _scrubberLineColor.CGColor;
    _scrubberThumbView.alpha = 0;
    [self addSubview:_scrubberThumbView];
}

- (void)updateHorizontalReferenceLines {
    [_horizontalReferenceLineLayer removeFromSuperlayer];
    _horizontalReferenceLineLayer = nil;
    if (_showsHorizontalReferenceLines) {
        _horizontalReferenceLineLayer = [CAShapeLayer layer];
        _horizontalReferenceLineLayer.strokeColor = _referenceLineColor.CGColor;
        _horizontalReferenceLineLayer.lineDashPattern = @[@6, @4];
        
        [_referenceLinesView.layer insertSublayer:_horizontalReferenceLineLayer atIndex:0];
    }
}

inline static UIImage *graphVerticalReferenceLineLayerImageWithTintColor(UIColor *tintColor, CGFloat height) {
    static UIImage *lineImage = nil;
    static UIColor *lineImageColor = nil;
    static CGFloat lineImageHeight = 0.0;
    if (height > 0 && (!lineImage || ![lineImageColor isEqual:tintColor] || lineImageHeight != height)) {
        lineImageColor = tintColor;
        UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
        [referenceLinePath moveToPoint:CGPointMake(0, 0)];
        [referenceLinePath addLineToPoint:CGPointMake(0, height)];

        CAShapeLayer *referenceLineLayer = [CAShapeLayer new];
        referenceLineLayer.path = referenceLinePath.CGPath;
        referenceLineLayer.strokeColor = tintColor.CGColor;
        referenceLineLayer.lineDashPattern = @[@6, @4];
        
        UIGraphicsBeginImageContextWithOptions((CGSize){1, height}, NO, [UIScreen mainScreen].scale);
        [referenceLineLayer renderInContext:UIGraphicsGetCurrentContext()];
        lineImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return lineImage;
}

inline static CALayer *graphVerticalReferenceLineLayerWithTintColor(UIColor *tintColor, CGFloat height) {
    CALayer *referenceLineLayer = [CALayer new];
    referenceLineLayer.frame = (CGRect){{0, 0}, {[UIScreen mainScreen].scale, height}};
    referenceLineLayer.anchorPoint = CGPointMake(0, 0);
    referenceLineLayer.contents = (__bridge id)(graphVerticalReferenceLineLayerImageWithTintColor(tintColor, height).CGImage);
    
    return referenceLineLayer;
}

- (void)obtainDataPoints {
    [_dataPoints removeAllObjects];
    _hasDataPoints = NO;
    
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        
        [_dataPoints addObject:[NSMutableArray new]];
        NSInteger numberOfPoints = [_dataSource graphChartView:self numberOfPointsForPlotIndex:plotIndex];
        for (NSInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
            ORKRangedPoint *value = [_dataSource graphChartView:self pointForPointIndex:pointIndex plotIndex:plotIndex];
            [_dataPoints[plotIndex] addObject:value];
            if (!value.isUnset) {
                _hasDataPoints = YES;
            }
        }

        // Add dummy points for empty data points
        if (_dataPoints.count < self.numberOfXAxisPoints ) {
            ORKRangedPoint *dummyPoint = [[ORKRangedPoint alloc] init];
            for (NSInteger idx = 0; idx < self.numberOfXAxisPoints - ((NSArray *)_dataPoints[plotIndex]).count; idx++) {
                [_dataPoints[plotIndex] addObject:dummyPoint];
            }
        }
        
    }
}

#pragma mark - Layout

- (void)setBounds:(CGRect)bounds {
    BOOL sizeChanged = !CGSizeEqualToSize(bounds.size, self.bounds.size);
    [super setBounds:bounds];
    if (sizeChanged) {
        [self setNeedsLayout];
    }
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    if (sizeChanged) {
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat yAxisPadding = CGRectGetWidth(self.frame) * YAxisViewWidthFactor;
    CGRect plotViewFrame = CGRectMake(ORKGraphChartViewLeftPadding,
                                      TopPadding,
                                      CGRectGetWidth(self.frame) - yAxisPadding - ORKGraphChartViewLeftPadding,
                                      CGRectGetHeight(self.frame) - XAxisViewHeight - TopPadding);

    _referenceLinesView.frame = plotViewFrame;
    _plotView.frame = plotViewFrame;
    
    _xAxisView.frame = CGRectMake(CGRectGetMinX(_plotView.frame),
                                  CGRectGetMaxY(_plotView.frame),
                                  CGRectGetWidth(_plotView.frame),
                                  XAxisViewHeight);

    CGFloat yAxisViewXPosition = CGRectGetWidth(self.frame) * (1 - YAxisViewWidthFactor);
    CGFloat yAxisViewWidth = CGRectGetWidth(self.frame) * YAxisViewWidthFactor;
    _yAxisView.frame = CGRectMake(yAxisViewXPosition,
                                  TopPadding,
                                  yAxisViewWidth,
                                  CGRectGetHeight(_plotView.frame));
    
    [self layoutHorizontalReferenceLineLayers];
    [self updateAndLayoutVerticalReferenceLineLayers];
    
    NSLog(@"\n%@\n%@\n%@\n%@\n = %f",
          self,
          NSStringFromCGRect(self.bounds),
          NSStringFromCGRect(_plotView.frame),
          NSStringFromCGRect(_yAxisView.frame),
          _plotView.bounds.size.width + _yAxisView.bounds.size.width);

    if (_noDataLabel) {
        _noDataLabel.frame = CGRectMake(0,
                                        0,
                                        CGRectGetWidth(_plotView.frame),
                                        CGRectGetHeight(_plotView.frame));
    }
    
    // Scrubber Views
    _scrubberLine.frame = CGRectMake(CGRectGetMinX(_scrubberLine.frame),
                                     TopPadding,
                                     1,
                                     CGRectGetHeight(_plotView.frame));
    
    [self updateYAxisPoints];
    [self layoutLineLayers];
    [self layoutPointLayers];
}

- (void)updateYAxisPoints {
    [_yAxisPoints removeAllObjects];
    for (NSInteger plotIndex = 0; plotIndex < [self numberOfPlots]; plotIndex++) {
        [_yAxisPoints addObject:[self normalizedCanvasPointsForPlotIndex:plotIndex canvasHeight:_plotView.bounds.size.height]];
    }
}

- (void)layoutHorizontalReferenceLineLayers {
    if (_showsHorizontalReferenceLines) {
        CGSize plotViewSize = _plotView.bounds.size;
        UIBezierPath *horizontalReferenceLinePath = [UIBezierPath bezierPath];
        [horizontalReferenceLinePath moveToPoint:CGPointMake(0,
                                                             plotViewSize.height / 2)];
        [horizontalReferenceLinePath addLineToPoint:CGPointMake(plotViewSize.width + _yAxisView.bounds.size.width,
                                                                plotViewSize.height / 2)];
        _horizontalReferenceLineLayer.path = horizontalReferenceLinePath.CGPath;
    }
}

- (void)updateAndLayoutVerticalReferenceLineLayers {
    [_verticalReferenceLineLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _verticalReferenceLineLayers = nil;
    if (_showsVerticalReferenceLines) {
        _verticalReferenceLineLayers = [NSMutableArray new];
        CGFloat plotViewHeight = _plotView.bounds.size.height;
        CGFloat plotViewWidth = _plotView.bounds.size.width;
        for (NSUInteger i = 1; i < [self numberOfXAxisPoints]; i++) {
            CALayer *verticalReferenceLineLayer = graphVerticalReferenceLineLayerWithTintColor(_referenceLineColor, plotViewHeight);
            CGFloat positionOnXAxis = xAxisPoint(i, [self numberOfXAxisPoints], plotViewWidth);
            verticalReferenceLineLayer.position = CGPointMake(positionOnXAxis - 0.5, 0);
            [_referenceLinesView.layer insertSublayer:verticalReferenceLineLayer atIndex:0];
            [_verticalReferenceLineLayers addObject:verticalReferenceLineLayer];
        }
    }
}

#pragma mark - Drawing

inline static UIImage *graphPointLayerImageWithTintColor(UIColor *tintColor) {
    const CGFloat pointSize = ORKGraphChartViewPointAndLineSize;
    const CGFloat pointLineWidth = 2.0;
    
    static UIImage *pointImage = nil;
    static UIColor *pointImageColor = nil;
    if (!pointImage || ![pointImageColor isEqual:tintColor]) {
        pointImageColor = tintColor;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    (CGRect){{0 + (pointLineWidth/2), 0 + (pointLineWidth/2)}, {pointSize - pointLineWidth, pointSize - pointLineWidth}}];
        CAShapeLayer *pointLayer = [CAShapeLayer new];
        pointLayer.path = circlePath.CGPath;
        pointLayer.fillColor = [UIColor whiteColor].CGColor;
        pointLayer.strokeColor = tintColor.CGColor;
        pointLayer.lineWidth = pointLineWidth;
        
        UIGraphicsBeginImageContextWithOptions((CGSize){pointSize, pointSize}, NO, [UIScreen mainScreen].scale);
        [pointLayer renderInContext:UIGraphicsGetCurrentContext()];
        pointImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return pointImage;
}

inline static CALayer *graphPointLayerWithTintColor(UIColor *tintColor) {
    const CGFloat pointSize = ORKGraphChartViewPointAndLineSize;
    CALayer *pointLayer = [CALayer new];
    pointLayer.frame = (CGRect){{0, 0}, {pointSize, pointSize}};
    pointLayer.contents = (__bridge id)(graphPointLayerImageWithTintColor(tintColor).CGImage);
    
    return pointLayer;
}

- (void)updatePointLayers {
    for (NSInteger plotIndex = 0; plotIndex < _pointLayers.count; plotIndex++) {
        [_pointLayers[plotIndex] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    }
    [_pointLayers removeAllObjects];
    for (NSInteger plotIndex = 0; plotIndex < self.numberOfPlots; plotIndex++) {
        NSMutableArray *currentPlotPointLayers = [NSMutableArray new];
        [_pointLayers addObject:currentPlotPointLayers];
        [self updatePointLayersForPlotIndex:plotIndex];
    }
    
    // We perform the same double-looping when creating the elements and there is no need to do that if Voice Over is not running.
    if (!UIAccessibilityIsVoiceOverRunning()) {
        [self _axCreateAccessibilityElements];
    }
}

- (void)updatePointLayersForPlotIndex:(NSInteger)plotIndex {
    UIColor *tintColor = (plotIndex == 0) ? self.tintColor : _referenceLineColor;;
    for (NSUInteger i = 0; i < ((NSArray *)_dataPoints[plotIndex]).count; i++) {
        ORKRangedPoint *dataPoint = (ORKRangedPoint *)_dataPoints[plotIndex][i];
        if (!dataPoint.isUnset) {
            CALayer *pointLayer = graphPointLayerWithTintColor(tintColor);
            [_plotView.layer addSublayer:pointLayer];
            [_pointLayers[plotIndex] addObject:pointLayer];
            
            if (!dataPoint.hasEmptyRange) {
                CALayer *pointLayer = graphPointLayerWithTintColor(tintColor);
                [_plotView.layer addSublayer:pointLayer];
                [_pointLayers[plotIndex] addObject:pointLayer];
            }
        }
    }
}

- (void)layoutPointLayers {
    NSUInteger numberOfPlots = [self numberOfPlots];
    if (_yAxisPoints.count != numberOfPlots) { return; } // avoid layout if points have not been normalized yet

    for (NSInteger plotIndex = 0; plotIndex < [self numberOfPlots]; plotIndex++) {
        [self layoutPointLayersForPlotIndex:plotIndex];
    }
}

- (void)layoutPointLayersForPlotIndex:(NSInteger)plotIndex {
    NSUInteger pointLayerIndex = 0;
    for (NSUInteger pointIndex = 0; pointIndex < ((NSArray *)_dataPoints[plotIndex]).count; pointIndex++) {
        ORKRangedPoint *dataPointValue = (ORKRangedPoint *)_dataPoints[plotIndex][pointIndex];
        if (!dataPointValue.isUnset) {
            CGFloat positionOnXAxis = xAxisPoint(pointIndex, self.numberOfXAxisPoints, _plotView.bounds.size.width);
            positionOnXAxis += [self offsetForPlotIndex:plotIndex];
            ORKRangedPoint *positionOnYAxis = (ORKRangedPoint *)_yAxisPoints[plotIndex][pointIndex];
            CAShapeLayer *pointLayer = _pointLayers[plotIndex][pointLayerIndex];
            pointLayer.position = CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue);
            pointLayerIndex++;
            
            if (!positionOnYAxis.hasEmptyRange) {
                CAShapeLayer *pointLayer = _pointLayers[plotIndex][pointLayerIndex];
                pointLayer.position = CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue);
                pointLayerIndex++;
            }
        }
    }
}

- (void)updateLineLayers {
    for (NSInteger plotIndex = 0; plotIndex < _lineLayers.count; plotIndex++) {
        [_lineLayers[plotIndex] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    }
    [_lineLayers removeAllObjects];
    for (NSInteger plotIndex = 0; plotIndex < [self numberOfPlots]; plotIndex++) {
        // Add array even if it should not draw lines so all layer arays have the same number of elements for animating purposes
        NSMutableArray *currentPlotLineLayers = [NSMutableArray new];
        [self.lineLayers addObject:currentPlotLineLayers];
        if ([self shouldDrawLinesForPlotIndex:plotIndex]) {
            [self updateLineLayersForPlotIndex:plotIndex];
        }
    }
}

- (void)layoutLineLayers {
    NSUInteger numberOfPlots = [self numberOfPlots];
    if (_yAxisPoints.count != numberOfPlots) { return; } // avoid layout if points have not been normalized yet
    
    for (NSInteger plotIndex = 0; plotIndex < [self numberOfPlots]; plotIndex++) {
        if ([self shouldDrawLinesForPlotIndex:plotIndex]) {
            [self layoutLineLayersForPlotIndex:plotIndex];
        }
    }
}

- (void)updateNoDataLabel {
    if (!_hasDataPoints && !_noDataLabel) {
        _noDataLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noDataLabel.text = _noDataText;
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _noDataLabel.textColor = [UIColor lightGrayColor];
        [_plotView addSubview:_noDataLabel];
    } else if (!_hasDataPoints && _noDataLabel) {
        [_noDataLabel removeFromSuperview];
        _noDataLabel = nil;
    }
}

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex {
    return 0;
}

#pragma mark - Plotting Points

- (NSInteger)numberOfPlots {
    NSInteger numberOfPlots = 1;
    
    if ([_dataSource respondsToSelector:@selector(numberOfPlotsInGraphChartView:)]) {
        numberOfPlots = [_dataSource numberOfPlotsInGraphChartView:self];
    }
    
    return numberOfPlots;
}

- (NSInteger)numberOfXAxisPoints {
    if (_numberOfXAxisPoints != -1) {
        return _numberOfXAxisPoints;
    }
    
    _numberOfXAxisPoints = 0;
    
    if ([_dataSource respondsToSelector:@selector(numberOfDivisionsInXAxisForGraphChartView:)]) {
        _numberOfXAxisPoints = [_dataSource numberOfDivisionsInXAxisForGraphChartView:self];
    }
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger idx = 0; idx < numberOfPlots; idx++) {
        NSInteger numberOfPlotPoints = [_dataSource graphChartView:self numberOfPointsForPlotIndex:idx];
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
    if ((_dataPoints.count > 0) && (((NSArray *)_dataPoints[0]).count > 0) && [self numberOfValidValuesForPlotIndex:0] > 0) {
        
        CGPoint location = [gestureRecognizer locationInView:_plotView];
        CGFloat maxX = round(CGRectGetWidth(_plotView.bounds));
        CGFloat normalizedX = MAX(MIN(location.x, maxX), 0);
        location = CGPointMake(normalizedX, location.y);
        CGFloat snappedXPosition = [self snappedXPosition:location.x];
        [self updateScrubberViewForXPosition:snappedXPosition];
        
        if ([_delegate respondsToSelector:@selector(graphChartView:touchesMovedToXPosition:)]) {
            [_delegate graphChartView:self touchesMovedToXPosition:snappedXPosition];
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setScrubberViewsHidden:NO animated:YES];
            if ([_delegate respondsToSelector:@selector(graphChartViewTouchesBegan:)]) {
                [_delegate graphChartViewTouchesBegan:self];
            }
        }
        
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self setScrubberViewsHidden:YES animated:YES];
            if ([_delegate respondsToSelector:@selector(graphChartViewTouchesEnded:)]) {
                [_delegate graphChartViewTouchesEnded:self];
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
    [_scrubberThumbView setCenter:CGPointMake(xPosition + ORKGraphChartViewLeftPadding, scrubberYPosition + TopPadding)];
    _scrubberLabel.text = [NSString stringWithFormat:@"%.0f", scrubbingValue];
    CGSize textSize = [_scrubberLabel.text boundingRectWithSize:CGSizeMake(_plotView.bounds.size.width,
                                                                           _plotView.bounds.size.height)
                                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName: _scrubberLabel.font}
                                                        context:nil].size;
    _scrubberLabel.frame = CGRectMake(CGRectGetMaxX(_scrubberLine.frame) + ScrubberLineToLabelPadding,
                                      CGRectGetMinY(_scrubberLine.frame),
                                      textSize.width + ScrubberLabelHorizontalPadding,
                                      textSize.height + ScrubberLabelVerticalPadding);
}

- (CGFloat)snappedXPosition:(CGFloat)xPosition {
    CGFloat numberOfXAxisPoints = self.numberOfXAxisPoints;
    CGFloat widthBetweenPoints = CGRectGetWidth(_plotView.frame) / numberOfXAxisPoints;
    for (NSUInteger positionIndex = 0; positionIndex < ((NSArray *)_dataPoints[0]).count; positionIndex++) {
        
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

- (void)animateWithDuration:(NSTimeInterval)duration {
    if (duration < 0) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"animationDuration cannot be lower than 0" userInfo:nil];
    }
    for (NSUInteger plotIndex = 0; plotIndex < _pointLayers.count; plotIndex++) {
        [_pointLayers[plotIndex] makeObjectsPerformSelector:@selector(removeAllAnimations)];
        [_lineLayers[plotIndex] makeObjectsPerformSelector:@selector(removeAllAnimations)];
        for (CAShapeLayer *lineLayer in _lineLayers[plotIndex]) {
            lineLayer.strokeEnd = 0;
        }
        for (CAShapeLayer *pointLayer in _pointLayers[plotIndex]) {
            pointLayer.opacity = 0;
        }
    }
    [self animateLayersSequentiallyWithDuration:duration];
}

- (void)animateLayersSequentiallyWithDuration:(NSTimeInterval)duration {
    
    for (NSUInteger plotIndex = 0; plotIndex < _pointLayers.count; plotIndex++) {
        NSUInteger numberOfPoints = ((NSArray *)_pointLayers[plotIndex]).count;
        NSUInteger numberOfLines = ((NSArray *)_lineLayers[plotIndex]).count;
        
        CGFloat pointFadeDuration = duration / (numberOfPoints - 1);
        CGFloat lineFadeDuration = duration / (numberOfLines - 1);
        
        CGFloat pointDelay = 0.0;
        CGFloat lineDelay = 0.0;
        for (NSUInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
            CAShapeLayer *layer = _pointLayers[plotIndex][pointIndex];
            [self animateLayer:layer keyPath:@"opacity" duration:pointFadeDuration startDelay:pointDelay];
            pointDelay += pointFadeDuration;
        }
        
        for (NSUInteger pointIndex = 0; pointIndex < numberOfLines; pointIndex++) {
            CAShapeLayer *layer = _lineLayers[plotIndex][pointIndex];
            [self animateLayer:layer keyPath:@"strokeEnd" duration:lineFadeDuration startDelay:lineDelay];
            lineDelay += lineFadeDuration;
        }
    }
}

- (void)animateLayer:(CAShapeLayer *)layer
             keyPath:(NSString *)keyPath
            duration:(CGFloat)duration
          startDelay:(CGFloat)startDelay {
    [self animateLayer:layer
               keyPath:keyPath
              duration:duration
            startDelay:startDelay
        timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
}

- (void)animateLayer:(CALayer *)layer
             keyPath:(NSString *)keyPath
            duration:(CGFloat)duration
          startDelay:(CGFloat)startDelay
      timingFunction:(CAMediaTimingFunction *)timingFunction
{
    NSCAssert(layer && keyPath && duration >= 0.0 && startDelay >= 0.0 && timingFunction, @"");
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.beginTime = CACurrentMediaTime() + startDelay;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.duration = duration;
    animation.timingFunction = timingFunction;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:keyPath];
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
    
    for (NSUInteger i = 0; i < ((NSArray *)_dataPoints[plotIndex]).count; i++) {
        
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
    
    while (validPosition < (((NSArray *)_dataPoints[0]).count - 1)) {
        if (((ORKRangedPoint *)_dataPoints[0][validPosition]).maximumValue != ORKCGFloatInvalidValue) {
            break;
        }
        validPosition ++;
    }
    
    return validPosition;
}

- (void)calculateMinAndMaxValues {
    _minimumValue = ORKCGFloatInvalidValue;
    _maximumValue = ORKCGFloatInvalidValue;
    
    BOOL minimumValueProvided = NO;
    BOOL maximumValueProvided = NO;
    
    if ([_dataSource respondsToSelector:@selector(minimumValueForGraphChartView:)]) {
        _minimumValue = [_dataSource minimumValueForGraphChartView:self];
        minimumValueProvided = YES;
    }
    
    if ([_dataSource respondsToSelector:@selector(maximumValueForGraphChartView:)]) {
        _maximumValue = [_dataSource maximumValueForGraphChartView:self];
        maximumValueProvided = YES;
    }
    
    if (!minimumValueProvided || !maximumValueProvided) {
        NSInteger numberOfPlots = [self numberOfPlots];
        for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
            NSInteger numberOfPlotPoints = ((NSArray *)_dataPoints[plotIndex]).count;
            for (NSInteger pointIndex = 0; pointIndex < numberOfPlotPoints; pointIndex++) {
                ORKRangedPoint *point = _dataPoints[plotIndex][pointIndex];
                if (!minimumValueProvided &&
                    point.minimumValue != ORKCGFloatInvalidValue &&
                    ((_minimumValue == ORKCGFloatInvalidValue) || (point.minimumValue < _minimumValue))) {
                    _minimumValue = point.minimumValue;
                }
                if (!maximumValueProvided &&
                    point.maximumValue != ORKCGFloatInvalidValue &&
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

- (void)updateLineLayersForPlotIndex:(NSInteger)plotIndex {
    [self throwOverrideException];
}

- (void)layoutLineLayersForPlotIndex:(NSInteger)plotIndex {
    [self throwOverrideException];
}

- (BOOL)shouldDrawLinesForPlotIndex:(NSInteger)plotIndex {
    [self throwOverrideException];
    return NO;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

#pragma mark - Accessibility Helpers

- (void)_axVoiceOverStatusChanged:(NSNotification *)notification {
    if (UIAccessibilityIsVoiceOverRunning()) {
        [self _axCreateAccessibilityElements];
    }
}

- (void)_axCreateAccessibilityElements {
    NSInteger maxNumberOfPoints = [[_dataPoints valueForKeyPath:@"@max.@count.self"] integerValue];
    NSMutableArray *accessibilityElements = [[NSMutableArray alloc] initWithCapacity:maxNumberOfPoints];
    
    for (NSInteger pointIndex = 0; pointIndex < maxNumberOfPoints; pointIndex++) {
        ORKLineGraphAccessibilityElement *element = [[ORKLineGraphAccessibilityElement alloc] initWithAccessibilityContainer:self index:pointIndex maxIndex:maxNumberOfPoints];
        
        // Data points for all plots at any given pointIndex must be included (eg "2 and 4" or "range from 1-2 and range from 4-5").
        NSString *value = nil;
        for (NSInteger plotIndex = 0; plotIndex < _dataPoints.count; plotIndex++) {
            
            // Boundary check
            if ( pointIndex < [_dataPoints[plotIndex] count] ) {
                NSString *and = (value == nil || value.length == 0 ? nil : ORKLocalizedString(@"AX_GRAPH_AND_SEPARATOR", nil));
                ORKRangedPoint *rangePoint = _dataPoints[plotIndex][pointIndex];
                value = ORKAccessibilityStringForVariables(value, and, rangePoint.accessibilityLabel);
            }
        }
        
        element.accessibilityLabel = [self.dataSource graphChartView:self titleForXAxisAtIndex:pointIndex];
        element.accessibilityValue = value;
        [accessibilityElements addObject:element];
    }
    
    self.accessibilityElements = accessibilityElements;
}

@end
