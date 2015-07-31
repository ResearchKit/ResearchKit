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


NSString *const ORKGraphViewTriggerAnimationsNotification = @"ORKGraphViewTriggerAnimationsNotification";
NSString *const ORKGraphViewRefreshNotification = @"ORKGraphViewRefreshNotification";

const CGFloat ORKGraphViewLeftPadding = 10.0;
const CGFloat ORKGraphViewGrowAnimationDuration = 0.1;
const CGFloat ORKGraphViewPointAndLineSize = 8.0;

ORKDefineStringKey(FadeAnimationKey);
ORKDefineStringKey(GrowAnimationKey);

static const CGFloat TopPadding = 0.0;
static const CGFloat XAxisHeight = 30.0;
static const CGFloat YAxisPaddingFactor = 0.15;
static const CGFloat AxisMarkingRulerLength = 8.0;
static const CGFloat FadeAnimationDuration = 0.2;
static const CGFloat PopAnimationDuration  = 0.3;
static const CGFloat SnappingClosenessFactor = 0.3;
static const CGSize ScrubberThumbSize = (CGSize){10.0, 10.0};
static const CGFloat ScrubberMoveAnimationDuration = 0.1;
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
    _emptyText = NSLocalizedString(@"BASE_GRAPH_VIEW_EMPTY_TEXT", nil);
    self.dataPoints = [NSMutableArray new];
    self.xAxisPoints = [NSMutableArray new];
    self.yAxisPoints = [NSMutableArray new];
    self.xAxisTitles = [NSMutableArray new];
    self.referenceLines = [NSMutableArray new];
    self.pathLines = [NSMutableArray new];
    self.dots = [NSMutableArray new];
    self.tintColor = [UIColor colorWithRed:244/255.f green:190/255.f blue:74/255.f alpha:1.f];
    self.shouldAnimate = YES;
    self.hasDataPoint = NO;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGestureRecognizer.delaysTouchesBegan = YES;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateLayersSequentially)
                                                 name:ORKGraphViewTriggerAnimationsNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshGraph)
                                                 name:ORKGraphViewRefreshNotification
                                               object:nil];
    
    [self setupViews];
}

- (void)setupViews {
    self.plotsView = [UIView new];
    self.plotsView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.plotsView];
    
    self.scrubberLine = [UIView new];
    self.scrubberLine.backgroundColor = self.scrubberLineColor;
    self.scrubberLine.alpha = 0;
    [self addSubview:self.scrubberLine];
    
    self.scrubberLabel = [UILabel new];
    self.scrubberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12.0f];
    self.scrubberLabel.alpha = 0;
    self.scrubberLabel.layer.cornerRadius = 2.0f;
    self.scrubberLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.scrubberLabel.layer.borderWidth = 1.0f;
    self.scrubberLabel.textAlignment = NSTextAlignmentCenter;
    self.scrubberLabel.frame = CGRectMake(2, 0, 100, 20);
    self.scrubberLabel.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.8];
    [self addSubview:self.scrubberLabel];
    
    self.scrubberThumbView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      ScrubberThumbSize.width,
                                                                      ScrubberThumbSize.height)];
    self.scrubberThumbView.layer.borderWidth = 1.0;
    self.scrubberThumbView.backgroundColor = self.scrubberThumbColor;
    self.scrubberThumbView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.scrubberThumbView.alpha = 0;
    [self addSubview:self.scrubberThumbView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat yAxisPadding = CGRectGetWidth(self.frame) *YAxisPaddingFactor;
    
    // Basic Views
    self.plotsView.frame = CGRectMake(ORKGraphViewLeftPadding, TopPadding, CGRectGetWidth(self.frame) - yAxisPadding - ORKGraphViewLeftPadding, CGRectGetHeight(self.frame) - XAxisHeight - TopPadding);
    if (self.emptyLabel) {
        self.emptyLabel.frame = CGRectMake(ORKGraphViewLeftPadding, TopPadding, CGRectGetWidth(self.frame) - ORKGraphViewLeftPadding, CGRectGetHeight(self.frame) - XAxisHeight - TopPadding);
    }
    
    // Scrubber Views
    self.scrubberLine.frame = CGRectMake(CGRectGetMinX(self.scrubberLine.frame), TopPadding, 1, CGRectGetHeight(self.plotsView.frame));
    self.scrubberThumbView.frame = CGRectMake(CGRectGetMinX(self.scrubberThumbView.frame),
                                              CGRectGetMinY(self.scrubberThumbView.frame),
                                              ScrubberThumbSize.width,
                                              ScrubberThumbSize.height);
    self.scrubberThumbView.layer.cornerRadius = self.scrubberThumbView.bounds.size.height / 2;
    self.scrubberLabel.font = [UIFont fontWithName:self.scrubberLabel.font.familyName size:12.0f];
 
    [_xAxisView layoutSubviews];
}

