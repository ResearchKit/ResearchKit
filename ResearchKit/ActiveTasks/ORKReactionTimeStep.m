/*
 Copyright (c) 2015, James Cox. All rights reserved.
 
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


#import "ORKReactionTimeStep.h"
#import "ORKReactionTimeViewController.h"
#import "ORKHelpers.h"


@implementation ORKReactionTimeStep

+ (Class)stepViewControllerClass {
    return [ORKReactionTimeViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    self.shouldContinueOnFinish = YES;
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKReactionTimeStep *step = [super copyWithZone:zone];
    step.maximumStimulusInterval = self.maximumStimulusInterval;
    step.minimumStimulusInterval = self.minimumStimulusInterval;
    step.thresholdAcceleration = self.thresholdAcceleration;
    step.timeout = self.timeout;
    step.numberOfAttempts = self.numberOfAttempts;
    step.successSound = self.successSound;
    step.timeoutSound = self.timeoutSound;
    step.failureSound = self.failureSound;
    return step;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.minimumStimulusInterval <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"minimumStimulusInterval must be greater than zero"
                                     userInfo:nil];
    }
    if (self.maximumStimulusInterval < self.minimumStimulusInterval) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"maximumStimulusInterval cannot be less than minimumStimulusInterval"
                                     userInfo:nil];
    }
    if (self.thresholdAcceleration <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"thresholdAcceleration must be greater than zero"
                                     userInfo:nil];
    }
    if (self.timeout <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"timeout must be greater than zero"
                                     userInfo:nil];
    }
    if (self.numberOfAttempts <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"numberOfAttempts must be greater than zero"
                                     userInfo:nil];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, maximumStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, minimumStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, thresholdAcceleration);
        ORK_DECODE_DOUBLE(aDecoder, timeout);
        ORK_DECODE_UINT32(aDecoder, successSound);
        ORK_DECODE_UINT32(aDecoder, timeoutSound);
        ORK_DECODE_UINT32(aDecoder, failureSound);
        ORK_DECODE_INTEGER(aDecoder, numberOfAttempts);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
        ORK_ENCODE_DOUBLE(aCoder, maximumStimulusInterval);
        ORK_ENCODE_DOUBLE(aCoder, minimumStimulusInterval);
        ORK_ENCODE_DOUBLE(aCoder, thresholdAcceleration);
        ORK_ENCODE_DOUBLE(aCoder, timeout);
        ORK_ENCODE_UINT32(aCoder, successSound);
        ORK_ENCODE_UINT32(aCoder, timeoutSound);
        ORK_ENCODE_UINT32(aCoder, failureSound);
        ORK_ENCODE_INTEGER(aCoder, numberOfAttempts);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.maximumStimulusInterval == castObject.maximumStimulusInterval) &&
            (self.minimumStimulusInterval == castObject.minimumStimulusInterval) &&
            (self.thresholdAcceleration == castObject.thresholdAcceleration) &&
            (self.timeout == castObject.timeout) &&
            (self.successSound == castObject.successSound) &&
            (self.timeoutSound == castObject.timeoutSound) &&
            (self.failureSound == castObject.failureSound) &&
            (self.numberOfAttempts == castObject.numberOfAttempts));
}

- (BOOL)allowsBackNavigation {
    return NO;
}

- (BOOL)startsFinished {
    return NO;
}

@end
