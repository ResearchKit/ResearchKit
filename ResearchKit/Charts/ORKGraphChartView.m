/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 Copyright (c) 2017, Macro Yau.

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

#import "ORKChartTypes.h"
#import "ORKLineGraphChartView.h"
#import "ORKXAxisView.h"
#import "ORKYAxisView.h"

#import "ORKAccessibility.h"
#import "ORKSkin.h"


#if TARGET_INTERFACE_BUILDER

@implementation ORKIBGraphChartViewDataSource

- (NSInteger)numberOfPlotsInGraphChartView:(ORKGraphChartView *)graphChartView {
    return self.plotPoints.count;
}

- (NSInteger)graphChartView:(ORKGraphChartView *)graphChartView numberOfDataPointsForPlotIndex:(NSInteger)plotIndex {
    return self.plotPoints[plotIndex].count;
}

- (NSString *)graphChartView:(ORKGraphChartView *)graphChartView titleForXAxisAtPointIndex:(NSInteger)pointIndex {
    return [@(pointIndex + 1) stringValue];
}

@end


@implementation ORKIBValueRangeGraphChartViewDataSource

- (ORKValueRange *)graphChartView:(ORKGraphChartView *)graphChartView dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    return self.plotPoints[plotIndex][pointIndex];
}

@end

#endif


const CGFloat ORKGraphChartViewLeftPadding = 10.0;
const CGFloat ORKGraphChartViewPointAndLineWidth = 8.0;
const CGFloat ORKGraphChartViewScrubberMoveAnimationDuration = 0.1;
const CGFloat ORKGraphChartViewAxisTickLength = 12.0;
const CGFloat ORKGraphChartViewYAxisTickPadding = 2.0;

static const CGFloat TopPadding = 7.0;
static const CGFloat XAxisViewHeight = 30.0;
static const CGFloat YAxisViewWidth = 45.0;
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
    CAShapeLayer *_horizontalReferenceLineLayer;
    NSMutableArray<CALayer *> *_verticalReferenceLineLayers;
    UILabel *_scrubberLabel;
    UIView *_scrubberThumbView;
    NSString *_decimalFormat;
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

- (void)reloadData {
    _numberOfXAxisPoints = -1; // reset cached number of x axis points
    [self updateAndLayoutVerticalReferenceLineLayers];
    [self obtainDataPoints];
    [self calculateMinAndMaxValues];
    [_xAxisView updateTitles];
    [_yAxisView updateTicksAndLabels];
    [self updateLineLayers];
    [self updateNoDataLabel];
    
    [self _axCreateAccessibilityElementsIfNeeded];
    
    [self setNeedsLayout];
}

- (void)setDataSource:(id<ORKGraphChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setAxisColor:(UIColor *)axisColor {
    if (!axisColor) {
        axisColor = ORKColor(ORKGraphAxisColorKey);
    }
    _axisColor = axisColor;
    _xAxisView.axisColor = _axisColor;
    _yAxisView.axisColor = _axisColor;
}

- (void)setVerticalAxisTitleColor:(UIColor *)verticalAxisTitleColor {
    if (!verticalAxisTitleColor) {
        verticalAxisTitleColor = ORKColor(ORKGraphAxisTitleColorKey);
    }
    _verticalAxisTitleColor = verticalAxisTitleColor;
    _yAxisView.titleColor = _verticalAxisTitleColor;
}

- (void)setReferenceLineColor:(UIColor *)referenceLineColor {
    if (!referenceLineColor) {
        referenceLineColor = ORKColor(ORKGraphReferenceLineColorKey);
    }
    _referenceLineColor = referenceLineColor;
    _horizontalReferenceLineLayer.strokeColor = referenceLineColor.CGColor;
    [self updateAndLayoutVerticalReferenceLineLayers];
    [self updatePlotColors];
}

- (void)setScrubberLineColor:(UIColor *)scrubberLineColor {
    if (!scrubberLineColor) {
        scrubberLineColor = ORKColor(ORKGraphScrubberLineColorKey);
    }
    _scrubberLineColor = scrubberLineColor;
    _scrubberLine.backgroundColor = _scrubberLineColor;
    _scrubberThumbView.layer.borderColor = _scrubberLineColor.CGColor;
    _scrubberLabel.layer.borderColor = _scrubberLineColor.CGColor;
}

- (void)setScrubberThumbColor:(UIColor *)scrubberThumbColor {
    if (!scrubberThumbColor) {
        scrubberThumbColor = ORKColor(ORKGraphScrubberThumbColorKey);
    }
    _scrubberThumbColor = scrubberThumbColor;
    _scrubberThumbView.backgroundColor = _scrubberThumbColor;
}

- (void)setNoDataText:(NSString *)noDataText {
    if (!noDataText) {
        noDataText = ORKLocalizedString(@"CHART_NO_DATA_TEXT", nil);
    }
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

- (void)setDecimalPlaces:(NSUInteger)decimalPlaces {
    _decimalPlaces = decimalPlaces;
    _decimalFormat = [NSString stringWithFormat:@"%%.%luf", (unsigned long)_decimalPlaces];
    [_yAxisView setDecimalPlaces:_decimalPlaces];
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
    _showsHorizontalReferenceLines = NO;
    _showsVerticalReferenceLines = NO;
    _dataPoints = [NSMutableArray new];
    _yAxisPoints = [NSMutableArray new];
    _lineLayers = [NSMutableArray new];
    _hasDataPoints = NO;
    
    // init null resetable properties
    _axisColor =  ORKColor(ORKGraphAxisColorKey);
    _verticalAxisTitleColor = ORKColor(ORKGraphAxisTitleColorKey);
    _referenceLineColor = ORKColor(ORKGraphReferenceLineColorKey);
    _scrubberLineColor = ORKColor(ORKGraphScrubberLineColorKey);
    _scrubberThumbColor = ORKColor(ORKGraphScrubberThumbColorKey);
    _noDataText = ORKLocalizedString(@"CHART_NO_DATA_TEXT", nil);
    
    [self setDecimalPlaces:0];
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrubbingGesture:)];
    _longPressGestureRecognizer.delaysTouchesBegan = YES;
    _longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_longPressGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrubbingGesture:)];
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
    _xAxisView.tintColor = self.tintColor;
    [self updatePlotColors];
}

