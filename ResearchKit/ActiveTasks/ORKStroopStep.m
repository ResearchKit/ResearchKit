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


#import "ORKStroopStep.h"
#import "ORKStroopStepViewController.h"
#import "ORKHelpers_Internal.h"


@implementation ORKStroopStep

+ (Class)stepViewControllerClass {
    return [ORKStroopStepViewController class];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldVibrateOnStart = YES;
        self.shouldShowDefaultTimer = NO;
        self.shouldContinueOnFinish = YES;
        self.stepDuration = NSIntegerMax;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    NSInteger minimumAttempts = 10;
    if (self.numberOfAttempts < minimumAttempts) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"number of attempts should be greater or equal to %ld.", (long)minimumAttempts]  userInfo:nil];
    }
    if (self.minimumInterStimulusInterval <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"minimumInterStimulusInterval must be greater than zero"
                                     userInfo:nil];
    }
    if (self.maximumInterStimulusInterval < self.minimumInterStimulusInterval) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"maximumInterStimulusInterval cannot be less than minimumInterStimulusInterval"
                                     userInfo:nil];
    }
    if (self.timeout <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"timeout must be greater than zero"
                                     userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)allowsBackNavigation {
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKStroopStep *step = [super copyWithZone:zone];
    step.numberOfAttempts = self.numberOfAttempts;
    step.minimumInterStimulusInterval = self.minimumInterStimulusInterval;
    step.maximumInterStimulusInterval = self.maximumInterStimulusInterval;
    step.timeout = self.timeout;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self ) {
        ORK_DECODE_INTEGER(aDecoder, numberOfAttempts);
        ORK_DECODE_DOUBLE(aDecoder, minimumInterStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, maximumInterStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, timeout);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, numberOfAttempts);
    ORK_ENCODE_DOUBLE(aCoder, minimumInterStimulusInterval);
    ORK_ENCODE_DOUBLE(aCoder, maximumInterStimulusInterval);
    ORK_ENCODE_DOUBLE(aCoder, timeout);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.numberOfAttempts == castObject.numberOfAttempts) &&
            (self.minimumInterStimulusInterval == castObject.minimumInterStimulusInterval) &&
            (self.maximumInterStimulusInterval == castObject.maximumInterStimulusInterval) &&
            (self.timeout == castObject.timeout));
}

@end
