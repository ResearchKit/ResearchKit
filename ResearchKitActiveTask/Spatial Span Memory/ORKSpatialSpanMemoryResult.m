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


#import "ORKSpatialSpanMemoryResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKSpatialSpanMemoryGameTouchSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_INTEGER(aCoder, targetIndex);
    ORK_ENCODE_CGPOINT(aCoder, location);
    ORK_ENCODE_BOOL(aCoder, correct);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_INTEGER(aDecoder, targetIndex);
        ORK_DECODE_CGPOINT(aDecoder, location);
        ORK_DECODE_BOOL(aDecoder, correct);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return ((self.timestamp == castObject.timestamp) &&
            (self.targetIndex == castObject.targetIndex) &&
            (CGPointEqualToPoint(self.location, castObject.location)) &&
            (self.isCorrect == castObject.isCorrect));
}

- (NSUInteger)hash {
    return super.hash ^ [self targetIndex] ^ [self isCorrect];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryGameTouchSample *sample = [[[self class] allocWithZone:zone] init];
    sample.timestamp = self.timestamp;
    sample.targetIndex = self.targetIndex;
    sample.location = self.location;
    sample.correct = self.isCorrect;
    
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; timestamp: %@; targetIndex: %@; location: %@; correct: %@>", self.class.description, self, @(self.timestamp), @(self.targetIndex), NSStringFromCGPoint(self.location), @(self.isCorrect)];
}

@end


@implementation ORKSpatialSpanMemoryGameRecord

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_UINT32(aCoder, seed);
    ORK_ENCODE_OBJ(aCoder, sequence);
    ORK_ENCODE_INTEGER(aCoder, gameSize);
    ORK_ENCODE_OBJ(aCoder, touchSamples);
    ORK_ENCODE_INTEGER(aCoder, gameStatus);
    ORK_ENCODE_INTEGER(aCoder, score);
    ORK_ENCODE_OBJ(aCoder, targetRects);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_UINT32(aDecoder, seed);
        ORK_DECODE_OBJ_ARRAY(aDecoder, sequence, NSNumber);
        ORK_DECODE_INTEGER(aDecoder, gameSize);
        ORK_DECODE_OBJ_ARRAY(aDecoder, touchSamples, ORKSpatialSpanMemoryGameTouchSample);
        ORK_DECODE_INTEGER(aDecoder, gameStatus);
        ORK_DECODE_INTEGER(aDecoder, score);
        ORK_DECODE_OBJ_ARRAY(aDecoder, targetRects, NSValue);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return ((self.seed == castObject.seed) &&
            (ORKEqualObjects(self.sequence, castObject.sequence)) &&
            (ORKEqualObjects(self.touchSamples, castObject.touchSamples)) &&
            (self.gameSize == castObject.gameSize) &&
            (self.gameStatus == castObject.gameStatus) &&
            (self.score == castObject.score) &&
            (ORKEqualObjects(self.targetRects, castObject.targetRects)));
}

- (NSUInteger)hash {
    return super.hash ^ [self seed] ^ [self gameSize] ^ [self score] ^ [self gameStatus];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryGameRecord *record = [[[self class] allocWithZone:zone] init];
    record.seed = self.seed;
    record.sequence = [self.sequence copyWithZone:zone];
    record.touchSamples = [self.touchSamples copyWithZone:zone];
    record.gameSize = self.gameSize;
    record.gameStatus = self.gameStatus;
    record.score = self.score;
    record.targetRects = [self.targetRects copyWithZone:zone];
    return record;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; seed: %@; sequence: %@; gameSize: %@; gameStatus: %@; score: %@>", self.class.description, self, @(self.seed), self.sequence, @(self.gameSize), @(self.gameStatus), @(self.score)];
}

@end


@implementation ORKSpatialSpanMemoryResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, score);
    ORK_ENCODE_INTEGER(aCoder, numberOfGames);
    ORK_ENCODE_INTEGER(aCoder, numberOfFailures);
    ORK_ENCODE_OBJ(aCoder, gameRecords);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, score);
        ORK_DECODE_INTEGER(aDecoder, numberOfGames);
        ORK_DECODE_INTEGER(aDecoder, numberOfFailures);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gameRecords, ORKSpatialSpanMemoryGameRecord);
        
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
            (self.score == castObject.score) &&
            (self.numberOfGames == castObject.numberOfGames) &&
            (self.numberOfFailures == castObject.numberOfFailures) &&
            (ORKEqualObjects(self.gameRecords, castObject.gameRecords)));
}

- (NSUInteger)hash {
    return super.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryResult *result = [super copyWithZone:zone];
    result.score = self.score;
    result.numberOfGames = self.numberOfGames;
    result.numberOfFailures = self.numberOfFailures;
    result.gameRecords = [self.gameRecords copyWithZone:zone];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; score: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.score), self.descriptionSuffix];
}

@end
