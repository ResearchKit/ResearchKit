//
//  ORKShoulderRangeOfMotionStep.m
//  ResearchKit
//
//  Created by Darren Levy on 8/20/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKShoulderRangeOfMotionStep.h"
#import "ORKShoulderRangeOfMotionStepViewController.h"

#import "ORKHelpers_Internal.h"

@implementation ORKShoulderRangeOfMotionStep

+ (Class)stepViewControllerClass {
    return [ORKShoulderRangeOfMotionStepViewController class];
}

@end