- (UIColor *)colorForPlotIndex:(NSInteger)plotIndex subpointIndex:(NSInteger)subpointIndex totalSubpoints:(NSInteger)totalSubpoints {
    // pointIndex and totalSubpoints only affect the derived color on the ORKBarGraphChartView subclass
    UIColor *color = nil;
    if ([_dataSource respondsToSelector:@selector(graphChartView:colorForPlotIndex:)]) {
        color = [_dataSource graphChartView:self colorForPlotIndex:plotIndex];
    } else {
        color = (plotIndex == 0) ? self.tintColor : _referenceLineColor;
    }
    return color;
}

- (UIColor *)colorForPlotIndex:(NSInteger)plotIndex {
    return [self colorForPlotIndex:plotIndex subpointIndex:0 totalSubpoints:0];
}

- (void)updatePlotColors {
    for (NSUInteger plotIndex = 0; plotIndex < _lineLayers.count; plotIndex++) {
        [self updatePlotColorsForPlotIndex:plotIndex];
    }
}

- (void)updatePlotColorsForPlotIndex:(NSInteger)plotIndex {
    NSUInteger numberOfPoints = _lineLayers[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
        NSUInteger numberOfSubpoints = _lineLayers[plotIndex][pointIndex].count;
        for (NSUInteger subpointIndex = 0; subpointIndex < numberOfSubpoints; subpointIndex++) {
            UIColor *color = [self colorForPlotIndex:plotIndex subpointIndex:subpointIndex totalSubpoints:numberOfSubpoints];
            CAShapeLayer *lineLayer = _lineLayers[plotIndex][pointIndex][subpointIndex];
            lineLayer.strokeColor = color.CGColor;
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

ORK_INLINE UIImage *graphVerticalReferenceLineLayerImageWithColor(UIColor *color, CGFloat height) {
    static UIImage *lineImage = nil;
    static UIColor *lineImageColor = nil;
    static CGFloat lineImageHeight = 0.0;
    if (height > 0 && (!lineImage || ![lineImageColor isEqual:color] || lineImageHeight != height)) {
        lineImageColor = color;
        lineImageHeight = height;
        UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
        [referenceLinePath moveToPoint:CGPointMake(0, 0)];
        [referenceLinePath addLineToPoint:CGPointMake(0, height)];

        CAShapeLayer *referenceLineLayer = [CAShapeLayer new];
        referenceLineLayer.path = referenceLinePath.CGPath;
        referenceLineLayer.lineWidth = [UIScreen mainScreen].scale;
        referenceLineLayer.strokeColor = color.CGColor;
        referenceLineLayer.lineDashPattern = @[@6, @4];
        
        UIGraphicsBeginImageContextWithOptions((CGSize){1, height}, NO, [UIScreen mainScreen].scale);
        [referenceLineLayer renderInContext:UIGraphicsGetCurrentContext()];
        lineImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return lineImage;
}

ORK_INLINE CALayer *graphVerticalReferenceLineLayerWithColor(UIColor *color, CGFloat height) {
    CALayer *referenceLineLayer = [CALayer new];
    referenceLineLayer.frame = (CGRect){{0, 0}, {1, height}};
    referenceLineLayer.anchorPoint = CGPointMake(0, 0);
    referenceLineLayer.contents = (__bridge id)(graphVerticalReferenceLineLayerImageWithColor(color, height).CGImage);
    
    return referenceLineLayer;
}

- (void)obtainDataPoints {
    [_dataPoints removeAllObjects];
    _hasDataPoints = NO;
    
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        [self obtainDataPointsForPlotIndex:plotIndex];
    }
}
        
- (void)obtainDataPointsForPlotIndex:(NSInteger)plotIndex {
    [self.dataPoints addObject:[NSMutableArray new]];
    NSInteger numberOfPoints = [self.dataSource graphChartView:self numberOfDataPointsForPlotIndex:plotIndex];
        for (NSInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
        NSObject<ORKValueCollectionType> *value = [self dataPointForPointIndex:pointIndex plotIndex:plotIndex];
        [self.dataPoints[plotIndex] addObject:value];
            if (!value.isUnset) {
            self.hasDataPoints = YES;
            }
        }
        // Add dummy points for empty data points
    NSInteger emptyPointsCount = self.numberOfXAxisPoints - self.dataPoints[plotIndex].count;
        for (NSInteger idx = 0; idx < emptyPointsCount; idx++) {
        [self.dataPoints[plotIndex] addObject:[self dummyPoint]];
    }
}

#pragma mark - Layout & Drawing

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
    
    CGRect plotViewFrame = CGRectMake(ORKGraphChartViewLeftPadding,
                                      TopPadding,
                                      CGRectGetWidth(self.frame) - YAxisViewWidth - ORKGraphChartViewLeftPadding,
                                      CGRectGetHeight(self.frame) - XAxisViewHeight - TopPadding);

    _referenceLinesView.frame = plotViewFrame;
    _plotView.frame = plotViewFrame;
    
    _xAxisView.frame = CGRectMake(CGRectGetMinX(_plotView.frame),
                                  CGRectGetMaxY(_plotView.frame),
                                  CGRectGetWidth(_plotView.frame),
                                  XAxisViewHeight);

    _yAxisView.frame = CGRectMake(CGRectGetWidth(self.frame) - YAxisViewWidth,
                                  TopPadding,
                                  YAxisViewWidth,
                                  CGRectGetHeight(_plotView.frame));
    
    [self layoutHorizontalReferenceLineLayers];
    [self updateAndLayoutVerticalReferenceLineLayers];
    
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
}

- (void)updateYAxisPoints {
    [_yAxisPoints removeAllObjects];
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        [_yAxisPoints addObject:[self normalizedCanvasDataPointsForPlotIndex:plotIndex canvasHeight:_plotView.bounds.size.height]];
    }
}

- (void)layoutHorizontalReferenceLineLayers {
    if (_showsHorizontalReferenceLines) {
        CGSize plotViewSize = _plotView.bounds.size;
        UIBezierPath *horizontalReferenceLinePath = [UIBezierPath bezierPath];
        [horizontalReferenceLinePath moveToPoint:CGPointMake(0 - scalePixelAdjustment(),
                                                             floor(plotViewSize.height / 2))];
        [horizontalReferenceLinePath addLineToPoint:CGPointMake(plotViewSize.width + _yAxisView.bounds.size.width,
                                                                floor(plotViewSize.height / 2))];
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
        NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;
        for (NSUInteger pointIndex = 1; pointIndex < numberOfXAxisPoints; pointIndex++) {
            if (![_dataSource respondsToSelector:@selector(graphChartView:drawsVerticalReferenceLineAtPointIndex:)]
                || [_dataSource graphChartView:self drawsVerticalReferenceLineAtPointIndex:pointIndex]) {
                CALayer *verticalReferenceLineLayer = graphVerticalReferenceLineLayerWithColor(_referenceLineColor, plotViewHeight);
                CGFloat positionOnXAxis = xAxisPoint(pointIndex, self.numberOfXAxisPoints, plotViewWidth);
                verticalReferenceLineLayer.position = CGPointMake(positionOnXAxis - scalePixelAdjustment(), 0);
                [_referenceLinesView.layer insertSublayer:verticalReferenceLineLayer atIndex:0];
                [_verticalReferenceLineLayers addObject:verticalReferenceLineLayer];
            }
        }
    }
}

ORK_INLINE UIImage *graphPointLayerImageWithColor(UIColor *color) {
    const CGFloat pointSize = ORKGraphChartViewPointAndLineWidth;
    const CGFloat pointLineWidth = 2.0;
    
    static UIImage *pointImage = nil;
    static UIColor *pointImageColor = nil;
    if (!pointImage || ![pointImageColor isEqual:color]) {
        pointImageColor = color;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    (CGRect){{0 + (pointLineWidth / 2), 0 + (pointLineWidth / 2)}, {pointSize - pointLineWidth, pointSize - pointLineWidth}}];
        CAShapeLayer *pointLayer = [CAShapeLayer new];
        pointLayer.path = circlePath.CGPath;
        pointLayer.fillColor = [UIColor whiteColor].CGColor;
        pointLayer.strokeColor = color.CGColor;
        pointLayer.lineWidth = pointLineWidth;
        
        UIGraphicsBeginImageContextWithOptions((CGSize){pointSize, pointSize}, NO, [UIScreen mainScreen].scale);
        [pointLayer renderInContext:UIGraphicsGetCurrentContext()];
        pointImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return pointImage;
}

ORK_INLINE CALayer *graphPointLayerWithColor(UIColor *color, BOOL drawPointIndicator) {
    const CGFloat pointSize = ORKGraphChartViewPointAndLineWidth;
    CALayer *pointLayer = [CALayer new];
    pointLayer.frame = (CGRect){{0, 0}, {pointSize, pointSize}};
    if (drawPointIndicator) {
    pointLayer.contents = (__bridge id)(graphPointLayerImageWithColor(color).CGImage);
    }
    
    return pointLayer;
    }
    
- (BOOL)shouldDrawPointIndicatorForPointWithIndex:(NSInteger)pointIndex inPlotWithIndex:(NSInteger)plotIndex {
    ORKValueRange *dataPoint = (ORKValueRange *)_dataPoints[plotIndex][pointIndex];
    if (dataPoint.isUnset) {
        return NO;
    }
    if (!dataPoint.isEmptyRange) {
        return YES;
    }
    if ([self isKindOfClass:[ORKLineGraphChartView class]]
        && [_dataSource respondsToSelector:@selector(graphChartView:drawsPointIndicatorsForPlotIndex:)]) {
        return [_dataSource graphChartView:self drawsPointIndicatorsForPlotIndex:plotIndex];
    }
    return YES;
}

- (void)updateLineLayers {
    for (NSInteger plotIndex = 0; plotIndex < _lineLayers.count; plotIndex++) {
        for (NSMutableArray <CAShapeLayer *> *sublineLayers in self.lineLayers[plotIndex]) {
            [sublineLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        }
    }
    [_lineLayers removeAllObjects];
    
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        // Add array even if it should not draw lines so all layer arays have the same number of elements for animating purposes
        NSMutableArray<NSMutableArray<CAShapeLayer *> *> *currentPlotLineLayers = [NSMutableArray new];
        [_lineLayers addObject:currentPlotLineLayers];
        if ([self shouldDrawLinesForPlotIndex:plotIndex]) {
            [self updateLineLayersForPlotIndex:plotIndex];
        }
    }
}

- (void)layoutLineLayers {
    
    NSInteger numberOfPlots = [self numberOfPlots];
    if (_yAxisPoints.count != numberOfPlots) {
        // avoid layout if points have not been normalized yet
        return;
    }
    
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
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
    } else if (_hasDataPoints && _noDataLabel) {
        [_noDataLabel removeFromSuperview];
        _noDataLabel = nil;
    }
}

