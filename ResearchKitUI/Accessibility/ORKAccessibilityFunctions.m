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

#import "ORKScaleSlider.h"
#import "ORKScaleSliderView.h"

#import "ORKAnswerFormat_Internal.h"

#import "ORKAccessibilityFunctions.h"
#import "UIView+ORKAccessibility.h"


NSString *ORKAccessibilityFormatScaleSliderValue(CGFloat value, ORKScaleSlider *slider) {
    ORKScaleSliderView *sliderView = (ORKScaleSliderView *)[slider ork_superviewOfType:[ORKScaleSliderView class]];
    if (!slider || !sliderView) {
        return nil;
    }
    
    NSNumber *normalizedValue = [sliderView.formatProvider normalizedValueForNumber:@(value)];
    return [sliderView.formatProvider localizedStringForNumber:normalizedValue];
}

NSString *ORKAccessibilityFormatContinuousScaleSliderValue(CGFloat value, ORKScaleSlider *slider) {
    ORKScaleSliderView *sliderView = (ORKScaleSliderView *)[slider ork_superviewOfType:[ORKScaleSliderView class]];
    if (!slider || !sliderView) {
        return nil;
    }
    
    return [sliderView.formatProvider localizedStringForNumber:@(value)];
}

void ORKAccessibilityPerformBlockAfterDelay(NSTimeInterval delay, void(^block)(void)) {
    if (block == nil) {
        return;
    }
    if (!UIAccessibilityIsVoiceOverRunning()) {
        delay = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

NSString *_ORKAccessibilityStringForVariables(NSInteger numParameters, NSString *baseString, ...) {
    NSMutableArray *variables = [[NSMutableArray alloc] init];
    
    NSInteger paramIndex = 0;
    
    va_list args;
    va_start(args, baseString);
    for (__unsafe_unretained NSString *variable = baseString;
         paramIndex < numParameters;
         variable = va_arg(args, __unsafe_unretained NSString *), paramIndex++) {
        
        if ([variable isKindOfClass:[NSString class]] && variable.length > 0) {
            [variables addObject:variable];
        }
        
    }
    va_end(args);
    
    return [variables componentsJoinedByString:@", "];
}
