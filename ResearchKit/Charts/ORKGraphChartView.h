/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.

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
#import "ORKDefines.h"


NS_ASSUME_NONNULL_BEGIN

@class ORKGraphChartView;
@class ORKRangedPoint;

/**
 The graph view delegate protocol declares methods which forward pan gesture events occuring within
 the bounds of an `ORKGraphChartView` object.
*/
ORK_AVAILABLE_DECL
@protocol ORKGraphChartViewDelegate <NSObject>

@optional
/**
 Notifies the delegate that a pan gesture has begun within the bounds of an `ORKGraphChartView` object.

 @param graphChartView      The `ORKGraphChartView` object in which the gesture occurred.
*/
- (void)graphChartViewTouchesBegan:(ORKGraphChartView *)graphChartView;

/**
 Notifies the delegate of updates in the x-coordinate of an ongoing pan gesture within the bounds
 of an `ORKGraphChartView` object.

 @param graphChartView      The `ORKGraphChartView` object in which the gesture occurred.
 @param xPosition           The updated xPosition of an ongoing pan gesture.
*/
- (void)graphChartView:(ORKGraphChartView *)graphChartView touchesMovedToXPosition:(CGFloat)xPosition;

/**
 Notifies the delegate that a pan gesture which began within the bounds of an `ORKGraphChartView` object
 has ended.

@param graphChartView       The `ORKGraphChartView` object in which the gesture occurred.
*/
- (void)graphChartViewTouchesEnded:(ORKGraphChartView *)graphChartView;

@end


/**
 An object that adopts the `ORKGraphChartViewDataSource` protocol is responsible for providing the data
 required to populate an `ORKGraphChartView` object.

 At a minimum, a data source object must implement the `graphChartView:numberOfPointsInPlot:` and
 `graphChartView:plot:valueForPointAtIndex:` methods. These methods are responsible for returning the
 number of points in a plot and the points themselves. A point in a plot is represented by an 
 instance of `ORKRangedPoint`. Optionally, a data source object may provide additional information
 to the graph view by implementing the remaining `ORKGraphChartViewDataSouce` methods.

 When configuring an `ORKGraphChartView` object, assign your data source to its dataSource property.
*/
ORK_AVAILABLE_DECL
@protocol ORKGraphChartViewDataSource <NSObject>

@required
/**
 Asks the data source for the number of range points to be plotted by the graph view at the
 specified plot index.

 @param graphChartView      The graph view asking for the number of range points.
 @param plotIndex           An index number identifying the plot in `graphChartView`. This index is 0 in
 single-plot graph views.

 @return The number of range points in the plot at `plotIndex`.
*/
- (NSInteger)graphChartView:(ORKGraphChartView *)graphChartView numberOfPointsForPlotIndex:(NSInteger)plotIndex;


/**
 Asks the data source for the range point to be plotted at the specified point index for the
 specified plot.

 @param graphChartView      The graphChartView asking for the range point.
 @param pointIndex          An index number identifying the range point in `graphChartView`.
 @param plotIndex           An index number identifying the plot in `graphChartView`. This index is 0 in
 single-plot graph views.

 @return The range point specified by `pointIndex` in the plot specified by `plotIndex` for the 
 specified `graphChartView`.
*/
- (ORKRangedPoint *)graphChartView:(ORKGraphChartView *)graphChartView pointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex;

@optional
/**
 Asks the data source for the number of plots to be plotted by the graph view. If this method is not
 implemented, the graph view will assume it has a single plot.

 @param graphChartView      The graph view asking for the number of plots.

 @return The number of plots in `graphChartView`.
*/
- (NSInteger)numberOfPlotsInGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the color of the specified plot.
 
 If this method is not implemented, the first plot will use chart view will use the current
 `tintColor`, and all subsequent plots will use the current `referenceLineColor`.
 
 @param graphChartView      The graph view asking for the color of the segment.
 @param plotIndex           An index number identifying the plot in `graphChartView`. This index is 
 always 0 in single-plot graph views.
 
 @return The color of the segment at the specified `index` in `pieChartView`.
 */
- (UIColor *)graphChartView:(ORKGraphChartView *)graphChartView colorForPlotIndex:(NSInteger)plotIndex;

/**
 Asks the data source which plot should the scrubber snap to in multi-graph chart views.
 
 If this method is not implemented, the scrubber snaps over the first plot.
 
 @param graphChartView      The graph view asking for the scrubbing plot index.
 
 @return The index of the plot the scrubber should snap to.
 */
- (NSInteger)scrubbingPlotIndexForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the upper limit of the y-axis drawn by the graph view.

 If this method is not implemented, the greatest `maximumValue` of all `ORKRangedPoint` instances
 returned in `graphChartView:plot:valueForPointAtIndex:` will be used.

 See also: `graphChartView:plot:valueForPointAtIndex:`.

 @param graphChartView      The graph view asking for the maximum value.

 @return The maximum value of the y-axis drawn by `graphChartView`.
*/
- (CGFloat)maximumValueForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the lower limit of the y-axis drawn by the graph view.

 If this method is not implemented, The smallest `minimumValue` of all ORKRangedPoint instances
 returned in `graphChartView:plot:valueForPointAtIndex:` will be used.

 See also: `graphChartView:plot:valueForPointAtIndex:`.

 @param graphChartView      The graph view asking for the minimum value.

 @return The minimum value of the y-axis drawn by `graphChartView`.
*/
- (CGFloat)minimumValueForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the number of divisions in the x-axis. The value is ignored if it is lower
 than the number of data points. A title appearing adjacent to each
 division may optionally be returned in `graphChartView:titleForXAxisAtIndex:`.

 @param graphChartView      The graph view asking for the number of divisions in its x-axis.

 @return The number of divisions in the x-axis for `graphChartView`.