- (CGFloat)xOffsetForPlotIndex:(NSInteger)plotIndex {
    return 0;
}

#pragma mark - Plotting Points

- (NSInteger)numberOfPlots {
    NSInteger numberOfPlots = 0;
    
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
        NSInteger numberOfPlotPoints = [_dataSource graphChartView:self numberOfDataPointsForPlotIndex:idx];
        if (_numberOfXAxisPoints < numberOfPlotPoints) {
            _numberOfXAxisPoints = numberOfPlotPoints;
        }
    }
    
    return _numberOfXAxisPoints;
}

#pragma Mark - Scrubbing

- (NSInteger)scrubbingPlotIndex {
    NSInteger plotIndex = 0;
    if ([_dataSource respondsToSelector:@selector(scrubbingPlotIndexForGraphChartView:)]) {
        plotIndex = [_dataSource scrubbingPlotIndexForGraphChartView:self];
        if (plotIndex >= [self numberOfPlots]) {
            plotIndex = 0;
        }
    }
    return plotIndex;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = NO;
    if (gestureRecognizer == _panGestureRecognizer) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
    if (fabs(translation.x) > fabs(translation.y)) {
            shouldBegin = YES;
        }
    } else if (gestureRecognizer == _longPressGestureRecognizer) {
        shouldBegin = YES;
    }
    return shouldBegin;
}

