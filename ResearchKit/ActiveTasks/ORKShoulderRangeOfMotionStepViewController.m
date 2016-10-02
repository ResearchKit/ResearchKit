//
//  ORKShoulderRangeOfMotionStepViewController.m
//  ResearchKit
//
//  Created by Darren Levy on 8/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKShoulderRangeOfMotionStepViewController.h"

@implementation ORKShoulderRangeOfMotionStepViewController

#pragma mark - ORKActiveTaskViewController

- (ORKResult *)result {
    ORKRangeOfMotionResult *result = [[ORKRangeOfMotionResult alloc] initWithIdentifier:self.step.identifier];
    result.flexed = 90.0 - _flexedAngle;
    result.extended = result.flexed + _rangeOfMotionAngle;
    return result;
}

@end
