//
//  ORKRangeOfMotionStep.h
//  ResearchKit
//
//  Created by Darren Levy on 8/20/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

@import Foundation;
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKActiveStep.h>
#import <ResearchKit/ORKOrderedTask.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKRangeOfMotionStep` class represents a step that takes a range of motion measurement.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangeOfMotionStep : ORKActiveStep

@property (nonatomic, assign) ORKPredefinedTaskLimbOption limbOption;

- (instancetype)initWithIdentifier:(NSString *)identifier limbOption:(ORKPredefinedTaskLimbOption)limbOption;

@end

NS_ASSUME_NONNULL_END
