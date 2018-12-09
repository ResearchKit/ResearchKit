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


#import "ORKEnvironmentSPLMeterStep.h"
#import "ORKEnvironmentSPLMeterStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKEnvironmentSPLMeterTaskDefaultThresholdValue 35.0
#define ORKEnvironmentSPLMeterTaskMinimumSamplingInterval 1.0
#define ORKEnvironmentSPLMeterTaskDefaultRequiredContiguousSamples 5

@implementation ORKEnvironmentSPLMeterStep

+ (Class)stepViewControllerClass {
    return [ORKEnvironmentSPLMeterStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.thresholdValue = ORKEnvironmentSPLMeterTaskDefaultThresholdValue;
    self.samplingInterval = ORKEnvironmentSPLMeterTaskMinimumSamplingInterval;
    self.requiredContiguousSamples = ORKEnvironmentSPLMeterTaskDefaultRequiredContiguousSamples;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.thresholdValue < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"threshold cannot be lesser than 0"]  userInfo:nil];
    }
    if (self.samplingInterval < ORKEnvironmentSPLMeterTaskMinimumSamplingInterval) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"sampling interval cannot be lesser than %@", @(ORKEnvironmentSPLMeterTaskMinimumSamplingInterval)]  userInfo:nil];
    }
    if (self.requiredContiguousSamples <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"required contiguous samples cannot be less than or equal to 0"]  userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKEnvironmentSPLMeterStep *step = [super copyWithZone:zone];
    step.thresholdValue = self.thresholdValue;
    step.samplingInterval = self.samplingInterval;
    step.requiredContiguousSamples = self.requiredContiguousSamples;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, thresholdValue);
        ORK_DECODE_DOUBLE(aDecoder, samplingInterval);
        ORK_DECODE_INTEGER(aDecoder, requiredContiguousSamples);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, thresholdValue);
    ORK_ENCODE_DOUBLE(aCoder, samplingInterval);
    ORK_ENCODE_INTEGER(aCoder, requiredContiguousSamples);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && (self.thresholdValue == castObject.thresholdValue)
            && (self.samplingInterval == castObject.samplingInterval)
            && (self.requiredContiguousSamples == castObject.requiredContiguousSamples));
}

@end


