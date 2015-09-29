/*
 Copyright (c) 2015, Dr. Andrew Hill.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 The Epworth Sleep Scale is a validated tool to assess somnolence. High Epworth scores are associated
 With diseases such as obstructive sleep apnoea.
 
 If you would like to read more about this research tool, visit the original publication article:
 
 http://www.mwjohns.com/wp-content/uploads/2009/murray_papers/reliabiltiy_and_factor_analysis_of_the_epworth_sleepiness_scale.pdf
 */


#import "ORKEpworthSleepScale.h"
#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"
#import "ORKCompletionStep.h"


@implementation ORKEpworthSleepScale

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
    
    for (int questionID = 0; questionID < 8; questionID++) {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",questionID]];
            step.title = ORKLocalizedString(@"EPWORTH_INTRO_TITLE", nil);
        {
            NSString *questionStem = [NSString stringWithFormat:@"EPWORTH_Q%d",questionID];
            step.text = ORKLocalizedString(questionStem, nil);
            step.optional = NO;
        }
        step.answerFormat = answerFormat;
        ORKStepArrayAddStep(steps,step);
    }
    
    ORKCompletionStep *finalStep = [[ORKCompletionStep alloc] initWithIdentifier:@"FinalStep"];
    ORKStepArrayAddStep(steps,finalStep);

    
    self = [super initWithIdentifier:identifier steps:steps];
    return self;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {

    ORKStep *nextStep = [super stepAfterStep:step withResult:result];
    
    if ([nextStep.identifier isEqualToString:@"FinalStep"]) {
        int epworthScore = 0;
        for (int i = 0; i < 8; i++) {
            ORKStepResult *itemResult = (ORKStepResult *)result.results[i];
            if (itemResult.results.count > 0) {
                if ([itemResult.results[0] isKindOfClass:[ORKChoiceQuestionResult class]]) {
                    ORKChoiceQuestionResult *choiceResultArray = (ORKChoiceQuestionResult *) itemResult.results[0];
                     NSNumber *choiceValue = (NSNumber *) choiceResultArray.choiceAnswers[0];
                    epworthScore += [choiceValue intValue];
                }
            }
        }
        nextStep.title = ORKLocalizedString(@"EPWORTH_FINAL_TITLE", nil);
        if (epworthScore > 12) {
            nextStep.text = ORKLocalizedString(@"EPWORTH_RESULT_2", nil);
        } else if (epworthScore > 9) {
            nextStep.text = ORKLocalizedString(@"EPWORTH_RESULT_1", nil);
        } else {
            nextStep.text = ORKLocalizedString(@"EPWORTH_RESULT_0", nil);
        }
    }

    return nextStep;
}


@end
