//
//  ORKRangeOfMotionStepViewController.h
//  ResearchKit
//
//  Created by Darren Levy on 8/20/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>
#import <CoreMotion/CMDeviceMotion.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This class is used by the `ORKRangeOfMotionStep.` Its result corresponds to the device's orientation
 as recorded by CoreMotion.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangeOfMotionStepViewController : ORKActiveStepViewController {
    double _flexedAngle;
    double _rangeOfMotionAngle;
}

@end

NS_ASSUME_NONNULL_END
