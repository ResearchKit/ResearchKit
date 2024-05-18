/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

#import "ORKAccuracyStroopResult.h"
#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

@interface ORKAccuracyStroopResult ()
@property (readwrite) BOOL didSelectCorrectColor;
@end

@implementation ORKAccuracyStroopResult

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        ORK_DECODE_DOUBLE(coder, distanceToClosestCenter);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    ORK_ENCODE_BOOL(coder, didSelectCorrectColor);
    ORK_ENCODE_DOUBLE(coder, timeTakenToSelect);
    ORK_ENCODE_DOUBLE(coder, distanceToClosestCenter);
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKAccuracyStroopResult *result = [super copyWithZone:zone];
    result.distanceToClosestCenter = self.distanceToClosestCenter;
    return result;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            self.distanceToClosestCenter == castObject.distanceToClosestCenter);
}

- (NSUInteger)hash {
    return [super hash] ^ @(self.didSelectCorrectColor).hash ^ @(self.timeTakenToSelect).hash ^ @(self.distanceToClosestCenter).hash;
}

#pragma mark - ResearchKit

- (BOOL)didSelectCorrectColor {
    _didSelectCorrectColor = [self.color isEqualToString:self.colorSelected];
    return _didSelectCorrectColor;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; didSelectCorrectColor: %i; timeTakenToSelect: %.3f; distanceToClosestCenter: %.0f %@",
            [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces],
            self.didSelectCorrectColor,
            self.timeTakenToSelect,
            self.distanceToClosestCenter,
            self.descriptionSuffix];
}

@end
