/*
Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


@interface ORKPieChartView ()

@property (nonatomic) CGFloat pieChartRadius;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic) CGFloat legendDotRadius;

@property (nonatomic) CGFloat legendPaddingHeight;

@property (nonatomic) CGFloat plotRegionHeight;

@property (nonatomic, strong) NSMutableArray *actualValues;

@property (nonatomic, strong) NSMutableArray *normalizedValues;

@property (nonatomic) CGFloat sumOfValues;

@property (nonatomic, strong) UILabel *emptyLabel;

@end


@implementation ORKPieChartView

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

- (void)sharedInit {
    _lineWidth = CGRectGetHeight(self.frame)/20.0f;
    
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.strokeColor = [UIColor colorWithWhite:0.96 alpha:1.000].CGColor;
    _circleLayer.lineWidth = _lineWidth;
    _legendDotRadius = 9;
    
    _shouldAnimate = YES;
    _shouldAnimateLegend = YES;
    _animationDuration = 0.35f;
    _shouldDrawClockwise = YES;
    
    _actualValues = [NSMutableArray new];
    _normalizedValues = [NSMutableArray new];
    _sumOfValues = 0;
    
    _legendFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    _percentageFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    
    _centreTitleLabel = [UILabel new];
    [_centreTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieChartRadius/3.0f]];
    [_centreTitleLabel setTextColor:[UIColor colorWithWhite:0.17 alpha:1.0]];
    [_centreTitleLabel setTextAlignment:NSTextAlignmentCenter];
    
    _centreSubtitleLabel = [UILabel new];
    [_centreSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieChartRadius/6.0f]];
    [_centreSubtitleLabel setTextColor:[UIColor colorWithWhite:0.55 alpha:1.0]];
    [_centreSubtitleLabel setTextAlignment:NSTextAlignmentCenter];
    
    _emptyText = NSLocalizedString(@"No Data", @"No Data");
}

- (void)setupEmptyView {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _emptyLabel.text = self.emptyText;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
        _emptyLabel.textColor = [UIColor lightGrayColor];
        _emptyLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
    
    [self addSubview:_emptyLabel];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.circleLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self updateValues];
    self.circleLayer.frame = CGRectMake(CGRectGetWidth(self.frame)/2 - self.pieChartRadius, _plotRegionHeight/2 - self.pieChartRadius, self.pieChartRadius * 2, self.pieChartRadius * 2);
    self.circleLayer.path = [self circularPath].CGPath;
    [self.layer addSublayer:self.circleLayer];

    // Reset Data
    [self.actualValues removeAllObjects];
    [self.normalizedValues removeAllObjects];
    [self normalizeActualValues];
    
    [self drawTitleLabels];
    [self drawPieChart];
    [self drawPercentageLabels];
    [self drawLegend];
    
    if (self.sumOfValues == 0) {
        [self setupEmptyView];
    }
}

- (void)drawTitleLabels {
    CGFloat labelWidth = self.pieChartRadius * 1.2;
    CGFloat labelXPos = CGRectGetMidX(self.circleLayer.frame) - labelWidth/2;
    CGFloat labelYPos = CGRectGetMidY(self.circleLayer.frame);
    
    [self.centreTitleLabel setFrame:CGRectMake(labelXPos, labelYPos, labelWidth, self.pieChartRadius*0.4)];
    [self.centreSubtitleLabel setFrame:CGRectMake(labelXPos, CGRectGetMaxY(self.centreTitleLabel.frame), labelWidth, CGRectGetHeight(self.centreTitleLabel.frame)*0.6)];
    
    [self addSubview:self.centreTitleLabel];
    [self addSubview:self.centreSubtitleLabel];
}

- (void)updateValues {
    _legendPaddingHeight = CGRectGetHeight(self.frame) * 0.35;
    _plotRegionHeight = (CGRectGetHeight(self.frame)) - _legendPaddingHeight;
    _pieChartRadius = _plotRegionHeight * 0.55 * 0.5;
    [_centreTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieChartRadius/3.0f]];
    [_centreSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieChartRadius/6.0f]];
}

- (UIBezierPath *)circularPath {
    CGPoint center = CGPointMake(CGRectGetWidth(self.circleLayer.bounds)/2, CGRectGetHeight(self.circleLayer.bounds)/2);
    CGFloat radius = self.pieChartRadius;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3*M_PI_2;
    
    if (!self.shouldDrawClockwise) {
        startAngle = 3*M_PI_2;
        endAngle = -M_PI_2;
    }

    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:self.shouldDrawClockwise];
    
    return circularArcBezierPath;
}

#pragma mark - Private Methods

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
    } else{
        
        // Default colors
        NSInteger numberOfSegments = [self numberOfSegments];
        if(numberOfSegments > 1){
            CGFloat divisionFactor = (CGFloat)(1/(CGFloat)(numberOfSegments -1));
            color = [UIColor colorWithWhite:(divisionFactor * index) alpha:1.0f];
        } else{
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

- (void)drawPieChart {
    CGFloat cumulativeValue = 0;
    
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        segmentLayer.fillColor = [[UIColor clearColor] CGColor];
        segmentLayer.frame = self.circleLayer.bounds;
        segmentLayer.path = self.circleLayer.path;
        segmentLayer.lineCap = self.circleLayer.lineCap;
        segmentLayer.lineWidth = self.circleLayer.lineWidth;
        segmentLayer.strokeColor = [self colorForSegmentAtIndex:idx].CGColor;
        CGFloat value = ((NSNumber *)self.normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            
            if (idx == 0) {
                segmentLayer.strokeStart = 0.0;
            } else {
                segmentLayer.strokeStart = cumulativeValue;
            }
            
            segmentLayer.strokeEnd = cumulativeValue;
            [self.circleLayer addSublayer:segmentLayer];
            
            if (self.shouldAnimate) {
                
                CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                strokeAnimation.fromValue = @(segmentLayer.strokeStart);
                strokeAnimation.toValue = @(cumulativeValue + value);
                strokeAnimation.duration = _animationDuration + 0.1;
                strokeAnimation.removedOnCompletion = NO;
                strokeAnimation.fillMode = kCAFillModeForwards;
                strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [segmentLayer addAnimation:strokeAnimation forKey:@"strokeAnimation"];
            }
            else {
                segmentLayer.strokeEnd = cumulativeValue + value;
            }
        }
        cumulativeValue += value;
    }
}

- (void)drawPercentageLabels {
    CGFloat cumulativeValue = 0;
    NSMutableArray * textLayers = [NSMutableArray array];
    
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = ((NSNumber *)self.normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            CGFloat angle = (value/2 + cumulativeValue) * M_PI * 2;
            
            if (!self.shouldDrawClockwise) {
                angle = (value/2 + cumulativeValue) * - M_PI * 2;
            }
            
            CGPoint labelCenter = [self getCirclePointForAngle: angle];
            
            NSString *text = [NSString stringWithFormat:@"%0.0f%%", (value < .01) ? 1 :value * 100];
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.string = text;
            textLayer.fontSize = 14.0;
            textLayer.foregroundColor = [self colorForSegmentAtIndex:idx].CGColor;
            
            CGFloat textWidth = [text boundingRectWithSize:CGSizeMake(100, 21) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:textLayer.fontSize]} context:nil].size.width;
            
            textLayer.frame = CGRectMake(0, 0, textWidth, 21);
            textLayer.position = labelCenter;
            textLayer.alignmentMode = @"center";
            textLayer.contentsScale = [[UIScreen mainScreen] scale];
            
            NSMutableDictionary * layerData = [@{@"layer" : textLayer, @"angle": [NSNumber numberWithFloat:angle]} mutableCopy];
            [textLayers addObject: layerData];
            
            [self.circleLayer addSublayer: textLayer];
            
            cumulativeValue += value;
            
            if (self.shouldAnimate) {
                
                CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                textAnimation.fromValue = @0;
                textAnimation.toValue = @1;
                textAnimation.duration = 0.3;
                textAnimation.removedOnCompletion = NO;
                textAnimation.fillMode = kCAFillModeForwards;
                textAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [textLayer addAnimation:textAnimation forKey:@"textAnimation"];
            }
        }
    }
    [self adjustIntersectionsOfLayers:textLayers];
}

- (CGPoint)getCirclePointForAngle:(CGFloat) angle {
    CGRect boundingBox = CGPathGetBoundingBox(self.circleLayer.path);
    NSInteger offset = self.lineWidth/2 + 20;
    CGPoint labelCenter = CGPointMake(cos(angle - M_PI_2) * (self.pieChartRadius + offset) + boundingBox.size.width/2, sin(angle - M_PI_2) * (self.pieChartRadius + offset) + boundingBox.size.height/2);
    return labelCenter;
}

- (void)adjustIntersectionsOfLayers:(NSArray*) layers {
    if (!layers.count){
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
            for (NSUInteger idx = 0; idx < layers.count - 1; idx++) {
                // Prevent from infinite loop
                if (!idx) {
                    totalAngle+= 0.01;
                    if (totalAngle >= 2*M_PI) {
                        return;
                    }
                }
                NSMutableDictionary* layerDict = layers[idx];
                NSMutableDictionary* nextLayerDict = layers[(idx+1)];
                if ([self shiftLayerDictionary:nextLayerDict fromLayerDictionary:layerDict inDirection:rotateDirection]) {
                    intersections = YES;
                }
            }
        } else {
            for (NSInteger i = layers.count - 1; i > 0; i--) {
                NSMutableDictionary* layerDict = layers[i];
                NSMutableDictionary* nextLayerDict = layers[i - 1];
                if ([self shiftLayerDictionary:nextLayerDict fromLayerDictionary:layerDict inDirection:-rotateDirection]) {
                    intersections = YES;
                }
            }
        }
        // Adjust space between last and first element
        NSMutableDictionary* lastLayerDict = layers.lastObject;
        CALayer * lastLayer = lastLayerDict[@"layer"];
        NSMutableDictionary* firstLayerDict = layers.firstObject;
        CALayer * firstLayer = firstLayerDict[@"layer"];
        if (CGRectIntersectsRect(lastLayer.frame, firstLayer.frame)) {
            CGFloat firstLayerAngle = [firstLayerDict[@"angle"] floatValue];
            CGFloat lastLayerAngle = [lastLayerDict[@"angle"] floatValue];
            firstLayerAngle += rotateDirection * 0.01;
            lastLayerAngle -= rotateDirection*0.01;
            firstLayerDict[@"angle"] = [NSNumber numberWithFloat:firstLayerAngle];
            lastLayerDict[@"angle"] = [NSNumber numberWithFloat:lastLayerAngle];
        }
    }
}

- (BOOL)shiftLayerDictionary:(NSMutableDictionary*)nextLayerDictionary fromLayerDictionary:(NSMutableDictionary*)fromLayerDictionary inDirection:(CGFloat) direction {
    CGFloat shiftStep = 0.01;
    CALayer * layer = fromLayerDictionary[@"layer"];
    CALayer * nextLayer = nextLayerDictionary[@"layer"];
    if (CGRectIntersectsRect(layer.frame, nextLayer.frame)) {
        CGFloat nextLayerAngle = [nextLayerDictionary[@"angle"] floatValue];
        nextLayerAngle += direction*shiftStep;
        nextLayerDictionary[@"angle"] = [NSNumber numberWithFloat:nextLayerAngle];
        nextLayer.position = [self getCirclePointForAngle: nextLayerAngle];
        return YES;
    }
    return NO;
}

- (void)drawLegend {
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        
        CGFloat dotSegmentWidth = (CGRectGetWidth(self.frame)/[self numberOfSegments]);
        CGFloat dotXPosition = dotSegmentWidth * (idx + 0.5);
        
        CAShapeLayer *dot = [CAShapeLayer layer];
        dot.frame = CGRectMake(0, 0, self.legendDotRadius*2, self.legendDotRadius*2);
        dot.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(dot.bounds), CGRectGetHeight(dot.bounds))
                                              cornerRadius:self.legendDotRadius].CGPath;
        dot.position = CGPointMake(dotXPosition, self.plotRegionHeight + self.legendDotRadius*3.5);
        dot.fillColor = [self colorForSegmentAtIndex:idx].CGColor;
        [self.layer addSublayer:dot];
        
        NSString *text = @"";
        if ([self.datasource respondsToSelector:@selector(pieChartView:titleForSegmentAtIndex:)]) {
            text = [self.datasource pieChartView:self titleForSegmentAtIndex:idx];
        }
        CGFloat labelPadding = 5;
        UILabel *textLabel = [UILabel new];
        textLabel.text = text;
        textLabel.font = self.legendFont;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.adjustsFontSizeToFitWidth = NO;
        textLabel.frame = CGRectMake(labelPadding + dotSegmentWidth * idx, self.plotRegionHeight + 3.5*self.legendDotRadius, dotSegmentWidth - 2*labelPadding, self.legendPaddingHeight - self.legendDotRadius*2);
        textLabel.numberOfLines = 1;
        textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:textLabel];

        if (self.shouldAnimateLegend) {
            
            CABasicAnimation *dotAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            dotAnimation.fromValue = [NSValue valueWithCGPoint:self.circleLayer.position];
            dotAnimation.toValue = [NSValue valueWithCGPoint:dot.position];
            dotAnimation.beginTime = CACurrentMediaTime() + 0.05*idx;
            dotAnimation.duration = _animationDuration;
            dotAnimation.removedOnCompletion = NO;
            dotAnimation.fillMode = kCAFillModeForwards;
            dotAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [dot addAnimation:dotAnimation forKey:@"dotAnimation"];
            
            CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            textAnimation.fromValue = @0;
            textAnimation.toValue = @1;
            textAnimation.beginTime = CACurrentMediaTime() + 0.05*idx;
            textAnimation.duration = dotAnimation.duration;
            textAnimation.removedOnCompletion = NO;
            textAnimation.fillMode = kCAFillModeForwards;
            textAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [textLabel.layer addAnimation:textAnimation forKey:@"textAnimation"];
        }
    }
}

#pragma mark - Data Normalization

- (void)normalizeActualValues {
    self.sumOfValues = 0;
    
    for (int idx=0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = [self valueForSegmentAtIndex:idx];
        [self.actualValues addObject:@(value)];
        self.sumOfValues += value;
    }
    
    for (int idx=0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = 0;
        if (self.sumOfValues != 0) {
            value = ((NSNumber *)self.actualValues[idx]).floatValue/self.sumOfValues;
        }
        [self.normalizedValues addObject:@(value)];
    }
}

@end
