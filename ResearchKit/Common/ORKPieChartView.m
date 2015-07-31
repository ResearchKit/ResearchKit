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


#import "ORKPieChartView.h"
#import "ORKLegendCollectionViewCell.h"
#import "ORKCenteredCollectionViewLayout.h"


@interface ORKPieChartLabel : NSObject

- (instancetype)initWithLabel:(UILabel *)label angle:(CGFloat)angle;

@property (nonatomic) UILabel *label;
@property (nonatomic) CGFloat angle;

@end


@implementation ORKPieChartLabel

- (instancetype)initWithLabel:(UILabel *)label angle:(CGFloat)angle {
    if (self = [super init])
    {
        _label = label;
        _angle = angle;
    }
    return self;
}

@end



@interface ORKPieChartView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end


@implementation ORKPieChartView {
    CGFloat _pieRadius;
    CGFloat _sumOfValues;
    CGFloat _originAngle;
    CGFloat _percentageLabelOffset;
    
    NSMutableArray *_actualValues;
    NSMutableArray *_normalizedValues;
    NSMutableArray *_constraints;
    
    CAShapeLayer *_circleLayer;
    UILabel *_emptyLabel;
    UILabel *_titleLabel;
    UILabel *_textLabel;
    UIView *_contentView;
    UIView *_plotView;
    UICollectionView *_legendView;
    UICollectionViewFlowLayout *_legendLayout;
    
    UIFont *_titleFont;
    UIFont *_textFont;
    UIFont *_legendFont;
    UIFont *_percentageFont;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)updateAppearance {
    _titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _emptyLabel.textColor = [UIColor lightGrayColor];
    _textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _legendFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _percentageFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)sharedInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAppearance)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    _lineWidth = 10;
    _percentageLabelOffset = 10;
    
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.strokeColor = [UIColor colorWithWhite:0.96 alpha:1.000].CGColor;
    _circleLayer.lineWidth = _lineWidth;
    
    _originAngle = -M_PI_2;
    
    _shouldAnimate = YES;
    _shouldAnimateLegend = YES;
    _animationDuration = 0.35f;
    _shouldDrawClockwise = YES;
    
    _actualValues = [NSMutableArray new];
    _normalizedValues = [NSMutableArray new];
    _sumOfValues = 0;

    _titleLabel = [UILabel new];
    _textLabel = [UILabel new];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    
    _emptyText = NSLocalizedString(@"No Data", @"No Data");
    
    _emptyLabel = [UILabel new];
    _emptyLabel.text = _emptyText;
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    
    _legendLayout = [[ORKCenteredCollectionViewLayout alloc] init];
    _legendView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout: _legendLayout];
    [_legendView registerClass: NSClassFromString(@"ORKLegendCollectionViewCell") forCellWithReuseIdentifier:@"cell"];
    _legendView.backgroundColor = [UIColor clearColor];
    _legendView.translatesAutoresizingMaskIntoConstraints = NO;
    _legendView.dataSource = self;
    _legendView.delegate = self;
    
    _plotView = [UIView new];
    _plotView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _contentView = [UIView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview: _contentView];
    [_contentView addSubview:_plotView];
    [_contentView addSubview:_legendView];
    [_contentView addSubview:_titleLabel];
    [_contentView addSubview:_textLabel];
    
    [self updateAppearance];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // element padding.
    CGFloat titlePlotPadding = 8;
    CGFloat plotLegendPadding = 8;
    
    // title / text height.
    _titleLabel.font = _titleFont;
    _textLabel.font = _textFont;
    _titleLabel.text = _title;
    _textLabel.text = _text;
    [_titleLabel sizeToFit];
    [_textLabel sizeToFit];
    CGFloat titleTextHeight = _shouldDrawTitleAboveChart ? _titleLabel.bounds.size.height + _textLabel.bounds.size.height + titlePlotPadding : 0;

    // legendView height.
    [_contentView layoutIfNeeded];
    CGFloat legendHeight = [_legendView.collectionViewLayout collectionViewContentSize].height;
    
    // plotView height.
    CGFloat plotAccessoriesHeight = (titleTextHeight + plotLegendPadding + legendHeight);
    CGFloat maximumPlotHeight = CGRectGetHeight(_contentView.frame) - plotAccessoriesHeight;
    CGFloat plotHeight = MIN(maximumPlotHeight, _contentView.frame.size.width); // The largest diameter possible within the bounds.
    
    // content padding.
    CGFloat contentHeight = plotAccessoriesHeight + plotHeight;
    CGFloat verticalWhiteSpace = CGRectGetHeight(_contentView.frame) - contentHeight;
    
    // vertically centered frames.
    _plotView.frame = CGRectMake(0, (verticalWhiteSpace * 0.5) + titleTextHeight, CGRectGetWidth(_contentView.frame), plotHeight);
    _legendView.frame = CGRectMake(0, CGRectGetMaxY(_plotView.frame) + plotLegendPadding, CGRectGetWidth(_contentView.frame), legendHeight);
    
    // circle path.
    CGFloat startAngle = _originAngle;
    CGFloat endAngle = startAngle + (2 * M_PI);
    CGFloat unlabeledRadius = plotHeight * 0.5;
    CGFloat labelHeight = [@"100%" boundingRectWithSize: CGRectInfinite.size
                                                options:0
                                             attributes:@{NSFontAttributeName : _percentageFont}
                                                context:nil].size.height;
    CGFloat labeledRadius = unlabeledRadius - (labelHeight + _percentageLabelOffset);
    _lineWidth = MIN(_lineWidth, labeledRadius);
    _circleLayer.lineWidth = _lineWidth;
    _pieRadius = labeledRadius - (_lineWidth * 0.5);
    
    if (!self.shouldDrawClockwise) {
        startAngle = 3*M_PI_2;
        endAngle = -M_PI_2;
    }
    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(_plotView.frame), CGRectGetMidY(_plotView.frame))
                                                                         radius:_pieRadius
                                                                     startAngle:startAngle
                                                                       endAngle:endAngle
                                                                      clockwise:self.shouldDrawClockwise];
    
    _circleLayer.path = circularArcBezierPath.CGPath;
    [_plotView.layer addSublayer: _circleLayer];
    
    // reset data.
    [_actualValues removeAllObjects];
    [_normalizedValues removeAllObjects];
    [self normalizeActualValues];
    
    // redraw.
    [_circleLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_plotView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_emptyLabel removeFromSuperview];
    [self drawTitleText];
    [self drawPieChart];
    [self drawPercentageLabels];
    [self drawLegend];
    
    // emptyLabel.
    if (!_sumOfValues) {
        [_emptyLabel sizeToFit];
        _emptyLabel.center = _plotView.center;
        [_plotView addSubview:_emptyLabel];
    }
}

