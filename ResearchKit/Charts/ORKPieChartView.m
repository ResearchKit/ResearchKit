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


#import "ORKPieChartView.h"
#import "ORKLegendCollectionViewCell.h"
#import "ORKCenteredCollectionViewLayout.h"
#import "ORKSkin.h"
#import "ORKDefines_Private.h"


static const CGFloat TitleToPiePadding = 8.0;
static const CGFloat PieToLegendPadding = 8.0;
static const CGFloat OriginAngle = -M_PI_2;
static const CGFloat PercentageLabelOffset = 10.0;
static const CGFloat InterAnimationDelay = 0.05;


@interface ORKPieChartView ()

- (UIColor *)colorForSegmentAtIndex:(NSInteger)index;

@end


@interface ORKPieChartSection : NSObject

- (instancetype)initWithLabel:(UILabel *)label angle:(CGFloat)angle;

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic) CGFloat angle;

@end


@implementation ORKPieChartSection

- (instancetype)initWithLabel:(UILabel *)label angle:(CGFloat)angle {
    if (self = [super init]) {
        _label = label;
        _angle = angle;
    }
    return self;
}

@end


@interface ORKPieChartPieView : UIView

@property (nonatomic) UIFont *percentageLabelFont;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame
           parentPieChartView:(ORKPieChartView *)parentPieChartView NS_DESIGNATED_INITIALIZER;

@end


@implementation ORKPieChartPieView {
    __weak ORKPieChartView *_parentPieChartView;
    
    CAShapeLayer *_circleLayer;
    NSMutableArray *_normalizedValues;
    NSMutableArray *_segmentLayers;
    NSMutableArray *_pieSections;
}

- (instancetype)initWithFrame:(CGRect)frame
           parentPieChartView:(ORKPieChartView *)parentPieChartView {
    self = [super initWithFrame:frame];
    if (self) {
        _parentPieChartView = parentPieChartView;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor colorWithWhite:0.96 alpha:1.000].CGColor;
        [self.layer addSublayer:_circleLayer];

        _normalizedValues = [NSMutableArray new];
        _segmentLayers = [NSMutableArray new];
        _pieSections = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Data Normalization

- (CGFloat)normalizeValues {
    [_normalizedValues removeAllObjects];
    
    CGFloat sumOfValues = 0;
    NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
    for (int idx = 0; idx < numberOfSegments; idx++) {
        CGFloat value = [_parentPieChartView.dataSource pieChartView:_parentPieChartView valueForSegmentAtIndex:idx];
        sumOfValues += value;
    }
    
    for (int idx = 0; idx < numberOfSegments; idx++) {
        CGFloat value = 0;
        if (sumOfValues != 0) {
            value = [_parentPieChartView.dataSource pieChartView:_parentPieChartView valueForSegmentAtIndex:idx] / sumOfValues;
        }
        [_normalizedValues addObject:@(value)];
    }
    return sumOfValues;
}

#pragma mark - Layout and drawing

- (void)setUpSublayersAndLabels {
    [_circleLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addPieChartLayers];
    [self addPercentageLabels];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGFloat startAngle = OriginAngle;
    CGFloat endAngle = startAngle + (2 * M_PI);
    CGFloat outerRadius = bounds.size.height * 0.5;
    CGFloat labelHeight = [@"100%" boundingRectWithSize:CGRectInfinite.size
                                                options:(NSStringDrawingOptions)0
                                             attributes:@{NSFontAttributeName : _percentageLabelFont}
                                                context:nil].size.height;
    CGFloat innerRadius = outerRadius - (labelHeight + PercentageLabelOffset);
    CGFloat lineWidth = MIN(_parentPieChartView.lineWidth, innerRadius);
    _circleLayer.lineWidth = lineWidth;
    CGFloat drawingRadius = innerRadius - (lineWidth * 0.5);
    
    if (!_parentPieChartView.shouldDrawClockwise) {
        startAngle = 3 * M_PI_2;
        endAngle = -M_PI_2;
    }
    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(bounds),
                                                                                            CGRectGetMidY(bounds))
                                                                         radius:drawingRadius
                                                                     startAngle:startAngle
                                                                       endAngle:endAngle
                                                                      clockwise:_parentPieChartView.shouldDrawClockwise];
    
    _circleLayer.path = circularArcBezierPath.CGPath;
    
    [self updatePieChartLayers];
    [self updatePercentageLabelsWithRadius:innerRadius];
}

