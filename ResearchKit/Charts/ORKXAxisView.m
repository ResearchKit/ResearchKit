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


#import "ORKXAxisView.h"
#import "ORKGraphChartView_Internal.h"


static const CGFloat LastLabelHeight = 20.0;

@implementation ORKXAxisView {
    __weak ORKGraphChartView *_parentGraphChartView;
    CALayer *_lineLayer;
    NSMutableArray<UILabel *> *_titleLabels;
    NSMutableArray<CALayer *> *_titleTickLayers;
}

- (instancetype)initWithFrame:(CGRect)frame {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithParentGraphChartView:nil];
    return self;
}

- (instancetype)initWithParentGraphChartView:(ORKGraphChartView *)parentGraphChartView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _parentGraphChartView = parentGraphChartView;
        _axisColor = _parentGraphChartView.axisColor;
        
        _lineLayer = [CALayer layer];
        _lineLayer.backgroundColor = _axisColor.CGColor;
        [self.layer addSublayer:_lineLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    _lineLayer.frame = CGRectMake(0, -0.5, width, 1);
    NSUInteger index = 0;
    NSUInteger numberOfTitleLabels = _titleTickLayers.count;
    for (CALayer *titleTickLayer in _titleTickLayers) {
        CGFloat positionOnXAxis = xAxisPoint(index, numberOfTitleLabels, width);
        titleTickLayer.frame = CGRectMake(positionOnXAxis - scalePixelAdjustment(), -ORKGraphChartViewAxisTickLength + scalePixelAdjustment(), 1, ORKGraphChartViewAxisTickLength);
        index++;
    }
    _titleLabels.lastObject.layer.cornerRadius = LastLabelHeight * 0.5;
}

- (void)setUpConstraints {
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray new];
    
    NSUInteger numberOfTitleLabels = _titleLabels.count;
    for (NSUInteger i = 0; i < numberOfTitleLabels; i++) {
        UILabel *label = _titleLabels[i];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:label.superview
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        if (i == 0) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:label.superview
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:0.0]];
        } else {
            // This "magic" multiplier constraints evenly space the labels among
            // the superview without having to manually specify its width.
            CGFloat multiplier = 1.0 - ((CGFloat)(numberOfTitleLabels - i - 1) / (numberOfTitleLabels - 1));
            [constraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:label.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:multiplier
                                                                 constant:0.0]];
        }
        
        if (i == _titleLabels.count - 1) {
            NSLayoutConstraint *constraint = nil;
            
            constraint = [NSLayoutConstraint constraintWithItem:label
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:LastLabelHeight];
            constraint.priority = UILayoutPriorityRequired - 1;
            [constraints addObject:constraint];
            
            constraint = [NSLayoutConstraint constraintWithItem:label
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:LastLabelHeight];
            constraint.priority = UILayoutPriorityRequired - 1;
            [constraints addObject:constraint];
        }
    }
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateTitles {
    [_titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)]; // Old constraints automatically removed when removing the views
    [_titleTickLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _titleLabels = nil;
    _titleTickLayers = nil;
    
    if ([_parentGraphChartView.dataSource respondsToSelector:@selector(graphChartView:titleForXAxisAtPointIndex:)]) {
        _titleLabels = [NSMutableArray new];
        _titleTickLayers = [NSMutableArray new];

        NSInteger numberOfTitleLabels = _parentGraphChartView.numberOfXAxisPoints;
        for (NSInteger i = 0; i < numberOfTitleLabels; i++) {
            NSString *title = [_parentGraphChartView.dataSource graphChartView:_parentGraphChartView titleForXAxisAtPointIndex:i];
            UILabel *label = [UILabel new];
            label.text = title;
            label.font = _titleFont;
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.7;
            label.translatesAutoresizingMaskIntoConstraints = NO;
            
            if (i < (numberOfTitleLabels - 1)) {
                label.textColor = self.tintColor;
            } else {
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = self.tintColor;
                label.layer.cornerRadius = LastLabelHeight * 0.5;
                label.layer.masksToBounds = YES;
            }
            
            [self addSubview:label];
            [_titleLabels addObject:label];
        }
        
        // Add vertical tick layers above labels
        for (NSInteger i = 0; i < numberOfTitleLabels; i++) {
            CALayer *titleTickLayer = [CALayer layer];
            CGFloat positionOnXAxis = xAxisPoint(i, numberOfTitleLabels, self.bounds.size.width);
            titleTickLayer.frame = CGRectMake(positionOnXAxis - 0.5, -ORKGraphChartViewAxisTickLength, 1, ORKGraphChartViewAxisTickLength);
            titleTickLayer.backgroundColor = _axisColor.CGColor;

            [self.layer addSublayer:titleTickLayer];
            [_titleTickLayers addObject:titleTickLayer];
        }

        [self setUpConstraints];
    }
}

- (void)tintColorDidChange {
    NSUInteger numberOfTitleLabels = _titleLabels.count;
    for (NSUInteger i = 0; i < numberOfTitleLabels; i++) {
        UILabel *label = _titleLabels[i];
        if (i < (numberOfTitleLabels - 1)) {
            label.textColor = self.tintColor;
        } else {
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = self.tintColor;
        }
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (UILabel *label in _titleLabels) {
        label.font = _titleFont;
        [label sizeToFit];
    }
    [self setNeedsLayout];
}

- (void)setAxisColor:(UIColor *)axisColor {
    _axisColor = axisColor;
    _lineLayer.backgroundColor = _axisColor.CGColor;
    for (CALayer *titleTickLayer in _titleTickLayers) {
        titleTickLayer.backgroundColor = _axisColor.CGColor;
    }
}

@end
