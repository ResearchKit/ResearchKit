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
#import "ORKRecorder_Private.h"
#import "ORKHelpers_Internal.h"

#import <ResearchKit/ORKActiveStep_Internal.h>

#define ORKEnvironmentSPLMeterTaskDefaultThresholdValue 35.0
#define ORKEnvironmentSPLMeterTaskMinimumSamplingInterval 1.0
#define ORKEnvironmentSPLMeterTaskDefaultRequiredContiguousSamples 5

@implementation ORKEnvironmentSPLMeterStep

+ (double)maximumThresholdValue {
    return 120.0;
}

+ (NSTimeInterval)maximumSamplingInterval {
    return 3600.0;
}

+ (NSTimeInterval)minimumSamplingInterval {
    return ORKEnvironmentSPLMeterTaskMinimumSamplingInterval;
}

+ (NSInteger)maximumRequiredContiguousSamples {
    return 1000;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier outputDirectory:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInitWithOutputDirectory:outputDirectory];
    }
    return self;
}

- (void)commonInitWithOutputDirectory:(NSURL *)outputDirectory {
    self.thresholdValue = ORKEnvironmentSPLMeterTaskDefaultThresholdValue;
    self.samplingInterval = ORKEnvironmentSPLMeterTaskMinimumSamplingInterval;
    self.requiredContiguousSamples = ORKEnvironmentSPLMeterTaskDefaultRequiredContiguousSamples;
    self.stepDuration = CGFLOAT_MAX;
    self.shouldShowDefaultTimer = NO;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (!isfinite(self.thresholdValue) || self.thresholdValue <= 0 || self.thresholdValue > ORKEnvironmentSPLMeterStep.maximumThresholdValue) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"thresholdValue must be a finite number greater than 0 and no more than %g dBSPL-A", ORKEnvironmentSPLMeterStep.maximumThresholdValue] userInfo:nil];
    }
    ORKValidateBoundedValue(self.samplingInterval, ORKEnvironmentSPLMeterStep.minimumSamplingInterval, ORKEnvironmentSPLMeterStep.maximumSamplingInterval, @"samplingInterval", YES);
    if (self.requiredContiguousSamples <= 0 || self.requiredContiguousSamples > ORKEnvironmentSPLMeterStep.maximumRequiredContiguousSamples) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"requiredContiguousSamples must be greater than 0 and no more than %ld", (long)ORKEnvironmentSPLMeterStep.maximumRequiredContiguousSamples] userInfo:nil];
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

- (BOOL)hasAudioRecording {
    return YES;
}

- (ORKPermissionMask)requiredPermissions {
    return ORKPermissionAudioRecording;
}

@end


