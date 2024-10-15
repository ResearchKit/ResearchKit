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


#import "ORKPSATResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKPSATSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_BOOL(aCoder, correct);
    ORK_ENCODE_INTEGER(aCoder, digit);
    ORK_ENCODE_INTEGER(aCoder, answer);
    ORK_ENCODE_DOUBLE(aCoder, time);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_BOOL(aDecoder, correct);
        ORK_DECODE_INTEGER(aDecoder, digit);
        ORK_DECODE_INTEGER(aDecoder, answer);
        ORK_DECODE_DOUBLE(aDecoder, time);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.isCorrect == castObject.isCorrect) &&
            (self.digit == castObject.digit) &&
            (self.answer == castObject.answer) &&
            (self.time == castObject.time)) ;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPSATSample *sample = [[[self class] allocWithZone:zone] init];
    sample.correct = self.isCorrect;
    sample.digit = self.digit;
    sample.answer = self.answer;
    sample.time = self.time;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; correct: %@; digit: %@; answer: %@; time: %@>", self.class.description, self, @(self.isCorrect), @(self.digit), @(self.answer), @(self.time)];
}

@end


@implementation ORKPSATResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, presentationMode);
    ORK_ENCODE_DOUBLE(aCoder, interStimulusInterval);
    ORK_ENCODE_DOUBLE(aCoder, stimulusDuration);
    ORK_ENCODE_INTEGER(aCoder, length);
    ORK_ENCODE_INTEGER(aCoder, totalCorrect);
    ORK_ENCODE_INTEGER(aCoder, totalDyad);
    ORK_ENCODE_DOUBLE(aCoder, totalTime);
    ORK_ENCODE_INTEGER(aCoder, initialDigit);
    ORK_ENCODE_OBJ(aCoder, samples);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, presentationMode);
        ORK_DECODE_DOUBLE(aDecoder, interStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, stimulusDuration);
        ORK_DECODE_INTEGER(aDecoder, length);
        ORK_DECODE_INTEGER(aDecoder, totalCorrect);
        ORK_DECODE_INTEGER(aDecoder, totalDyad);
        ORK_DECODE_DOUBLE(aDecoder, totalTime);
        ORK_DECODE_INTEGER(aDecoder, initialDigit);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKPSATSample);
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
            (self.presentationMode == castObject.presentationMode) &&
            (self.interStimulusInterval == castObject.interStimulusInterval) &&
            (self.stimulusDuration == castObject.stimulusDuration) &&
            (self.length == castObject.length) &&
            (self.totalCorrect == castObject.totalCorrect) &&
            (self.totalDyad == castObject.totalDyad) &&
            (self.totalTime == castObject.totalTime) &&
            (self.initialDigit == castObject.initialDigit) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPSATResult *result = [super copyWithZone:zone];
    result.presentationMode = self.presentationMode;
    result.interStimulusInterval = self.interStimulusInterval;
    result.stimulusDuration = self.stimulusDuration;
    result.length = self.length;
    result.totalCorrect = self.totalCorrect;
    result.totalDyad = self.totalDyad;
    result.totalTime = self.totalTime;
    result.initialDigit = self.initialDigit;
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; correct: %@/%@; samples: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.totalCorrect), @(self.length), self.samples, self.descriptionSuffix];
}

@end