- (void)addPieChartLayers {
    [_segmentLayers removeAllObjects];
    
    CGFloat cumulativeValue = 0;
    NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
    for (NSInteger idx = 0; idx < numberOfSegments; idx++) {
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        segmentLayer.fillColor = [[UIColor clearColor] CGColor];
        segmentLayer.frame = _circleLayer.bounds;
        segmentLayer.path = _circleLayer.path;
        segmentLayer.lineWidth = _circleLayer.lineWidth;
        segmentLayer.strokeColor = [_parentPieChartView colorForSegmentAtIndex:idx].CGColor;
        CGFloat value = ((NSNumber *)_normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            if (idx == 0) {
                segmentLayer.strokeStart = 0.0;
            } else {
                segmentLayer.strokeStart = cumulativeValue;
            }
            
            segmentLayer.strokeEnd = cumulativeValue;
            [_circleLayer addSublayer:segmentLayer];
            [_segmentLayers addObject:segmentLayer];
            segmentLayer.strokeEnd = cumulativeValue + value;
        }
        cumulativeValue += value;
    }
}

- (void)addPercentageLabels {
    CGFloat cumulativeValue = 0;
    NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
    for (NSInteger idx = 0; idx < numberOfSegments; idx++) {
        CGFloat value = ((NSNumber *)_normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            
            // Create a label
            UILabel *label = [UILabel new];
            label.text = [NSString stringWithFormat:@"%0.0f%%", (value < .01) ? 1 :value * 100];
            label.font = _percentageLabelFont;
            label.textColor = [_parentPieChartView colorForSegmentAtIndex:idx];
            [label sizeToFit];
            
            // Calculate the angle to the centre of this segment in radians
            CGFloat angle = 0;
            if (_parentPieChartView.shouldDrawClockwise) {
                angle = (value / 2 + cumulativeValue) * M_PI * 2;
            } else {
                angle = (value / 2 + cumulativeValue) * - M_PI * 2;
            }
            
            cumulativeValue += value;
            ORKPieChartSection *pieSection = [[ORKPieChartSection alloc] initWithLabel:label angle:angle];
            [_pieSections addObject:pieSection];
            [self addSubview:label];
        }
    }
}

- (void)updatePieChartLayers {
    NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
    for (NSInteger idx = 0; idx < numberOfSegments; idx++) {
        CAShapeLayer *segmentLayer = _segmentLayers[idx];
        segmentLayer.frame = _circleLayer.bounds;
        segmentLayer.path = _circleLayer.path;
        segmentLayer.lineWidth = _circleLayer.lineWidth;
    }
}

