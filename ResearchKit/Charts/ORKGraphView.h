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

@class ORKGraphView;
@class ORKRangedPoint;

/**
 The graph view delegate protocol declares methods which forward pan gesture events occuring within
 the bounds of an `ORKGraphView` object.
*/
ORK_AVAILABLE_DECL
@protocol ORKGraphViewDelegate <NSObject>

@optional
/**
 Notifies the delegate that a pan gesture has begun within the bounds of an `ORKGraphView` object.

 @param graphView    The `ORKGraphView` object in which the gesture occurred.
*/
- (void)graphViewTouchesBegan:(ORKGraphView *)graphView;

/**
 Notifies the delegate of updates in the x-coordinate of an ongoing pan gesture within the bounds
 of an `ORKGraphView` object.

 @param graphView    The `ORKGraphView` object in which the gesture occurred.
 @param xPosition    The updated xPosition of an ongoing pan gesture.
*/
- (void)graphView:(ORKGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition;

/**
 Notifies the delegate that a pan gesture which began within the bounds of an `ORKGraphView` object
 has ended.

@param graphView    The `ORKGraphView` object in which the gesture occurred.
*/
- (void)graphViewTouchesEnded:(ORKGraphView *)graphView;

@end


/**
 An object that adopts the `ORKGraphViewDataSource` protocol is responsible for providing the data
 required to populate an `ORKGraphView` object.

 At a minimum, a data source object must implement the `graphView:numberOfPointsInPlot:` and
 `graphView:plot:valueForPointAtIndex:` methods. These methods are responsible for returning the
 number of points in a plot and the points themselves. A point in a plot is represented by an 
 instance of `ORKRangedPoint`. Optionally, a data source object may provide additional information
 to the graph view by implementing the remaining `ORKGraphViewDataSouce` methods.

 When configuring an `ORKGraphView` object, assign your data source to its dataSource property.
*/
ORK_AVAILABLE_DECL
@protocol ORKGraphViewDataSource <NSObject>

@required
/**
 Asks the data source for the number of range points to be plotted by the graph view at the
 specified plot index.

 @param graphView    The graph view asking for the number of range points.
 @param plotIndex    An index number identifying the plot in `graphView`. This index is 0 in 
 single-plot graph views.

 @return The number of range points in the plot at `plotIndex`.
*/
- (NSInteger)graphView:(ORKGraphView *)graphView numberOfPointsForPlotIndex:(NSInteger)plotIndex;


/**
 Asks the data source for the range point to be plotted at the specified point index for the
 specified plot.

 @param graphView    The graphView asking for the range point.
 @param plotIndex    An index number identifying the plot in `graphView`. This index is 0 in 
 single-plot graph views.
 @param pointIndex   An index number identifying the range point in  `graphView`.

 @return The range point specified by `pointIndex` in the plot specified by `plotIndex` for the 
 specified `graphView`.
*/
- (ORKRangedPoint *)graphView:(ORKGraphView *)graphView pointForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex;

@optional
/**
 Asks the data source for the number of plots to be plotted by the graph view. If this method is not
 implemented, the graph view will assume it has a single plot.

 @param graphView    The graph view asking for the number of plots.

 @return The number of plots in `graphView`.
*/
- (NSInteger)numberOfPlotsInGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the upper limit of the y-axis drawn by the graph view.

 If this method is not implemented, the greatest `maximumValue` of all `ORKRangedPoint` instances
 returned in `graphView:plot:valueForPointAtIndex:` will be used.

 See also: `graphView:plot:valueForPointAtIndex:`.

 @param graphView    The graph view asking for the maximum value.

 @return The maximum value of the y-axis drawn by `graphView`.
*/
- (CGFloat)maximumValueForGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the lower limit of the y-axis drawn by the graph view.

 If this method is not implemented, The smallest `minimumValue` of all ORKRangedPoint instances
 returned in `graphView:plot:valueForPointAtIndex:` will be used.

 See also: `graphView:plot:valueForPointAtIndex:`.

 @param graphView    The graph view asking for the minimum value.

 @return The minimum value of the y-axis drawn by `graphView`.
*/
- (CGFloat)minimumValueForGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the number of divisions in the x-axis. The value is ignored if it is lower
 than the number of data points. A title appearing adjacent to each
 division may optionally be returned in `graphView:titleForXAxisAtIndex:`.

 @param graphView    The graph view asking for the number of divisions in its x-axis.

 @return The number of divisions in the x-axis for `graphView`.
*/
- (NSInteger)numberOfDivisionsInXAxisForGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the title to be displayed adjacent to each division in the x-axis (the 
 number returned by `numberOfDivisionsInXAxisForGraphView:`).

 If this method is not implemented, the x-axis will not have titles.

 See also: `numberOfDivisionsInXAxisForGraphView:`.

 @param graphView    The graph view asking for the tile.
 @param pointIndex   The index corresponding to the number returned by 
 `numberOfDivisionsInXAxisForGraphView:`.

 @return The title string to be displayed adjacent to each division of the x-axis of `graphView`.
*/
- (NSString *)graphView:(ORKGraphView *)graphView titleForXAxisAtIndex:(NSInteger)index;

@end


/**
 The `ORKGraphView` class is an abstract class. It holds properties and methods common to classes
 like `ORKLineGraphView` and `ORKDiscreteGraphView`. You should not instantiate this class directly,
 you should use a subclass.
*/
ORK_CLASS_AVAILABLE
@interface ORKGraphView : UIView

/**
 The minimum value of the y-axis.

 This value can be provided to an instance of `ORKGraphView` by implementing the
 optional `maximumValueForGraphView:` method of the `ORKGraphViewDataSource` protocol.

 If `maximumValueForGraphView:` is not implemented, the minimum value will be assigned
 the smallest value of the `minimumValue` property belonging to the `ORKRangedPoint`
 instances returned by the `ORKGraphViewDataSource` protocol's
 `graphView:plot:valueForPointAtIndex:` method.
*/
@property (nonatomic, readonly) CGFloat minimumValue;

/**
 The maximum value of the y-axis.

 This value can be provided to an instance of `ORKGraphView` by implementing the
 optional `maximumValueForGraphView:` method of the `ORKGraphViewDataSource` protocol.

 If `maximumValueForGraphView:` is not implemented, the maximum value will be assigned
 the largest value of the `maximumValue` property belonging to the `ORKRangedPoint`
 instances returned by the `ORKGraphViewDataSource` protocol's
 `graphView:plot:valueForPointAtIndex:` method.
*/
@property (nonatomic, readonly) CGFloat maximumValue;

/**
 A Boolean value indicating whether the graph view should draw horizontal refrerence lines.

 The default value of this property is NO.
 */
@property (nonatomic) BOOL showsHorizontalReferenceLines;

/**
 A Boolean value indicating whether the graph view should draw vertical refrerence lines.

 The default value of this property is NO.
*/
@property (nonatomic) BOOL showsVerticalReferenceLines;

/**
 The delegate will be notified of pan gesture events occuring within the bounds of the graphView.

 See the `ORKGraphViewDelegate` protocol.
*/
@property (nonatomic, weak, nullable) id <ORKGraphViewDelegate> delegate;

/**
 The dataSource is responsible for providing the data required to populate the graphView.

 See the `ORKGraphViewDataSource` protocol.
*/
@property (nonatomic, weak) id <ORKGraphViewDataSource> dataSource;

/**
 The color of the axes drawn by the graphView.
 
 The default value for this property is a very light gray color.
*/
@property (nonatomic, strong) UIColor *axisColor;

/**
 The color of the axes titles.
 
 The default value for this property is a light gray color.
*/
@property (nonatomic, strong) UIColor *axisTitleColor;

/**
 The color of the reference lines.
 
 The default value for this property is a light gray color.
*/
@property (nonatomic, strong) UIColor *referenceLineColor;

/**
 The background color of the thumb on the scrubber line.
 
 The default value for this property is a white color.
*/
@property (nonatomic, strong) UIColor *scrubberThumbColor;

/**
 The color of the scrubber line.
 
 The default value for this property is a gray color.
*/
@property (nonatomic, strong) UIColor *scrubberLineColor;

/**
 The string that will be displayed if no data points are provided by the `dataSource`.
 
 The default value for this property is an appropriate message string.
*/
@property (nonatomic, copy, nullable) NSString *noDataText;

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
 The gesture recogniser that is used for scrubbint by the graph view.
 
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
