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


#import "ORKSkin.h"

#import "ORKHelpers_Internal.h"


NSString *const ORKSignatureColorKey = @"ORKSignatureColorKey";
NSString *const ORKBackgroundColorKey = @"ORKBackgroundColorKey";
NSString *const ORKConsentBackgroundColorKey = @"ORKConsentBackgroundColorKey";
NSString *const ORKToolBarTintColorKey = @"ORKToolBarTintColorKey";
NSString *const ORKLightTintColorKey = @"ORKLightTintColorKey";
NSString *const ORKDarkTintColorKey = @"ORKDarkTintColorKey";
NSString *const ORKCaptionTextColorKey = @"ORKCaptionTextColorKey";
NSString *const ORKBlueHighlightColorKey = @"ORKBlueHighlightColorKey";
NSString *const ORKChartDefaultTextColorKey = @"ORKChartDefaultTextColorKey";
NSString *const ORKGraphAxisColorKey = @"ORKGraphAxisColorKey";
NSString *const ORKGraphAxisTitleColorKey = @"ORKGraphAxisTitleColorKey";
NSString *const ORKGraphReferenceLineColorKey = @"ORKGraphReferenceLineColorKey";
NSString *const ORKGraphScrubberLineColorKey = @"ORKGraphScrubberLineColorKey";
NSString *const ORKGraphScrubberThumbColorKey = @"ORKGraphScrubberThumbColorKey";
NSString *const ORKAuxiliaryImageTintColorKey = @"ORKAuxiliaryImageTintColorKey";
NSString *const ORKNavigationContainerColorKey = @"ORKNavigationContainerColorKey";
NSString *const ORKNavigationContainerShadowColorKey = @"ORKNavigationContainerShadowColorKey";
NSString *const ORKProgressLabelColorKey = @"ORKProgressLabelColorKey";
NSString *const ORKiPadBackgroundViewColorKey = @"ORKiPadBacgroundViewColorKey";
NSString *const ORKTopContentImageViewBackgroundColorKey = @"ORKTopContentImageViewBackgroundColorKey";
NSString *const ORKBulletItemTextColorKey = @"ORKBulletItemTextColorKey";
NSString *const ORKStepTopContentImageChangedKey = @"ORKStepTopContentImageChanged";
NSString *const ORKDoneButtonPressedKey = @"ORKDoneButtonPressed";
NSString *const ORKResetDoneButtonKey = @"ORKResetDoneButton";
CGFloat ORKQuestionStepMinimumHeaderHeight = 29.75;
CGFloat ORKCardDefaultCornerRadii = 10.0;
CGFloat ORKCardDefaultBorderWidth = 0.0;
CGFloat ORKCardDefaultFontSize = 25.0;
CGFloat ORKSurveyItemMargin = 16.0;
CGFloat ORKSurveyTableContainerLeftRightPadding = 20.0;
CGFloat ORKiPadBackgroundViewCornerRadius = 20.0;
CGFloat ORKiPadBackgroundViewBottomPadding = 50.0;
CGFloat ORKiPadBackgroundViewLeftRightPadding = 115.0;

CGFloat ORKStepContainerLeftRightMarginForXSMax = 20.0;
CGFloat ORKStepContainerLeftRightMarginForXS = 16.0;
CGFloat ORKStepContainerLeftRightMarginFor7Plus = 20.0;
CGFloat ORKStepContainerLeftRightMarginFor7 = 16.0;
CGFloat ORKStepContainerLeftRightMarginForSE = 16.0;
CGFloat ORKStepContainerLeftRightMarginForDefault = 16.0;

CGFloat ORKStepContainerExtendedLeftRightMarginForXSMax = 24.0;
CGFloat ORKStepContainerExtendedLeftRightMarginForXS = 24.0;
CGFloat ORKStepContainerExtendedLeftRightMarginFor7Plus = 24.0;
CGFloat ORKStepContainerExtendedLeftRightMarginFor7 = 24.0;
CGFloat ORKStepContainerExtendedLeftRightMarginForSE = 16.0;
CGFloat ORKStepContainerExtendedLeftRightMarginForDefault = 24.0;