- (void)updatePercentageLabelsWithRadius:(CGFloat)pieRadius {
    CGFloat cumulativeValue = 0;
    NSInteger numberOfSegments = [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
    for (NSInteger idx = 0; idx < numberOfSegments; idx++) {
        CGFloat value = ((NSNumber *)_normalizedValues[idx]).floatValue;
        if (value != 0) {
            // Create a label
            ORKPieChartSection *pieSection = _pieSections[idx];
            UILabel *label = pieSection.label;
            
            // Calculate the angle to the centre of this segment in radians
            CGFloat angle = (value / 2 + cumulativeValue) * M_PI * 2;
            if (!_parentPieChartView.shouldDrawClockwise) {
                angle = (value / 2 + cumulativeValue) * - M_PI * 2;
            }
            
            label.center = [self percentageLabel:label calculateCenterForAngle:angle pieRadius:pieRadius];
            cumulativeValue += value;
        }
    }
    [self adjustIntersectionsOfPercentageLabels:_pieSections pieRadius:pieRadius];
}

- (CGPoint)percentageLabel:(UILabel *)label calculateCenterForAngle:(CGFloat)angle pieRadius:(CGFloat)pieRadius {
    // Calculate the desired distance from the circle's centre.
    const CGFloat offset = 10;
    CGFloat length = pieRadius + offset;
    
    // Calculate x and y coordinates for the point at this distance at the specified angle.
    CGSize size = self.bounds.size;
    CGFloat cosine = cos(angle + OriginAngle);
    CGFloat sine = sin(angle + OriginAngle);
    CGFloat x = cosine * length + size.width / 2;
    CGFloat y = sine *  length + size.height / 2;
    
    // Offset (x,y) to normalise the spacing from the circle's centre to the intersection with the label's frame rather than its centre.
    CGSize labelSize = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat xIn = cosine * labelSize.width / 2;
    CGFloat yIn = sine * labelSize.height / 2;
    x += xIn;
    y += yIn;
    
    return  CGPointMake(x, y);
}

- (void)adjustIntersectionsOfPercentageLabels:(NSArray *)pieSections pieRadius:(CGFloat)pieRadius {
    if (pieSections.count == 0) {
        return;
    }
    // Adjust labels while we have intersections
    BOOL intersections = YES;
    // We alternate directions in each iteration
    BOOL shiftClockwise = NO;
    CGFloat rotateDirection = _parentPieChartView.shouldDrawClockwise ? 1 : -1;
    // We use totalAngle to prevent from infinite loop
    CGFloat totalAngle = 0;
    while (intersections) {
        intersections = NO;
        shiftClockwise = !shiftClockwise;
        
        if (shiftClockwise) {
            for (NSUInteger idx = 0; idx < ([pieSections count] - 1); idx++) {
                // Prevent from infinite loop
                if (!idx) {
                    totalAngle += 0.01;
                    if (totalAngle >= 2 * M_PI) {
                        return;
                    }
                }
                ORKPieChartSection *pieLabel  = pieSections[idx];
                ORKPieChartSection *nextPieLabel = pieSections[(idx + 1)];
                if ([self shiftSectionLabel:nextPieLabel fromSectionLabel:pieLabel direction:rotateDirection pieRadius:pieRadius]) {
                    intersections = YES;
                }
            }
        } else {
            for (NSInteger i = [pieSections count] - 1; i > 0; i--) {
                ORKPieChartSection *pieLabel = pieSections[i];
                ORKPieChartSection *nextPieLabel = pieSections[i - 1];
                if ([self shiftSectionLabel:nextPieLabel fromSectionLabel:pieLabel direction:-rotateDirection pieRadius:pieRadius]) {
                    intersections = YES;
                }
            }
        }
        
        // Adjust space between last and first element
        ORKPieChartSection *firstPieLabel = pieSections.firstObject;
        ORKPieChartSection *lastPieLabel = pieSections.lastObject;
        UILabel *firstLabel = firstPieLabel.label;
        UILabel *lastLabel = lastPieLabel.label;
        if (CGRectIntersectsRect(lastLabel.frame, firstLabel.frame)) {
            CGFloat firstLabelAngle = firstPieLabel.angle;
            CGFloat lastLabelAngle = lastPieLabel.angle;
            firstLabelAngle += rotateDirection * 0.01;
            lastLabelAngle -= rotateDirection * 0.01;
            firstPieLabel.angle = firstLabelAngle;
            lastPieLabel.angle = lastLabelAngle;
        }
    }
}

- (BOOL)shiftSectionLabel:(ORKPieChartSection *)nextPieSection
         fromSectionLabel:(ORKPieChartSection *)fromPieSection
                direction:(CGFloat)direction
                pieRadius:(CGFloat)pieRadius {
    CGFloat shiftStep = 0.01;
    UILabel *label = fromPieSection.label;
    UILabel *nextLabel = nextPieSection.label;
    if (CGRectIntersectsRect(label.frame, nextLabel.frame)) {
        CGFloat nextLabelAngle = nextPieSection.angle;
        nextLabelAngle += direction * shiftStep;
        nextPieSection.angle = nextLabelAngle;
        nextLabel.center = [self percentageLabel:nextLabel calculateCenterForAngle:nextLabelAngle pieRadius:pieRadius];
        return YES;
    }
    return NO;
}

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    NSUInteger pieSectionCount = _pieSections.count;
    NSTimeInterval interAnimationDelay = InterAnimationDelay;
    NSTimeInterval singleAnimationDuration = animationDuration - (interAnimationDelay * (pieSectionCount-1));
    if (singleAnimationDuration < 0) {
        interAnimationDelay = 0;
        singleAnimationDuration = animationDuration;
    }
    
    CGFloat cumulativeValue = 0;
    for (int idx = 0; idx < pieSectionCount; idx++) {
        ORKPieChartSection *section = _pieSections[idx];
        UILabel *label = section.label;
        label.alpha = 0;
        [UIView animateWithDuration:singleAnimationDuration
                              delay:interAnimationDelay * idx
                            options:(UIViewAnimationOptions)0
                         animations:^{
                             label.alpha = 1.0;
                         }
                         completion:nil];
    
        CAShapeLayer *segmentLayer = _segmentLayers[idx];
        CGFloat value = ((NSNumber *)_normalizedValues[idx]).floatValue;
        CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeAnimation.fromValue = @(segmentLayer.strokeStart);
        strokeAnimation.toValue = @(cumulativeValue + value);
        strokeAnimation.duration = animationDuration;
        strokeAnimation.removedOnCompletion = NO;
        strokeAnimation.fillMode = kCAFillModeForwards;
        strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [segmentLayer addAnimation:strokeAnimation forKey:@"strokeAnimation"];

        cumulativeValue += value;
    }
}

