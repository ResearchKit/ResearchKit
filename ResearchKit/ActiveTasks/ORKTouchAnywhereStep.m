//
//  ORKTouchAnywhereStep.m
//  ResearchKit
//
//  Created by Darren Levy on 8/8/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKTouchAnywhereStep.h"
#import "ORKTouchAnywhereStepViewController.h"
#import "ORKHelpers_Internal.h"

@implementation ORKTouchAnywhereStep

+ (Class)stepViewControllerClass {
    return [ORKTouchAnywhereStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier instructionText:(NSString *)instructionText {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.text = ORKLocalizedString(@"TOUCH_ANYWHERE_LABEL", nil);
        self.title = instructionText;
    }
    return self;
}

@end
