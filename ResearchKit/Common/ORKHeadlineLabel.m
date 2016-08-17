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


#import "ORKHeadlineLabel.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@implementation ORKHeadlineLabel

+ (UIFont *)defaultFontInSurveyMode:(BOOL)surveyMode {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    const CGFloat defaultHeadlineSize = 17;
    
    CGFloat fontSize = [[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] - defaultHeadlineSize + ORKGetMetricForWindow(surveyMode ? ORKScreenMetricFontSizeSurveyHeadline : ORKScreenMetricFontSizeHeadline, nil);
    CGFloat maxFontSize = ORKGetMetricForWindow(surveyMode ? ORKScreenMetricMaxFontSizeSurveyHeadline : ORKScreenMetricMaxFontSizeHeadline, nil);
    
    return ORKLightFontWithSize(MIN(maxFontSize, fontSize));
}

+ (UIFont *)defaultFont {
    return [self defaultFontInSurveyMode:NO];
}

- (UIFont *)defaultFont {
    return [[self class] defaultFontInSurveyMode:_useSurveyMode];
}

- (void)setUseSurveyMode:(BOOL)useSurveyMode {
    _useSurveyMode = useSurveyMode;
    [self updateAppearance];
}

// Nasty override (hack)
- (void)updateAppearance {
    self.font = [self defaultFont];
    [self invalidateIntrinsicContentSize];
}

#pragma mark Accessibility

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitHeader;
}

@end