@end


@interface ORKPieChartLegendView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UIFont *labelFont;

- (instancetype)initWithFrame:(CGRect)frame
         collectionViewLayout:(UICollectionViewLayout *)collectionViewLayout NS_UNAVAILABLE;

- (instancetype)initWithParentPieChartView:(ORKPieChartView *)parentPieChartView NS_DESIGNATED_INITIALIZER;

@end


@implementation ORKPieChartLegendView {
    __weak ORKPieChartView *_parentPieChartView;
}

- (instancetype)initWithParentPieChartView:(ORKPieChartView *)parentPieChartView {
    ORKCenteredCollectionViewLayout *centeredCollectionViewLayout = [[ORKCenteredCollectionViewLayout alloc] init];
    self = [super initWithFrame:CGRectZero collectionViewLayout:centeredCollectionViewLayout];
    if (self) {
        _parentPieChartView = parentPieChartView;
        [self registerClass:[ORKLegendCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.dataSource = self;
        self.delegate = self;
        
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeMake(UIViewNoIntrinsicMetric, [self.collectionViewLayout collectionViewContentSize].height);
    return size;
}

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    NSArray *sortedCells = [self.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *cell1, UICollectionViewCell *cell2) {
        return cell1.tag > cell2.tag;
    }];
    NSUInteger cellCount = sortedCells.count;
    NSTimeInterval interAnimationDelay = 0.05;
    NSTimeInterval singleAnimationDuration = animationDuration - (interAnimationDelay * (cellCount-1));
    if (singleAnimationDuration < 0) {
        interAnimationDelay = 0;
        singleAnimationDuration = animationDuration;
    }
    for (int idx = 0; idx < cellCount; idx++) {
        UICollectionViewCell *cell = sortedCells[idx];
        cell.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:singleAnimationDuration
                              delay:interAnimationDelay * idx
                            options:(UIViewAnimationOptions)0
                         animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ORKLegendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.titleLabel.text = [_parentPieChartView.dataSource pieChartView:_parentPieChartView
                                                 titleForSegmentAtIndex:indexPath.item];
    cell.titleLabel.font = _labelFont;
    cell.dotView.backgroundColor = [_parentPieChartView.dataSource pieChartView:_parentPieChartView
                                                         colorForSegmentAtIndex:indexPath.item];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_parentPieChartView.dataSource numberOfSegmentsInPieChartView:_parentPieChartView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ORKLegendCollectionViewCell *cell = [[ORKLegendCollectionViewCell alloc] initWithFrame:CGRectZero];
    cell.titleLabel.text = [_parentPieChartView.dataSource pieChartView:_parentPieChartView titleForSegmentAtIndex:indexPath.item];
    cell.titleLabel.font = _labelFont;
    [cell.contentView setNeedsUpdateConstraints];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    // NSLog(@"%@", NSStringFromCGSize(size));
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

@end


@interface ORKPieChartTitleTextView : UIView

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UILabel *noDataLabel;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame
           parentPieChartView:(ORKPieChartView *)parentPieChartView NS_DESIGNATED_INITIALIZER;


@end


@implementation ORKPieChartTitleTextView  {
    __weak ORKPieChartView *_parentPieChartView;
    
    NSMutableArray *_variableConstraints;
}

- (instancetype)initWithFrame:(CGRect)frame
           parentPieChartView:(ORKPieChartView *)parentPieChartView {
    self = [super initWithFrame:frame];
    if (self) {
        _parentPieChartView = parentPieChartView;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _titleLabel = [UILabel new];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];

        _textLabel = [UILabel new];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        
        _noDataLabel = [UILabel new];
        _noDataLabel.textColor = [UIColor lightGrayColor];
        _noDataLabel.text = ORKLocalizedString(@"CHART_NO_DATA_TEXT", nil);
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.hidden = YES;

        [self addSubview:_titleLabel];
        [self addSubview:_textLabel];
        [self addSubview:_noDataLabel];
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self setUpConstraints];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_noDataLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _textLabel, _noDataLabel);
    if (_noDataLabel.hidden) {
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel][_textLabel]|"
                                                 options:(NSLayoutFormatOptions)0
                                                 metrics:nil
                                                   views:views]];
    } else {
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_noDataLabel]|"
                                                 options:(NSLayoutFormatOptions)0
                                                 metrics:nil
                                                   views:views]];
    }
    
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (void)showNoDataLabel:(BOOL)showNoDataLabel {
    _titleLabel.hidden = showNoDataLabel;
    _textLabel.hidden = showNoDataLabel;
    _noDataLabel.hidden = !showNoDataLabel;
    [self setNeedsUpdateConstraints];
}

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    _titleLabel.alpha = 0.0;
    _textLabel.alpha = 0.0;
    _noDataLabel.alpha = 0.0;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _titleLabel.alpha = 1.0;
                         _textLabel.alpha = 1.0;
                         _noDataLabel.alpha = 1.0;
                     }];
}

