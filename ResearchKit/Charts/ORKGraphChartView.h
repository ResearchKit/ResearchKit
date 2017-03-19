/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 Copyright (c) 2017, Macro Yau.

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
#import "ORKDefines.h"


NS_ASSUME_NONNULL_BEGIN

@class ORKValueRange;
@class ORKValueStack;
@class ORKGraphChartView;

/**
 The graph chart view delegate protocol forwards pan gesture events occuring
 within the bounds of an `ORKGraphChartView` object.
*/
ORK_AVAILABLE_DECL
@protocol ORKGraphChartViewDelegate <NSObject>

@optional
/**
 Notifies the delegate that a pan gesture has begun within the bounds of an `ORKGraphChartView`
 object.

 @param graphChartView      The graph chart view in which the gesture occurred.
*/
- (void)graphChartViewTouchesBegan:(ORKGraphChartView *)graphChartView;

/**
 Notifies the delegate of updates in the x-coordinate of an ongoing pan gesture within the bounds
 of an `ORKGraphChartView` object.

 @param graphChartView      The graph chart view object in which the gesture occurred.
 @param xPosition           The updated x-coordinate of the ongoing pan gesture.
*/
- (void)graphChartView:(ORKGraphChartView *)graphChartView touchesMovedToXPosition:(CGFloat)xPosition;

/**
 Notifies the delegate that a pan gesture that began within the bounds of an `ORKGraphChartView`
 object has ended.

@param graphChartView       The graph chart view object in which the gesture occurred.
*/
- (void)graphChartViewTouchesEnded:(ORKGraphChartView *)graphChartView;

@end


/**
 The abstract `ORKGraphChartViewDataSource` protocol is the base protocol which conforms the basis
 for the `ORKValueRangeGraphChartViewDataSource` and `ORKValueStackGraphChartViewDataSource`
 protocols, required to populate the concrete `ORKGraphChartView` subclass.

 At a minimum, a data source object must implement the `graphChartView:numberOfPointsInPlot:` and
 `graphChartView:plot:valueForPointAtIndex:` methods. These methods return
 the number of points in a plot and the points themselves. Each point in a plot is represented by
 an object of the `ORKValueRange` or `ORKValueStack` class, depending on the concrete subprotocol.
 
 A data source object may provide additional information to the graph chart view by implementing the
 optional methods.

 When configuring an `ORKGraphChartView` object, assign your data source to its `dataSource`
 property.
*/
@protocol ORKGraphChartViewDataSource <NSObject>

@required
/**
 Asks the data source for the number of value points to be plotted by the graph chart view at the
 specified plot index.

 @param graphChartView      The graph chart view asking for the number of value points.
 @param plotIndex           An index number identifying the plot in the graph chart view. This index
                                is 0 in a single-plot graph chart view.

 @return The number of range points in the plot at `plotIndex`.
*/
- (NSInteger)graphChartView:(ORKGraphChartView *)graphChartView numberOfDataPointsForPlotIndex:(NSInteger)plotIndex;


/**
 Asks the data source for the number of plots to be plotted by the graph chart view.

 @param graphChartView      The graph chart view asking for the number of plots.

 @return The number of plots in the graph chart view.
*/
- (NSInteger)numberOfPlotsInGraphChartView:(ORKGraphChartView *)graphChartView;

@optional
/**
 Asks the data source for the color of the specified plot.
 
 If this method is not implemented, the first plot uses the graph chart view `tintColor`, and
 all subsequent plots uses the current `referenceLineColor`.
 
 @param graphChartView      The graph chart view asking for the color of the segment.
 @param plotIndex           An index number identifying the plot in the graph chart view. This index
                                is always 0 in single-plot graph chart views.
 
 @return The color of the segment at the specified index in a pie chart view.
 */
- (UIColor *)graphChartView:(ORKGraphChartView *)graphChartView colorForPlotIndex:(NSInteger)plotIndex;