CGFloat ORKStepContainerTopMarginForXSMax = 44.0;
CGFloat ORKStepContainerTopMarginForXS = 44.0;
CGFloat ORKStepContainerTopMarginFor7Plus = 20.0;
CGFloat ORKStepContainerTopMarginFor7 = 20.0;
CGFloat ORKStepContainerTopMarginForSE = 20.0;
CGFloat ORKStepContainerTopMarginForDefault = 20.0;

CGFloat ORKStepContainerTitleToBodyTopPaddingStandard = 15.0;
CGFloat ORKStepContainerTitleToBodyTopPaddingShort = 11.0;
CGFloat ORKBodyToBodyPaddingStandard = 12.0;
CGFloat ORKBodyToBodyParagraphPaddingStandard = 22.0;

CGFloat ORKStepContainerTitleToBulletTopPaddingShort = 37.0;

CGFloat ORKStepContainerTopContentHeightPercentage = 36.0;
CGFloat ORKStepContainerFirstItemTopPaddingPercentage = 9.0;

CGFloat ORKStepContentIconImageViewDimension = 80.0;

CGFloat ORKEffectViewOpacityHidden = 0.0;
CGFloat ORKEffectViewOpacityVisible = 1.0;

CGFloat CheckmarkViewDimension = 25.0;

@implementation UIColor (ORKColor)

#define ORKCachedColorMethod(m, r, g, b, a) \
+ (UIColor *)m { \
    static UIColor *c##m = nil; \
    static dispatch_once_t onceToken##m; \
    dispatch_once(&onceToken##m, ^{ \
        c##m = [[UIColor alloc] initWithRed:r green:g blue:b alpha:a]; \
    }); \
    return c##m; \
}

ORKCachedColorMethod(ork_midGrayTintColor, 0.0 / 255.0, 0.0 / 255.0, 25.0 / 255.0, 0.22)
ORKCachedColorMethod(ork_redColor, 255.0 / 255.0,  59.0 / 255.0,  48.0 / 255.0, 1.0)
ORKCachedColorMethod(ork_grayColor, 142.0 / 255.0, 142.0 / 255.0, 147.0 / 255.0, 1.0)
ORKCachedColorMethod(ork_darkGrayColor, 102.0 / 255.0, 102.0 / 255.0, 102.0 / 255.0, 1.0)
ORKCachedColorMethod(ork_borderGrayColor, 239.0 / 255.0, 239.0 / 255.0, 244.0 / 255.0, 1.0)

#undef ORKCachedColorMethod

@end

static NSMutableDictionary *colors() {
    static NSMutableDictionary *colors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *backgroundColor;
        if (@available(iOS 13.0, *)) {
            backgroundColor = [UIColor secondarySystemBackgroundColor];
        } else {
            backgroundColor = [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:244.0 / 255.0 alpha:1.0];
        }

        colors = [@{
                    ORKSignatureColorKey: ORKRGB(0x000000),
                    ORKBackgroundColorKey: backgroundColor,
                    ORKConsentBackgroundColorKey: ORKRGB(0xffffff),
                    ORKToolBarTintColorKey: ORKRGB(0xffffff),
                    ORKLightTintColorKey: ORKRGB(0xeeeeee),
                    ORKDarkTintColorKey: ORKRGB(0x888888),
                    ORKCaptionTextColorKey: ORKRGB(0xcccccc),
                    ORKBlueHighlightColorKey: [UIColor colorWithRed:0.0 green:122.0 / 255.0 blue:1.0 alpha:1.0],
                    ORKChartDefaultTextColorKey: [UIColor lightGrayColor],
                    ORKGraphAxisColorKey: [UIColor colorWithRed:217.0 / 255.0 green:217.0 / 255.0 blue:217.0 / 255.0 alpha:1.0],
                    ORKGraphAxisTitleColorKey: [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0],
                    ORKGraphReferenceLineColorKey: [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:229.0 / 255.0 alpha:1.0],
                    ORKGraphScrubberLineColorKey: [UIColor grayColor],
                    ORKGraphScrubberThumbColorKey: [UIColor colorWithWhite:1.0 alpha:1.0],
                    ORKAuxiliaryImageTintColorKey: [UIColor colorWithRed:228.0 / 255.0 green:233.0 / 255.0 blue:235.0 / 255.0 alpha:1.0],
                    ORKNavigationContainerColorKey: [UIColor colorWithRed:249.0 / 255.0 green:249.0 / 255.0 blue:251.0 / 255.0 alpha:0.0],
                    ORKNavigationContainerShadowColorKey: [UIColor blackColor],
                    ORKProgressLabelColorKey: [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0],
                    ORKiPadBackgroundViewColorKey: [UIColor colorWithRed:249.0 / 255.0 green:249.0 / 255.0 blue:251.0 / 255.0 alpha:1.0],
                    ORKTopContentImageViewBackgroundColorKey: (ORKRGB(0xD7D7D7)),
                    ORKBulletItemTextColorKey: [UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]
                    } mutableCopy];
    });
    return colors;
}