#pragma mark - Layout

- (void)updateConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView, _plotView, _legendView, _titleLabel, _textLabel);
    
    // These constraints describe the layout used to calculate the height of _legendView in layoutSubviews, not the final layout.
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|"
                                                                              options:(NSLayoutFormatOptions)0
                                                                              metrics:nil
                                                                                views:views]];
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                              options:(NSLayoutFormatOptions)0
                                                                              metrics:nil
                                                                                views:views]];
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_legendView]|"
                                                                              options:(NSLayoutFormatOptions)0
                                                                              metrics:nil
                                                                                views:views]];
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_legendView]|"
                                                                              options:(NSLayoutFormatOptions)0
                                                                              metrics:nil
                                                                                views:views]];
    [NSLayoutConstraint activateConstraints:_constraints];
    [super updateConstraints];
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ORKLegendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.titleLabel.text = [_datasource pieChartView:self titleForSegmentAtIndex:indexPath.item];
    cell.titleLabel.font = _legendFont;
    cell.dotView.backgroundColor = [_datasource pieChartView:self colorForSegmentAtIndex:indexPath.item];
    cell.transform = CGAffineTransformMakeScale(0, 0);
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_datasource numberOfSegmentsInPieChartView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ORKLegendCollectionViewCell *cell = [[ORKLegendCollectionViewCell alloc]initWithFrame:CGRectZero];
    cell.titleLabel.text = [_datasource pieChartView:self titleForSegmentAtIndex:indexPath.item];
    cell.titleLabel.font = _legendFont;
    [cell.contentView setNeedsUpdateConstraints];
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

#pragma mark - DataSource

- (NSInteger)numberOfSegments {
    NSInteger count = 0;
    if ([self.datasource respondsToSelector:@selector(numberOfSegmentsInPieChartView)]) {
        count = [self.datasource numberOfSegmentsInPieChartView];
    }
    return count;
}

- (UIColor *)colorForSegmentAtIndex:(NSInteger)index {
    UIColor *color = nil;
    if ([self.datasource respondsToSelector:@selector(pieChartView:colorForSegmentAtIndex:)]) {
        color = [self.datasource pieChartView:self colorForSegmentAtIndex:index];
    }
    else {
        // Default colors
        NSInteger numberOfSegments = [self numberOfSegments];
        if (numberOfSegments > 1) {
            CGFloat divisionFactor = (CGFloat)(1/(CGFloat)(numberOfSegments -1));
            color = [UIColor colorWithWhite:(divisionFactor * index) alpha:1.0f];
        }
        else {
            color = [UIColor grayColor];
        }
    }
    return color;
}

