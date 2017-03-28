 //
//  TaskFactory+PasscodeManagement.m
//  ORKTest
//
//  Created by Ricardo Sanchez-Saez on 3/28/17.
//  Copyright © 2017 ResearchKit. All rights reserved.
//

#import "TaskFactory+PasscodeManagement.h"

@import ResearchKit;


@implementation TaskFactory (PasscodeManagement)

/*
 Tests various uses of passcode step and view controllers.
 
 Passcode authentication and passcode editing are presented in
 the examples. Passcode creation would ideally be as part of
 the consent process.
 */

- (id<ORKTask>)makeCreatePasscodeTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    ORKPasscodeStep *passcodeStep = [[ORKPasscodeStep alloc] initWithIdentifier:@"consent_passcode"];
    passcodeStep.text = @"This passcode protects your privacy and ensures that the user giving consent is the one completing the tasks.";
    [steps addObject: passcodeStep];
    return [[ORKOrderedTask alloc] initWithIdentifier:CreatePasscodeTaskIdentifier steps:steps];
}

@end
