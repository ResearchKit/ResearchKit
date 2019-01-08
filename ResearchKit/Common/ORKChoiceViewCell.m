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


#import "ORKChoiceViewCell.h"

#import "ORKSelectionTitleLabel.h"
#import "ORKSelectionSubTitleLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


static const CGFloat LabelRightMargin = 44.0;
static const CGFloat cardTopBottomMargin = 2.0;

@interface ORKChoiceViewCell()

@property (nonatomic) UIView *containerView;

@end

@implementation ORKChoiceViewCell {
    
    CGFloat _leftRightMargin;
    CGFloat _topBottomMargin;
    CAShapeLayer *_contentMaskLayer;
    
    UIImageView *_checkView;
    ORKSelectionTitleLabel *_shortLabel;
    ORKSelectionSubTitleLabel *_longLabel;
    NSArray<NSLayoutConstraint *> *_containerConstraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        _leftRightMargin = 0.0;
        _topBottomMargin = 0.0;
        _checkView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.accessoryView = _checkView;
        [self setupContainerView];
        [self setupConstraints];
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setMaskLayers];
}

- (void)setMaskLayers {
    if (_useCardView) {
        if (_contentMaskLayer) {
            for (CALayer *sublayer in [_contentMaskLayer.sublayers mutableCopy]) {
                [sublayer removeFromSuperlayer];
            }
            [_contentMaskLayer removeFromSuperlayer];
            _contentMaskLayer = nil;
        }
        _contentMaskLayer = [[CAShapeLayer alloc] init];
        UIColor *fillColor = [UIColor ork_borderGrayColor];
        [_contentMaskLayer setFillColor:[fillColor CGColor]];
        
        CAShapeLayer *foreLayer = [CAShapeLayer layer];
        [foreLayer setFillColor:[[UIColor whiteColor] CGColor]];
        foreLayer.zPosition = 0.0f;
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];

        if (_isLastItem || _isFirstItemInSectionWithoutTitle) {
            NSUInteger rectCorners;
            if (_isLastItem && !_isFirstItemInSectionWithoutTitle) {
                rectCorners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }
            else if (!_isLastItem && _isFirstItemInSectionWithoutTitle) {
                rectCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
            }
            else {
                rectCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }
            
            CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height - ORKCardDefaultBorderWidth);
            
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.containerView.bounds
                                                           byRoundingCorners: rectCorners
                                                                 cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
            
            CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
            
            foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds
                                                   byRoundingCorners: rectCorners
                                                         cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
        }
        else {
            CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height);
            foreLayer.path = [UIBezierPath bezierPathWithRect:foreLayerBounds].CGPath;
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
            
            CGRect lineBounds = CGRectMake(_leftRightMargin, self.containerView.bounds.size.height - 1.0, self.containerView.bounds.size.width - 2 * _leftRightMargin, 0.5);
            lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
            lineLayer.zPosition = 0.0f;
            [lineLayer setFillColor:[[UIColor ork_midGrayTintColor] CGColor]];

        }
        [_contentMaskLayer addSublayer:foreLayer];
        [_contentMaskLayer addSublayer:lineLayer];
        [_containerView.layer insertSublayer:_contentMaskLayer atIndex:0];
    }
}


- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    
    [self.contentView addSubview:_containerView];
}

