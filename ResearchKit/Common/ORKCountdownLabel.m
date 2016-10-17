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


#import "ORKCountdownLabel.h"

#import "ORKHelpers_Internal.h"


@implementation ORKCountdownLabel {
    NSInteger _currentCountDownValue;
}

+ (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:65.f weight:UIFontWeightUltraLight];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentCountDownValue = 0;
    }
    return self;
}

- (void)updateAppearance {
    [self setCountDownValue:_currentCountDownValue];
}

- (void)setCountDownValue:(NSInteger)value {
    _currentCountDownValue = value;
    [self renderText];
}

- (void)renderText {
    static dispatch_once_t onceToken;
    static NSDateComponentsFormatter *durationFormatter = nil;
    dispatch_once(&onceToken, ^{
        durationFormatter = [NSDateComponentsFormatter new];
        [durationFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStylePositional];
        durationFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
        durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    });
   
    [self setText:[durationFormatter stringFromTimeInterval:_currentCountDownValue]];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self renderText];
}

- (CGSize)intrinsicContentSize {
    CGSize intrinsic = [super intrinsicContentSize];
    return (CGSize){.width=intrinsic.width,ORKExpectedLabelHeight(self)};
}

@end