UIColor *ORKColor(NSString *colorKey) {
    return colors()[colorKey];
}

void ORKColorSetColorForKey(NSString *key, UIColor *color) {
    NSMutableDictionary *d = colors();
    d[key] = color;
}

const CGSize ORKiPhone4ScreenSize = (CGSize){320, 480};
const CGSize ORKiPhone5ScreenSize = (CGSize){320, 568};
const CGSize ORKiPhone6ScreenSize = (CGSize){375, 667};
const CGSize ORKiPhone6PlusScreenSize = (CGSize){414, 736};
const CGSize ORKiPhoneXScreenSize = (CGSize){375, 812};
const CGSize ORKiPhoneXSMaxScreenSize = (CGSize){414, 896};
const CGSize ORKiPadScreenSize = (CGSize){768, 1024};
const CGSize ORKiPad10_5ScreenSize = (CGSize){834, 1112};
const CGSize ORKiPad12_9ScreenSize = (CGSize){1024, 1366};

static ORKScreenType ORKGetVerticalScreenTypeForBounds(CGRect bounds) {
    ORKScreenType screenType = ORKScreenTypeiPhone6;
    CGFloat maximumDimension = MAX(bounds.size.width, bounds.size.height);
    if (maximumDimension < ORKiPhone5ScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone5;
    } else if (maximumDimension < ORKiPhone6ScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone6;
    } else if (maximumDimension < ORKiPhone6PlusScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone6Plus;
    } else if (maximumDimension < ORKiPhoneXScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhoneX;
    } else if (maximumDimension < ORKiPhoneXSMaxScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhoneXSMax;
    } else if (maximumDimension < ORKiPadScreenSize.height + 1) {
        screenType = ORKScreenTypeiPad;
    } else if (maximumDimension < ORKiPad10_5ScreenSize.height + 1) {
        screenType = ORKScreenTypeiPad10_5;
    } else {
        screenType = ORKScreenTypeiPad12_9;
    }
    return screenType;
}

static ORKScreenType ORKGetHorizontalScreenTypeForBounds(CGRect bounds) {
    ORKScreenType screenType = ORKScreenTypeiPhone6;
    CGFloat minimumDimension = MIN(bounds.size.width, bounds.size.height);
    if (minimumDimension < ORKiPhone5ScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone5;
    } else if (minimumDimension < ORKiPhone6ScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone6;
    }  else if (minimumDimension < ORKiPhoneXScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhoneX;
    }  else if (minimumDimension < ORKiPhoneXSMaxScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhoneXSMax;
    } else if (minimumDimension < ORKiPhone6PlusScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone6Plus;
    } else if (minimumDimension < ORKiPadScreenSize.width + 1) {
        screenType = ORKScreenTypeiPad;
    } else if (minimumDimension < ORKiPad10_5ScreenSize.width + 1) {
        screenType = ORKScreenTypeiPad10_5;
    } else {
        screenType = ORKScreenTypeiPad12_9;
    }
    return screenType;
}

static UIWindow *ORKDefaultWindowIfWindowIsNil(UIWindow *window) {
    if (!window) {
        // Use this method instead of UIApplication's keyWindow or UIApplication's delegate's window
        // because we may need the window before the keyWindow is set (e.g., if a view controller
        // loads programmatically on the app delegate to be assigned as the root view controller)
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    return window;
}

ORKScreenType ORKGetVerticalScreenTypeForWindow(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window);
    return ORKGetVerticalScreenTypeForBounds(window.bounds);
}

static ORKScreenType ORKGetHorizontalScreenTypeForWindow(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window);
    return ORKGetHorizontalScreenTypeForBounds(window.bounds);
}

const CGFloat ORKScreenMetricMaxDimension = 10000.0;

