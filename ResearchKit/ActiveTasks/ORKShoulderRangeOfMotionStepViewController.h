//
//  ORKShoulderRangeOfMotionStepViewController.h
//  ResearchKit
//
//  Created by Darren Levy on 8/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKRangeOfMotionStepViewController.h"

/**
 This class override its parent's result because here 
 a flex result of 0 degrees would mean the device is at a 90 degree angle.
 */
ORK_CLASS_AVAILABLE
@interface ORKShoulderRangeOfMotionStepViewController : ORKRangeOfMotionStepViewController

@end