- (CGFloat)valueForSegmentAtIndex:(NSInteger)index {
    CGFloat value = 0;
    if ([self.datasource respondsToSelector:@selector(pieChartView:valueForSegmentAtIndex:)]) {
        value = [self.datasource pieChartView:self valueForSegmentAtIndex:index];
    }
    return value;
}

#pragma mark - Draw

- (void)drawTitleText {
    if (_titleColor) {
        _titleLabel.textColor = _titleColor;
    }
    if (_textColor) {
        _textLabel.textColor = _textColor;
    }
    _shouldDrawTitleAboveChart ? [self drawTitleTextAboveChart] : [self drawTitleTextInFrontOfChart];
}

- (void)drawTitleTextAboveChart {
    _titleLabel.center = CGPointMake(CGRectGetMidX(_contentView.bounds), CGRectGetMinY(_contentView.bounds) + _titleLabel.bounds.size.height * 0.5);
    _textLabel.center =  CGPointMake(_titleLabel.center.x, CGRectGetMaxY(_titleLabel.frame) + _textLabel.bounds.size.height * 0.5);
}

- (void)drawTitleTextInFrontOfChart {
    _titleLabel.center = _plotView.center;
    _textLabel.center =  _plotView.center;
    
    if (_textLabel.text && _titleLabel.text) {
        _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0, - CGRectGetHeight(_titleLabel.frame) * 0.5);
        _textLabel.frame = CGRectOffset(_textLabel.frame, 0, CGRectGetHeight(_textLabel.frame) * 0.5);
    }
}

- (void)drawLegend {
    if (self.shouldAnimate) {
        NSArray *sorted = [_legendView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *cell1, UICollectionViewCell *cell2) {
            return cell1.tag > cell2.tag;
        }];
        for (UICollectionViewCell *cell in sorted) {
            [UIView animateWithDuration:0.75 delay: [sorted indexOfObject:cell] * 0.075 options:0 animations:^{
                cell.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
    else {
        for (UICollectionViewCell *cell in _legendView.visibleCells) {
            cell.transform = CGAffineTransformIdentity;
        }
    }
}

- (void)drawPieChart {
    CGFloat cumulativeValue = 0;
    
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        segmentLayer.fillColor = [[UIColor clearColor] CGColor];
        segmentLayer.frame = _circleLayer.bounds;
        segmentLayer.path = _circleLayer.path;
        segmentLayer.lineCap = _circleLayer.lineCap;
        segmentLayer.lineWidth = _circleLayer.lineWidth;
        segmentLayer.strokeColor = [self colorForSegmentAtIndex:idx].CGColor;
        CGFloat value = ((NSNumber *)_normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            if (idx == 0) {
                segmentLayer.strokeStart = 0.0;
            } else {
                segmentLayer.strokeStart = cumulativeValue;
            }
            
            segmentLayer.strokeEnd = cumulativeValue;
            [_circleLayer addSublayer:segmentLayer];
            
            if (self.shouldAnimate) {
                CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                strokeAnimation.fromValue = @(segmentLayer.strokeStart);
                strokeAnimation.toValue = @(cumulativeValue + value);
                strokeAnimation.duration = _animationDuration + 0.1;
                strokeAnimation.removedOnCompletion = NO;
                strokeAnimation.fillMode = kCAFillModeForwards;
                strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [segmentLayer addAnimation:strokeAnimation forKey:@"strokeAnimation"];
            } else {
                segmentLayer.strokeEnd = cumulativeValue + value;
            }
        }
        cumulativeValue += value;
    }
}

- (void)drawPercentageLabels {
    CGFloat cumulativeValue = 0;
    NSMutableArray *pieLabels = [NSMutableArray new];
    
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = ((NSNumber *)_normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            
            // Create a label
            UILabel *label = [UILabel new];
            label.text = [NSString stringWithFormat:@"%0.0f%%", (value < .01) ? 1 :value * 100];
            label.font = _percentageFont;
            label.textColor = [self colorForSegmentAtIndex:idx];
            [label sizeToFit];
            
            // Calculate the angle to the centre of this segment in radians
            CGFloat angle = (value / 2 + cumulativeValue) * M_PI * 2;
            if (!self.shouldDrawClockwise) {
                angle = (value / 2 + cumulativeValue) * - M_PI * 2;
            }
            
            label.center = [self percentageLabel:label calculateCenterForAngle:angle];
            [_plotView addSubview:label];
            
            cumulativeValue += value;
            ORKPieChartLabel *pieLabel = [[ORKPieChartLabel alloc] initWithLabel:label angle:angle];
            [pieLabels addObject:pieLabel];
            
            if (_shouldAnimate) {
                label.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    label.alpha = 1.0;
                }];
            }
        }
    }
    [self adjustIntersectionsOfPercentageLabels:pieLabels];
}

