//
//  EpworthSleepScale.m
//  ResearchKit
//
//  Created by Andrew Hill on 12/09/2015.
//  Copyright © 2015 researchkit.org. All rights reserved.
//
//
//  The Epworth Sleep Scale is a validated tool to assess somnolence. High Epworth scores are associated
//  With diseases such as obstructive sleep apnoea.
//
//  If you would like to read more about this research tool, visit the original publication article on
// http://www.mwjohns.com/wp-content/uploads/2009/murray_papers/reliabiltiy_and_factor_analysis_of_the_epworth_sleepiness_scale.pdf

//  Added to ResearchKit by Dr. Andrew Hill, Consultant in Stroke Medicine, St Helens and Knowsley NHS Trust
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "EpworthSleepScale.h"
#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"

@implementation EpworthSleepScale

static void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Explain the purpose of the introduction survey
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"IntroStep"];
        step.title = ORKLocalizedString(@"EPWORTH_INTRO_TITLE", nil);
        step.text = ORKLocalizedString(@"EPWORTH_INTRO_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    NSArray *answerChoices = [NSArray arrayWithObjects:
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"EPWORTH_ANSWER_0", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"EPWORTH_ANSWER_1", nil) detailText:nil value:[NSNumber numberWithInt:1] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"EPWORTH_ANSWER_2", nil) detailText:nil value:[NSNumber numberWithInt:2] exclusive:true],
                              [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"EPWORTH_ANSWER_3", nil) detailText:nil value:[NSNumber numberWithInt:3] exclusive:true],
                              nil];
    
    ORKTextChoiceAnswerFormat *answerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerChoices];
    
    for (int questionID=0; questionID<8; questionID++) {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",questionID]];
            step.title = ORKLocalizedString(@"EPWORTH_INTRO_TITLE", nil);
        {
            NSString *questionStem = [NSString stringWithFormat:@"EPWORTH_Q%d",questionID];
            step.text = ORKLocalizedString(questionStem, nil);
        }
        step.answerFormat = answerFormat;
        ORKStepArrayAddStep(steps,step);
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    return self;
}

@end