- (void)handleScrubbingGesture:(UIGestureRecognizer *)gestureRecognizer {
    NSInteger scrubbingPlotIndex = [self scrubbingPlotIndex];
    if ((_dataPoints.count > scrubbingPlotIndex) && ([self numberOfValidValuesForPlotIndex:scrubbingPlotIndex] > 0)) {
        
        CGPoint location = [gestureRecognizer locationInView:_plotView];
        CGFloat maxX = round(CGRectGetWidth(_plotView.bounds));
        CGFloat normalizedX = MAX(MIN(location.x, maxX), 0);
        location = CGPointMake(normalizedX, location.y);
        CGFloat snappedXPosition = [self snappedXPosition:location.x plotIndex:scrubbingPlotIndex];
        [self updateScrubberViewForXPosition:snappedXPosition plotIndex:scrubbingPlotIndex];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setScrubberViewsHidden:NO animated:YES];
            if ([_delegate respondsToSelector:@selector(graphChartViewTouchesBegan:)]) {
                [_delegate graphChartViewTouchesBegan:self];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            if ([_delegate respondsToSelector:@selector(graphChartView:touchesMovedToXPosition:)]) {
                [_delegate graphChartView:self touchesMovedToXPosition:snappedXPosition];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self setScrubberViewsHidden:YES animated:YES];
            if ([_delegate respondsToSelector:@selector(graphChartViewTouchesEnded:)]) {
                [_delegate graphChartViewTouchesEnded:self];
            }
        }
    }
}

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    void (^updateScrubberLinePosition)() = ^{
        self.scrubberLine.center = CGPointMake(xPosition + ORKGraphChartViewLeftPadding, self.scrubberLine.center.y);
    };
    BOOL scrubberlineAnimated = (self.scrubberLine.alpha > 0);
    BOOL scrubberlineAccessoriesAnimated = !self.scrubberAccessoryViewsHidden;
    if (scrubberlineAnimated || scrubberlineAccessoriesAnimated) {
        [UIView animateWithDuration:ORKGraphChartViewScrubberMoveAnimationDuration animations:^{
            if (scrubberlineAnimated) {
                updateScrubberLinePosition();
            }
            if (scrubberlineAccessoriesAnimated) {
                [self updateScrubberLineAccessories:xPosition plotIndex:plotIndex];
            }
        }];
    }
    if (!scrubberlineAnimated) {
        updateScrubberLinePosition();
    }
    if (!scrubberlineAccessoriesAnimated) {
        [self updateScrubberLineAccessories:xPosition plotIndex:plotIndex];
    }
}