/**
 Asks the data source for the fill color of the specified plot.
 
 The fill color is only used by `ORKLineGraphChartView`. If this method is not implemented, the
 chart uses the main color of the specified plot with a 0.4 opacity value.
 
 @param graphChartView      The graph chart view asking for the color of the segment.
 @param plotIndex           An index number identifying the plot in the graph chart view. This index
 is always 0 in single-plot graph chart views.
 
 @return The color of the fill layer at the specified index in a line chart view.
 */
- (UIColor *)graphChartView:(ORKGraphChartView *)graphChartView fillColorForPlotIndex:(NSInteger)plotIndex;

/**
 Asks the data source which plot the scrubber should snap to in multigraph chart views.
 
 If this method is not implemented, the scrubber snaps over the first plot.
 
 @param graphChartView      The graph chart view asking for the scrubbing plot index.
 
 @return The index of the plot that the scrubber should snap to.
 */
- (NSInteger)scrubbingPlotIndexForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the upper limit of the y-axis drawn by the graph chart view.

 If this method is not implemented, the greatest `maximumValue` of all `ORKValueRange` instances
 returned in `graphChartView:plot:valueForPointAtIndex:` is used.

 See also: `graphChartView:plot:valueForPointAtIndex:`.

 @param graphChartView      The graph chart view asking for the maximum value.

 @return The maximum value of the y-axis drawn by `graphChartView`.
*/
- (double)maximumValueForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the lower limit of the y-axis drawn by the graph chart view.

 If this method is not implemented, the smallest `minimumValue` of all ORKValueRange instances
 returned in `graphChartView:plot:valueForPointAtIndex:` is used.

 See also: `graphChartView:plot:valueForPointAtIndex:`.

 @param graphChartView      The graph chart view asking for the minimum value.

 @return The minimum value of the y-axis drawn by `graphChartView`.
*/
- (double)minimumValueForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the number of divisions in the x-axis. The value is ignored if it is lower
 than the number of data points. A title appearing adjacent to each
 division may optionally be returned by the `graphChartView:titleForXAxisAtPointIndex:` method.

 @param graphChartView      The graph chart view asking for the number of divisions in its x-axis.

 @return The number of divisions in the x-axis for `graphChartView`.
*/
- (NSInteger)numberOfDivisionsInXAxisForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the title to be displayed adjacent to each division in the x-axis (the
 number returned by `numberOfDivisionsInXAxisForGraphChartView:`). You can return `nil` from this
 method if you don't want to display a title for the specified point index.

 If this method is not implemented, the x-axis has no titles.

 See also: `numberOfDivisionsInXAxisForGraphChartView:`.

 @param graphChartView  The graph chart view asking for the title.
 @param pointIndex      The index of the specified x-axis division.

 @return The title string to be displayed adjacent to each division of the x-axis of the graph chart
 view.
*/
- (nullable NSString *)graphChartView:(ORKGraphChartView *)graphChartView titleForXAxisAtPointIndex:(NSInteger)pointIndex;

/**
 Asks the data source if the vertical reference line at the specified point index should be drawn..
 
 If this method is not implemented, the graph chart view will draw all vertical reference lines.
 
 @param graphChartView  The graph view asking for the tile.
 @param pointIndex      The index corresponding to the number returned by
                            `numberOfDivisionsInXAxisForGraphChartView:`.
 
 @return Whether the graph chart view should draw the vertical reference line.
 */
- (BOOL)graphChartView:(ORKGraphChartView *)graphChartView drawsVerticalReferenceLineAtPointIndex:(NSInteger)pointIndex;


/**
 Asks the data source if the plot at specified index should display circular indicators on its data points.
 
 This only applys to `ORKLineGrapthChartView`.
 If this method is not implemented, point indicators will be drawn for all plots.
 
 @param graphChartView  The graph view asking whether point indicators should be drawn.
 @param plotIndex       An index number identifying the plot in the graph chart view. This index
 is always 0 in single-plot graph chart views.
 
 @return Whether the graph chart view should draw point indicators for its points.
 */
