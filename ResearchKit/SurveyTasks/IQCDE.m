//
//  IQCDE.m
//  ResearchKit
//
//  Created by Andrew Hill on 13/09/2015.
//  Copyright © 2015 researchkit.org. All rights reserved.
//
//  The IQCDE was developed by A. F. Jorm
//  Centre for Mental Health Research The Australian National University Canberra, Australia
//

#import "IQCDE.h"
#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"

@implementation IQCDE

static void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Explain the purpose of the introduction survey
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"IntroStep"];
        step.title = ORKLocalizedString(@"IQCDE_INTRO_TITLE", nil);
        step.text = ORKLocalizedString(@"IQCDE_INTRO_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    NSArray *answerChoices = [NSArray arrayWithObjects:
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"IQCDE_ANSWER_0", nil) detailText:nil value:[NSNumber numberWithInt:1] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"IQCDE_ANSWER_1", nil) detailText:nil value:[NSNumber numberWithInt:2] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"IQCDE_ANSWER_2", nil) detailText:nil value:[NSNumber numberWithInt:3] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"IQCDE_ANSWER_3", nil) detailText:nil value:[NSNumber numberWithInt:4] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"IQCDE_ANSWER_4", nil) detailText:nil value:[NSNumber numberWithInt:5] exclusive:true],
                              nil];
    
    ORKTextChoiceAnswerFormat *answerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerChoices];
    
    for (int questionID=0; questionID<16; questionID++) {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",questionID]];
        step.title = ORKLocalizedString(@"IQCDE_TITLE", nil);
        {
            NSString *questionStem = [NSString stringWithFormat:@"IQCDE_Q%d",questionID];
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