- (BOOL)scrubberAccessoryViewsHidden {
    return _scrubberLabel.hidden && _scrubberThumbView.hidden;
}

- (void)setScrubberAccessoryViewsHidden:(BOOL)hidden {
    _scrubberLabel.hidden = hidden;
    _scrubberThumbView.hidden = hidden;
}

- (void)updateScrubberLineAccessories:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    double scrubberYPosition = [self canvasYPositionForXPosition:xPosition plotIndex:plotIndex];
    double scrubbingValue = [self scrubbingLabelValueForCanvasXPosition:xPosition plotIndex:plotIndex];

    _scrubberThumbView.center = CGPointMake(xPosition + ORKGraphChartViewLeftPadding, scrubberYPosition + TopPadding);
    _scrubberLabel.text = [NSString stringWithFormat:_decimalFormat, scrubbingValue == ORKDoubleInvalidValue ? 0.0 : scrubbingValue ];
    CGSize textSize = [_scrubberLabel.text boundingRectWithSize:CGSizeMake(_plotView.bounds.size.width,
                                                                           _plotView.bounds.size.height)
                                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName: _scrubberLabel.font}
                                                        context:nil].size;
    _scrubberLabel.frame = CGRectMake(xPosition + ORKGraphChartViewLeftPadding + ScrubberLineToLabelPadding,
                                      CGRectGetMinY(_scrubberLine.frame),
                                      textSize.width + ScrubberLabelHorizontalPadding,
                                      textSize.height + ScrubberLabelVerticalPadding);

    if (scrubbingValue == ORKDoubleInvalidValue) {
        [self setScrubberAccessoryViewsHidden:YES];
    } else {
        [self setScrubberAccessoryViewsHidden:NO];
    }
}

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated {
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

- (NSInteger)pointIndexForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    NSInteger pointIndex = 0;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;
    for (pointIndex = 0; pointIndex < (numberOfXAxisPoints - 1); pointIndex++) {
        CGFloat xAxisPointValue = xAxisPoint(pointIndex, numberOfXAxisPoints, _plotView.bounds.size.width);
        if (xAxisPointValue >= xPosition) {
            break;
        }
    }
    return pointIndex;
}

- (NSInteger)numberOfValidValuesForPlotIndex:(NSInteger)plotIndex {
    NSInteger count = 0;
    
    if (plotIndex < _dataPoints.count) {
        for (ORKValueRange *rangePoint in _dataPoints[plotIndex]) {
            if (!rangePoint.isUnset) {
                count++;
            }
        }
    }
    return count;
}

- (BOOL)isXPositionSnapped:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    BOOL snapped = NO;
    CGFloat viewWidth = _plotView.bounds.size.width;
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;
    for (NSInteger idx = 0; idx < numberOfXAxisPoints; idx++) {
        if (xPosition == xAxisPoint(idx, numberOfXAxisPoints, viewWidth)) {
            snapped = YES;
            break;
        }
    }
    return snapped;
}

- (CGFloat)snappedXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    NSInteger numberOfXAxisPoints = self.numberOfXAxisPoints;
    CGFloat widthBetweenPoints = CGRectGetWidth(self.plotView.frame) / numberOfXAxisPoints;
    NSUInteger positionCount = self.dataPoints[plotIndex].count;
    for (NSUInteger pointIndex = 0; pointIndex < positionCount; pointIndex++) {
        
        double scrubbingValue = [self scrubbingValueForPlotIndex:plotIndex pointIndex:pointIndex];
        
        if (scrubbingValue != ORKDoubleInvalidValue) {
            CGFloat snappedXPosition = xAxisPoint(pointIndex, numberOfXAxisPoints, self.plotView.bounds.size.width);
            
            if (fabs(snappedXPosition - xPosition) < (widthBetweenPoints * SnappingClosenessFactor)) {
                xPosition = snappedXPosition;
            }
        }
    }
    return xPosition;
}

- (double)scrubbingLabelValueForCanvasXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    double value = ORKDoubleInvalidValue;
    BOOL snapped = [self isXPositionSnapped:xPosition plotIndex:(NSInteger)plotIndex];
    if (snapped) {
        NSInteger pointIndex = [self pointIndexForXPosition:xPosition plotIndex:plotIndex];
        value = [self scrubbingValueForPlotIndex:plotIndex pointIndex:pointIndex];;
    }
    return value;
}