*/
- (NSInteger)numberOfDivisionsInXAxisForGraphChartView:(ORKGraphChartView *)graphChartView;

/**
 Asks the data source for the title to be displayed adjacent to each division in the x-axis (the 
 number returned by `numberOfDivisionsInXAxisForGraphChartView:`).

 If this method is not implemented, the x-axis will not have titles.

 See also: `numberOfDivisionsInXAxisForGraphChartView:`.

 @param graphChartView    The graph view asking for the tile.
 @param pointIndex   The index corresponding to the number returned by 
 `numberOfDivisionsInXAxisForGraphChartView:`.

 @return The title string to be displayed adjacent to each division of the x-axis of `graphChartView`.
*/
- (NSString *)graphChartView:(ORKGraphChartView *)graphChartView titleForXAxisAtIndex:(NSInteger)index;

@end


/**
 The `ORKGraphChartView` class is an abstract class. It holds properties and methods common to classes
 like `ORKLineGraphChartView` and `ORKDiscreteGraphChartView`. You should not instantiate this class directly,
 use one of the subclasses instead.
*/
ORK_CLASS_AVAILABLE
@interface ORKGraphChartView : UIView

/**
 The minimum value of the y-axis.

 This value can be provided to an instance of `ORKGraphChartView` by implementing the
 optional `maximumValueForGraphChartView:` method of the `ORKGraphChartViewDataSource` protocol.

 If `maximumValueForGraphChartView:` is not implemented, the minimum value will be assigned
 the smallest value of the `minimumValue` property belonging to the `ORKRangedPoint`
 instances returned by the `ORKGraphChartViewDataSource` protocol's
 `graphChartView:plot:valueForPointAtIndex:` method.
*/
@property (nonatomic, readonly) CGFloat minimumValue;

/**
 The maximum value of the y-axis.

 This value can be provided to an instance of `ORKGraphChartView` by implementing the
 optional `maximumValueForGraphChartView:` method of the `ORKGraphChartViewDataSource` protocol.

 If `maximumValueForGraphChartView:` is not implemented, the maximum value will be assigned
 the largest value of the `maximumValue` property belonging to the `ORKRangedPoint`
 instances returned by the `ORKGraphChartViewDataSource` protocol's
 `graphChartView:plot:valueForPointAtIndex:` method.
*/
@property (nonatomic, readonly) CGFloat maximumValue;

/**
 A Boolean value indicating whether the graph view should draw horizontal reference lines.

 The default value of this property is NO.
 */
@property (nonatomic) BOOL showsHorizontalReferenceLines;

/**
 A Boolean value indicating whether the graph view should draw vertical reference lines.

 The default value of this property is NO.
*/
@property (nonatomic) BOOL showsVerticalReferenceLines;

/**
 The delegate will be notified of pan gesture events occuring within the bounds of the graphChartView.

 See the `ORKGraphChartViewDelegate` protocol.
*/
@property (nonatomic, weak, nullable) id <ORKGraphChartViewDelegate> delegate;

/**
 The dataSource is responsible for providing the data required to populate the graphChartView.

 See the `ORKGraphChartViewDataSource` protocol.
*/
@property (nonatomic, weak) id <ORKGraphChartViewDataSource> dataSource;

/**
 The color of the axes drawn by the graphChartView.
 
 The default value for this property is a very light gray color. Setting this property to `nil` 
 resets it to its default value.
*/
@property (nonatomic, strong, null_resettable) UIColor *axisColor;

/**
 The color of the vertical axis titles.
 
 @note The horizontal axis titles use the current `tintColor`.
 
 The default value for this property is a light gray color. Setting this property to `nil` resets it
 to its default value.
*/
@property (nonatomic, strong, null_resettable) UIColor *verticalAxisTitleColor;

/**
 The color of the reference lines.
 
 The default value for this property is a light gray color. Setting this property to `nil` resets it
 to its default value.
*/
@property (nonatomic, strong, null_resettable) UIColor *referenceLineColor;

/**
 The background color of the thumb on the scrubber line.
 
 The default value for this property is a white color. Setting this property to `nil` resets it to
 its default value.
*/
@property (nonatomic, strong, null_resettable) UIColor *scrubberThumbColor;

/**
 The color of the scrubber line.
 
 The default value for this property is a gray color. Setting this property to `nil` resets it to
 its default value.
*/
@property (nonatomic, strong, null_resettable) UIColor *scrubberLineColor;

/**
 The string that will be displayed if no data points are provided by the `dataSource`.
 
 The default value for this property is an appropriate message string. Setting this property to
 `nil` resets it to its default value.
*/
@property (nonatomic, copy, null_resettable) NSString *noDataText;

/**
 An image to be optionally displayed in place of the maximum value label on the y-axis.
 
 The default value for this property is nil.
*/
@property (nonatomic, strong, nullable) UIImage *maximumValueImage;

/**
 An image to be optionally displayed in place of the minimum value label on the y-axis.
 
 The default value for this property is nil.
*/
@property (nonatomic, strong, nullable) UIImage *minimumValueImage;

/**
 The gesture recogniser that is used for scrubbing by the graph view.
 
 This object is instatiated and added to the view on initialisation.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/**
 Animates the graph when it first displays on the screen.
 
 You can optionally call this method from the `viewWillAppear:` implementation of the view
 controller that owns the graph view.
 
 @param animationDuration       The duration of the appearing animation.
 */
- (void)animateWithDuration:(NSTimeInterval)animationDuration;

@end

NS_ASSUME_NONNULL_END