- (void)setupConstraints {
    if (_containerConstraints) {
        [NSLayoutConstraint deactivateConstraints:_containerConstraints];
    }
    
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _containerConstraints = @[
                              [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                              [NSLayoutConstraint constraintWithItem:self.contentView
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0],
                              [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                              [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:_leftRightMargin],
                              [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-_leftRightMargin],
                              [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]
                              ];
    [NSLayoutConstraint activateConstraints:_containerConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat firstBaselineOffsetFromTop = ORKGetMetricForWindow(ORKScreenMetricChoiceCellFirstBaselineOffsetFromTop, self.window);
    CGFloat labelLastBaselineToLabelFirstBaseline = ORKGetMetricForWindow(ORKScreenMetricChoiceCellLabelLastBaselineToLabelFirstBaseline, self.window);
    
    CGFloat cellLeftMargin = self.separatorInset.left;

    CGFloat labelWidth =  self.bounds.size.width - (cellLeftMargin + LabelRightMargin);
    CGFloat cellHeight = self.bounds.size.height;
    
    if (self.longLabel.text.length == 0 && self.shortLabel.text.length == 0) {
        self.shortLabel.frame = CGRectZero;
        self.longLabel.frame = CGRectZero;
    } else if (self.longLabel.text.length == 0) {
        self.shortLabel.frame = CGRectMake(cellLeftMargin, 0, labelWidth, cellHeight);
        self.longLabel.frame = CGRectZero;
    } else if (self.shortLabel.text.length == 0) {
        self.longLabel.frame = CGRectMake(cellLeftMargin, 0, labelWidth, cellHeight);
        self.shortLabel.frame = CGRectZero;
    } else {
        {
            self.shortLabel.frame = CGRectMake(cellLeftMargin, 0,
                                               labelWidth, 1);
            
            ORKAdjustHeightForLabel(self.shortLabel);
            
            CGRect rect = self.shortLabel.frame;
            
            CGFloat shortLabelFirstBaselineApproximateOffsetFromTop = self.shortLabel.font.ascender;
            
            rect.origin.y = firstBaselineOffsetFromTop - shortLabelFirstBaselineApproximateOffsetFromTop;
            self.shortLabel.frame = rect;
        }
        
        {
            self.longLabel.frame = CGRectMake(cellLeftMargin, 0,
                                              labelWidth, 1);
            
            ORKAdjustHeightForLabel(self.longLabel);
            
            CGRect rect = self.longLabel.frame;
            
            CGFloat shortLabelBaselineApproximateOffsetFromBottom = ABS(self.shortLabel.font.descender);
            CGFloat longLabelApproximateFirstBaselineOffset = self.longLabel.font.ascender;
            
            rect.origin.y = CGRectGetMaxY(self.shortLabel.frame) - shortLabelBaselineApproximateOffsetFromBottom + labelLastBaselineToLabelFirstBaseline - longLabelApproximateFirstBaselineOffset;
    
            self.longLabel.frame = rect;
            
        }
    }
    [self updateSelectedItem];
    [self setMaskLayers];
}

- (void)setUseCardView:(bool)useCardView {
    _useCardView = useCardView;
    _leftRightMargin = ORKCardLeftRightMargin;
    _topBottomMargin = cardTopBottomMargin;
    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupConstraints];

}

- (ORKSelectionTitleLabel *)shortLabel {
    if (_shortLabel == nil ) {
        _shortLabel = [ORKSelectionTitleLabel new];
        _shortLabel.numberOfLines = 0;
        [self.containerView addSubview:_shortLabel];
    }
    return _shortLabel;
}

- (ORKSelectionSubTitleLabel *)longLabel {
    if (_longLabel == nil) {
        _longLabel = [ORKSelectionSubTitleLabel new];
        _longLabel.numberOfLines = 0;
        _longLabel.textColor = [UIColor ork_darkGrayColor];
        [self.containerView addSubview:_longLabel];
    }
    return _longLabel;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self updateSelectedItem];
}

- (void)updateSelectedItem {
    if (_immediateNavigation == NO) {
        self.accessoryView.hidden = _selectedItem ? NO : YES;
        if (_selectedItem) {
            self.shortLabel.textColor = [self tintColor];
            self.longLabel.textColor = [[self tintColor] colorWithAlphaComponent:192.0 / 255.0];
        }
    }
}

- (void)setImmediateNavigation:(BOOL)immediateNavigation {
    _immediateNavigation = immediateNavigation;
    
    if (_immediateNavigation == YES) {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)setSelectedItem:(BOOL)selectedItem {
    _selectedItem = selectedItem;
    [self updateSelectedItem];
}

+ (CGFloat)suggestedCellHeightForPrimaryText:(NSString *)shortText primaryTextAttributedString:(NSAttributedString *)primaryTextAttributedString detailText:(NSString *)longText  detailTextAttributedString:(NSAttributedString *)detailTextAttributedString inTableView:(UITableView *)tableView {
    CGFloat height = 0;
    
    CGFloat firstBaselineOffsetFromTop = ORKGetMetricForWindow(ORKScreenMetricChoiceCellFirstBaselineOffsetFromTop, tableView.window);
    CGFloat labelLastBaselineToLabelFirstBaseline = ORKGetMetricForWindow(ORKScreenMetricChoiceCellLabelLastBaselineToLabelFirstBaseline, tableView.window);
    CGFloat lastBaselineToBottom = ORKGetMetricForWindow(ORKScreenMetricChoiceCellLastBaselineToBottom, tableView.window);
    CGFloat cellLeftMargin =  ORKStandardLeftMarginForTableViewCell(tableView);
    CGFloat labelWidth =  tableView.bounds.size.width - (cellLeftMargin + LabelRightMargin);
   
    if (shortText.length > 0 || primaryTextAttributedString != nil) {
        static ORKSelectionTitleLabel *shortLabel;
        if (shortLabel == nil) {
            shortLabel = [ORKSelectionTitleLabel new];
            shortLabel.numberOfLines = 0;
        }
        
        shortLabel.frame = CGRectMake(0, 0, labelWidth, 0);
        shortLabel.text = shortText;
        if (primaryTextAttributedString) {
            shortLabel.attributedText = primaryTextAttributedString;
        }
        ORKAdjustHeightForLabel(shortLabel);
        CGFloat shortLabelFirstBaselineApproximateOffsetFromTop = shortLabel.font.ascender;
    
        height += firstBaselineOffsetFromTop - shortLabelFirstBaselineApproximateOffsetFromTop + shortLabel.frame.size.height;
    }
    
    if (longText.length > 0 || detailTextAttributedString != nil) {
        static ORKSelectionSubTitleLabel *longLabel;
        if (longLabel == nil) {
            longLabel = [ORKSelectionSubTitleLabel new];
            longLabel.numberOfLines = 0;
        }
        
        longLabel.frame = CGRectMake(0, 0, labelWidth, 0);
        longLabel.text = longText;
        if (detailTextAttributedString) {
            longLabel.attributedText = detailTextAttributedString;
        }
        ORKAdjustHeightForLabel(longLabel);
        
        CGFloat longLabelApproximateFirstBaselineOffset = longLabel.font.ascender;
        
        if (shortText.length > 0) {
            height += labelLastBaselineToLabelFirstBaseline - longLabelApproximateFirstBaselineOffset + longLabel.frame.size.height;
        } else {
            height += firstBaselineOffsetFromTop - longLabelApproximateFirstBaselineOffset + longLabel.frame.size.height;
        }

    }
    
    height += lastBaselineToBottom;
   
    CGFloat minCellHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, tableView.window);
    
    return MAX(height, minCellHeight);
}

#pragma mark - Accessibility

- (NSString *)accessibilityLabel {
    return ORKAccessibilityStringForVariables(self.shortLabel.accessibilityLabel, self.longLabel.accessibilityLabel);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitButton | (self.selectedItem ? UIAccessibilityTraitSelected : 0);
}

@end