- (void)setDefaults {
    _minimumValue = MAXFLOAT;
    _maximumValue = -MAXFLOAT;
}

#pragma mark - Drawing

- (void)refreshGraph {
    // Clear subviews and sublayers
    [self.plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    [self.plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self drawXAxis];
    [self drawYAxis];
    
    [self drawHorizontalReferenceLines];
    
    if (self.showsVerticalReferenceLines) {
        [self drawVerticalReferenceLines];
    }
    
    [self calculateXAxisPoints];
    [self.dots removeAllObjects];
    [self.pathLines removeAllObjects];
    
    for (int i = 0; i < [self numberOfPlots]; i++) {
        if ([self numberOfPointsinPlot:i] <= 1) {
            return;
        } else {
            [self drawGraphForPlotIndex:i];
        }
    }
    
    if (!self.hasDataPoint) {
        [self setupEmptyView];
    } else {
        if (self.emptyLabel) {
            [self.emptyLabel removeFromSuperview];
        }
    }
    
    [self animateLayersSequentially];
}

- (void)prepareDataForPlotIndex:(NSInteger)plotIndex {
    [_dataPoints removeAllObjects];
    [_yAxisPoints removeAllObjects];
    _hasDataPoint = NO;
    for (int i = 0; i < [self numberOfPointsinPlot:plotIndex]; i++) {
        if ([_dataSource respondsToSelector:@selector(graphView:pointForForPointIndex:plotIndex:)]) {
            ORKRangePoint *value = [self.dataSource graphView:self pointForForPointIndex:i plotIndex:plotIndex];
            [_dataPoints addObject:value];
            if (!value.isEmpty){
                _hasDataPoint = YES;
            }
        }
    }
    [self.yAxisPoints addObjectsFromArray:[self normalizeCanvasPointsForRect:self.plotsView.frame.size]];
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
    
    for (NSUInteger i = 0; i < self.yAxisPoints.count; i++) {
        ORKRangePoint *dataPointVal = (ORKRangePoint *)self.dataPoints[i];
        CGFloat positionOnXAxis = [self.xAxisPoints[i] floatValue];
        positionOnXAxis += [self offsetForPlotIndex:plotIndex];
        
        if (!dataPointVal.isEmpty) {
            ORKRangePoint *positionOnYAxis = (ORKRangePoint *)self.yAxisPoints[i];
            ORKCircleView *point = [[ORKCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
            point.tintColor = (plotIndex == 0) ? self.tintColor : self.referenceLineColor;
            point.center = CGPointMake(positionOnXAxis, positionOnYAxis.minimumValue);
            [self.plotsView.layer addSublayer:point.layer];
    
            if (self.shouldAnimate) {
                point.alpha = 0;
            }
            
            [self.dots addObject:point];
            
            if (![positionOnYAxis isRangeZero]) {
                ORKCircleView *point = [[ORKCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
                point.tintColor = (plotIndex == 0) ? self.tintColor : self.referenceLineColor;
                point.center = CGPointMake(positionOnXAxis, positionOnYAxis.maximumValue);
                [self.plotsView.layer addSublayer:point.layer];
                
                if (self.shouldAnimate) {
                    point.alpha = 0;
                }
                
                [self.dots addObject:point];
            }
        }
    }
}

- (void)drawXAxis {
    //Add Title Labels
    [self.xAxisTitles removeAllObjects];
    
    for (int i = 0; i < self.numberOfXAxisTitles; i++) {
        if ([self.dataSource respondsToSelector:@selector(graphView:titleForXAxisAtIndex:)]) {
            NSString *title = [self.dataSource graphView:self titleForXAxisAtIndex:i];
            
            [self.xAxisTitles addObject:title];
        }
    }
    
    if (self.xAxisView) {
        [self.xAxisView removeFromSuperview];
        self.xAxisView = nil;
    }
    
    self.xAxisView = [[ORKAxisView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.plotsView.frame),
                                                                   CGRectGetMaxY(self.plotsView.frame),
                                                                   CGRectGetWidth(self.plotsView.frame),
                                                                   XAxisHeight)];
    self.xAxisView.tintColor = self.tintColor;
    [self.xAxisView setupTitles:self.xAxisTitles];
    [self addSubview:self.xAxisView];
    
    UIBezierPath *xAxispath = [UIBezierPath bezierPath];
    [xAxispath moveToPoint:CGPointMake(0, 0)];
    [xAxispath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    
    CAShapeLayer *xAxisLineLayer = [CAShapeLayer layer];
    xAxisLineLayer.strokeColor = self.axisColor.CGColor;
    xAxisLineLayer.path = xAxispath.CGPath;
    [self.xAxisView.layer addSublayer:xAxisLineLayer];
    
    for (NSUInteger i = 0; i < self.xAxisTitles.count; i++) {
        CGFloat positionOnXAxis = ((CGRectGetWidth(self.plotsView.frame) / (self.numberOfXAxisTitles - 1)) * i);
        
        UIBezierPath *rulerPath = [UIBezierPath bezierPath];
        [rulerPath moveToPoint:CGPointMake(positionOnXAxis, - AxisMarkingRulerLength)];
        [rulerPath addLineToPoint:CGPointMake(positionOnXAxis, 0)];
        
        CAShapeLayer *rulerLayer = [CAShapeLayer layer];
        rulerLayer.strokeColor = self.axisColor.CGColor;
        rulerLayer.path = rulerPath.CGPath;
        [self.xAxisView.layer addSublayer:rulerLayer];
    }
}

- (void)drawYAxis {
    [self prepareDataForPlotIndex:0];
    
    if (self.yAxisView) {
        [self.yAxisView removeFromSuperview];
        self.yAxisView = nil;
    }
    
    CGFloat axisViewXPosition = CGRectGetWidth(self.frame) * (1 - YAxisPaddingFactor);
    CGFloat axisViewWidth = CGRectGetWidth(self.frame)*YAxisPaddingFactor;
    
    self.yAxisView = [[UIView alloc] initWithFrame:CGRectMake(axisViewXPosition,
                                                              TopPadding,
                                                              axisViewWidth,
                                                              CGRectGetHeight(self.plotsView.frame))];
    [self addSubview:self.yAxisView];
    CGFloat rulerXPosition = CGRectGetWidth(self.yAxisView.bounds) - AxisMarkingRulerLength + 2;
    
    if (self.maximumValueImage && self.minimumValueImage) {
        // Use image icons as legends
        CGFloat width = CGRectGetWidth(self.yAxisView.frame) / 2;
        CGFloat verticalPadding = 3.f;
        
        UIImageView *maxImageView = [[UIImageView alloc] initWithImage:self.maximumValueImage];
        maxImageView.contentMode = UIViewContentModeScaleAspectFit;
        maxImageView.frame = CGRectMake(CGRectGetWidth(self.yAxisView.bounds) - width, -width/2, width, width);
        [self.yAxisView addSubview:maxImageView];
        
        UIImageView *minImageView = [[UIImageView alloc] initWithImage:self.minimumValueImage];
        minImageView.contentMode = UIViewContentModeScaleAspectFit;
        minImageView.frame = CGRectMake(CGRectGetWidth(self.yAxisView.bounds) - width, CGRectGetMaxY(self.yAxisView.bounds) - width - verticalPadding, width, width);
        [self.yAxisView addSubview:minImageView];
        
    } else {
        
        NSArray *yAxisLabelFactors;
        
        if (self.minimumValue == self.maximumValue) {
            yAxisLabelFactors = @[@0.5f];
        } else {
            yAxisLabelFactors = @[@0.2f,@1.0f];
        }
        
        for (NSUInteger i = 0; i < yAxisLabelFactors.count; i++) {
            
            CGFloat factor = [yAxisLabelFactors[i] floatValue];
            CGFloat positionOnYAxis = CGRectGetHeight(self.plotsView.frame) * (1 - factor);
            
            UIBezierPath *rulerPath = [UIBezierPath bezierPath];
            [rulerPath moveToPoint:CGPointMake(rulerXPosition, positionOnYAxis)];
            [rulerPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.yAxisView.bounds), positionOnYAxis)];
            
            CAShapeLayer *rulerLayer = [CAShapeLayer layer];
            rulerLayer.strokeColor = self.axisColor.CGColor;
            rulerLayer.path = rulerPath.CGPath;
            [self.yAxisView.layer addSublayer:rulerLayer];
            
            CGFloat labelHeight = 20;
            CGFloat labelYPosition = positionOnYAxis - labelHeight/2;
            
            CGFloat yValue = self.minimumValue + (self.maximumValue - self.minimumValue)*factor;
            
            UILabel *axisTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYPosition, CGRectGetWidth(self.yAxisView.frame) - AxisMarkingRulerLength, labelHeight)];
            
            if (yValue != 0) {
                axisTitleLabel.text = [NSString stringWithFormat:@"%0.0f", yValue];
            }
            axisTitleLabel.backgroundColor = [UIColor clearColor];
            axisTitleLabel.textColor = self.axisTitleColor;
            axisTitleLabel.textAlignment = NSTextAlignmentRight;
            axisTitleLabel.font = self.axisTitleFont;
            axisTitleLabel.minimumScaleFactor = 0.8;
            [self.yAxisView addSubview:axisTitleLabel];
        }
    }
}

- (void)drawHorizontalReferenceLines {
    [self.referenceLines removeAllObjects];
    
    UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
    [referenceLinePath moveToPoint:CGPointMake(ORKGraphViewLeftPadding, TopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    [referenceLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), TopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = self.referenceLineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineDashPattern = @[@6, @4];
    [self.plotsView.layer addSublayer:referenceLineLayer];
    
    [self.referenceLines addObject:referenceLineLayer];
}

- (void)drawVerticalReferenceLines {
    for (int i = 1; i < self.numberOfXAxisTitles; i++) {
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(self.plotsView.frame) / (self.numberOfXAxisTitles - 1)) * i);
        
        UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
        [referenceLinePath moveToPoint:CGPointMake(positionOnXAxis, 0)];
        [referenceLinePath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotsView.frame))];
        
        CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
        referenceLineLayer.strokeColor = self.referenceLineColor.CGColor;
        referenceLineLayer.path = referenceLinePath.CGPath;
        referenceLineLayer.lineDashPattern = @[@6, @4];
        [self.plotsView.layer addSublayer:referenceLineLayer];
        
        [self.referenceLines addObject:referenceLineLayer];
    }
}

