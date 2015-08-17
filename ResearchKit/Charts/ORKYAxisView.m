/*
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


#import "ORKYAxisView.h"
#import "ORKGraphView_Internal.h"


static const CGFloat ImageVerticalPadding = 3.0;

@implementation ORKYAxisView {
    __weak ORKGraphView *_parentGraphView;
    NSMutableArray *_titleTickLayers;
    
    UIImageView *_maxImageView;
    UIImageView *_minImageView;
    
    NSMutableDictionary *_tickLayersByFactor;
    NSMutableDictionary *_tickLabelsByFactor;
}

- (instancetype)initWithParentGraphView:(ORKGraphView *)parentGraphView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _parentGraphView = parentGraphView;
        _axisColor = _parentGraphView.axisColor;
        _titleColor = _parentGraphView.axisTitleColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutTicksAndLabels];
}

- (void)updateTicksAndLabels {
    [_maxImageView removeFromSuperview];
    _maxImageView = nil;
    [_minImageView removeFromSuperview];
    _minImageView = nil;
    
    [[_tickLayersByFactor allValues] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[_tickLabelsByFactor allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _tickLayersByFactor = nil;
    _tickLabelsByFactor = nil;
    
    CGRect bounds = self.bounds;
    CGFloat width = bounds.size.width;
    if (_parentGraphView.maximumValueImage && _parentGraphView.minimumValueImage) {
        // Use image icons as legends
        CGFloat halfWidth = width / 2;
        
        _maxImageView = [[UIImageView alloc] initWithImage:_parentGraphView.maximumValueImage];
        _maxImageView.contentMode = UIViewContentModeScaleAspectFit;
        _maxImageView.frame = CGRectMake(width - halfWidth, -halfWidth/2, halfWidth, halfWidth);
        [self addSubview:_maxImageView];
        
        _minImageView = [[UIImageView alloc] initWithImage:_parentGraphView.minimumValueImage];
        _minImageView.contentMode = UIViewContentModeScaleAspectFit;
        _minImageView.frame = CGRectMake(width - halfWidth,
                                        CGRectGetMaxY(bounds) - halfWidth - ImageVerticalPadding,
                                        halfWidth,
                                        halfWidth);
        [self addSubview:_minImageView];
        
    } else {
        _tickLayersByFactor = [NSMutableDictionary new];
        _tickLabelsByFactor = [NSMutableDictionary new];
        
        NSArray *yAxisLabelFactors = nil;
        CGFloat minimumValue = _parentGraphView.minimumValue;
        CGFloat maximumValue = _parentGraphView.maximumValue;
        if (minimumValue == maximumValue) {
            yAxisLabelFactors = @[@0.5f];
        } else {
            yAxisLabelFactors = @[@0.2f, @1.0f];
        }
        
        for (NSNumber *factorNumber in yAxisLabelFactors) {
            
            CGFloat factor = factorNumber.floatValue;
            
            CALayer *tickLayer = [CALayer layer];
            CGFloat tickYPosition = CGRectGetHeight(self.bounds) * (1 - factor);
            CGFloat tickXOrigin = CGRectGetWidth(self.bounds) - ORKGraphViewAxisTickLength;
            tickLayer.frame = CGRectMake(tickXOrigin,
                                         tickYPosition - 0.5,
                                         ORKGraphViewAxisTickLength,
                                         1);
            tickLayer.backgroundColor = _parentGraphView.axisColor.CGColor;

            [self.layer addSublayer:tickLayer];
            _tickLayersByFactor[factorNumber] = tickLayer;
            
            CGFloat labelHeight = 20;
            CGFloat labelYPosition = tickYPosition - labelHeight / 2;
            UILabel *tickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           labelYPosition,
                                                                           width - (ORKGraphViewAxisTickLength + ORKGraphViewYAxisTickPadding),
                                                                           labelHeight)];
            
            CGFloat yValue = minimumValue + (maximumValue - minimumValue) * factor;
            if (yValue != 0) {
                tickLabel.text = [NSString stringWithFormat:@"%0.0f", yValue];
            }
            tickLabel.backgroundColor = [UIColor clearColor];
            tickLabel.textColor = _parentGraphView.axisTitleColor;
            tickLabel.textAlignment = NSTextAlignmentRight;
            tickLabel.font = _titleFont;
            tickLabel.minimumScaleFactor = 0.8;
            [tickLabel sizeToFit];
            [self addSubview:tickLabel];
            _tickLabelsByFactor[factorNumber] = tickLabel;
        }
    }
}

- (void)layoutTicksAndLabels {
    CGRect bounds = self.bounds;
    CGFloat width = bounds.size.width;
    CGFloat halfWidth = width / 2;
    _maxImageView.frame = CGRectMake(width - halfWidth, -halfWidth/2, halfWidth, halfWidth);
    _minImageView.frame = CGRectMake(width - halfWidth,
                                     CGRectGetMaxY(bounds) - halfWidth - ImageVerticalPadding,
                                     halfWidth,
                                     halfWidth);
    
    for (NSNumber *factorNumber in [_tickLayersByFactor allKeys]) {
        CGFloat factor = factorNumber.floatValue;
        CALayer *tickLayer = _tickLayersByFactor[factorNumber];
        CGFloat tickYPosition = CGRectGetHeight(self.bounds) * (1 - factor);
        CGFloat tickXOrigin = CGRectGetWidth(self.bounds) - ORKGraphViewAxisTickLength;
        tickLayer.frame = CGRectMake(tickXOrigin,
                                     tickYPosition - 0.5,
                                     ORKGraphViewAxisTickLength,
                                     1);
        
        UILabel *tickLabel = _tickLabelsByFactor[factorNumber];
        tickLabel.center = CGPointMake(tickXOrigin - (ORKGraphViewYAxisTickPadding + tickLabel.bounds.size.width / 2), tickYPosition);
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (UILabel *label in [_tickLabelsByFactor allValues]) {
        label.font = _titleFont;
        [label sizeToFit];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    for (UILabel *label in [_tickLabelsByFactor allValues]) {
        label.textColor = titleColor;
    }
}

- (void)setAxisColor:(UIColor *)axisColor {
    _axisColor = axisColor;
    for (CALayer *tickLayer in [_tickLayersByFactor allValues]) {
        tickLayer.backgroundColor = _axisColor.CGColor;
    }
}

@end