- (CGPoint)percentageLabel: (UILabel *)label calculateCenterForAngle:(CGFloat)angle {
    
    // Calculate the desired distance from the circle's centre.
    NSInteger lineOffset = _lineWidth / 2;
    CGFloat radius = _pieRadius;
    CGFloat offset = 10;
    CGFloat length = radius + lineOffset + offset;
    
    // Calculate x and y coordinates for the point at this distance at the specified angle.
    CGFloat cosine = cos(angle + _originAngle);
    CGFloat sine = sin(angle + _originAngle);
    CGFloat x = cosine * length + _plotView.frame.size.width / 2;
    CGFloat y = sine *  length + _plotView.frame.size.height / 2;
    
    // Offset (x,y) to normalise the spacing from the circle's centre to the intersection with the label's frame rather than its centre.
    CGSize labelSize = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat xIn = cosine * labelSize.width / 2;
    CGFloat yIn = sine * labelSize.height / 2;
    x += xIn;
    y+= yIn;
    
    return  CGPointMake(x, y);
}

- (void)adjustIntersectionsOfPercentageLabels:(NSArray *)pieLabels {
    if ([pieLabels count] == 0) {
        return;
    }
    // Adjust labels while we have intersections
    BOOL intersections = YES;
    // We alternate directions in each iteration
    BOOL shiftClockwise = NO;
    CGFloat rotateDirection = self.shouldDrawClockwise ? 1 : -1;
    // We use totalAngle to prevent from infinite loop
    CGFloat totalAngle = 0;
    while (intersections) {
        intersections = NO;
        shiftClockwise = !shiftClockwise;
        
        if (shiftClockwise) {
            for (NSUInteger idx = 0; idx < ([pieLabels count] - 1); idx++) {
                // Prevent from infinite loop
                if (!idx) {
                    totalAngle += 0.01;
                    if (totalAngle >= 2 * M_PI) {
                        return;
                    }
                }
                ORKPieChartLabel *pieLabel  = pieLabels[idx];
                ORKPieChartLabel *nextPieLabel = pieLabels[(idx + 1)];
                if ([self shiftLabel:nextPieLabel fromLabel:pieLabel inDirection:rotateDirection]) {
                    intersections = YES;
                }
            }
        } else {
            for (NSInteger i = [pieLabels count] - 1; i > 0; i--) {
                ORKPieChartLabel *pieLabel = pieLabels[i];
                ORKPieChartLabel *nextPieLabel = pieLabels[i - 1];
                if ([self shiftLabel:nextPieLabel fromLabel:pieLabel inDirection:-rotateDirection]) {
                    intersections = YES;
                }
            }
        }
        
        // Adjust space between last and first element
        ORKPieChartLabel *firstPieLabel = pieLabels.firstObject;
        ORKPieChartLabel *lastPieLabel = pieLabels.lastObject;
        UILabel *firstLabel = firstPieLabel.label;
        UILabel *lastLabel = lastPieLabel.label;
        if (CGRectIntersectsRect(lastLabel.frame, firstLabel.frame)) {
            CGFloat firstLabelAngle = firstPieLabel.angle;
            CGFloat lastLabelAngle = lastPieLabel.angle;
            firstLabelAngle += rotateDirection * 0.01;
            lastLabelAngle -= rotateDirection*0.01;
            firstPieLabel.angle = firstLabelAngle;
            lastPieLabel.angle = lastLabelAngle;
        }
    }
}

- (BOOL)shiftLabel:(ORKPieChartLabel *)nextPieLabel fromLabel:(ORKPieChartLabel *)fromPieLabel inDirection:(CGFloat) direction {
    CGFloat shiftStep = 0.01;
    UILabel *label = fromPieLabel.label;
    UILabel *nextLabel = nextPieLabel.label;
    if (CGRectIntersectsRect(label.frame, nextLabel.frame)) {
        CGFloat nextLabelAngle = nextPieLabel.angle;
        nextLabelAngle += direction * shiftStep;
        nextPieLabel.angle = nextLabelAngle;
        nextLabel.center = [self percentageLabel:nextLabel calculateCenterForAngle:nextLabelAngle];
        return YES;
    }
    return NO;
}

#pragma mark - Data Normalization

- (void)normalizeActualValues {
    _sumOfValues = 0;
    
    for (int idx = 0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = [self valueForSegmentAtIndex:idx];
        [_actualValues addObject:@(value)];
        _sumOfValues += value;
    }
    
    for (int idx = 0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = 0;
        if (_sumOfValues != 0) {
            value = ((NSNumber *)_actualValues[idx]).floatValue/_sumOfValues;
        }
        [_normalizedValues addObject:@(value)];
    }
}

@end