- (void)setupEmptyView {
    if (!self.emptyLabel) {
        self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(ORKGraphViewLeftPadding,
                                                                    TopPadding,
                                                                    CGRectGetWidth(self.frame) - ORKGraphViewLeftPadding,
                                                                    CGRectGetHeight(self.frame) - XAxisHeight - TopPadding)];
        self.emptyLabel.text = self.emptyText;
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
        self.emptyLabel.textColor = [UIColor lightGrayColor];
    }
    
    [self addSubview:self.emptyLabel];
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

- (NSInteger)numberOfPointsinPlot:(NSInteger)plotIndex {
    NSInteger numberOfPoints = 0;
    
    if ([_dataSource respondsToSelector:@selector(graphView:numberOfPointsForPlotIndex:)]) {
        numberOfPoints = [_dataSource graphView:self numberOfPointsForPlotIndex:plotIndex];
    }
    
    return numberOfPoints;
}

- (NSInteger)numberOfXAxisTitles {
    NSInteger numberOfXAxisTitles = 0;
    
    if ([_dataSource respondsToSelector:@selector(numberOfDivisionsInXAxisForGraphView:)]) {
        numberOfXAxisTitles = [_dataSource numberOfDivisionsInXAxisForGraphView:self];
    } else {
        numberOfXAxisTitles = [self numberOfPointsinPlot:0];
    }
    
    return numberOfXAxisTitles;
}