static CGFloat ORKGetMetricForScreenType(ORKScreenMetric metric, ORKScreenType screenType) {
    static  const CGFloat metrics[ORKScreenMetric_COUNT][ORKScreenType_COUNT] = {
        //   iPhoneX, iPhoneXSMAX, iPhone 6+,  iPhone 6,  iPhone 5,    iPad,    iPad 10.5,   iPad 12.9
        {        128,       128,       128,       128,       100,       218,       218,       218},      // ORKScreenMetricTopToCaptionBaseline
        {         35,        35,        35,        35,        32,        35,        35,        35},      // ORKScreenMetricFontSizeHeadline
        {         38,        38,        38,        38,        32,        38,        38,        38},      // ORKScreenMetricMaxFontSizeHeadline
        {         30,        30,        30,        30,        30,        30,        30,        30},      // ORKScreenMetricFontSizeSurveyHeadline
        {         32,        32,        32,        32,        32,        32,        32,        32},      // ORKScreenMetricMaxFontSizeSurveyHeadline
        {         17,        17,        17,        17,        17,        17,        17,        17},      // ORKScreenMetricFontSizeSubheadline
        {         12,        12,        12,        12,        12,        12,        12,        12},      // ORKScreenMetricFontSizeFootnote
        {         62,        62,        62,        62,        51,        62,        62,        62},      // ORKScreenMetricCaptionBaselineToFitnessTimerTop
        {         62,        62,        62,        62,        43,        62,        62,        62},      // ORKScreenMetricCaptionBaselineToTappingLabelTop
        {         36,        36,        36,        36,        32,        36,        36,        36},      // ORKScreenMetricCaptionBaselineToInstructionBaseline
        {         30,        30,        30,        30,        28,        30,        30,        30},      // ORKScreenMetricInstructionBaselineToLearnMoreBaseline
        {         44,        44,        44,        44,        20,        44,        44,        44},      // ORKScreenMetricLearnMoreBaselineToStepViewTop
        {         40,        40,        40,        40,        30,        40,        40,        40},      // ORKScreenMetricLearnMoreBaselineToStepViewTopWithNoLearnMore
        {         36,        36,        36,        36,        20,        36,        36,        36},      // ORKScreenMetricContinueButtonTopMargin
        {         40,        40,        40,        40,        20,        40,        40,        40},      // ORKScreenMetricContinueButtonTopMarginForIntroStep
        {          0,         0,         0,         0,         0,        80,       170,       170},      // ORKScreenMetricTopToIllustration
        {         44,        44,        44,        40,        40,        44,        44,        44},      // ORKScreenMetricIllustrationToCaptionBaseline
        {        198,       198,       198,       194,       152,       297,       297,       297},      // ORKScreenMetricIllustrationHeight
        {        300,       300,       300,       176,       152,       300,       300,       300},      // ORKScreenMetricInstructionImageHeight
        {        150,       150,       150,       146,       146,       150,       150,       150},      // ORKScreenMetricContinueButtonWidth
        {        162,       162,       162,       120,       116,       240,       240,       240},      // ORKScreenMetricMinimumStepHeaderHeightForMemoryGame
        {        200,       250,       200,       180,       150,       250,       250,       250},      // ORKScreenMetricMinimumGameViewHeightForMemoryGame
        {        162,       162,       162,       120,       116,       240,       240,       240},      // ORKScreenMetricMinimumStepHeaderHeightForTowerOfHanoiPuzzle
        {         60,        60,        60,        60,        44,        60,        60,        60},      // ORKScreenMetricTableCellDefaultHeight
        {         55,        55,        55,        55,        44,        55,        55,        55},      // ORKScreenMetricTextFieldCellHeight
        {         36,        36,        36,        36,        26,        36,        36,        36},      // ORKScreenMetricChoiceCellFirstBaselineOffsetFromTop,
        {         24,        24,        24,        24,        18,        24,        24,        24},      // ORKScreenMetricChoiceCellLastBaselineToBottom,
        {         24,        24,        24,        24,        24,        24,        24,        24},      // ORKScreenMetricChoiceCellLabelLastBaselineToLabelFirstBaseline,
        {         30,        30,        30,        30,        20,        30,        30,        30},      // ORKScreenMetricLearnMoreButtonSideMargin
        {         10,        10,        10,        10,         0,        10,        10,        10},      // ORKScreenMetricHeadlineSideMargin
        {         44,        44,        44,        44,        44,        44,        44,        44},      // ORKScreenMetricToolbarHeight
        {        274,       322,       274,       217,       217,       446,       446,       446},      // ORKScreenMetricVerticalScaleHeight
        {        200,       200,       200,       200,       198,       256,       256,       256},      // ORKScreenMetricSignatureViewHeight
        {        324,       384,       324,       304,       304,       384,       384,       384},      // ORKScreenMetricPSATKeyboardViewWidth
        {        197,       197,       167,       157,       157,       197,       197,       197},      // ORKScreenMetricPSATKeyboardViewHeight
        {        238,       238,       238,       150,        90,       238,       238,       238},      // ORKScreenMetricLocationQuestionMapHeight
        {         40,        40,        40,        20,        14,        40,        40,        40},      // ORKScreenMetricTopToIconImageViewTop
        {         44,        44,        44,        40,        40,        80,        80,        80},      // ORKScreenMetricIconImageViewToCaptionBaseline
        {         30,        30,        30,        26,        22,        30,        30,        30},      // ORKScreenMetricVerificationTextBaselineToResendButtonBaseline
    };
    return metrics[metric][screenType];
}

