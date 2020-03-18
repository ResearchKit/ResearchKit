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


#import "ORKPSATStep.h"

#import "ORKPSATStepViewController.h"

#import "ORKHelpers_Internal.h"


@implementation ORKPSATStep

+ (Class)stepViewControllerClass {
    return [ORKPSATStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldStartTimerAutomatically = YES;
        self.shouldShowDefaultTimer = NO;
        self.shouldContinueOnFinish = YES;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];

    NSTimeInterval const ORKPSATInterStimulusMinimumInterval = 1.0;
    NSTimeInterval const ORKPSATInterStimulusMaximumInterval = 5.0;
    
    NSTimeInterval const ORKPSATStimulusMinimumDuration = 0.2;
    
    NSInteger const ORKPSATSeriesMinimumLength = 3;
    NSInteger const ORKPSATSeriesMaximumLength = 120;

    NSTimeInterval totalDuration = (self.seriesLength + 1) * self.interStimulusInterval;
    if (self.stepDuration != totalDuration) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"step duration must be equal to %@ seconds.", @(totalDuration)] userInfo:nil];
    }
    
    if (!(self.presentationMode & ORKPSATPresentationModeAuditory) &&
        !(self.presentationMode & ORKPSATPresentationModeVisual)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"step presentation mode must be auditory and/or visual." userInfo:nil];
    }
    
    if (self.interStimulusInterval < ORKPSATInterStimulusMinimumInterval ||
        self.interStimulusInterval > ORKPSATInterStimulusMaximumInterval) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"inter stimulus interval must be greater than or equal to %@ seconds and less than or equal to %@ seconds.", @(ORKPSATInterStimulusMinimumInterval), @(ORKPSATInterStimulusMaximumInterval)] userInfo:nil];
    }
    
    if ((self.presentationMode & ORKPSATPresentationModeVisual) &&
        (self.stimulusDuration < ORKPSATStimulusMinimumDuration || self.stimulusDuration > self.interStimulusInterval)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"stimulus duration must be greater than or equal to %@ seconds and less than or equal to %@ seconds.", @(ORKPSATStimulusMinimumDuration), @(self.interStimulusInterval)] userInfo:nil];
    }
    
    if (self.seriesLength < ORKPSATSeriesMinimumLength ||
        self.seriesLength > ORKPSATSeriesMaximumLength) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"series length must be greater than or equal to %@ additions and less than or equal to %@ additions.", @(ORKPSATSeriesMinimumLength), @(ORKPSATSeriesMaximumLength)] userInfo:nil];
    }
}

- (BOOL)allowsBackNavigation {
    return NO;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, presentationMode);
        ORK_DECODE_DOUBLE(aDecoder, interStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, stimulusDuration);
        ORK_DECODE_INTEGER(aDecoder, seriesLength);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, presentationMode);
    ORK_ENCODE_DOUBLE(aCoder, interStimulusInterval);
    ORK_ENCODE_DOUBLE(aCoder, stimulusDuration);
    ORK_ENCODE_INTEGER(aCoder, seriesLength);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPSATStep *step = [super copyWithZone:zone];
    step.presentationMode = self.presentationMode;
    step.interStimulusInterval = self.interStimulusInterval;
    step.stimulusDuration = self.stimulusDuration;
    step.seriesLength = self.seriesLength;
    return step;
}

- (NSUInteger)hash {
    return [super hash] ^ self.presentationMode ^ (NSInteger)(self.interStimulusInterval*100) ^ (NSInteger)(self.stimulusDuration*100) ^ self.seriesLength;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.presentationMode == castObject.presentationMode) &&
            (self.interStimulusInterval == castObject.interStimulusInterval) &&
            (self.stimulusDuration == castObject.stimulusDuration) &&
            (self.seriesLength == castObject.seriesLength));
}

@end