- (void)calculateXAxisPoints {
    [_xAxisPoints removeAllObjects];
    
    for (int i = 0; i < [self numberOfXAxisTitles]; i++) {
        CGFloat positionOnXAxis = ((CGRectGetWidth(_plotsView.frame) / (_yAxisPoints.count - 1)) * i);
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
    if ((self.dataPoints.count > 0) && [self numberOfValidValues] > 0) {
        
        CGPoint location = [gestureRecognizer locationInView:self.plotsView];
        CGFloat maxX = round(CGRectGetWidth(self.plotsView.bounds));
        CGFloat normalizedX = MAX(MIN(location.x, maxX), 0);
        location = CGPointMake(normalizedX, location.y);
        CGFloat snappedXPosition = [self snappedXPosition:location.x];
        [self updateScrubberViewForXPosition:snappedXPosition];
        
        if ([self.delegate respondsToSelector:@selector(graphView:touchesMovedToXPosition:)]) {
            [self.delegate graphView:self touchesMovedToXPosition:snappedXPosition];
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setScrubberViewsHidden:NO animated:YES];
            if ([self.delegate respondsToSelector:@selector(graphViewTouchesBegan:)]) {
                [self.delegate graphViewTouchesBegan:self];
            }
        }
        
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self setScrubberViewsHidden:YES animated:YES];
            if ([self.delegate respondsToSelector:@selector(graphViewTouchesEnded:)]) {
                [self.delegate graphViewTouchesEnded:self];
            }
        }
    }
}