CGFloat ORKGetMetricForWindow(ORKScreenMetric metric, UIWindow *window) {
    CGFloat metricValue = 0;
    switch (metric) {
        case ORKScreenMetricContinueButtonWidth:
        case ORKScreenMetricHeadlineSideMargin:
        case ORKScreenMetricLearnMoreButtonSideMargin:
            metricValue = ORKGetMetricForScreenType(metric, ORKGetHorizontalScreenTypeForWindow(window));
            break;
            
        default:
            metricValue = ORKGetMetricForScreenType(metric, ORKGetVerticalScreenTypeForWindow(window));
            break;
    }
    
    return metricValue;
}

const CGFloat ORKLayoutMarginWidthRegularBezel = 15.0;
const CGFloat ORKLayoutMarginWidthThinBezelRegular = 20.0;
const CGFloat ORKLayoutMarginWidthiPad = 0.0;

static CGFloat ORKStandardLeftTableViewCellMarginForWindow(UIWindow *window) {
    CGFloat margin = 0;
    switch (ORKGetHorizontalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhone5:
        case ORKScreenTypeiPhone6:
            margin = ORKLayoutMarginWidthRegularBezel;
            break;
        case ORKScreenTypeiPhone6Plus:
        case ORKScreenTypeiPad:
        case ORKScreenTypeiPad10_5:
        case ORKScreenTypeiPad12_9:
        default:
            margin = ORKLayoutMarginWidthThinBezelRegular;
            break;
    }
    return margin;
}

CGFloat ORKStandardLeftMarginForTableViewCell(UITableViewCell *cell) {
    return ORKStandardLeftTableViewCellMarginForWindow(cell.window);
}

static CGFloat ORKStandardHorizontalAdaptiveSizeMarginForiPadWidth(CGFloat screenSizeWidth, UIWindow *window) {
    // Use adaptive side margin, if window is wider than iPhone6 Plus.
    // Min Margin = ORKLayoutMarginWidthThinBezelRegular, Max Margin = ORKLayoutMarginWidthiPad or iPad12_9
    
    CGFloat ratio =  (window.bounds.size.width - ORKiPhone6PlusScreenSize.width) / (screenSizeWidth - ORKiPhone6PlusScreenSize.width);
    ratio = MIN(1.0, ratio);
    ratio = MAX(0.0, ratio);
    return ORKLayoutMarginWidthThinBezelRegular + (ORKLayoutMarginWidthiPad - ORKLayoutMarginWidthThinBezelRegular)*ratio;
}

static CGFloat ORKStandardHorizontalMarginForWindow(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window); // need a proper window to use bounds
    CGFloat margin = 0;
    switch (ORKGetHorizontalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhone5:
        case ORKScreenTypeiPhone6:
        case ORKScreenTypeiPhoneX:
        case ORKScreenTypeiPhoneXSMax:
        case ORKScreenTypeiPhone6Plus:
        default:
            margin = ORKStandardLeftTableViewCellMarginForWindow(window);
            break;
        case ORKScreenTypeiPad:{
            margin = ORKStandardHorizontalAdaptiveSizeMarginForiPadWidth(ORKiPadScreenSize.width, window);
            break;
        }
        case ORKScreenTypeiPad10_5:{
            margin = ORKStandardHorizontalAdaptiveSizeMarginForiPadWidth(ORKiPad10_5ScreenSize.width, window);
            break;
        }
        case ORKScreenTypeiPad12_9:{
            margin = ORKStandardHorizontalAdaptiveSizeMarginForiPadWidth(ORKiPad12_9ScreenSize.width, window);
            break;
        }
    }
    return margin;
}

