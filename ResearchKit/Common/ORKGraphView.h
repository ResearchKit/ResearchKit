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
@class ORKRangePoint;

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

 At a minimum, a data source object must implement the graphView:numberOfPointsInPlot: and 
 graphView:plot:valueForPointAtIndex: methods. These methods are responsible for returning the
 number of points in a plot and the points themselves. A point in a plot is represented by an 
 instance of `ORKRangePoint`. Optionally, a data source object may provide additional information
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
- (ORKRangePoint *)graphView:(ORKGraphView *)graphView pointForForPointIndex:(NSInteger)pointIndex plotIndex:(NSInteger)plotIndex;

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

 If this method is not implemented, the greatest `maximumValue` of all `ORKRangePoint` instances
 returned in `graphView:plot:valueForPointAtIndex:` will be used.

 @param graphView    The graph view asking for the maximum value.

 @return The maximum value of the y-axis drawn by `graphView`.

 see also: `graphView:plot:valueForPointAtIndex:`.
*/
- (CGFloat)maximumValueForGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the lower limit of the y-axis drawn by the graph view.

 If this method is not implemented, The smallest `minimumValue` of all ORKRangePoint instances
 returned in `graphView:plot:valueForPointAtIndex:` will be used.

 @param graphView    The graph view asking for the minimum value.

 @return The minimum value of the y-axis drawn by `graphView`.

 see also: `graphView:plot:valueForPointAtIndex:`.
*/
- (CGFloat)minimumValueForGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the number of divisions in the x-axis. A title appearing adjacent to each
 division may optionally be returned in `graphView:titleForXAxisAtIndex:`

 @param graphView    The graph view asking for the number of divisions in its x-axis.

 @return The number of divisions in the x-axis for `graphView`.
*/
- (NSInteger)numberOfDivisionsInXAxisForGraphView:(ORKGraphView *)graphView;

/**
 Asks the data source for the title to be displayed adjacent to each division in the x-axis (the 
 number returned by `numberOfDivisionsInXAxisForGraphView:`).

 If this method is not implemented, the x-axis will not have titles.

 @param graphView    The graph view asking for the tile.
 @param pointIndex   The index corresponding to the number returned by 
 `numberoFDivisionsInXAxisForGraphView:`.

 @return The title string to be displayed adjacent to each division of the x-axis of `graphView`.

 see also: `numberOfDivisionsInXAxisForGraphView:`.
*/
- (NSString *)graphView:(ORKGraphView *)graphView titleForXAxisAtIndex:(NSInteger)index;

@end


/**
 The `ORKGraphView` class is an abstract class. It holds properties and methods common to classes
 like ORKLineGraphView and ORKDiscreteGraphView. You should not instantiate this class directly,
 you should use a subclass.
*/
ORK_CLASS_AVAILABLE
@interface ORKGraphView : UIView

/**
 The minimum value of the y-axis.

 This value can be provided to an instance of `ORKGraphView` by implementing the
 optional `maximumValueForGraphView:` method of the `ORKGraphViewDataSource` protocol.

 If `maximumValueForGraphView:` is not implemented, the minimum value will be assigned
 the smallest value of the `minimumValue` property belonging to the `ORKRangePoint`
 instances returned by the `ORKGraphViewDataSource` protocol's
 `graphView:plot:valueForPointAtIndex:` method.
*/
@property (nonatomic, readonly) CGFloat minimumValue;

/**
 The maximum value of the y-axis.

 This value can be provided to an instance of `ORKGraphView` by implementing the
 optional `maximumValueForGraphView:` method of the `ORKGraphViewDataSource` protocol.

 If `maximumValueForGraphView:` is not implemented, the maximum value will be assigned
 the largest value of the `maximumValue` property belonging to the `ORKRangePoint`
 instances returned by the `ORKGraphViewDataSource` protocol's
 `graphView:plot:valueForPointAtIndex:` method.
*/
@property (nonatomic, readonly) CGFloat maximumValue;

