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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

/// Color used for toolbar
ORK_EXTERN NSString *const ORKToolBarTintColorKey;

/// Color used for view's backgroud
ORK_EXTERN NSString *const ORKBackgroundColorKey;

/// Color used for signature
ORK_EXTERN NSString *const ORKSignatureColorKey;

/// Color used for a light-colored tint
ORK_EXTERN NSString *const ORKLightTintColorKey;

/// Color used for a dark-colored tint
ORK_EXTERN NSString *const ORKDarkTintColorKey;

/// Color used for caption text
ORK_EXTERN NSString *const ORKCaptionTextColorKey;

/// Caption used for a "blue" highlight
ORK_EXTERN NSString *const ORKBlueHighlightColorKey;

/// Return the color for a specified ORK..ColorKey
UIColor *ORKColor(NSString *colorKey);

/// Modify the color for a specified ORK..ColorKey. (for customization)
void ORKColorSetColorForKey(NSString *key, UIColor *color);

@interface UIColor (ORKColor)

+ (UIColor *)ork_midGrayTintColor;
+ (UIColor *)ork_redColor;
+ (UIColor *)ork_grayColor;
+ (UIColor *)ork_darkGrayColor;

@end

extern const CGFloat ORKScreenMetricMaxDimension;

typedef NS_ENUM(NSInteger, ORKScreenMetric) {
    ORKScreenMetricTopToCaptionBaseline,
    ORKScreenMetricFontSizeHeadline,
    ORKScreenMetricMaxFontSizeHeadline,
    ORKScreenMetricFontSizeSurveyHeadline,
    ORKScreenMetricMaxFontSizeSurveyHeadline,
    ORKScreenMetricFontSizeSubheadline,
    ORKScreenMetricCaptionBaselineToFitnessTimerTop,
    ORKScreenMetricCaptionBaselineToTappingLabelTop,
    ORKScreenMetricCaptionBaselineToInstructionBaseline,
    ORKScreenMetricInstructionBaselineToLearnMoreBaseline,
    ORKScreenMetricLearnMoreBaselineToStepViewTop,
    ORKScreenMetricLearnMoreBaselineToStepViewTopWithNoLearnMore,
    ORKScreenMetricContinueButtonTopMargin,
    ORKScreenMetricContinueButtonTopMarginForIntroStep,
    ORKScreenMetricTopToIllustration,
    ORKScreenMetricIllustrationToCaptionBaseline,
    ORKScreenMetricIllustrationHeight,
    ORKScreenMetricInstructionImageHeight,
    ORKScreenMetricContinueButtonWidth,
    ORKScreenMetricMinimumStepHeaderHeightForMemoryGame,
    ORKScreenMetricTableCellDefaultHeight,
    ORKScreenMetricTextFieldCellHeight,
    ORKScreenMetricChoiceCellFirstBaselineOffsetFromTop,
    ORKScreenMetricChoiceCellLastBaselineToBottom,
    ORKScreenMetricChoiceCellLabelLastBaselineToLabelFirstBaseline,
    ORKScreenMetricLearnMoreButtonSideMargin,
    ORKScreenMetricHeadlineSideMargin,
    ORKScreenMetricToolbarHeight,
    ORKScreenMetricVerticalScaleHeight,
    ORKScreenMetricSignatureViewHeight,
    ORKScreenMetric_COUNT
};

typedef NS_ENUM(NSInteger, ORKScreenType) {
    ORKScreenTypeiPhone6Plus,
    ORKScreenTypeiPhone6,
    ORKScreenTypeiPhone5,
    ORKScreenTypeiPhone4,
    ORKScreenTypeiPad,
    ORKScreenType_COUNT
};

ORKScreenType ORKGetScreenTypeForWindow(UIWindow *__nullable window);
CGFloat ORKGetMetricForScreenType(ORKScreenMetric metric, ORKScreenType screenType);
CGFloat ORKGetMetricForWindow(ORKScreenMetric metric, UIWindow *__nullable window);

CGFloat ORKStandardLeftMarginForTableViewCell(UIView *view);
CGFloat ORKStandardHorizMarginForView(UIView *view);
UIEdgeInsets ORKStandardLayoutMarginsForTableViewCell(UIView *view);
UIEdgeInsets ORKStandardFullScreenLayoutMarginsForView(UIView *view);
UIEdgeInsets ORKScrollIndicatorInsetsForScrollView(UIView *view);
CGFloat ORKWidthForSignatureView(UIWindow *window);

void ORKUpdateScrollViewBottomInset(UIScrollView *scrollView, CGFloat bottomInset);


NS_ASSUME_NONNULL_END
