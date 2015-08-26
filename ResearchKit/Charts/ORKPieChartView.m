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
#import "ORKPieChartView_Internal.h"
#import "ORKPieChartPieView.h"
#import "ORKPieChartLegendView.h"
#import "ORKPieChartTitleTextView.h"
#import "ORKSkin.h"
#import "ORKDefines_Private.h"


static const CGFloat TitleToPiePadding = 8.0;
static const CGFloat PieToLegendPadding = 8.0;

@implementation ORKPieChartSection

- (instancetype)initWithLabel:(UILabel *)label angle:(CGFloat)angle {
    if (self = [super init]) {
        _label = label;
        _angle = angle;
    }
    return self;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return self.label.isAccessibilityElement;
}

- (NSString *)accessibilityLabel {
    return self.label.accessibilityLabel;
}

- (CGRect)accessibilityFrame {
    return self.label.accessibilityFrame;
}

@end


@implementation ORKPieChartView {
    NSMutableArray *_variableConstraints;

    ORKPieChartPieView *_pieView;
    ORKPieChartLegendView *_legendView;
    ORKPieChartTitleTextView *_titleTextView;
    BOOL _shouldInvalidateLegendViewIntrinsicContentSize;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDataSource:(id<ORKPieChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    CGFloat sumOfValues = [_pieView normalizeValues];
    [_pieView updatePieLayers];
    [_pieView updatePercentageLabels];
    [_titleTextView showNoDataLabel:(sumOfValues == 0)];
    [self updateLegendView];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [_pieView setNeedsLayout];
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

- (void)setShowsTitleAboveChart:(BOOL)showsTitleAboveChart {
    _showsTitleAboveChart = showsTitleAboveChart;
    [self setNeedsUpdateConstraints];
}

- (void)setShowsPercentageLabels:(BOOL)showsPercentageLabels {
    _showsPercentageLabels = showsPercentageLabels;
    [_pieView updatePercentageLabels];
    [_pieView setNeedsLayout];
}

- (void)setDrawsClockwise:(BOOL)drawsClockwise {
    _drawsClockwise = drawsClockwise;
    [_pieView setNeedsLayout];
}

- (void)updateContentSizeCategoryFonts {
    _titleTextView.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _titleTextView.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _titleTextView.noDataLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _pieView.percentageLabelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    _legendView.labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void)sharedInit {
    _lineWidth = 10;
    _showsTitleAboveChart = NO;
    _showsPercentageLabels = YES;
    _drawsClockwise = YES;
    
    _legendView = nil; // legend lazily initialized on demand

    _pieView = [[ORKPieChartPieView alloc] initWithParentPieChartView:self];
    [self addSubview:_pieView];

    _titleTextView = [[ORKPieChartTitleTextView alloc] initWithParentPieChartView:self];
    [self addSubview:_titleTextView];
    
    [self updateContentSizeCategoryFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContentSizeCategoryFonts)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [self setUpConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_pieView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pieView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_pieView]->=0-|"
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

    if (_showsTitleAboveChart) {
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
    
    if (_legendView) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_pieView, _legendView);
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_legendView]|"
                                                 options:(NSLayoutFormatOptions)0
                                                 metrics:nil
                                                   views:views]];
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pieView]-PlotToLegendPadding-[_legendView]|"
                                                 options:(NSLayoutFormatOptions)0
                                                 metrics:@{ @"PlotToLegendPadding": @(PieToLegendPadding) }
                                                   views:views]];
    }
    
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (void)updateLegendView {
    if ([_dataSource respondsToSelector:@selector(pieChartView:titleForSegmentAtIndex:)]) {
        _legendView = [[ORKPieChartLegendView alloc] initWithParentPieChartView:self];
        [self addSubview:_legendView];
        _legendView.labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _shouldInvalidateLegendViewIntrinsicContentSize = YES;
    } else {
        [_legendView removeFromSuperview];
        _legendView = nil;
    }
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_shouldInvalidateLegendViewIntrinsicContentSize) {
        _shouldInvalidateLegendViewIntrinsicContentSize = NO;
        [_legendView invalidateIntrinsicContentSize];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [_legendView invalidateIntrinsicContentSize];
    [self setNeedsLayout];
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
            // Avoid pure white and pure black
            CGFloat divisionFactor = (1.0 / (numberOfSegments + 1));
            CGFloat whiteComponent = (divisionFactor + (divisionFactor * index));
            color = [UIColor colorWithWhite:whiteComponent
                                      alpha:1.0f];
        } else {
            color = [UIColor grayColor];
        }
    }
    return color;
}

- (void)animateWithDuration:(NSTimeInterval)animationDuration {
    if (animationDuration < 0) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"animationDuration cannot be lower than 0" userInfo:nil];
    }
    [self layoutIfNeeded]; // layout pass needed so _pieView (a UICollectionView subclass) dequees and displays the cells
    [_pieView animateWithDuration:animationDuration];
    [_legendView animateWithDuration:animationDuration];
    [_titleTextView animateWithDuration:animationDuration];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSArray *)accessibilityElements {
    NSMutableArray *accessibilityElements = [[NSMutableArray alloc] init];
    [accessibilityElements addObjectsFromArray:_titleTextView.accessibilityElements];
    
    // Use legends if there are any and percentage labels if not
    if (_legendView) {
        [accessibilityElements addObject:_legendView];
    } else {
        [accessibilityElements addObjectsFromArray:_pieView.accessibilityElements];
    }
    
    return accessibilityElements;
}

@end