/**
 A Boolean value indicating whether the graph view should draw vertical refrerence lines.
 The default value of this property is NO.
*/
@property (nonatomic) BOOL showsVerticalReferenceLines;

/**
 The delegate will be notified of pan gesture events occuring within the bounds of the graphView.

 see also: `ORKGraphViewDelegate` protocol.
*/
@property (nonatomic, weak, nullable) id <ORKGraphViewDelegate> delegate;

/**
 The dataSource is responsible for providing the data required to populate the graphView.

 see also: `ORKGraphViewDataSource` protocol.
*/
@property (nonatomic, weak) IBOutlet id <ORKGraphViewDataSource> dataSource;

/**
 The color of the axes drawn by the graphView.
 If you do not set a value for this property, the graph view will assume a sensible value.
*/
@property (nonatomic, strong, nullable) UIColor *axisColor;

/**
 The color of the axes titles.
 If you do not set a value for this property, the graph view will assume a sensible value.
*/
@property (nonatomic, strong, nullable) UIColor *axisTitleColor;

/**
 The font of the axes titles.
 The default value for this peoperty is a system font.
*/
@property (nonatomic, strong, nullable) UIFont *axisTitleFont;

/**
 The color of the reference lines.
  If you do not set a value for this property, the graph view will assume a sensible value.
*/
@property (nonatomic, strong, nullable) UIColor *referenceLineColor;

/**
 The color of the thub circle on the scrubber line.
 If you do not set a value for this property, the graph view will assume a sensible value.
*/
@property (nonatomic, strong, nullable) UIColor *scrubberThumbColor;

/**
 The color of the scrubber line.
 If you do not set a value for this property, the graph view will assume a sensible value.
*/
@property (nonatomic, strong, nullable) UIColor *scrubberLineColor;

/**
 The gesture recogniser that is added to this view.
 This object is instatiated and added to the view on initialisation.
*/
@property (nonatomic, strong, nullable) UIPanGestureRecognizer *panGestureRecognizer;

/**
 A string that will be displayed in the UI if no data points are provided by the `dataSource`.
 If you do not set a value for this property, the graph view will assume a sensible value.
*/
@property (nonatomic, strong, nullable) NSString *emptyText;

/**
 An image that will be displayed adjacent to the maximum value of the y-axis.
 The default value for this property is nil.
*/
@property (nonatomic, strong, nullable) UIImage *maximumValueImage;

/**
 An image that will be displayed adjacent to the minimum value of the y-axis.
 The default value for this property is nil.
*/
@property (nonatomic, strong, nullable) UIImage *minimumValueImage;

/**
 Redraws the content of the graphView.
 */
- (void)refreshGraph;

@end


/**
 The `ORKRangePoint` class represents a ranged point used in a graph plot.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangePoint : NSObject

/**
 Returns a range point initialized using the specified `minimumValue` and `maximumValue`.

 @param minimumValue     The `minimumValue` to set.
 @param maximumValue     The `maximumValue` to set.

 @return A range point.
*/
- (instancetype)initWithMinimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue NS_DESIGNATED_INITIALIZER;

/**
 Returns a range point initialized using the specified `value` for both `minimumValue` and
 `maximumValue`. This is useful for creating points that model a single data value without a range.

 This method is a convenience initializer.

 @param value    The `minimumValue` and `maximumValue` to set.

 @return A range point.
*/
- (instancetype)initWithValue:(CGFloat)value;

/**
 The upper limit of the range represented by this point.
 The default value of this property is zero.
 */
@property (nonatomic) CGFloat maximumValue;

/**
 The lower limit of the range represented by this point.
 The default value of this property is zero.
 */
@property (nonatomic) CGFloat minimumValue;

/**
 A Boolean value indicating that `minimumValue` is equal to `maximumValue`. (read-only)
*/
@property (nonatomic, readonly) BOOL hasEmptyRange;

/**
 A Boolean value indicating that both `minimum value` and `maximum value` have not been set.  (read-only)
*/
@property (nonatomic, readonly) BOOL isUnset;

@end

NS_ASSUME_NONNULL_END
