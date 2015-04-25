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

@implementation UIColor(ORKColor)

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
                    ORKBlueHighlightColorKey : [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
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

CGFloat ORKGetMetricForWindow(ORKScreenMetric metric, UIWindow *window){
    return ORKGetMetricForScreenType(metric, ORKGetScreenTypeForWindow(window));
}

ORKScreenType ORKGetScreenTypeForWindow(UIWindow *window) {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ORKScreenTypeiPad;
    }
    if (! window) {
        window = [[[UIApplication sharedApplication] windows] firstObject];
    }
    CGRect windowBounds = [window bounds];
    if (windowBounds.size.height < 481) {
        return ORKScreenTypeiPhone4;
    } else if (windowBounds.size.height < 569) {
        return ORKScreenTypeiPhone5;
    } else {
        return ORKScreenTypeiPhone6;
    }
}


CGFloat ORKGetMetricForScreenType(ORKScreenMetric metric, ORKScreenType screenType) {
    
    static  const CGFloat metrics[ORKScreenMetric_COUNT][ORKScreenType_COUNT] = {
        // iPhone 6,iPhone 5, iPhone 4,    iPad
        {       128,     100,      100,     128},      // ORKScreenMetricTopToCaptionBaseline
        {        35,      32,       24,      35},      // ORKScreenMetricFontSizeHeadline
        {        38,      32,       28,      38},      // ORKScreenMetricMaxFontSizeHeadline
        {        30,      30,       24,      30},      // ORKScreenMetricFontSizeSurveyHeadline
        {        32,      32,       28,      32},      // ORKScreenMetricMaxFontSizeSurveyHeadline
        {        17,      17,       16,      17},      // ORKScreenMetricFontSizeSubheadline
        {        62,      51,       51,      62},      // ORKScreenMetricCaptionBaselineToFitnessTimerTop
        {        62,      43,       43,      62},      // ORKScreenMetricCaptionBaselineToTappingLabelTop
        {        36,      32,       32,      36},      // ORKScreenMetricCaptionBaselineToInstructionBaseline
        {        30,      28,       24,      30},      // ORKScreenMetricInstructionBaselineToLearnMoreBaseline
        {        44,      20,       14,      44},      // ORKScreenMetricLearnMoreBaselineToStepViewTop
        {        40,      30,       14,      40},      // ORKScreenMetricLearnMoreBaselineToStepViewTopWithNoLearnMore
        {        36,      20,       12,      36},      // ORKScreenMetricContinueButtonTopMargin
        {        40,      20,       12,      40},      // ORKScreenMetricContinueButtonTopMarginForIntroStep
        {        44,      40,       40,      44},      // ORKScreenMetricIllustrationToCaptionBaseline
        {       198,     194,      152,     297},      // ORKScreenMetricIllustrationHeight
        {       300,     176,      152,     300},      // ORKScreenMetricInstructionImageHeight
        {       150,     146,      146,     150},      // ORKScreenMetricContinueButtonWidth
        {       162,     120,      116,     162},      // ORKScreenMetricMinimumStepHeaderHeightForMemoryGame
        {        60,      60,       44,      60},      // ORKScreenMetricTableCellDefaultHeight
        {        55,      55,       44,      55},      // ORKScreenMetricTextFieldCellHeight
        {        36,      36,       26,      36},      // ORKScreenMetricChoiceCellFirstBaselineOffsetFromTop,
        {        24,      24,       18,      24},      // ORKScreenMetricChoiceCellLastBaselineToBottom,
        {        24,      24,       24,      24},      // ORKScreenMetricChoiceCellLabelLastBaselineToLabelFirstBaseline,
        {        30,      20,       20,      30},      // ORKScreenMetricLearnMoreButtonSideMargin
        {        10,       0,        0,      10},      // ORKScreenMetricHeadlineSideMargin
        {        44,      44,       44,      44},      // ORKScreenMetricToolbarHeight
    };
    
    return metrics[metric][screenType];
}

