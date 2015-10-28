/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.

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

 
#import "ORKRangedPoint.h"
#import "ORKHelpers.h"
#import "ORKDefines_Private.h"


@implementation ORKRangedPoint

- (instancetype)initWithMinimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue {
    self = [super init];
    if (self) {
        _minimumValue = minimumValue;
        _maximumValue = maximumValue;
    }
    return self;
}

- (instancetype)init {
    return [self initWithMinimumValue:ORKCGFloatInvalidValue maximumValue:ORKCGFloatInvalidValue];
}

- (instancetype)initWithValue:(CGFloat)value {
    return [self initWithMinimumValue:value maximumValue:value];
}

- (BOOL)isUnset {
    return (self.minimumValue == ORKCGFloatInvalidValue && self.maximumValue == ORKCGFloatInvalidValue);
}

- (BOOL)isRangeZero {
    return (self.minimumValue == self.maximumValue);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{min: %0.0f, max: %0.0f}", self.minimumValue, self.maximumValue];
}

#pragma mark - Accessibility

- (NSString *)accessibilityLabel {
    if (self.isUnset) {
        return nil;
    }

    if (self.hasEmptyRange || _minimumValue == _maximumValue) {
        return @(_maximumValue).stringValue;
    } else {
        NSString *rangeFormat = ORKLocalizedString(@"AX_GRAPH_RANGE_FORMAT", nil);
        return [NSString stringWithFormat:rangeFormat, @(_minimumValue).stringValue, @(_maximumValue).stringValue];
    }
}

@end
