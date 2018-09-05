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


#import "ORKdBHLToneAudiometryStep.h"

#import "ORKdBHLToneAudiometryStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKdBHLToneAudiometryTaskToneMinimumDuration 1.0
#define ORKdBHLToneAudiometryTaskDefaultMaxRandomPreStimulusDelay 2.0
#define ORKdBHLToneAudiometryTaskDefaultMaxPostStimulusDelay 1.0
#define ORKdBHLToneAudiometryTaskDefaultTransitionsPerFrequency 15
#define ORKdBHLToneAudiometryTaskInitialdBHLValue 30.0
#define ORKdBHLToneAudiometryTaskdBHLStepUpSize 5.0
#define ORKdBHLToneAudiometryTaskdBHLStepDownSize 10.0

@implementation ORKdBHLToneAudiometryStep

+ (Class)stepViewControllerClass {
    return [ORKdBHLToneAudiometryStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.toneDuration = ORKdBHLToneAudiometryTaskToneMinimumDuration;
    self.maxRandomPreStimulusDelay = ORKdBHLToneAudiometryTaskDefaultMaxRandomPreStimulusDelay;
    self.postStimulusDelay = ORKdBHLToneAudiometryTaskDefaultMaxPostStimulusDelay;
    self.maxNumberOfTransitionsPerFrequency = ORKdBHLToneAudiometryTaskDefaultTransitionsPerFrequency;
    self.initialdBHLValue = ORKdBHLToneAudiometryTaskInitialdBHLValue;
    self.dBHLStepUpSize = ORKdBHLToneAudiometryTaskdBHLStepUpSize;
    self.dBHLStepDownSize = ORKdBHLToneAudiometryTaskdBHLStepDownSize;
    self.frequencyList = @[@1000.0, @2000.0, @3000.0, @4000.0, @8000.0, @1000.0, @500.0, @250.0];
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.toneDuration < ORKdBHLToneAudiometryTaskToneMinimumDuration) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"pulse duration cannot be shorter than %@ seconds.", @(ORKdBHLToneAudiometryTaskToneMinimumDuration)]  userInfo:nil];
    }
    if (self.maxNumberOfTransitionsPerFrequency <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"number of transitions per frequency cannot be less than or equal to 0"]  userInfo:nil];
    }
    if ((self.dBHLStepDownSize <= 0) || self.dBHLStepUpSize <=0) {
       @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"step size cannot be less than or equal to 0"]  userInfo:nil];
    }
    if (self.frequencyList.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"frequency list cannot be empty"]  userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKdBHLToneAudiometryStep *step = [super copyWithZone:zone];
    step.toneDuration = self.toneDuration;
    step.maxRandomPreStimulusDelay = self.maxRandomPreStimulusDelay;
    step.postStimulusDelay = self.postStimulusDelay;
    step.maxNumberOfTransitionsPerFrequency = self.maxNumberOfTransitionsPerFrequency;
    step.initialdBHLValue = self.initialdBHLValue;
    step.dBHLStepDownSize = self.dBHLStepDownSize;
    step.dBHLStepUpSize = self.dBHLStepUpSize;
    step.headphoneType = self.headphoneType;
    step.earPreference = self.earPreference;
    step.frequencyList = self.frequencyList;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, toneDuration);
        ORK_DECODE_DOUBLE(aDecoder, maxRandomPreStimulusDelay);
        ORK_DECODE_DOUBLE(aDecoder, postStimulusDelay);
        ORK_DECODE_DOUBLE(aDecoder, initialdBHLValue);
        ORK_DECODE_DOUBLE(aDecoder, dBHLStepDownSize);
        ORK_DECODE_DOUBLE(aDecoder, dBHLStepUpSize);
        ORK_DECODE_INTEGER(aDecoder, maxNumberOfTransitionsPerFrequency);
        ORK_DECODE_INTEGER(aDecoder, earPreference);
        ORK_DECODE_OBJ(aDecoder, headphoneType);
        ORK_DECODE_OBJ_ARRAY(aDecoder, frequencyList, NSNumber);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, toneDuration);
    ORK_ENCODE_DOUBLE(aCoder, maxRandomPreStimulusDelay);
    ORK_ENCODE_DOUBLE(aCoder, postStimulusDelay);
    ORK_ENCODE_DOUBLE(aCoder, initialdBHLValue);
    ORK_ENCODE_DOUBLE(aCoder, dBHLStepDownSize);
    ORK_ENCODE_DOUBLE(aCoder, dBHLStepUpSize);
    ORK_ENCODE_INTEGER(aCoder, maxNumberOfTransitionsPerFrequency);
    ORK_ENCODE_INTEGER(aCoder, earPreference);
    ORK_ENCODE_OBJ(aCoder, headphoneType);
    ORK_ENCODE_OBJ(aCoder, frequencyList);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && (self.toneDuration == castObject.toneDuration)
            && (self.maxRandomPreStimulusDelay == castObject.maxRandomPreStimulusDelay)
            && (self.postStimulusDelay == castObject.postStimulusDelay)
            && (self.maxNumberOfTransitionsPerFrequency == castObject.maxNumberOfTransitionsPerFrequency)
            && (self.initialdBHLValue == castObject.initialdBHLValue)
            && (self.dBHLStepDownSize == castObject.dBHLStepDownSize)
            && (self.dBHLStepUpSize == castObject.dBHLStepUpSize)
            && (self.earPreference == castObject.earPreference)
            && ORKEqualObjects(self.headphoneType, castObject.headphoneType)
            && ORKEqualObjects(self.frequencyList, castObject.frequencyList));
}

@end

