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


@import UIKit;
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKPieChartView;

/**
 An object that adopts the `ORKPieChartViewDataSource` protocol is responsible for providing the
 data required to populate an `ORKPieChartView` object.

 At a minimumm, a data source object must implement the `numberOfSegmentsInPieChartView` and
 `pieChartView:valueForSegmentAtIndex:` methods. These methods are responsible for returning the
 number of segments in a pie chart view and the value for each segment. A data source object may
 provide additional information to the pie chart by implementing the optional
 `ORKPieChartViewDataSource` methods.

 When configuring an `ORKPieChartView` object, assign your data source to its `dataSource` property.
*/
ORK_AVAILABLE_DECL
@protocol ORKPieChartViewDataSource <NSObject>

@required
/**
 Asks the data source for the number of segments in the pie chart view.
 
 @param pieChartView     The pie chart view asking for the number of segments.
 
 @return The number of segments in the pie chart view.
*/
- (NSInteger)numberOfSegmentsInPieChartView:(ORKPieChartView *)pieChartView;

/**
 Asks the data source for the value of a segment in the pie chart view.
 
 The value can be any arbitrary integer: the pie chart view normalizes them by the sum of all
 returned values.

 @param pieChartView     The pie chart view asking for the value of the segment.
 @param index            An index number specifying the segment in the pie chart view.

 @return The value of the segment at the specified `index` in the pie chart view.
*/
- (CGFloat)pieChartView:(ORKPieChartView *)pieChartView valueForSegmentAtIndex:(NSInteger)index;

@optional
/**
 Asks the data source for the color of a segment in the pie chart view.

 If this method is not implemented, the pie chart view uses a unique shade of the current
 tint color for each segment.

 @param pieChartView     The pie chart view asking for the color of the segment.
 @param index            An index number specifying the segment in the pie chart view.

 @return The color of the segment at the specified `index` in the pie chart view.
*/
- (UIColor *)pieChartView:(ORKPieChartView *)pieChartView colorForSegmentAtIndex:(NSInteger)index;

/**
 Asks the data source for the title to appear in the legend for a segment in the pie chart view.

 If this method is not implemented, the pie chart view does not display the legend.

 @param pieChartView     The pie chart view asking for the title.
 @param index            An index number specifying the segment in the pie chart view.

 @return The title of the segment at the specified index in the pie chat view's
 legend.
*/
- (NSString *)pieChartView:(ORKPieChartView *)pieChartView titleForSegmentAtIndex:(NSInteger)index;

@end

/**
 The `ORKPieChartView` class presents data provided by an object conforming to the
 `ORKPieChartViewDataSource` protocol as a pie chart.
*/
ORK_CLASS_AVAILABLE
IB_DESIGNABLE
@interface ORKPieChartView : UIView

/**
 The data source object responsible for populating the pie chart with data.
*/
@property (nonatomic, weak, nullable) id <ORKPieChartViewDataSource> dataSource;

/**
 The width of the line used to draw the circular sections of the pie chart.
 
 If you do not set a value for this property, the pie chart view assumes a sensible value. If
 you set a number higher than the radius of the pie chart, the pie chart draws a completely
 filled pie.
*/
@property (nonatomic) IBInspectable CGFloat lineWidth;

/**
 The text to display as a title in the pie chart view.
 
 If you do not set a value for this property, the pie chart does not display a title.
*/
@property (nonatomic, copy, nullable) IBInspectable NSString *title;

/**
 The text to display beneath the title in the pie chart view.
 
 If you do not set a value for this property, the pie chart does not display any text beneath the
 title.
*/
@property (nonatomic, copy, nullable) IBInspectable NSString *text;

/**
 The color used for the text of the title label.
 
 The default value for this property is a light gray color. Setting this property to `nil` resets it
 to its default value.
 */
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *titleColor;

/**
 The color used for the text of the text label.
 
 The default value for this property is a light gray color. Setting this property to `nil` resets it
 to its default value.
 */
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *textColor;

/**
 A Boolean value indicating whether the title and text labels should be drawn above the chart.
 
 If this value of this property is `NO`, the title and text are drawn at the center of the chart.
 The default value for this property is `NO`.
 */
@property (nonatomic) IBInspectable BOOL showsTitleAboveChart;

/**
 A Boolean value indicating whether the pie chart should draw percentage labels next to each
 segement.
 
 The default value for this property is YES.
*/
@property (nonatomic) IBInspectable BOOL showsPercentageLabels;

/**
 A Boolean value indicating whether the pie chart drawing animation draws clockwise or
 counterclockwise.
 
 The default value for this property is YES.
*/
@property (nonatomic) IBInspectable BOOL drawsClockwise;

/**
 The string that will be displayed if the sum of the values of all segments is zero.
 
 The default value for this property is an appropriate message string. Setting this property to
 `nil` resets it to its default value.
*/
@property (nonatomic, copy, null_resettable) IBInspectable NSString *noDataText;

/**
 Animates the pie chart when it is first displayed on the screen.
 
 You can optionally call this method from the `viewWillAppear:` implementation of the view
 controller that owns the pie chart view.
 
 @param animationDuration       The duration of the appearing animation.
*/
- (void)animateWithDuration:(NSTimeInterval)animationDuration;

/**
 Reloads the plotted data.
 
 Call this method to reload the data and re-plot the graph. You should call it if the data provided by the dataSource changes.
 */
- (void)reloadData;

/**
 A scaling facor for the radius of the pie chart.
 Increase it to increase the radius of the pie chart and vice versa.
 
 Defaults to 0.5.
 */
@property (nonatomic) CGFloat radiusScaleFactor;

@end

NS_ASSUME_NONNULL_END
