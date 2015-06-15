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
 An object that adopts the `ORKPieChartViewDataSource` protocol is responsible for providing the
 data required to populate an `ORKPieChartView` object.

 At a minimumm a data source object must implement the `numberOfSegmentsInPieChartView` and
 `pieChartView:valueForSegmentAtIndex:`methods. These methods are responsible for returning the
 number of segments in a pie chart view and the value for each segment. Optionally, a data source
 object may provide additional information to the pie chart by implementing the remaining
 `ORKPieChartViewDataSource` methods.

 When configuring an `ORKPieChartView` object, assign your data source to its dataSource property.
*/
ORK_AVAILABLE_DECL
@protocol ORKPieChartViewDataSource <NSObject>

@required
/**
 Asks the data source for the number of segments in the pie chart view.

 @return The number of segments in the pie chart view.
*/
- (NSInteger)numberOfSegmentsInPieChartView;

/**
 Asks the data source for the value of a segment in the pie chart view.

 @param pieChartView     The pie chart view asking for the value of the segment.
 @param index            An index number specifying the segment in `pieChartView`.

 @return The value of the segment at the specified `index` in `pieChartView`.
*/
- (CGFloat)pieChartView:(ORKPieChartView *)pieChartView valueForSegmentAtIndex:(NSInteger)index;

@optional
/**
 Asks the data source for the color of a segment in the pie chart view.

 If this method is not implemented, the pie chart view will use a unique grayscale shade for each
 segment.

 @param pieChartView     The pie chart view asking for the color of the segment.
 @param index            An index number specifying the segment in `pieChartView`.

 @return The color of the segment at the specified `index` in `pieChartView`.
*/
- (UIColor *)pieChartView:(ORKPieChartView *)pieChartView colorForSegmentAtIndex:(NSInteger)index;

/**
 Asks the data source for the title to appear in the legend for a segment in the pie chart view.

 If this method is not implemented, the pie chart view will not display a title in the legend for
 the segment at the specified index.

 @param pieChartView     The pie chart view asking for the title.
 @param index            An index number specifying the segment in `pieChartView`.

 @return The string value to appear as the title for the segement at the specified `index` in the
 legend of `pieChartView`.
*/
- (NSString *)pieChartView:(ORKPieChartView *)pieChartView titleForSegmentAtIndex:(NSInteger)index;

@end

/* 
 The `ORKPieChartView` class presents data provided by an object conforming to the
 `ORKPieChartViewDataSource` protocol as a pie chart.
*/
ORK_CLASS_AVAILABLE
@interface ORKPieChartView : UIView

/**
 The data source object responsible for populating the pie chart with data.
*/
@property (nonatomic, weak, nullable) id <ORKPieChartViewDataSource> datasource;

/**
 A Boolean value indicating whether the pie chart should animate when it is drawn.
 The default value for this property is YES.
*/
@property (nonatomic) BOOL shouldAnimate;

/**
 A Boolean value indicating whether the legend should animate when it is drawn.
 The default value for this property is YES.
*/
@property (nonatomic) BOOL shouldAnimateLegend;

/**
 The duration, measured in seconds, of the pie chart and legend animations.
 If you do not set a value for this property, the pie chart view will assume a sensible value.
*/
@property (nonatomic) CGFloat animationDuration;

/**
 The width of the line used to draw the pie chart.
 If you do not set a value for this property, the pie chart view will assume a sensible value.
*/
@property (nonatomic) CGFloat lineWidth;

/**
 The text to display as a title in the pie chart view.
 If you do not set a value for this property, the pie chart will not display a title.
*/
@property (nonatomic, strong, nullable) NSString *title;

/**
 The text to display beneath a title in the pie chart view.
 If you do not set a value for this property, the pie chart will not display any text beneath the
 title.
*/
@property (nonatomic, strong, nullable) NSString *text;

/**
 A Boolean value indicating whether the percentage labels drawn adjacent to each segement are
 hidden.
 The default value for this property is NO.
*/
@property (nonatomic) BOOL hidesPercentageLabels;

/**
 A Boolean value indicating whether the legend is hidden.
 The default value for this property is NO.
*/
@property (nonatomic) BOOL hidesLegend;

/**
 A Boolean value indicating whether the pie chart drawing animation should proceed clockwise or
 anticlockwise.
 The default value for this property is YES.
*/
@property (nonatomic) BOOL shouldDrawClockwise;

/*
 A string that will be displayed in the UI if the sum of the values of all segments is zero.
 If you do not set a value for this property, the pie chart will use a sensible value.
*/
@property (nonatomic, strong, nullable) NSString *emptyText;

@end

NS_ASSUME_NONNULL_END