- (double)canvasYPositionForXPosition:(CGFloat)xPosition plotIndex:(NSInteger)plotIndex {
    BOOL snapped = [self isXPositionSnapped:xPosition plotIndex:plotIndex];
    double canvasYPosition = 0;
    if (snapped) {
        NSInteger pointIndex = [self pointIndexForXPosition:xPosition plotIndex:plotIndex];
        canvasYPosition = [self scrubbingYAxisPointForPlotIndex:plotIndex pointIndex:pointIndex];
    }
    return canvasYPosition;
}

#pragma Mark - Animation

- (void)animateWithDuration:(NSTimeInterval)duration {
    if (duration < 0) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"animationDuration cannot be lower than 0" userInfo:nil];
    }
    for (NSUInteger plotIndex = 0; plotIndex < [self numberOfPlots]; plotIndex++) {
        [self prepareAnimationsForPlotIndex:plotIndex];
        [self animateLayersSequentiallyWithDuration:duration plotIndex:plotIndex];
        }
        }

- (void)prepareAnimationsForPlotIndex:(NSInteger)plotIndex {
    for (NSMutableArray <CAShapeLayer *> *sublineLayers in self.lineLayers[plotIndex]) {
        [sublineLayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
        for (CAShapeLayer *lineLayer in sublineLayers) {
            lineLayer.strokeEnd = 0;
    }
}
            }

- (void)animateLayersSequentiallyWithDuration:(NSTimeInterval)duration plotIndex:(NSInteger)plotIndex {
    NSUInteger numberOfLines = self.lineLayers[plotIndex].count;
        if (numberOfLines > 0) {
            CGFloat lineFadeDuration = duration / numberOfLines;
            CGFloat lineDelay = 0.0;
            for (NSUInteger lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
            NSUInteger numberOfSublines = self.lineLayers[plotIndex][lineIndex].count;
            if (numberOfSublines > 0) {
                CGFloat sublineFadeDuration = lineFadeDuration / numberOfSublines;
                CGFloat sublineDelay = 0.0;
                for (NSUInteger sublineIndex = 0; sublineIndex < numberOfSublines; sublineIndex++) {
                    CAShapeLayer *layer = self.lineLayers[plotIndex][lineIndex][sublineIndex];
                    [self animateLayer:layer keyPath:@"strokeEnd" duration:sublineFadeDuration startDelay:lineDelay + sublineDelay];
                    sublineDelay += sublineFadeDuration;
                }
                lineDelay += sublineDelay;
            }
        }
    }
}

- (void)animateLayer:(CALayer *)layer
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

#pragma mark - Abstract

- (void)throwOverrideException {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSObject<ORKValueCollectionType> *)dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    [self throwOverrideException];
    return nil;
}

- (NSObject<ORKValueCollectionType> *)dummyPoint {
    [self throwOverrideException];
    return nil;
}