CGFloat ORKStandardHorizontalMarginForView(UIView *view) {
    return ORKStandardHorizontalMarginForWindow(view.window);
}

UIEdgeInsets ORKStandardLayoutMarginsForTableViewCell(UITableViewCell *cell) {
    const CGFloat StandardVerticalTableViewCellMargin = 8.0;
    return (UIEdgeInsets){.left = ORKStandardLeftMarginForTableViewCell(cell),
                          .right = ORKStandardLeftMarginForTableViewCell(cell),
                          .bottom = StandardVerticalTableViewCellMargin,
                          .top = StandardVerticalTableViewCellMargin};
}

UIEdgeInsets ORKStandardFullScreenLayoutMarginsForView(UIView *view) {
    UIEdgeInsets layoutMargins = UIEdgeInsetsZero;
    ORKScreenType screenType = ORKGetHorizontalScreenTypeForWindow(view.window);
    if (screenType == ORKScreenTypeiPad || screenType == ORKScreenTypeiPad10_5 || screenType == ORKScreenTypeiPad12_9) {
        CGFloat margin = ORKStandardHorizontalMarginForView(view);
        layoutMargins = (UIEdgeInsets){.left = margin, .right = margin };
    }
    return layoutMargins;
}

UIEdgeInsets ORKScrollIndicatorInsetsForScrollView(UIView *view) {
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsZero;
    ORKScreenType screenType = ORKGetHorizontalScreenTypeForWindow(view.window);
    if (screenType == ORKScreenTypeiPad || screenType == ORKScreenTypeiPad10_5 || screenType == ORKScreenTypeiPad12_9) {
        CGFloat margin = ORKStandardHorizontalMarginForView(view);
        scrollIndicatorInsets = (UIEdgeInsets){.left = -margin, .right = -margin };
    }
    return scrollIndicatorInsets;
}

CGFloat ORKWidthForSignatureView(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window); // need a proper window to use bounds
    const CGSize windowSize = window.bounds.size;
    const CGFloat windowPortraitWidth = MIN(windowSize.width, windowSize.height);
    const CGFloat signatureViewWidth = windowPortraitWidth - (2 * ORKStandardHorizontalMarginForView(window) + 2 * ORKStandardLeftMarginForTableViewCell(window));
    if (ORKNeedWideScreenDesign(window)) {
        return signatureViewWidth - 2 * ORKiPadBackgroundViewLeftRightPadding;
    }
    return signatureViewWidth;
}

BOOL ORKNeedWideScreenDesign(UIView *view) {
    return ORKStandardHorizontalMarginForView(view) == ORKLayoutMarginWidthiPad;
}

void ORKUpdateScrollViewBottomInset(UIScrollView *scrollView, CGFloat bottomInset) {
    UIEdgeInsets insets = scrollView.contentInset;
    if (!ORKCGFloatNearlyEqualToFloat(insets.bottom, bottomInset)) {
        CGPoint savedOffset = scrollView.contentOffset;
        
        insets.bottom = bottomInset;
        scrollView.contentInset = insets;
        
        insets = scrollView.scrollIndicatorInsets;
        insets.bottom = bottomInset;
        scrollView.scrollIndicatorInsets = insets;
        
        scrollView.contentOffset = savedOffset;
    }
}

CGFloat ORKStepContainerLeftRightPaddingForWindow(UIWindow *window) {
    CGFloat margin = 0;
    switch (ORKGetHorizontalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhoneXSMax:
            margin = ORKStepContainerLeftRightMarginForXSMax;
            break;
        case ORKScreenTypeiPhoneX:
            margin = ORKStepContainerLeftRightMarginForXS;
            break;
        case ORKScreenTypeiPhone6Plus:
            margin = ORKStepContainerLeftRightMarginFor7Plus;
            break;
        case ORKScreenTypeiPhone6:
            margin = ORKStepContainerLeftRightMarginFor7;
            break;
        case ORKScreenTypeiPhone5:
            margin = ORKStepContainerLeftRightMarginForSE;
            break;
        default:
            margin = ORKStepContainerLeftRightMarginForDefault;
            break;
    }
    return margin;
}

