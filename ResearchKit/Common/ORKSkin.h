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


@import UIKit;
#import "ORKDefines.h"


NS_ASSUME_NONNULL_BEGIN

/// Color used for toolbar
ORK_EXTERN NSString *const ORKToolBarTintColorKey;

/// Color used for view's backgroud
ORK_EXTERN NSString *const ORKBackgroundColorKey;

/// Color used for consent view's backgroud
ORK_EXTERN NSString *const ORKConsentBackgroundColorKey;

/// Color used for signature
ORK_EXTERN NSString *const ORKSignatureColorKey;

/// Color used for a light-colored tint
ORK_EXTERN NSString *const ORKLightTintColorKey;

/// Color used for a dark-colored tint
ORK_EXTERN NSString *const ORKDarkTintColorKey;

/// Color used for caption text
ORK_EXTERN NSString *const ORKCaptionTextColorKey;

/// Color used for a "blue" highlight
ORK_EXTERN NSString *const ORKBlueHighlightColorKey;

/// Default color used for legend, title and text on ORKPieChartView
ORK_EXTERN NSString *const ORKChartDefaultTextColorKey;

/// Default color used for axes of ORKGraphChartView
ORK_EXTERN NSString *const ORKGraphAxisColorKey;

/// Default color used for titles on axes of ORKGraphChartView
ORK_EXTERN NSString *const ORKGraphAxisTitleColorKey;

/// Default color used for scrubber line of ORKGraphChartView
ORK_EXTERN NSString *const ORKGraphScrubberLineColorKey;

/// Default color used for scrubber thumb of ORKGraphChartView
ORK_EXTERN NSString *const ORKGraphScrubberThumbColorKey;

/// Default color used for reference line of ORKGraphChartView
ORK_EXTERN NSString *const ORKGraphReferenceLineColorKey;

/// Default color used for auxiliary image tint of ORKInstructionStepView
ORK_EXTERN NSString *const ORKAuxiliaryImageTintColorKey;

/// Default color used for navigation container view
ORK_EXTERN NSString *const ORKNavigationContainerColorKey;

/// Color used for view's backgroud
ORK_EXTERN NSString *const ORKNavigationContainerShadowColorKey;

/// Default color progress label
ORK_EXTERN NSString *const ORKProgressLabelColorKey;

/// Default color used by iPadBackgroundView
ORK_EXTERN NSString *const ORKiPadBackgroundViewColorKey;

/// Return the color for a specified ORK...ColorKey
UIColor *ORKColor(NSString *colorKey);

/// Return minimum height for question step header view
ORK_EXTERN CGFloat ORKQuestionStepMinimumHeaderHeight;

/// Default CGFloat used for rounded corner radii for card view
ORK_EXTERN CGFloat ORKCardDefaultCornerRadii;

/// Default CGFloat used for border width for card view
ORK_EXTERN CGFloat ORKCardDefaultBorderWidth;

/// Default font size for card view
ORK_EXTERN CGFloat ORKCardDefaultFontSize;

/// Default Left and Right margin for card view
ORK_EXTERN CGFloat ORKCardLeftRightMargin;

/// Default Top and Bottom margin for card view
ORK_EXTERN CGFloat ORKCardTopBottomMargin;

/// Padding for Form and Question Step Table Containers
ORK_EXTERN CGFloat ORKSurveyTableContainerLeftRightPadding;

/// Default corner radius for iPadBackgroundView;
ORK_EXTERN CGFloat ORKiPadBackgroundViewCornerRadius;

/// Default Bottom margin for iPadBackgroundView;
ORK_EXTERN CGFloat ORKiPadBackgroundViewBottomPadding;

/// Default Left Right margin for iPadBackgroundView;
ORK_EXTERN CGFloat ORKiPadBackgroundViewLeftRightPadding;

/// Modify the color for a specified ORK...ColorKey. (for customization)
void ORKColorSetColorForKey(NSString *key, UIColor *color);

@interface UIColor (ORKColor)

+ (UIColor *)ork_midGrayTintColor;
+ (UIColor *)ork_redColor;
+ (UIColor *)ork_grayColor;
+ (UIColor *)ork_darkGrayColor;
+ (UIColor *)ork_borderGrayColor;

@end

extern const CGFloat ORKScreenMetricMaxDimension;

typedef NS_ENUM(NSInteger, ORKScreenMetric) {
    ORKScreenMetricTopToCaptionBaseline,
    ORKScreenMetricFontSizeHeadline,
    ORKScreenMetricMaxFontSizeHeadline,
    ORKScreenMetricFontSizeSurveyHeadline,
    ORKScreenMetricMaxFontSizeSurveyHeadline,
    ORKScreenMetricFontSizeSubheadline,
    ORKScreenMetricFontSizeFootnote,
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
    ORKScreenMetricContinueButtonHeightRegular,
    ORKScreenMetricContinueButtonHeightCompact,
    ORKScreenMetricContinueButtonWidth,
    ORKScreenMetricMinimumStepHeaderHeightForMemoryGame,
    ORKScreenMetricMinimumGameViewHeightForMemoryGame,
    ORKScreenMetricMinimumStepHeaderHeightForTowerOfHanoiPuzzle,
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
    ORKScreenMetricPSATKeyboardViewWidth,
    ORKScreenMetricPSATKeyboardViewHeight,
    ORKScreenMetricLocationQuestionMapHeight,
    ORKScreenMetricTopToIconImageViewTop,
    ORKScreenMetricIconImageViewToCaptionBaseline,
    ORKScreenMetricVerificationTextBaselineToResendButtonBaseline,
    ORKScreenMetric_COUNT
};

typedef NS_ENUM(NSInteger, ORKScreenType) {
    ORKScreenTypeiPhoneX,
    ORKScreenTypeiPhoneXSMax,
    ORKScreenTypeiPhone6Plus,
    ORKScreenTypeiPhone6,
    ORKScreenTypeiPhone5,
    ORKScreenTypeiPhone4,
    ORKScreenTypeiPad,
    ORKScreenTypeiPad10_5,
    ORKScreenTypeiPad12_9,
    ORKScreenType_COUNT
};

ORKScreenType ORKGetScreenTypeForScreen(UIScreen *screen);
ORKScreenType ORKGetVerticalScreenTypeForWindow(UIWindow * _Nullable window);
ORKScreenType ORKGetHorizontalScreenTypeForWindow(UIWindow * _Nullable window);
CGFloat ORKGetMetricForWindow(ORKScreenMetric metric, UIWindow * _Nullable window);

CGFloat ORKStandardLeftMarginForTableViewCell(UIView *view);
CGFloat ORKStandardHorizontalMarginForView(UIView *view);
UIEdgeInsets ORKStandardLayoutMarginsForTableViewCell(UIView *view);
UIEdgeInsets ORKStandardFullScreenLayoutMarginsForView(UIView *view);
UIEdgeInsets ORKScrollIndicatorInsetsForScrollView(UIView *view);
CGFloat ORKWidthForSignatureView(UIWindow * _Nullable window);
BOOL ORKNeedWideScreenDesign(UIView *view);

void ORKUpdateScrollViewBottomInset(UIScrollView *scrollView, CGFloat bottomInset);


NS_ASSUME_NONNULL_END