@end


@implementation ORKPieChartView {
    NSMutableArray *_variableConstraints;

    ORKPieChartPieView *_pieView;
    ORKPieChartLegendView *_legendView;
    ORKPieChartTitleTextView *_titleTextView;
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

- (void)updateContentSizeFonts {
    _titleTextView.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _titleTextView.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _titleTextView.noDataLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _pieView.percentageLabelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    _legendView.labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void)sharedInit {
    _drawTitleAboveChart = NO;
    
    _lineWidth = 10;
    _shouldDrawClockwise = YES;
    
    _legendView = [[ORKPieChartLegendView alloc] initWithParentPieChartView:self];
    
    _pieView = [[ORKPieChartPieView alloc] initWithFrame:CGRectZero parentPieChartView:self];
    
    _titleTextView = [[ORKPieChartTitleTextView alloc] initWithFrame:CGRectZero parentPieChartView:self];
    
    [self addSubview:_pieView];
    [self addSubview:_legendView];
    [self addSubview:_titleTextView];
    
    [self updateContentSizeFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContentSizeFonts)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [self setUpConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_pieView, _legendView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_legendView]|"
                                                                              options:(NSLayoutFormatOptions)0
                                                                              metrics:nil
                                                                                views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pieView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_pieView]-PlotToLegendPadding-[_legendView]|"
                                                                              options:(NSLayoutFormatOptions)0
                                                                             metrics:@{ @"PlotToLegendPadding": @(PieToLegendPadding) }
                                                                                views:views]];

    NSLayoutConstraint *maximumHeightConstraint = [NSLayoutConstraint constraintWithItem:_pieView
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0
                                                                                constant:ORKScreenMetricMaxDimension];
    maximumHeightConstraint.priority = UILayoutPriorityDefaultLow - 1;
    [constraints addObject:maximumHeightConstraint];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:_titleTextView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_pieView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }

    if (_drawTitleAboveChart) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_pieView, _titleTextView);
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleTextView]-TitleToPiePading-[_pieView]"
                                                 options:(NSLayoutFormatOptions)0
                                                 metrics:@{ @"TitleToPiePading": @(TitleToPiePadding) }
                                                   views:views]];

    } else {
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_titleTextView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_pieView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0.0]];
    }
    
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (void)setDataSource:(id<ORKPieChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    CGFloat sumOfValues = [_pieView normalizeValues];
    [_pieView setUpSublayersAndLabels];
    [_titleTextView showNoDataLabel:(sumOfValues == 0)];
    [_legendView invalidateIntrinsicContentSize];
    [self layoutIfNeeded];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (![self.traitCollection isEqual:previousTraitCollection]) {
        [_legendView invalidateIntrinsicContentSize];
    }
}

