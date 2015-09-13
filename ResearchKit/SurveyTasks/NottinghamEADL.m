//
//  NottinghamEADLSurvey.m
//  ResearchKit
//
//  The Nottingham Extended Activities of Daily Living Scale is a commonly used validated survey
//  To measure current function in the context of rehabilitation or functional decline.
//
//  If you would like to read more about the scale, the original paper on this scale is available from
//  http://www.researchgate.net/publication/246107444_An_Extended_Activities_of_Daily_Living_Index_for_stroke_patients

//  Added to ResearchKit by Dr. Andrew Hill, Consultant in Stroke Medicine, St Helens and Knowsley NHS Trust
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "NottinghamEADL.h"
#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"

@implementation NottinghamEADLSurvey

static void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Explain the purpose of the introduction survey
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"IntroStep"];
        step.title = ORKLocalizedString(@"NEADL_INTRO_TITLE", nil);
        step.text = ORKLocalizedString(@"NEADL_INTRO_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    NSArray *answerChoices = [NSArray arrayWithObjects:
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"NEADL_ANSWER_0", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"NEADL_ANSWER_1", nil) detailText:nil value:[NSNumber numberWithInt:1] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"NEADL_ANSWER_2", nil) detailText:nil value:[NSNumber numberWithInt:2] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"NEADL_ANSWER_3", nil) detailText:nil value:[NSNumber numberWithInt:3] exclusive:true],
                              nil];
    
    ORKTextChoiceAnswerFormat *answerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerChoices];
    
    for (int questionID=0; questionID<22; questionID++) {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",questionID]];
        switch (questionID) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
                step.title = ORKLocalizedString(@"NEADL_TITLE_MOBILITY", nil);
                break;
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
                step.title = ORKLocalizedString(@"NEADL_TITLE_KITCHEN", nil);
                break;
            case 11:
            case 12:
            case 13:
            case 14:
                step.title = ORKLocalizedString(@"NEADL_TITLE_TASKS", nil);
                break;
            default:
                step.title = ORKLocalizedString(@"NEADL_TITLE_LEISURE", nil);
        }
        {
            NSString *questionStem = [NSString stringWithFormat:@"NEADL_Q%d",questionID];
            step.text = ORKLocalizedString(questionStem, nil);
        }
        step.answerFormat = answerFormat;
        ORKStepArrayAddStep(steps,step);
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    return self;
}

@end