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

ORK_AVAILABLE_DECL
@protocol ORKPieChartViewDatasource <NSObject>

@required

- (NSInteger)numberOfSegmentsInPieChartView;

- (CGFloat)pieChartView:(ORKPieChartView *)pieChartView valueForSegmentAtIndex:(NSInteger)index;

@optional

- (UIColor *)pieChartView:(ORKPieChartView *)pieChartView colorForSegmentAtIndex:(NSInteger)index;

- (NSString *)pieChartView:(ORKPieChartView *)pieChartView titleForSegmentAtIndex:(NSInteger)index;

@end

ORK_CLASS_AVAILABLE
@interface ORKPieChartView : UIView

@property (nonatomic) CGFloat pieChartRadius;

@property (nonatomic) CGFloat legendDotRadius;

@property (nonatomic) CGFloat legendPaddingHeight;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic) BOOL shouldAnimate;

@property (nonatomic) BOOL shouldAnimateLegend;

@property (nonatomic) CGFloat animationDuration;

@property (nonatomic, strong, nullable) UIFont *legendFont;

@property (nonatomic, strong, nullable) UIFont *percentageFont;

@property (nonatomic, weak, nullable) id <ORKPieChartViewDatasource> datasource;

@property (nonatomic) BOOL hidesPercentageLabels;

@property (nonatomic) BOOL hidesLegend;

@property (nonatomic) BOOL hidesCenterLabels;

@property (nonatomic, nullable) UILabel *titleLabel;

@property (nonatomic, nullable) UILabel *valueLabel;

@property (nonatomic) BOOL shouldDrawClockwise;

@property (nonatomic, strong, nullable) NSString *emptyText;

@end

NS_ASSUME_NONNULL_END