CGFloat ORKStepContainerExtendedLeftRightPaddingForWindow(UIWindow *window) {
    CGFloat margin = 0;
    switch (ORKGetHorizontalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhoneXSMax:
            margin = ORKStepContainerExtendedLeftRightMarginForXSMax;
            break;
        case ORKScreenTypeiPhoneX:
            margin = ORKStepContainerExtendedLeftRightMarginForXS;
            break;
        case ORKScreenTypeiPhone6Plus:
            margin = ORKStepContainerExtendedLeftRightMarginFor7Plus;
            break;
        case ORKScreenTypeiPhone6:
            margin = ORKStepContainerExtendedLeftRightMarginFor7;
            break;
        case ORKScreenTypeiPhone5:
            margin = ORKStepContainerExtendedLeftRightMarginForSE;
            break;
        default:
            margin = ORKStepContainerExtendedLeftRightMarginForDefault;
            break;
    }
    return margin;
}

CGFloat ORKStepContainerTopPaddingForWindow(UIWindow *window) {
    CGFloat margin = 0;
    switch (ORKGetVerticalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhoneXSMax:
            margin = ORKStepContainerTopMarginForXSMax;
            break;
        case ORKScreenTypeiPhoneX:
            margin = ORKStepContainerTopMarginForXS;
            break;
        case ORKScreenTypeiPhone6Plus:
            margin = ORKStepContainerTopMarginFor7Plus;
            break;
        case ORKScreenTypeiPhone6:
            margin = ORKStepContainerTopMarginFor7;
            break;
        case ORKScreenTypeiPhone5:
            margin = ORKStepContainerTopMarginForSE;
            break;
        default:
            margin = ORKStepContainerTopMarginForDefault;
            break;
    }
    return margin;
}

CGFloat ORKStepContainerTopContentHeightForWindow(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window);
    const CGSize windowSize = window.bounds.size;
    return ceil((ORKStepContainerTopContentHeightPercentage / 100.0) * windowSize.height);
}

CGFloat ORKStepContainerFirstItemTopPaddingForWindow(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window);
    const CGSize windowSize = window.bounds.size;
    return ceil((ORKStepContainerFirstItemTopPaddingPercentage / 100.0) * windowSize.height);
}

//FIXME: Consolidate title/Icon to Body/Bullet methods into one. remove copy paste.

CGFloat ORKStepContainerTitleToBodyTopPaddingForWindow(UIWindow *window) {
    CGFloat padding = 0;
    switch (ORKGetVerticalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhone5:
            padding = ORKStepContainerTitleToBodyTopPaddingShort;
            break;
        case ORKScreenTypeiPhoneXSMax:
        case ORKScreenTypeiPhoneX:
        case ORKScreenTypeiPhone6Plus:
        case ORKScreenTypeiPhone6:
        default:
            padding = ORKStepContainerTitleToBodyTopPaddingStandard;
            break;
    }
    return padding;
}

CGFloat ORKStepContainerTitleToBulletTopPaddingForWindow(UIWindow *window) {
    CGFloat padding = 0;
    switch (ORKGetVerticalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhone5:
            padding = ORKStepContainerTitleToBulletTopPaddingShort;
            break;
        case ORKScreenTypeiPhoneXSMax:
        case ORKScreenTypeiPhoneX:
        case ORKScreenTypeiPhone6Plus:
        case ORKScreenTypeiPhone6:
        default:
            // FIXME:- defaulting to short padding for larger devices as well
            padding = ORKStepContainerTitleToBulletTopPaddingShort;
            break;
    }
    return padding;
}

CGFloat ORKCardLeftRightMarginForWindow(UIWindow *window) {
    return ORKStepContainerLeftRightPaddingForWindow(window);
}

UIFontTextStyle ORKTitleLabelFontTextStyleForWindow(UIWindow *window) {
    window = ORKDefaultWindowIfWindowIsNil(window);
    switch (ORKGetVerticalScreenTypeForWindow(window)) {
        case ORKScreenTypeiPhone5:
            return UIFontTextStyleTitle1;
        default:
            return UIFontTextStyleLargeTitle;
    }
}
