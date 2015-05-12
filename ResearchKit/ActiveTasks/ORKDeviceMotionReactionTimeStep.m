/*
  ORKDeviceMotionReactionTimeStep.m
  ResearchKit

  Created by James Cox on 07/05/2015.
  Copyright (c) 2015 researchkit.org. All rights reserved.
*/


#import "ORKDeviceMotionReactionTimeStep.h"
#import "ORKDeviceMotionReactionTimeViewController.h"
#import "ORKHelpers.h"


@implementation ORKDeviceMotionReactionTimeStep

+ (Class) stepViewControllerClass {
    return [ORKDeviceMotionReactionTimeViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    self.shouldContinueOnFinish = YES;
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKDeviceMotionReactionTimeStep *step = [super copyWithZone:zone];
    step.getReadyInterval = self.getReadyInterval;
    step.maximumStimulusInterval = self.maximumStimulusInterval;
    step.minimumStimulusInterval = self.minimumStimulusInterval;
    step.thresholdAcceleration = self.thresholdAcceleration;
    step.timeout = self.timeout;
    step.numberOfAttempts = self.numberOfAttempts;
    return step;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.maximumStimulusInterval < self.minimumStimulusInterval) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"maximumStimulusInterval can not be less than minimumStimulusInterval"
                                     userInfo:nil];
    }
    if (self.thresholdAcceleration <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"thresholdAcceleration must be greater than zero"
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
        ORK_DECODE_DOUBLE(aDecoder, getReadyInterval);
        ORK_DECODE_DOUBLE(aDecoder, maximumStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, minimumStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, thresholdAcceleration);
        ORK_DECODE_DOUBLE(aDecoder, timeout);
        ORK_DECODE_INTEGER(aDecoder, numberOfAttempts);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
        ORK_ENCODE_DOUBLE(aCoder, getReadyInterval);
        ORK_ENCODE_DOUBLE(aCoder, maximumStimulusInterval);
        ORK_ENCODE_DOUBLE(aCoder, minimumStimulusInterval);
        ORK_ENCODE_DOUBLE(aCoder, thresholdAcceleration);
        ORK_ENCODE_DOUBLE(aCoder, timeout);
        ORK_ENCODE_INTEGER(aCoder, numberOfAttempts);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.getReadyInterval == castObject.getReadyInterval) &&
            (self.maximumStimulusInterval == castObject.maximumStimulusInterval) &&
            (self.minimumStimulusInterval == castObject.minimumStimulusInterval) &&
            (self.thresholdAcceleration == castObject.thresholdAcceleration) &&
            (self.timeout == castObject.timeout) &&
            (self.numberOfAttempts == castObject.numberOfAttempts));
}

- (BOOL)allowsBackNavigation {
    return NO;
}

- (BOOL)startsFinished {
    return NO;
}

@end