- (NSMutableArray<NSObject<ORKValueCollectionType> *> *)normalizedCanvasDataPointsForPlotIndex:(NSInteger)plotIndex canvasHeight:(CGFloat)viewHeight {
    [self throwOverrideException];
    return nil;
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

- (void)calculateMinAndMaxValues {
    [self throwOverrideException];
}

- (double)scrubbingValueForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex {
    [self throwOverrideException];
    return 0;
}

- (double)scrubbingYAxisPointForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex {
    [self throwOverrideException];
    return 0;
}

- (void)updatePointLayers {
    [self throwOverrideException];
}

- (void)layoutPointLayers {
    [self throwOverrideException];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

#pragma mark - Accessibility Helpers

- (void)_axVoiceOverStatusChanged:(NSNotification *)notification {
    [self _axCreateAccessibilityElementsIfNeeded];
}

- (void)_axCreateAccessibilityElementsIfNeeded {
    if (!UIAccessibilityIsVoiceOverRunning()) {
        // No need to creating accessibility elements if Voice Over is not running
        return;
    }
    
    NSInteger maxNumberOfPoints = [[_dataPoints valueForKeyPath:@"@max.@count.self"] integerValue];
    NSMutableArray<id> *accessibilityElements = [[NSMutableArray alloc] initWithCapacity:maxNumberOfPoints];
    
    for (NSInteger pointIndex = 0; pointIndex < maxNumberOfPoints; pointIndex++) {
        ORKLineGraphAccessibilityElement *element = [[ORKLineGraphAccessibilityElement alloc] initWithAccessibilityContainer:self index:pointIndex maxIndex:maxNumberOfPoints];
        
        // Data points for all plots at any given pointIndex must be included (eg "2 and 4" or "range from 1-2 and range from 4-5").
        NSString *value = nil;
        for (NSInteger plotIndex = 0; plotIndex < _dataPoints.count; plotIndex++) {
            
            // Boundary check
            if ( pointIndex < _dataPoints[plotIndex].count ) {
                NSString *and = (value == nil || value.length == 0 ? nil : ORKLocalizedString(@"AX_GRAPH_AND_SEPARATOR", nil));
                NSObject<ORKValueCollectionType> *dataPoint = _dataPoints[plotIndex][pointIndex];
                value = ORKAccessibilityStringForVariables(value, and, dataPoint.accessibilityLabel);
            }
        }
        
        if ([_dataSource respondsToSelector:@selector(graphChartView:titleForXAxisAtPointIndex:)]) {
            element.accessibilityLabel = [self.dataSource graphChartView:self titleForXAxisAtPointIndex:pointIndex];
        } else {
            element.accessibilityLabel = [NSString stringWithFormat:ORKLocalizedString(@"AX_GRAPH_POINT_%@", nil), ORKLocalizedStringFromNumber(@(pointIndex))];
        }
        element.accessibilityValue = value;
        [accessibilityElements addObject:element];
    }
    
    self.accessibilityElements = accessibilityElements;
}

@end


@implementation ORKValueRangeGraphChartView {
    NSMutableArray<NSMutableArray<CALayer *> *> *_pointLayers;
            }

@dynamic dataSource;
@dynamic dataPoints;
@dynamic yAxisPoints;
    
- (void)sharedInit {
    [super sharedInit];
    _pointLayers = [NSMutableArray new];
            }

- (void)reloadData {
    [super reloadData];
    [self updatePointLayers];
    [self setNeedsLayout];
        }

- (ORKValueRange *)dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex {
    return [self.dataSource graphChartView:self dataPointForPointIndex:pointIndex plotIndex:plotIndex];
    }

- (ORKValueRange *)dummyPoint {
    return [ORKValueRange new];
}

- (NSMutableArray<ORKValueRange *> *)normalizedCanvasDataPointsForPlotIndex:(NSInteger)plotIndex canvasHeight:(CGFloat)viewHeight {
    NSMutableArray<ORKValueRange *> *normalizedPoints = [NSMutableArray new];
    
    if (plotIndex < self.dataPoints.count) {
        NSUInteger pointCount = self.dataPoints[plotIndex].count;
        for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
            
            ORKValueRange *normalizedRangePoint = [ORKValueRange new];
            ORKValueRange *dataPointValue = self.dataPoints[plotIndex][pointIndex];
            
            if (dataPointValue.isUnset) {
                normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = viewHeight;
            } else if (self.minimumValue == self.maximumValue) {
                normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = viewHeight / 2;
            } else {
                double range = self.maximumValue - self.minimumValue;
                double normalizedMinimumValue = (dataPointValue.minimumValue - self.minimumValue) / range * viewHeight;
                double normalizedMaximumValue = (dataPointValue.maximumValue - self.minimumValue) / range * viewHeight;
                
                normalizedRangePoint.minimumValue = viewHeight - normalizedMinimumValue;
                normalizedRangePoint.maximumValue = viewHeight - normalizedMaximumValue;
            }
            [normalizedPoints addObject:normalizedRangePoint];
        }
    }
    
    return normalizedPoints;
}

- (void)calculateMinAndMaxValues {
    self.minimumValue = ORKDoubleInvalidValue;
    self.maximumValue = ORKDoubleInvalidValue;
    
    BOOL minimumValueProvided = NO;
    BOOL maximumValueProvided = NO;
    
    if ([self.dataSource respondsToSelector:@selector(minimumValueForGraphChartView:)]) {
        self.minimumValue = [self.dataSource minimumValueForGraphChartView:self];
        minimumValueProvided = YES;
    }
    
    if ([self.dataSource respondsToSelector:@selector(maximumValueForGraphChartView:)]) {
        self.maximumValue = [self.dataSource maximumValueForGraphChartView:self];
        maximumValueProvided = YES;
    }
    
    if (!minimumValueProvided || !maximumValueProvided) {
        NSInteger numberOfPlots = [self numberOfPlots];
        for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
            NSInteger numberOfPlotPoints = self.dataPoints[plotIndex].count;
            for (NSInteger pointIndex = 0; pointIndex < numberOfPlotPoints; pointIndex++) {
                ORKValueRange *point = self.dataPoints[plotIndex][pointIndex];
                if (!minimumValueProvided &&
                    point.minimumValue != ORKDoubleInvalidValue &&
                    ((self.minimumValue == ORKDoubleInvalidValue) || (point.minimumValue < self.minimumValue))) {
                    self.minimumValue = point.minimumValue;
                }
                if (!maximumValueProvided &&
                    point.maximumValue != ORKDoubleInvalidValue &&
                    ((self.maximumValue == ORKDoubleInvalidValue) || (point.maximumValue > self.maximumValue))) {
                    self.maximumValue = point.maximumValue;
                }
            }
        }
    }
    
    if (self.minimumValue == ORKDoubleInvalidValue) {
        self.minimumValue = 0;
    }
    if (self.maximumValue == ORKDoubleInvalidValue) {
        self.maximumValue = 0;
    }
}

#pragma mark - Layout & Drawing