- (void)updateScrubberViewForXPosition:(CGFloat)xPosition {
    [UIView animateWithDuration:ScrubberMoveAnimationDuration animations:^{
        self.scrubberLine.center = CGPointMake(xPosition + ORKGraphViewLeftPadding, self.scrubberLine.center.y);
        [self updateScrubberLineAccessories:xPosition];
    }];
}

- (void)updateScrubberLineAccessories:(CGFloat)xPosition {
    CGFloat scrubberYPos = [self canvasYPointForXPosition:xPosition];
    CGFloat scrubbingVal = [self valueForCanvasXPosition:(xPosition)];
   [self.scrubberThumbView setCenter:CGPointMake(xPosition + ORKGraphViewLeftPadding, scrubberYPos + TopPadding)];
    self.scrubberLabel.text = [NSString stringWithFormat:@"%.0f", scrubbingVal];
   CGSize textSize = [self.scrubberLabel.text boundingRectWithSize:CGSizeMake(320, CGRectGetHeight(self.scrubberLabel.bounds))
                                                           options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin)
                                                        attributes:@{NSFontAttributeName:self.scrubberLabel.font}
                                                           context:nil].size;
   [self.scrubberLabel setFrame:CGRectMake(CGRectGetMaxX(self.scrubberLine.frame) + 6, CGRectGetMinY(self.scrubberLine.frame), textSize.width + 8, CGRectGetHeight(self.scrubberLabel.frame))];
}

