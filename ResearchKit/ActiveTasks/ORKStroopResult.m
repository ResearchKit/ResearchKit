/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
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

#import "ORKStroopResult.h"
#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

@implementation ORKStroopResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, color);
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, colorSelected);
    ORK_ENCODE_BOOL(aCoder, match);
    ORK_ENCODE_BOOL(aCoder, timedOut);
    ORK_ENCODE_DOUBLE(aCoder, percentCorrect);
    ORK_ENCODE_DOUBLE(aCoder, startTime);
    ORK_ENCODE_DOUBLE(aCoder, endTime);
    ORK_ENCODE_DOUBLE(aCoder, reactionTime);
    ORK_ENCODE_DOUBLE(aCoder, meanReactionTime);
    ORK_ENCODE_DOUBLE(aCoder, stdReactionTime);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, color, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, colorSelected, NSString);
        ORK_DECODE_BOOL(aDecoder, match);
        ORK_DECODE_BOOL(aDecoder, timedOut);
        ORK_DECODE_DOUBLE(aDecoder, percentCorrect);
        ORK_DECODE_DOUBLE(aDecoder, startTime);
        ORK_DECODE_DOUBLE(aDecoder, endTime);
        ORK_DECODE_DOUBLE(aDecoder, reactionTime);
        ORK_DECODE_DOUBLE(aDecoder, meanReactionTime);
        ORK_DECODE_DOUBLE(aDecoder, stdReactionTime);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.color, castObject.color) &&
            ORKEqualObjects(self.text, castObject.text) &&
            ORKEqualObjects(self.colorSelected, castObject.colorSelected) &&
            (self.match == castObject.match) &&
            (self.timedOut == castObject.timedOut) &&
            (self.percentCorrect == castObject.percentCorrect) &&
            (self.startTime == castObject.startTime) &&
            (self.endTime == castObject.endTime) &&
            (self.reactionTime == castObject.reactionTime) &&
            (self.meanReactionTime == castObject.meanReactionTime) &&
            (self.stdReactionTime == castObject.stdReactionTime));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKStroopResult *result = [super copyWithZone:zone];
    result -> _color = [self.color copy];
    result -> _text = [self.text copy];
    result -> _colorSelected = [self.colorSelected copy];
    result.match = self.match;
    result.timedOut = self.timedOut;
    result.percentCorrect = self.percentCorrect;
    result.startTime = self.startTime;
    result.endTime = self.endTime;
    result.reactionTime = self.reactionTime;
    result.meanReactionTime = self.meanReactionTime;
    result.stdReactionTime = self.stdReactionTime;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; color: %@; text: %@; colorselected: %@; match: %d; timedOut: %d; percentCorrect: %f; reactionTime: %f; meanReactionTime: %f; stdReactionTime: %f %@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.color, self.text, self.colorSelected, self.match, self.timedOut, self.percentCorrect, self.reactionTime, self.meanReactionTime, self.stdReactionTime, self.descriptionSuffix];
}

@end