- (BOOL)graphChartView:(ORKGraphChartView *)graphChartView drawsPointIndicatorsForPlotIndex:(NSInteger)plotIndex;

@end


/**
 An object that adopts the `ORKValueRangeGraphChartViewDataSource` protocol is responsible for
 providing data in the form of `ORKValueRange` values required to populate an
 `ORKValueRangeGraphChartView` concrete subclass, such as `ORKLineGraphChartView` and
 `ORKDiscreteGraphChartView`.
 */
ORK_AVAILABLE_DECL
@protocol ORKValueRangeGraphChartViewDataSource <ORKGraphChartViewDataSource>

@required

/**
 Asks the data source for the value range to be plotted at the specified point index for the
 specified plot.
 
 @param graphChartView      The graph chart view that is asking for the value range.
 @param pointIndex          An index number identifying the value range in the graph chart view.
 @param plotIndex           An index number identifying the plot in the graph chart view. This index
                                is 0 in a single-plot graph chart view.
 
 @return The value range specified by `pointIndex` in the plot specified by `plotIndex` for the
 specified graph chart view`.
 */
- (ORKValueRange *)graphChartView:(ORKGraphChartView *)graphChartView dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex;

@end


/**
 An object that adopts the `ORKValueStackGraphChartViewDataSource` protocol is responsible for
 providing data in the form of `ORKValueStack` values required to populate an `ORKBarGraphChartView`
 object.
 */
ORK_AVAILABLE_DECL
@protocol ORKValueStackGraphChartViewDataSource <ORKGraphChartViewDataSource>

@required

/**
 Asks the data source for the value stack to be plotted at the specified point index for the
 specified plot.
 
 @param graphChartView      The graph chart view that is asking for the value stack.
 @param pointIndex          An index number identifying the value stack in the graph chart view.
 @param plotIndex           An index number identifying the plot in the graph chart view. This index
 is 0 in a single-plot graph chart view.
 
 @return The value stack specified by `pointIndex` in the plot specified by `plotIndex` for the
 specified graph chart view`.
 */
- (ORKValueStack *)graphChartView:(ORKGraphChartView *)graphChartView dataPointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex;

@end


/**
 The `ORKGraphChartView` class is an abstract class which holds properties and methods common to
 concrete subclasseses.
 
 You should not instantiate this class directly; use one of the subclasses instead. The concrete
 subclasses are `ORKLineGraphChartView`, `ORKDiscreteGraphChartView`, and `ORKBarGraphChartView`.
*/
ORK_CLASS_AVAILABLE
IB_DESIGNABLE
@interface ORKGraphChartView : UIView

/**
 The minimum value of the y-axis.

 You can provide this value to an instance of `ORKGraphChartView` by implementing the optional
 `minimumValueForGraphChartView:` method of the `ORKGraphChartViewDataSource` protocol.

 If `minimumValueForGraphChartView:` is not implemented, the minimum value is assigned to the
 smallest value of the `minimumValue` property of all `ORKValueRange` instances returned by the
 graph chart view data source.
*/
@property (nonatomic, readonly) double minimumValue;

/**
 The maximum value of the y-axis.

 You can provide this value instance of `ORKGraphChartView` by implementing the
 optional `maximumValueForGraphChartView:` method of the `ORKGraphChartViewDataSource` protocol.

 If `maximumValueForGraphChartView:` is not implemented, the maximum value is assigned to the
 largest value of the `maximumValue` property of all `ORKValueRange` instances returned by the
 graph chart view data source.
*/
@property (nonatomic, readonly) double maximumValue;

/**
 A Boolean value indicating whether the graph chart view should draw horizontal reference lines.

 The default value of this property is NO.
 */
@property (nonatomic) IBInspectable BOOL showsHorizontalReferenceLines;

/**
 A Boolean value indicating whether the graph chart view should draw vertical reference lines.

 The default value of this property is NO.
*/
@property (nonatomic) IBInspectable BOOL showsVerticalReferenceLines;

