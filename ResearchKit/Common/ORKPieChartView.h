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


#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>

@class ORKPieChartView;

NS_ASSUME_NONNULL_BEGIN

/**
    The pie chart view data source is responsible for providing the data required to populate
    a pie chart view.
 */
ORK_AVAILABLE_DECL
@protocol ORKPieChartViewDatasource <NSObject>

@required
/**
    Returns the number of segments in the pie chart.
    Defaults to zero if not implemented.
    
    @return The number of segments in the pie chart.
 */
- (NSInteger)numberOfSegmentsInPieChartView;

/**
    Returns the value of a segment in the pie chart.
    Defaults to zero if not implemented.
 
    @param pieChartView     The pie chart view instance using the returned value.
    @param index            The index of the segment of `pieChartView` displaying the returned value.
 
    @return The value of the segment at the given `index` in `pieChartView`.
 */
- (CGFloat)pieChartView:(ORKPieChartView *)pieChartView valueForSegmentAtIndex:(NSInteger)index;

@optional
/**
    Returns the color of a segment in the pie chart.
    Defaults to a unique grayscale shade per segment if not implemented.
 
    @param pieChartView     The pie chart view instance using the returned value.
    @param index            The index of the segment of `pieChartView` displaying the returned value.
 
    @return The color of the segment at the given `index` in `pieChartView`.
 */
- (UIColor *)pieChartView:(ORKPieChartView *)pieChartView colorForSegmentAtIndex:(NSInteger)index;

/**
    Returns the title which appears in the legend for a segment in the pie chart.
    Defaults to an empty string if not implemented.
 
    @param pieChartView     The pie chart view instance using the returned value.
    @param index            The index of the segment of `pieChartView` corresponding to the returned value.
 
    @return The string value to appear as the title for the segement at the given `index` in the legend of `pieChartView`.
 */
- (NSString *)pieChartView:(ORKPieChartView *)pieChartView titleForSegmentAtIndex:(NSInteger)index;

@end

/* 
    The `ORKPieChartView` class presents data provided by an object conforming to the `ORKPieChartViewDataSource`
    protocol as a pie chart.
 */
ORK_CLASS_AVAILABLE
@interface ORKPieChartView : UIView

/**
    The data source responsible for populating the pie chart with data.
    If nil, the pie chart will be empty.
 */
@property (nonatomic, weak, nullable) id <ORKPieChartViewDatasource> datasource;

/**
    A Boolean value indicating whether the pie chart should animate when it is drawn.
    Defaults to YES.
 */
@property (nonatomic) BOOL shouldAnimate;

/**
    A Boolean value indicating whether the legend should animate when it is drawn.
    Defaults to YES.
 */
@property (nonatomic) BOOL shouldAnimateLegend;

/**
    The duration, measured in seconds, of the pie chart and legend animations.
    Defaults to a sensible value.
 */
@property (nonatomic) CGFloat animationDuration;

/**
    The font used to display titles appearing in the legend.
    Defaults to a system font.
 */
@property (nonatomic, strong, nullable) UIFont *legendFont;

/**
    The font used to display the percentages appearing adjacent to each segment.
    Defaults to a system font.
 */
@property (nonatomic, strong, nullable) UIFont *percentageFont;

/**
    A Boolean value indicating whether the percentage labels drawn adjacent to each segement are hidden.
    Defaults to NO.
 */
@property (nonatomic) BOOL hidesPercentageLabels;

/**
    A Boolean value indicating whether the legend is hidden.
    Defaults to NO.
 */
@property (nonatomic) BOOL hidesLegend;

/**
    A label drawn centrally, within the bounds of the pie chart.
    The value of the `text` property of this label is empty by default.
 */
@property (nonatomic) UILabel *centreTitleLabel;

/*
    A label drawn centrally, within the bounds of the pie chart, beneath the `centreTitleLabel`
    The value of the `text` property of this label is empty by default.
 */
@property (nonatomic) UILabel *centreSubtitleLabel;

/**
    A Boolean value indicating whether the pie chart drawing animation should proceed clockwise or anticlockwise.
    Defaults to YES.
 */
@property (nonatomic) BOOL shouldDrawClockwise;

/*
    A string that will be displayed in the UI if the sum of the values of all segments is zero.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) NSString *emptyText;

@end

NS_ASSUME_NONNULL_END
