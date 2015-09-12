//
//  StrokeImpactScale.m
//  ResearchKit
//
//  The Stroke Impact Scale is a commonly used validated survey to measure at some detail across domains
//  Rehabilitation in patients following a stroke.
//  Read more about the research credential of the SIS here:
//  http://www.rehabmeasures.org/Lists/RehabMeasures/DispForm.aspx?ID=934
//

//  Added to ResearchKit by Dr. Andrew Hill, Consultant in Stroke Medicine, St Helens and Knowsley NHS Trust
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "StrokeImpactScale.h"

#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"

@implementation StrokeImpactScaleSurvey

static void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    // Explain the purpose of the introduction survey
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"IntroStep"];
        step.title = ORKLocalizedString(@"SIS_INTRO_TITLE", nil);
        step.text = ORKLocalizedString(@"SIS_INTRO_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
    }
    
    NSArray *answerStrengthChoices = [NSArray arrayWithObjects:
                                      [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_STRENGTH_ANSWER_1", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                      [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_STRENGTH_ANSWER_2", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                      [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_STRENGTH_ANSWER_3", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                      [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_STRENGTH_ANSWER_4", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                      [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_STRENGTH_ANSWER_5", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                      nil];
    
    NSArray *answerDifficultyChoices = [NSArray arrayWithObjects:
                                        [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_DIFFICULTY_ANSWER_1", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                        [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_DIFFICULTY_ANSWER_2", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                        [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_DIFFICULTY_ANSWER_3", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                        [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_DIFFICULTY_ANSWER_4", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                        [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_DIFFICULTY_ANSWER_5", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                        nil];
    
    NSArray *answerTimeChoices = [NSArray arrayWithObjects:
                                  [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_TIME_ANSWER_1", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                  [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_TIME_ANSWER_2", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                  [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_TIME_ANSWER_3", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                  [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_TIME_ANSWER_4", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                  [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"SIS_TIME_ANSWER_5", nil) detailText:nil value:[NSNumber numberWithInt:0] exclusive:true],
                                  nil];
    
    ORKTextChoiceAnswerFormat *answerStrengthFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerStrengthChoices];
    ORKTextChoiceAnswerFormat *answerDifficultyFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerDifficultyChoices];
    ORKTextChoiceAnswerFormat *answerTimeFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:answerTimeChoices];
    
    for (int questionID=0; questionID<59; questionID++) {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",questionID]];
        switch (questionID) {
            case 0:
            case 1:
            case 2:
            case 3:
                step.answerFormat = answerStrengthFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_PHYSICAL", nil);
                break;
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
                step.answerFormat = answerDifficultyFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_MEMORY", nil);
                break;
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
            case 17:
            case 18:
            case 19:
                step.answerFormat = answerTimeFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_MOOD", nil);
                break;
            case 20:
            case 21:
            case 22:
            case 23:
            case 24:
            case 25:
            case 26:
                step.answerFormat = answerDifficultyFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_COMMUNICATION", nil);
                break;
            case 27:
            case 28:
            case 29:
            case 30:
            case 31:
            case 32:
            case 33:
            case 34:
            case 35:
            case 36:
                step.answerFormat = answerDifficultyFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_ACTIVITIES", nil);
                break;
            case 37:
            case 38:
            case 39:
            case 40:
            case 41:
            case 42:
            case 43:
            case 44:
            case 45:
                step.answerFormat = answerDifficultyFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_MOBILITY", nil);
                break;
            case 46:
            case 47:
            case 48:
            case 49:
            case 50:
                step.answerFormat = answerDifficultyFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_HAND", nil);
                break;
            default:
                step.answerFormat = answerTimeFormat;
                step.title = ORKLocalizedString(@"SIS_TITLE_PARTICIPATE", nil);
        }
        {
            NSString *questionStem = [NSString stringWithFormat:@"SIS_Q%d",questionID];
            step.text = ORKLocalizedString(questionStem, nil);
        }
        ORKStepArrayAddStep(steps,step);
    }
    
    // Finally we ask about stroke recovery using a vertical scale from 0 to 100.
    {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:@"Recovery"];
        step.title = ORKLocalizedString(@"SIS_RECOVERY_TITLE",nil);
        step.text = ORKLocalizedString(@"SIS_RECOVERY_TEXT",nil);
        step.answerFormat = [[ORKScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:0 defaultValue:50 step:10 vertical:true maximumValueDescription:ORKLocalizedString(@"SIS_RECOVERY_MAX",nil) minimumValueDescription:ORKLocalizedString(@"SIS_RECOVERY_MIN",nil)];
        
        ORKStepArrayAddStep(steps,step);
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    return self;
}

@end