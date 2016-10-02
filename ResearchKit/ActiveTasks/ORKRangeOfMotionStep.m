//
//  ORKRangeOfMotionStep.m
//  ResearchKit
//
//  Created by Darren Levy on 8/20/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKRangeOfMotionStep.h"
#import "ORKRangeOfMotionStepViewController.h"
#import "ORKHelpers_Internal.h"

@implementation ORKRangeOfMotionStep

+ (Class)stepViewControllerClass {
    return [ORKRangeOfMotionStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier limbOption:(ORKPredefinedTaskLimbOption)limbOption {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldVibrateOnStart = YES;
        self.shouldPlaySoundOnStart = YES;
        self.shouldVibrateOnFinish = YES;
        self.shouldPlaySoundOnFinish = YES;
        self.shouldContinueOnFinish = YES;
        self.shouldStartTimerAutomatically = YES;
        self.limbOption = limbOption;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.limbOption != ORKPredefinedTaskLimbOptionLeft && self.limbOption != ORKPredefinedTaskLimbOptionRight) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:ORKLocalizedString(@"LIMB_OPTION_LEFT_OR_RIGHT_ERROR", nil)
                                     userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRangeOfMotionStep *step = [super copyWithZone:zone];
    step.limbOption = self.limbOption;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, limbOption);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, limbOption);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame && (self.limbOption == castObject.limbOption));
}

@end
