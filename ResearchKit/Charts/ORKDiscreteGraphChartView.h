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
#import "ORKGraphChartView.h"


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKDiscreteGraphChartView` class presents data provided by an object conforming to the
 `ORKValueRangeGraphChartViewDataSource` protocol as a discrete graph of ranged points.
 
 You can optionally display a line connecting each ranged point pair.
 
 By default, the primary plot is colored by the `tintColor`, and any additional plots are colored
 using the `referenceLineColor` property. You can customize the plot colors by implementing the
 `-graphChartView:colorForPlotIndex:` method in the data source.
 */
ORK_CLASS_AVAILABLE
@interface ORKDiscreteGraphChartView : ORKValueRangeGraphChartView

/**
 A Boolean value indicating whether to draw a line connecting the minimum value and maximum value of
 each ranged point represented by the graph view.
 
 The default value for this property is `YES`.
 */
@property (nonatomic) IBInspectable BOOL drawsConnectedRanges;

@end

NS_ASSUME_NONNULL_END