- (void)updatePointLayersForPlotIndex:(NSInteger)plotIndex {
    if (plotIndex < self.dataPoints.count) {
        UIColor *color = [self colorForPlotIndex:plotIndex];
        NSUInteger pointCount = self.dataPoints[plotIndex].count;
        for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
            ORKValueRange *dataPoint = self.dataPoints[plotIndex][pointIndex];
            if (!dataPoint.isUnset) {
                BOOL drawPointIndicator = [self shouldDrawPointIndicatorForPointWithIndex:pointIndex inPlotWithIndex:plotIndex];
                CALayer *pointLayer = graphPointLayerWithColor(color, drawPointIndicator);
                [self.plotView.layer addSublayer:pointLayer];
                [_pointLayers[plotIndex] addObject:pointLayer];
                
                if (!dataPoint.isEmptyRange) {
                    CALayer *pointLayer = graphPointLayerWithColor(color, drawPointIndicator);
                    [self.plotView.layer addSublayer:pointLayer];
                    [_pointLayers[plotIndex] addObject:pointLayer];
                }
                }
            }
                }
            }
    
- (void)updatePlotColorsForPlotIndex:(NSInteger)plotIndex {
    [super updatePlotColorsForPlotIndex:plotIndex];
    UIColor *color = [self colorForPlotIndex:plotIndex];
    for (NSUInteger pointIndex = 0; pointIndex < _pointLayers[plotIndex].count; pointIndex++) {
        CALayer *pointLayer = _pointLayers[plotIndex][pointIndex];
        if (pointLayer.contents) {
        pointLayer.contents = (__bridge id)(graphPointLayerImageWithColor(color).CGImage);
        }
        }
    }
    
- (void)updatePointLayers {
    for (NSInteger plotIndex = 0; plotIndex < _pointLayers.count; plotIndex++) {
        [_pointLayers[plotIndex] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    }
    [_pointLayers removeAllObjects];
    
    NSInteger numberOfPlots = [self numberOfPlots];
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        NSMutableArray<CALayer *> *currentPlotPointLayers = [NSMutableArray new];
        [_pointLayers addObject:currentPlotPointLayers];
        [self updatePointLayersForPlotIndex:plotIndex];
    }
    }

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutPointLayers];
}

- (void)layoutPointLayers {
    NSInteger numberOfPlots = [self numberOfPlots];

    if (self.yAxisPoints.count != numberOfPlots) {
        // avoid layout if points have not been normalized yet
        return;
        }
    
    for (NSInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
        [self layoutPointLayersForPlotIndex:plotIndex];
    }
}

- (void)layoutPointLayersForPlotIndex:(NSInteger)plotIndex {
    if (plotIndex < self.dataPoints.count) {
        NSUInteger pointLayerIndex = 0;
        for (NSUInteger pointIndex = 0; pointIndex < self.dataPoints[plotIndex].count; pointIndex++) {
            ORKValueRange *dataPointValue = self.dataPoints[plotIndex][pointIndex];
            if (!dataPointValue.isUnset) {
                CGFloat positionOnXAxis = xAxisPoint(pointIndex, self.numberOfXAxisPoints, self.plotView.bounds.size.width);
                positionOnXAxis += [self xOffsetForPlotIndex:plotIndex];
                ORKValueRange *yAxisValueRange = self.yAxisPoints[plotIndex][pointIndex];
                CALayer *pointLayer = _pointLayers[plotIndex][pointLayerIndex];
                pointLayer.position = CGPointMake(positionOnXAxis, yAxisValueRange.minimumValue);
                pointLayerIndex++;

                if (!yAxisValueRange.isEmptyRange) {
                    CALayer *pointLayer = _pointLayers[plotIndex][pointLayerIndex];
                    pointLayer.position = CGPointMake(positionOnXAxis, yAxisValueRange.maximumValue);
                    pointLayerIndex++;
                }
            }
        }
    }
}

#pragma mark - Scrubbing

- (double)scrubbingValueForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex {
    return self.dataPoints[plotIndex][pointIndex].maximumValue;
}

- (double)scrubbingYAxisPointForPlotIndex:(NSInteger)plotIndex pointIndex:(NSInteger)pointIndex {
    return self.yAxisPoints[plotIndex][pointIndex].maximumValue;
}

#pragma mark - Animation

- (void)prepareAnimationsForPlotIndex:(NSInteger)plotIndex {
    [super prepareAnimationsForPlotIndex:plotIndex];
    [_pointLayers[plotIndex] makeObjectsPerformSelector:@selector(removeAllAnimations)];
    for (CAShapeLayer *pointLayer in _pointLayers[plotIndex]) {
        pointLayer.opacity = 0;
    }
}

- (void)animateLayersSequentiallyWithDuration:(NSTimeInterval)duration plotIndex:(NSInteger)plotIndex {
    [super animateLayersSequentiallyWithDuration:duration plotIndex:plotIndex];
    NSUInteger numberOfPoints = _pointLayers[plotIndex].count;
    if (numberOfPoints > 0) {
        CGFloat pointFadeDuration = duration / numberOfPoints;
        CGFloat pointDelay = 0.0;
        for (NSUInteger pointIndex = 0; pointIndex < numberOfPoints; pointIndex++) {
            CALayer *layer = _pointLayers[plotIndex][pointIndex];
            [self animateLayer:layer keyPath:@"opacity" duration:pointFadeDuration startDelay:pointDelay];
            pointDelay += pointFadeDuration;
        }
    }
}

@end