- (void)setTitle:(NSString *)title {
    _titleTextView.titleLabel.text = title;
}

- (NSString *)title {
    return _titleTextView.titleLabel.text;
}

- (void)setText:(NSString *)text {
    _titleTextView.textLabel.text = text;
}

- (NSString *)text {
    return _titleTextView.textLabel.text;
}

- (void)setNoDataText:(NSString *)noDataText {
    _titleTextView.noDataLabel.text = noDataText;
}

- (NSString *)noDataText {
    return _titleTextView.noDataLabel.text;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleTextView.titleLabel.textColor = titleColor;
}

- (UIColor *)titleColor {
    return _titleTextView.titleLabel.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _titleTextView.textLabel.textColor = textColor;
}

- (UIColor *)textColor {
    return _titleTextView.textLabel.textColor;
}

- (void)setDrawTitleAboveChart:(BOOL)drawTitleAboveChart {
    _drawTitleAboveChart = drawTitleAboveChart;
    [self setNeedsUpdateConstraints];
}

#pragma mark - DataSource

- (UIColor *)colorForSegmentAtIndex:(NSInteger)index {
    UIColor *color = nil;
    if ([_dataSource respondsToSelector:@selector(pieChartView:colorForSegmentAtIndex:)]) {
        color = [_dataSource pieChartView:self colorForSegmentAtIndex:index];
    }
    else {
        // Default colors
        NSInteger numberOfSegments = [_dataSource numberOfSegmentsInPieChartView:self];
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

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    if (animationDuration < 0) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"animationDuration cannot be lower than 0" userInfo:nil];
    }
    [self layoutIfNeeded]; // Needed so _pieView (a UICollectionView subclass) dequees and displays the cells
    [_pieView animateWithDuration:animationDuration];
    [_legendView animateWithDuration:animationDuration];
}

@end
