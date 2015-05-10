// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 


#import <UIKit/UIKit.h>
#import <ResearchKit/ORKBaseGraphView.h>

FOUNDATION_EXPORT NSString * const kORKDiscreteGraphViewTriggerAnimationsNotification;
FOUNDATION_EXPORT NSString * const kORKDiscreteGraphViewRefreshNotification;

@protocol APCDiscreteGraphViewDataSource;
@protocol APCDiscreteGraphViewDelegate;
@class APCRangePoint;

ORK_CLASS_AVAILABLE
@interface ORKDiscreteGraphView : ORKBaseGraphView


@property (nonatomic, weak) IBOutlet id <APCDiscreteGraphViewDataSource> datasource;

@property (nonatomic) BOOL shouldConnectRanges;

@end

ORK_AVAILABLE_DECL
@protocol APCDiscreteGraphViewDataSource <NSObject>


@required

- (NSInteger)discreteGraph:(ORKDiscreteGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex;

- (APCRangePoint *)discreteGraph:(ORKDiscreteGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex;

@optional

- (NSInteger)numberOfPlotsInDiscreteGraph:(ORKDiscreteGraphView *)graphView;

- (NSInteger)numberOfDivisionsInXAxisForGraph:(ORKDiscreteGraphView *)graphView;

- (CGFloat)maximumValueForDiscreteGraph:(ORKDiscreteGraphView *)graphView;

- (CGFloat)minimumValueForDiscreteGraph:(ORKDiscreteGraphView *)graphView;

- (NSString *)discreteGraph:(ORKDiscreteGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex;

@end

/******************************/
/*  Range Point Interface     */
/******************************/

ORK_AVAILABLE_DECL
@interface APCRangePoint : NSObject

@property (nonatomic) CGFloat maximumValue;

@property (nonatomic) CGFloat minimumValue;

@property (nonatomic, getter=isEmpty) BOOL empty;

- (instancetype)initWithMinimumValue:(CGFloat)minValue maximumValue:(CGFloat)maxValue;

- (BOOL)isRangeZero;

@end

