//
//  RivermeadMobilityIndex.m
//  ResearchKit
//
//  Created by Andrew Hill on 13/09/2015.
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "RivermeadMobilityIndex.h"
#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"

@implementation RivermeadMobilityIndex

static void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Explain the purpose of the introduction survey
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"IntroStep"];
        step.title = ORKLocalizedString(@"RIVERMEAD_INTRO_TITLE", nil);
        step.text = ORKLocalizedString(@"RIVERMEAD_INTRO_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    NSArray *answerChoices = [NSArray arrayWithObjects:
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"RIVERMEAD_ANSWER_YES", nil) detailText:nil value:[NSNumber numberWithInt:1] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"RIVERMEAD_ANSWER_NO", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                              nil];
    
    ORKTextChoiceAnswerFormat *answerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerChoices];
    
    for (int questionID=0; questionID<15; questionID++) {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",questionID]];
        step.title = ORKLocalizedString(@"RIVERMEAD_TITLE", nil);
        {
            NSString *questionStem = [NSString stringWithFormat:@"RIVERMEAD_Q%d",questionID];
            step.text = ORKLocalizedString(questionStem, nil);
            step.optional = false;
        }
        step.answerFormat = answerFormat;
        ORKStepArrayAddStep(steps,step);
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    return self;
}

@end
