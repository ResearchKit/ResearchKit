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
#import <ResearchKit/ORKDefines.h>

/**
 *  IMPORTANT: THIS IS AN ABSTRACT CLASS. IT HOLDS PROPERTIES & METHODS COMMON TO CLASSES LIKE ORKLineGraphView & ORKDiscreteGraphView.
 */

@protocol ORKBaseGraphViewDelegate;

ORK_CLASS_AVAILABLE
@interface ORKBaseGraphView : UIView

@property (nonatomic, readonly) CGFloat minimumValue;

@property (nonatomic, readonly) CGFloat maximumValue;

@property (nonatomic, getter=isLandscapeMode) BOOL landscapeMode;

@property (nonatomic) BOOL showsVerticalReferenceLines;

/* Appearance */

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *axisColor;

@property (nonatomic, strong) UIColor *axisTitleColor;

@property (nonatomic, strong) UIFont *axisTitleFont;

@property (nonatomic, strong) UIColor *referenceLineColor;

@property (nonatomic, strong) UIColor *scrubberThumbColor;

@property (nonatomic, strong) UIColor *scrubberLineColor;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) NSString *emptyText;

//Support for image icons as legends
@property (nonatomic, strong) UIImage *maximumValueImage;

@property (nonatomic, strong) UIImage *minimumValueImage;

@property (nonatomic, weak) id <ORKBaseGraphViewDelegate> delegate;

- (void)sharedInit;

- (NSInteger)numberOfPlots;

- (NSInteger)numberOfPointsinPlot:(NSInteger)plotIndex;

- (void)scrubReferenceLineForXPosition:(CGFloat)xPosition;

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)refreshGraph;

@end


ORK_AVAILABLE_DECL
@protocol ORKBaseGraphViewDelegate <NSObject>

@optional

- (void)graphViewTouchesBegan:(ORKBaseGraphView *)graphView;

- (void)graphView:(ORKBaseGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition;

- (void)graphViewTouchesEnded:(ORKBaseGraphView *)graphView;

@end
