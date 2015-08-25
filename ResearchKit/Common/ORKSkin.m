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
#import "ORKHelpers.h"


NSString *const ORKSignatureColorKey = @"ORKSignatureColorKey";
NSString *const ORKBackgroundColorKey = @"ORKBackgroundColorKey";
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

@implementation UIColor (ORKColor)

#define cachedColorMethod(m, r, g, b, a) \
+ (UIColor *)m { \
static UIColor *c##m = nil; \
static dispatch_once_t onceToken##m; \
dispatch_once(&onceToken##m, ^{ \
c##m = [[UIColor alloc] initWithRed:r green:g blue:b alpha:a]; \
}); \
return c##m; \
}

cachedColorMethod(ork_midGrayTintColor, 0./255., 0./255., 25./255., .22)
cachedColorMethod(ork_redColor, 255./255.,  59./255.,  48./255., 1.)
cachedColorMethod(ork_grayColor, 142./255., 142./255., 147./255., 1.)
cachedColorMethod(ork_darkGrayColor, 102./255., 102./255., 102./255., 1.)

#undef cachedColorMethod

@end

static NSMutableDictionary *colors() {
    
    static NSMutableDictionary *colors = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colors = [@{
                    ORKSignatureColorKey : ORKRGB(0x000000),
                    ORKBackgroundColorKey : ORKRGB(0xffffff),
                    ORKToolBarTintColorKey : ORKRGB(0xffffff),
                    ORKLightTintColorKey : ORKRGB(0xeeeeee),
                    ORKDarkTintColorKey : ORKRGB(0x888888),
                    ORKCaptionTextColorKey : ORKRGB(0xcccccc),
                    ORKBlueHighlightColorKey : [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0],
                    ORKChartDefaultTextColorKey : [UIColor lightGrayColor],
                    ORKGraphAxisColorKey : [UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:1.f],
                    ORKGraphAxisTitleColorKey : [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f],
                    ORKGraphReferenceLineColorKey : [UIColor colorWithRed:225/255.f green:225/255.f blue:229/255.f alpha:1.f],
                    ORKGraphScrubberLineColorKey : [UIColor grayColor],
                    ORKGraphScrubberThumbColorKey : [UIColor colorWithWhite:1 alpha:1.0]
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
const CGSize ORKiPadScreenSize = (CGSize){768, 1024};

ORKScreenType ORKGetVerticalScreenTypeForBounds(CGRect bounds) {
    ORKScreenType screenType = ORKScreenTypeiPhone6;
    CGFloat maximumDimension = MAX(bounds.size.width, bounds.size.height);
    if (maximumDimension < ORKiPhone4ScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone4;
    } else if (maximumDimension < ORKiPhone5ScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone5;
    } else if (maximumDimension < ORKiPhone6ScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone6;
    } else if (maximumDimension < ORKiPhone6PlusScreenSize.height + 1) {
        screenType = ORKScreenTypeiPhone6Plus;
    } else {
        screenType = ORKScreenTypeiPad;
    }
    return screenType;
}

ORKScreenType ORKGetHorizontalScreenTypeForBounds(CGRect bounds) {
    ORKScreenType screenType = ORKScreenTypeiPhone6;
    CGFloat minimumDimension = MIN(bounds.size.width, bounds.size.height);
    if (minimumDimension < ORKiPhone4ScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone4;
    } else if (minimumDimension < ORKiPhone5ScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone5;
    } else if (minimumDimension < ORKiPhone6ScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone6;
    } else if (minimumDimension < ORKiPhone6PlusScreenSize.width + 1) {
        screenType = ORKScreenTypeiPhone6Plus;
    } else {
        screenType = ORKScreenTypeiPad;
    }
    return screenType;
}

ORKScreenType ORKGetVerticalScreenTypeForWindow(UIWindow *window) {
    if (!window) {
        window = [[[UIApplication sharedApplication] windows] firstObject];
    }
    return ORKGetVerticalScreenTypeForBounds([window bounds]);
}

ORKScreenType ORKGetHorizontalScreenTypeForWindow(UIWindow *window) {
    if (!window) {
        window = [[[UIApplication sharedApplication] windows] firstObject];
    }
    return ORKGetHorizontalScreenTypeForBounds([window bounds]);
}


ORKScreenType ORKGetScreenTypeForScreen(UIScreen *screen) {
    ORKScreenType screenType = ORKScreenTypeiPhone6;
    if (screen == [UIScreen mainScreen]) {
        screenType = ORKGetVerticalScreenTypeForBounds([screen bounds]);
    }
    return screenType;
}



const CGFloat ORKScreenMetricMaxDimension = 10000.0;

CGFloat ORKGetMetricForScreenType(ORKScreenMetric metric, ORKScreenType screenType) {
    static  const CGFloat metrics[ORKScreenMetric_COUNT][ORKScreenType_COUNT] = {
        // iPhone 6+,  iPhone 6,  iPhone 5,  iPhone 4,      iPad
        {        128,       128,       100,       100,       218},      // ORKScreenMetricTopToCaptionBaseline
        {         35,        35,        32,        24,        35},      // ORKScreenMetricFontSizeHeadline
        {         38,        38,        32,        28,        38},      // ORKScreenMetricMaxFontSizeHeadline
        {         30,        30,        30,        24,        30},      // ORKScreenMetricFontSizeSurveyHeadline
        {         32,        32,        32,        28,        32},      // ORKScreenMetricMaxFontSizeSurveyHeadline
        {         17,        17,        17,        16,        17},      // ORKScreenMetricFontSizeSubheadline
        {         62,        62,        51,        51,        62},      // ORKScreenMetricCaptionBaselineToFitnessTimerTop
        {         62,        62,        43,        43,        62},      // ORKScreenMetricCaptionBaselineToTappingLabelTop
        {         36,        36,        32,        32,        36},      // ORKScreenMetricCaptionBaselineToInstructionBaseline
        {         30,        30,        28,        24,        30},      // ORKScreenMetricInstructionBaselineToLearnMoreBaseline
        {         44,        44,        20,        14,        44},      // ORKScreenMetricLearnMoreBaselineToStepViewTop
        {         40,        40,        30,        14,        40},      // ORKScreenMetricLearnMoreBaselineToStepViewTopWithNoLearnMore
        {         36,        36,        20,        12,        36},      // ORKScreenMetricContinueButtonTopMargin
        {         40,        40,        20,        12,        40},      // ORKScreenMetricContinueButtonTopMarginForIntroStep
        {          0,         0,         0,         0,        80},      // ORKScreenMetricTopToIllustration
        {         44,        44,        40,        40,        44},      // ORKScreenMetricIllustrationToCaptionBaseline
        {        198,       198,       194,       152,       297},      // ORKScreenMetricIllustrationHeight
        {        300,       300,       176,       152,       300},      // ORKScreenMetricInstructionImageHeight
        {         44,        44,        44,        44,        44},      // ORKScreenMetricContinueButtonHeightRegular
        {         44,        32,        32,        32,        44},      // ORKScreenMetricContinueButtonHeightCompact
        {        150,       150,       146,       146,       150},      // ORKScreenMetricContinueButtonWidth
        {        162,       162,       120,       116,       240},      // ORKScreenMetricMinimumStepHeaderHeightForMemoryGame
        {        162,       162,       120,       116,       240},      // ORKScreenMetricMinimumStepHeaderHeightForTowerOfHanoiPuzzle
        {         60,        60,        60,        44,        60},      // ORKScreenMetricTableCellDefaultHeight
        {         55,        55,        55,        44,        55},      // ORKScreenMetricTextFieldCellHeight
        {         36,        36,        36,        26,        36},      // ORKScreenMetricChoiceCellFirstBaselineOffsetFromTop,
        {         24,        24,        24,        18,        24},      // ORKScreenMetricChoiceCellLastBaselineToBottom,
        {         24,        24,        24,        24,        24},      // ORKScreenMetricChoiceCellLabelLastBaselineToLabelFirstBaseline,
        {         30,        30,        20,        20,        30},      // ORKScreenMetricLearnMoreButtonSideMargin
        {         10,        10,         0,         0,        10},      // ORKScreenMetricHeadlineSideMargin
        {         44,        44,        44,        44,        44},      // ORKScreenMetricToolbarHeight
        {        322,       274,       217,       217,       446},      // ORKScreenMetricVerticalScaleHeight
        {        156,       156,       156,       156,       256},      // ORKScreenMetricSignatureViewHeight
        {        384,       324,       304,       304,       384},      // ORKScreenMetricPSATKeyboardViewWidth
        {        197,       167,       157,       157,       197},      // ORKScreenMetricPSATKeyboardViewHeight
    };
    return metrics[metric][screenType];
}

CGFloat ORKGetMetricForWindow(ORKScreenMetric metric, UIWindow *window) {
    
    CGFloat ret = 0;
    switch (metric) {
        case ORKScreenMetricContinueButtonWidth:
        case ORKScreenMetricHeadlineSideMargin:
        case ORKScreenMetricLearnMoreButtonSideMargin:
            ret = ORKGetMetricForScreenType(metric, ORKGetHorizontalScreenTypeForWindow(window));
            break;
            
        default:
            ret = ORKGetMetricForScreenType(metric, ORKGetVerticalScreenTypeForWindow(window));
            break;
    }
    
    return ret;
}

const CGFloat ORKLayoutMarginWidthRegularBezel = 15.0;
const CGFloat ORKLayoutMarginWidthThinBezelRegular = 20.0;
const CGFloat ORKLayoutMarginWidthiPad = 115.0;

CGFloat ORKStandardLeftMarginForTableViewCell(UITableViewCell *cell) {
    CGFloat margin = 0;
    switch (ORKGetHorizontalScreenTypeForWindow(cell.window)) {
        case ORKScreenTypeiPhone4:
        case ORKScreenTypeiPhone5:
        case ORKScreenTypeiPhone6:
            margin = ORKLayoutMarginWidthRegularBezel;
            break;
        case ORKScreenTypeiPhone6Plus:
        case ORKScreenTypeiPad:
        default:
            margin = ORKLayoutMarginWidthThinBezelRegular;
            break;
    }
    return margin;
}

CGFloat ORKStandardHorizMarginForView(UIView *view) {
    CGFloat margin = 0;
    switch (ORKGetHorizontalScreenTypeForWindow(view.window)) {
        case ORKScreenTypeiPhone4:
        case ORKScreenTypeiPhone5:
        case ORKScreenTypeiPhone6:
        case ORKScreenTypeiPhone6Plus:
        default:
            margin = ORKStandardLeftMarginForTableViewCell(view);
            break;
        case ORKScreenTypeiPad:{
            // Use adaptive side margin, if view is wider than iPhone6 Plus.
            // Min Marign = ORKLayoutMarginWidthThinBezelRegular, Max Marign = ORKLayoutMarginWidthiPad
            CGFloat ratio =  (view.bounds.size.width - ORKiPhone6PlusScreenSize.width)/(ORKiPadScreenSize.width - ORKiPhone6PlusScreenSize.width);
            ratio = MIN(1.0, ratio);
            ratio = MAX(0.0, ratio);
            margin = ORKLayoutMarginWidthThinBezelRegular + (ORKLayoutMarginWidthiPad - ORKLayoutMarginWidthThinBezelRegular)*ratio;
            break;
        }
    }

    return margin;
}

UIEdgeInsets ORKStandardLayoutMarginsForTableViewCell(UITableViewCell *cell) {
    return (UIEdgeInsets){.left=ORKStandardLeftMarginForTableViewCell(cell),
                          .right=ORKStandardLeftMarginForTableViewCell(cell),
                          .bottom=8,
                          .top=8};
}

UIEdgeInsets ORKStandardFullScreenLayoutMarginsForView(UIView *view) {
    UIEdgeInsets layoutMargins = UIEdgeInsetsZero;
    ORKScreenType screenType = ORKGetHorizontalScreenTypeForWindow(view.window);
    if (screenType == ORKScreenTypeiPad) {
        CGFloat margin = ORKStandardHorizMarginForView(view);
        layoutMargins = (UIEdgeInsets){.left = margin, .right = margin };
    }
    return layoutMargins;
}

UIEdgeInsets ORKScrollIndicatorInsetsForScrollView(UIView *view) {
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsZero;
    ORKScreenType screenType = ORKGetHorizontalScreenTypeForWindow(view.window);
    if (screenType == ORKScreenTypeiPad) {
        CGFloat margin = ORKStandardHorizMarginForView(view);
        scrollIndicatorInsets = (UIEdgeInsets){.left = -margin, .right = -margin };
    }
    return scrollIndicatorInsets;
}

CGFloat ORKWidthForSignatureView(UIWindow *window) {
    const CGSize windowSize = window.bounds.size;
    const CGFloat windowPortraitWidth = MIN(windowSize.width, windowSize.height);
    const CGFloat signatureViewWidth = windowPortraitWidth - ( 2*ORKStandardHorizMarginForView(window) + 2*ORKStandardLeftMarginForTableViewCell(window) );
    return signatureViewWidth;
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