/**
 The delegate is notified of pan gesture events occuring within the bounds of the graph chart
 view.

 See the `ORKGraphChartViewDelegate` protocol.
*/
@property (nonatomic, weak, nullable) id <ORKGraphChartViewDelegate> delegate;

/**
 The data source responsible for providing the data required to populate the graph chart view.

 See the `ORKGraphChartViewDataSource` protocol.
*/
@property (nonatomic, weak) id <ORKGraphChartViewDataSource> dataSource;

/**
 The color of the axes drawn by the graph chart view.
 
 The default value for this property is a light gray color. Setting this property to `nil`
 resets it to its default value.
*/
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *axisColor;

/**
 The color of the vertical axis titles.
 
 The default value for this property is a light gray color. Setting this property to `nil` resets it
 to its default value.

 @note The horizontal axis titles use the current `tintColor`.
*/
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *verticalAxisTitleColor;

/**
 The color of the reference lines.
 
 The default value for this property is a light gray color. Setting this property to `nil` resets it
 to its default value.
*/
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *referenceLineColor;

/**
 The background color of the thumb on the scrubber line.
 
 The default value for this property is a white color. Setting this property to `nil` resets it to
 its default value.
*/
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *scrubberThumbColor;

/**
 The color of the scrubber line.
 
 The default value for this property is a gray color. Setting this property to `nil` resets it to
 its default value.
*/
@property (nonatomic, strong, null_resettable) IBInspectable UIColor *scrubberLineColor;

/**
 The string that is displayed if no data points are provided by the data source.
 
 The default value for this property is an appropriate message string. Setting this property to
 `nil` resets it to its default value.
*/
@property (nonatomic, copy, null_resettable) IBInspectable NSString *noDataText;

/**
 An image to be optionally displayed in place of the maximum value label on the y-axis.
 
 The default value for this property is `nil`.
*/
@property (nonatomic, strong, nullable) IBInspectable UIImage *maximumValueImage;

/**
 An image to be optionally displayed in place of the minimum value label on the y-axis.
 
 The default value for this property is `nil`.
*/
@property (nonatomic, strong, nullable) IBInspectable UIImage *minimumValueImage;

/**
 The long press gesture recognizer that is used for scrubbing by the graph chart view. You can use
 this property to prioritize your own gesture recognizers.
 
 This object is instatiated and added to the view when it is created.
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 The gesture recognizer that is used for scrubbing by the graph chart view.
 
 This object is instatiated and added to the view when it is created.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/**
 The number of decimal places that is used on the y-axis and scrubber value labels.
 
 The default value of this property is 0.
 */
@property (nonatomic) NSUInteger decimalPlaces;

/**
 Animates the graph when it first displays on the screen.
 
 You can optionally call this method from the `viewWillAppear:` implementation of the view
 controller that owns the graph chart view.
 
 @param animationDuration       The duration of the appearing animation.
 */
- (void)animateWithDuration:(NSTimeInterval)animationDuration;

/**
 Reloads the plotted data.
 
 Call this method to reload the data and re-plot the graph. You should call it if the data provided by the dataSource changes.
*/
- (void)reloadData;

@end


/**
 The `ORKValueRangeGraphChartView` class is an abstract class which holds a data source comforming
 to the `ORKValueRangeGraphChartViewDataSource` protocol, common to concrete subclasseses.
 
 You should not instantiate this class directly; use one of the subclasses instead. The concrete
 subclasses are `ORKLineGraphChartView` and `ORKDiscreteGraphChartView`.
 */
ORK_CLASS_AVAILABLE
@interface ORKValueRangeGraphChartView : ORKGraphChartView

/**
 The data source responsible for providing the data required to populate the graph chart view.
 
 See the `ORKValueRangeGraphChartViewDataSource` protocol.
 */
@property (nonatomic, weak) id <ORKValueRangeGraphChartViewDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