- (CGFloat)snappedXPosition:(CGFloat)xPosition {
    CGFloat widthBetweenPoints = CGRectGetWidth(self.plotsView.frame) / self.xAxisPoints.count;
    NSUInteger positionIndex;
    for (positionIndex = 0; positionIndex < self.xAxisPoints.count; positionIndex++) {
        
        CGFloat dataPointValue = ((ORKRangePoint *)self.dataPoints[positionIndex]).maximumValue;
        
        if (dataPointValue != NSNotFound) {
            CGFloat value = [self.xAxisPoints[positionIndex] floatValue];
            
            if (fabs(value - xPosition) < (widthBetweenPoints * SnappingClosenessFactor)) {
                xPosition = value;
            }
        }
    }
    return xPosition;
}

- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition {
    BOOL snapped = [self.xAxisPoints containsObject:@(xPosition)];
    CGFloat value = NSNotFound;
    NSUInteger positionIndex = 0;
    if (snapped) {
        for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
            CGFloat xAxisPointVal = [self.xAxisPoints[positionIndex] floatValue];
            if (xAxisPointVal == xPosition) {
                break;
            }
        }
        value = ((ORKRangePoint *)self.dataPoints[positionIndex]).maximumValue;
    }
    return value;
}

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated {
    if ([self numberOfValidValues] > 0) {
        
        void (^updateAlpha)(BOOL) = ^(BOOL hidden) {
            CGFloat alpha = hidden ? 0.0 : 1.0;
            self.scrubberThumbView.alpha = alpha;
            self.scrubberLine.alpha = alpha;
            self.scrubberLabel.alpha = alpha;
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
    for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
        CGFloat xAxisPointVal = [self.xAxisPoints[positionIndex] floatValue];
        if (xAxisPointVal > xPosition) {
            break;
        }
    }
    return positionIndex;
}

#pragma Mark - Animation

- (CGFloat)animateLayersSequentially {
    CGFloat delay = LayerAnimationDelay;
    
    for (NSUInteger i = 0; i < self.dots.count; i++) {
        CAShapeLayer *layer = [self.dots[i] shapeLayer];
        [self animateLayer:layer withAnimationType:ORKGraphAnimationTypeFade startDelay:delay];
        delay += LayerAnimationDelay;
    }
    
    for (NSUInteger i = 0; i < self.pathLines.count; i++) {
        CAShapeLayer *layer = self.pathLines[i];
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
    if (animationType == ORKGraphAnimationTypeFade) {
        
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.beginTime = CACurrentMediaTime() + delay;
        fadeAnimation.fromValue = @0;
        fadeAnimation.toValue = @(toValue);
        fadeAnimation.duration = FadeAnimationDuration;
        fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fadeAnimation.fillMode = kCAFillModeForwards;
        fadeAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:fadeAnimation forKey:FadeAnimationKey];
        
    } else if (animationType == ORKGraphAnimationTypeGrow) {
        
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        growAnimation.beginTime = CACurrentMediaTime() + delay;
        growAnimation.fromValue = @0;
        growAnimation.toValue = @(toValue);
        growAnimation.duration = ORKGraphViewGrowAnimationDuration;
        growAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        growAnimation.fillMode = kCAFillModeForwards;
        growAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:growAnimation forKey:GrowAnimationKey];
        
    } else if (animationType == ORKGraphAnimationTypePop) {
        
        CABasicAnimation *popAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        popAnimation.beginTime = CACurrentMediaTime() + delay;
        popAnimation.fromValue = @0;
        popAnimation.toValue = @(toValue);
        popAnimation.duration = PopAnimationDuration;
        popAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        popAnimation.fillMode = kCAFillModeForwards;
        popAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:popAnimation forKey:GrowAnimationKey];
        
    }
}

- (NSInteger)numberOfValidValues {
    NSInteger count = 0;
    
    for (ORKRangePoint *rangePoint in self.dataPoints) {
        if (!rangePoint.isEmpty) {
            count++;
        }
    }
    return count;
}

