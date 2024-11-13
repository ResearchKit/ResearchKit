/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKHolePegTestResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKHolePegTestResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, movingDirection);
    ORK_ENCODE_BOOL(aCoder, dominantHandTested);
    ORK_ENCODE_INTEGER(aCoder, numberOfPegs);
    ORK_ENCODE_INTEGER(aCoder, threshold);
    ORK_ENCODE_BOOL(aCoder, rotated);
    ORK_ENCODE_INTEGER(aCoder, totalSuccesses);
    ORK_ENCODE_INTEGER(aCoder, totalFailures);
    ORK_ENCODE_DOUBLE(aCoder, totalTime);
    ORK_ENCODE_DOUBLE(aCoder, totalDistance);
    ORK_ENCODE_OBJ(aCoder, samples);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, movingDirection);
        ORK_DECODE_BOOL(aDecoder, dominantHandTested);
        ORK_DECODE_INTEGER(aDecoder, numberOfPegs);
        ORK_DECODE_INTEGER(aDecoder, threshold);
        ORK_DECODE_BOOL(aDecoder, rotated);
        ORK_DECODE_INTEGER(aDecoder, totalSuccesses);
        ORK_DECODE_INTEGER(aDecoder, totalFailures);
        ORK_DECODE_DOUBLE(aDecoder, totalTime);
        ORK_DECODE_DOUBLE(aDecoder, totalDistance);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKHolePegTestSample);
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
            (self.movingDirection == castObject.movingDirection) &&
            (self.isDominantHandTested == castObject.isDominantHandTested) &&
            (self.numberOfPegs == castObject.numberOfPegs) &&
            (self.threshold == castObject.threshold) &&
            (self.isRotated == castObject.isRotated) &&
            (self.totalSuccesses == castObject.totalSuccesses) &&
            (self.totalFailures == castObject.totalFailures) &&
            (self.totalTime == castObject.totalTime) &&
            (self.totalDistance == castObject.totalDistance) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKHolePegTestResult *result = [super copyWithZone:zone];
    result.movingDirection = self.movingDirection;
    result.dominantHandTested = self.isDominantHandTested;
    result.numberOfPegs = self.numberOfPegs;
    result.threshold = self.threshold;
    result.rotated = self.isRotated;
    result.totalSuccesses = self.totalSuccesses;
    result.totalFailures = self.totalFailures;
    result.totalTime = self.totalTime;
    result.totalDistance = self.totalDistance;
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; successes: %@; time: %@; samples: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.totalSuccesses), @(self.totalTime), self.samples, self.descriptionSuffix];
}

@end


@implementation ORKHolePegTestSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, time);
    ORK_ENCODE_DOUBLE(aCoder, distance);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, time);
        ORK_DECODE_DOUBLE(aDecoder, distance);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.time == castObject.time) &&
            (self.distance == castObject.distance)) ;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKHolePegTestSample *sample = [[[self class] allocWithZone:zone] init];
    sample.time = self.time;
    sample.distance = self.distance;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; time: %@; distance: %@>", self.class.description, self, @(self.time), @(self.distance)];
}

@end
