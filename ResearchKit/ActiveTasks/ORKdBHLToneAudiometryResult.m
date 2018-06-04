/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKdBHLToneAudiometryResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKdBHLToneAudiometryResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, outputVolume);
    ORK_ENCODE_DOUBLE(aCoder, tonePlaybackDuration);
    ORK_ENCODE_DOUBLE(aCoder, postStimulusDelay);
    ORK_ENCODE_OBJ(aCoder, headphoneType);
    ORK_ENCODE_OBJ(aCoder, samples);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, outputVolume);
        ORK_DECODE_DOUBLE(aDecoder, tonePlaybackDuration);
        ORK_DECODE_DOUBLE(aDecoder, postStimulusDelay);
        ORK_DECODE_OBJ(aDecoder, headphoneType);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKdBHLToneAudiometryFrequencySample);
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
            self.outputVolume == castObject.outputVolume &&
            self.tonePlaybackDuration == castObject.tonePlaybackDuration &&
            self.postStimulusDelay == castObject.postStimulusDelay &&
            ORKEqualObjects(self.headphoneType, castObject.headphoneType) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryResult *result = [super copyWithZone:zone];
    result.outputVolume = self.outputVolume;
    result.headphoneType = [self.headphoneType copy];
    result.tonePlaybackDuration = self.tonePlaybackDuration;
    result.postStimulusDelay = self.postStimulusDelay;
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; outputvolume: %.1lf; samples: %@; headphoneType: %@; tonePlaybackDuration: %.1lf; postStimulusDelay: %.1lf%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.outputVolume, self.samples, self.headphoneType, self.tonePlaybackDuration, self.postStimulusDelay, self.descriptionSuffix];
}

@end


@implementation ORKdBHLToneAudiometryFrequencySample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_DOUBLE(aCoder, calculatedThreshold);
    ORK_ENCODE_INTEGER(aCoder, channel);
    ORK_ENCODE_OBJ(aCoder, units);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_DOUBLE(aDecoder, calculatedThreshold);
        ORK_DECODE_INTEGER(aDecoder, channel);
        ORK_DECODE_OBJ_ARRAY(aDecoder, units, ORKdBHLToneAudiometryUnit);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.frequency == castObject.frequency) &&
            (self.calculatedThreshold == castObject.calculatedThreshold) &&
            (self.channel == castObject.channel) &&
            ORKEqualObjects(self.units, castObject.units));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryFrequencySample *sample = [[[self class] allocWithZone:zone] init];
    sample.frequency = self.frequency;
    sample.calculatedThreshold = self.calculatedThreshold;
    sample.channel = self.channel;
    sample.units = self.units;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; frequency: %.1lf; calculatedThreshold: %.1lf; channel: %ld; units: %@>", self.class.description, self, self.frequency, self.calculatedThreshold, (long)self.channel, self.units];
}

@end

@implementation ORKdBHLToneAudiometryUnit

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, dBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, timeoutTimeStamp);
    ORK_ENCODE_DOUBLE(aCoder, userTapTimeStamp);
    ORK_ENCODE_DOUBLE(aCoder, startOfUnitTimeStamp);
    ORK_ENCODE_DOUBLE(aCoder, preStimulusDelay);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, dBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, timeoutTimeStamp);
        ORK_DECODE_DOUBLE(aDecoder, userTapTimeStamp);
        ORK_DECODE_DOUBLE(aDecoder, startOfUnitTimeStamp);
        ORK_DECODE_DOUBLE(aDecoder, preStimulusDelay);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.dBHLValue == castObject.dBHLValue) &&
            (self.timeoutTimeStamp == castObject.timeoutTimeStamp) &&
            (self.userTapTimeStamp == castObject.userTapTimeStamp) &&
            (self.preStimulusDelay == castObject.preStimulusDelay) &&
            (self.startOfUnitTimeStamp == castObject.startOfUnitTimeStamp));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryUnit *unit = [[[self class] allocWithZone:zone] init];
    unit.dBHLValue = self.dBHLValue;
    unit.timeoutTimeStamp = self.timeoutTimeStamp;
    unit.userTapTimeStamp = self.userTapTimeStamp;
    unit.startOfUnitTimeStamp = self.startOfUnitTimeStamp;
    unit.preStimulusDelay = self.preStimulusDelay;
    return unit;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; dBHLValue: %.1lf; timeoutTimeStamp %.5lf; userTapTimeStamp %.5lf; startOfUnitTimeStamp: %.5lf; preStimulusDelay %.1lf>", self.class.description, self.dBHLValue, self.timeoutTimeStamp, self.userTapTimeStamp, self.startOfUnitTimeStamp, self.preStimulusDelay];
}

@end