- (NSArray *)normalizeCanvasPointsForRect:(CGSize)canvasSize {
    [self calculateMinAndMaxPoints];
    
    NSMutableArray *normalizedPoints = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < self.dataPoints.count; i++) {
        
        ORKRangePoint *normalizedRangePoint = [ORKRangePoint new];
        ORKRangePoint *dataPointValue = (ORKRangePoint *)self.dataPoints[i];
        
        if (dataPointValue.isEmpty) {
            normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = canvasSize.height;
        } else if (self.minimumValue == self.maximumValue) {
            normalizedRangePoint.minimumValue = normalizedRangePoint.maximumValue = canvasSize.height / 2;
        } else {
            CGFloat range = self.maximumValue - self.minimumValue;
            CGFloat normalizedMinimumValue = (dataPointValue.minimumValue - self.minimumValue) / range * canvasSize.height;
            CGFloat normalizedMaximumValue = (dataPointValue.maximumValue - self.minimumValue) / range * canvasSize.height;
            
            normalizedRangePoint.minimumValue = canvasSize.height - normalizedMinimumValue;
            normalizedRangePoint.maximumValue = canvasSize.height - normalizedMaximumValue;
        }
        [normalizedPoints addObject:normalizedRangePoint];
    }
    
    return [NSArray arrayWithArray:normalizedPoints];
}

- (NSInteger)nextValidPositionIndexForPosition:(NSInteger)positionIndex {
    NSUInteger validPosition = positionIndex;
    
    while (validPosition < (self.dataPoints.count - 1)) {
        if (((ORKRangePoint *)self.dataPoints[validPosition]).maximumValue != NSNotFound) {
            break;
        }
        validPosition ++;
    }
    
    return validPosition;
}

- (void)calculateMinAndMaxPoints {
    [self setDefaults];
    
    // Minimum
    if ([self.dataSource respondsToSelector:@selector(minimumValueForGraphView:)]) {
        self.minimumValue = [self.dataSource minimumValueForGraphView:self];
    } else {
        
        if (self.dataPoints.count) {
            self.minimumValue = ((ORKRangePoint *)self.dataPoints[0]).minimumValue;
            
            for (NSUInteger i = 1; i < self.dataPoints.count; i++) {
                CGFloat value = ((ORKRangePoint *)self.dataPoints[i]).minimumValue;
                if ((self.minimumValue == NSNotFound) || (value < self.minimumValue)) {
                    self.minimumValue = value;
                }
            }
        }
    }
    
    // Maximum
    if ([self.dataSource respondsToSelector:@selector(maximumValueForGraphView:)]) {
        self.maximumValue = [self.dataSource maximumValueForGraphView:self];
    } else {
        if (self.dataPoints.count) {
            self.maximumValue = ((ORKRangePoint *)self.dataPoints[0]).maximumValue;
            
            for (NSUInteger i = 1; i < self.dataPoints.count; i++) {
                CGFloat value = ((ORKRangePoint *)self.dataPoints[i]).maximumValue;
                if (((value != NSNotFound) && (value > self.maximumValue)) || (self.maximumValue == NSNotFound)) {
                    self.maximumValue = value;
                }
            }
        }
    }
}

- (CAShapeLayer *)plotLineLayerForPlotIndex:(NSInteger)plotIndex withPath:(CGPathRef)path {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = (plotIndex == 0) ? self.tintColor.CGColor : self.referenceLineColor.CGColor;
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


@implementation ORKRangePoint

- (instancetype)init {
    self = [super init];
    if (self) {
        _minimumValue = NSNotFound;
        _maximumValue = NSNotFound;
    }
    return self;
}

- (instancetype)initWithMinimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue {
    self = [super init];
    if (self) {
        _minimumValue = minimumValue;
        _maximumValue = maximumValue;
    }
    return self;
}

- (instancetype)initWithValue:(CGFloat)value {
    return [self initWithMinimumValue:value maximumValue:value];
}

- (BOOL)isEmpty {
    return (self.minimumValue == NSNotFound && self.maximumValue == NSNotFound);
}

- (BOOL)isRangeZero {
    return (self.minimumValue == self.maximumValue);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{min: %0.0f, max: %0.0f}", self.minimumValue, self.maximumValue];
}

@end
