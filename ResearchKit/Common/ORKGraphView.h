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


NS_ASSUME_NONNULL_BEGIN

@class ORKGraphView;
@class ORKRangePoint;

/**
    The graph view delegate protocol defines methods which forward pan gesture events occuring
    within the bounds of an `ORKGraphView` subclass.
 */
ORK_AVAILABLE_DECL
@protocol ORKGraphViewDelegate <NSObject>

@optional
/**
    Notifies the delegate that a pan gesture has begun within the bounds of an `ORKGraphView` subclass.
 
    @param graphView    The `ORKGraphView` subclass in which the gesture occurred.
 */
- (void)graphViewTouchesBegan:(ORKGraphView *)graphView;

/**
    Notifies the delegate of updates in the x-coordinate of an ongoing pan gesture within the bounds of an `ORKGraphView` subclass.
 
    @param graphView    The `ORKGraphView` subclass in which the gesture occurred.
    @param xPosition    The updated xPosition of an ongoing pan gesture.
 */
- (void)graphView:(ORKGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition;

/**
    Notifies the delegate that a pan gesture which began within the bounds of an `ORKGraphView` subclass has ended.
 
    @param graphView    The `ORKGraphView` subclass in which the gesture occurred.
 */
- (void)graphViewTouchesEnded:(ORKGraphView *)graphView;

@end


/**
    The graph view data source is responsible for providing the data required to populate
    an `ORKGraphView` subclass.
 */
ORK_AVAILABLE_DECL
@protocol ORKGraphViewDataSource <NSObject>

@required
/**
    Returns the number of points that will appear in the plot.
 
    @param graphView    The `ORKGraphView` subclass requesting the points.
    @param plotIndex    The index of the plot using the returned value.
 
    @return The number of points to be plotted by `graphView` for it's plot at `plotIndex`.
 */
- (NSInteger)graphView:(ORKGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex;


/**
    Returns the point to be plotted at the given index in the given plot of the graphView.
 
    @param graphView    The `ORKGraphView` subclass requesting the points.
    @param plotIndex    The index of the plot using the returned value.
    @param pointIndex   The index of the returned point value.
 
    @return The point to be plotted at `pointIndex` in the plot at `plotIndex` to be drawn by `graphView`.
 */
- (ORKRangePoint *)graphView:(ORKGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex;

@optional
/**
    Returns the number of plots in the graph view.
    
    Defaults to 1 if not implemented.
 
    @param graphView    The `ORKGraphView` subclass requesting the number of plots.
 
    @return The number of plots in `graphView`.
 */
- (NSInteger)numberOfPlotsInGraphView:(ORKGraphView *)graphView;

/**
    Returns the number of divisions in the x-axis; a title appearing adjacent to each division may optionally be returned in graphView:titleForXAxisAtIndex:
    
    @param graphView    The `ORKGraphView` subclass requesting the number of divisions in its x-axis.
 
    @return The number of divisions in the x-axis for `graphView`.
 
    see also: graphView:titleForXAxisAtIndex:
 */
- (NSInteger)numberOfDivisionsInXAxisForGraphView:(ORKGraphView *)graphView;

/**
    Returns the upper limit of the y-axis drawn by the graphView.
    
    If this method is not implemented, The greatest `maximumValue` of all ORKRangePoint instances returned in graphView:plot:valueForPointAtIndex: will be used instead.
 
    @param graphView    The `ORKGraphView` subclass to which the returned value will apply.
    
    @return The maximum value of the y-axis drawn by `graphView`.
 
    see also: graphView:plot:valueForPointAtIndex:
 */
- (CGFloat)maximumValueForGraphView:(ORKGraphView *)graphView;

/**
    Returns the lower limit of the y-axis drawn by the graphView.
    
    If this method is not implemented, The smallest `minimumValue` of all ORKRangePoint instances returned in graphView:plot:valueForPointAtIndex: will be used instead.
 
    @param graphView    The `ORKGraphView` subclass to which the returned value will apply.
    
    @return The minimum value of the y-axis drawn by `graphView`.
 
    see also: graphView:plot:valueForPointAtIndex:
 */
- (CGFloat)minimumValueForGraphView:(ORKGraphView *)graphView;

/**
    Returns the title to be displayed adjacent to each division in the x-axis (the number returned by `numberOfDivisionsInXAxisForGraphView:).
    
    If this method is not implemented, the x-axis will not display a scale.
    
    @param graphView    The `ORKGraphView` subclass to which the returned values will apply.
    @param pointIndex   The index correspoding to the number returned by `numberOFDivisionsInXAxisForGraphView:`
    
    @return The title string to be displayed adjacent to each division of the x-axis of `graphView`.
 
    see also: numberOfDivisionsInXAxisForGraphView:
 */
- (NSString *)graphView:(ORKGraphView *)graphView titleForXAxisAtIndex:(NSInteger)index;

@end


/**
    The `ORKGraphView` class is an abstract class. It holds properties and methods common to classes like
    ORKLineGraphView and ORKDiscreteGraphView. You should not instantiate this class directly, you should
    use a subclass.
 */
ORK_CLASS_AVAILABLE
@interface ORKGraphView : UIView

/**
    Returns the minimum value of the y-axis.
 
    This value can be provided to an instance of `ORKGraphView` by implementing the
    optional maximumValueForGraphView: method of the ORKGraphViewDataSource protocol.
 
    If maximumValueForGraphView: is not implemented, the minimum value will be assigned
    the smallest value of the `minimumValue` property belonging to the `ORKRangePoint`
    instances returned by the ORKGraphViewDataSource protocol's
    `graphView:plot:valueForPointAtIndex:` method.
 
    If the graph view has no data source, this value defaults to MAXFLOAT.
 */
@property (nonatomic, readonly) CGFloat minimumValue;

/**
    Returns the maximum value of the y-axis.
 
    This value can be provided to an instance of `ORKGraphView` by implementing the
    optional maximumValueForGraphView: method of the ORKGraphViewDataSource protocol.
 
    If maximumValueForGraphView: is not implemented, the maximum value will be assigned
    the largest value of the `maximumValue` property belonging to the `ORKRangePoint`
    instances returned by the ORKGraphViewDataSource protocol's
    `graphView:plot:valueForPointAtIndex:` method.
 
    If the graph view has no data source, this value defaults to negative MAXFLOAT.
 */
@property (nonatomic, readonly) CGFloat maximumValue;

/**
    A Boolean value indicating whether the graphView should draw its content for a landscape or portrait
    presentation.
    Defaults to NO.
 */
@property (nonatomic, getter=isLandscapeMode) BOOL landscapeMode;

/**
    A Boolean value indicating whether the graphView should draw vertical refrerence lines.
    Defaults to NO.
 */
@property (nonatomic) BOOL showsVerticalReferenceLines;

/**
    The delegate will be notified of pan gesture events occuring
    within the bounds of the graphView.
    
    see also: ORKGraphViewDelegate protocol.
 */
@property (nonatomic, weak, nullable) id <ORKGraphViewDelegate> delegate;

/**
    The dataSource is responsible for providing the data required to populate the graphView.
 
    see also: ORKGraphViewDataSource protocol.
 */
@property (nonatomic, weak) IBOutlet id <ORKGraphViewDataSource> dataSource;

/**
    The color of the axes drawn by the graphView.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) UIColor *axisColor;

/**
    The color of the axes titles.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) UIColor *axisTitleColor;

/**
    The font of the axes titles.
    Defaults to a system font.
 */
@property (nonatomic, strong, nullable) UIFont *axisTitleFont;

/**
    The color of the reference lines.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) UIColor *referenceLineColor;

/**
    The color of the thub circle on the scrubber line.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) UIColor *scrubberThumbColor;

/**
    The color of the scrubber line.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) UIColor *scrubberLineColor;

/**
    The gesture recogniser that is added to this view.
    This object is instatiated and added to the view on initialisation.
 */
@property (nonatomic, strong, nullable) UIPanGestureRecognizer *panGestureRecognizer;

/**
    A string that will be displayed in the UI if no data points are provided by the `dataSource`.
    Defaults to a sensible value.
 */
@property (nonatomic, strong, nullable) NSString *emptyText;

/**
    An image that will be displayed adjacent to the maximum value of the y-axis.
    Defaults to nil.
 */
@property (nonatomic, strong, nullable) UIImage *maximumValueImage;

/**
    An image that will be displayed adjacent to the minimum value of the y-axis.
    Defaults to nil.
 */
@property (nonatomic, strong, nullable) UIImage *minimumValueImage;

/**
    Redraws the content of the graphView.
 */
- (void)refreshGraph;

@end


/**
    The ORKRangePoint class models the attributes of a point used in a graph plot.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangePoint : NSObject

/**
    Represents the upper limit of the range represented by this point.
    Defaults to zero.
 */
@property (nonatomic) CGFloat maximumValue;

/**
    Represents the lower limit of the range represented by this point.
    Defaults to zero.
 */
@property (nonatomic) CGFloat minimumValue;

/**
    Returns an initialized ORKRangePoint using the specified minimumValue and maximumValue.
 
    Convenience Initializer.
 
    @param minimumValue     The `minimumValue` to set.
    @param maximumValue     The `maximumValue` to set.
 
    @return an intialized ORKGraphView instance with `minimuValue` and `maximumValue` set 
    to the given parameter values.
 */
- (instancetype)initWithMinimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue;

/**
    Returns an intialized ORKRangePoint using the specified value for both minimumValue and maximumValue, this is useful for creating points that model a single data value without a range.
 
    Convenience Initializer.
 
    @param value    The `minimumValue` and `maximumValue` to set.
    
    @return an intialized ORKGraphView instance with `minimuValue` and `maximumValue` equal to `value`.
 */
- (instancetype)initWithValue:(CGFloat)value;

/**
    Returns true if `minimumValue` is equal to `maximumValue`, otherwise returns false.
 */
- (BOOL)isRangeZero;

/**
    Return true if both `minimum value` and `maximum value` are not set, otherwise returns false.
 */
- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
