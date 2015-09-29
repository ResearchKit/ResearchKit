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
 The IQCDE was developed by A. F. Jorm
 Centre for Mental Health Research The Australian National University Canberra, Australia
 */


#import "ORKIQCDE.h"
#import "ORKDefines_Private.h"
#import "ORKOrderedTask.h"


@implementation ORKIQCDE

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
            step.optional = NO;
        }
        step.answerFormat = answerFormat;
        ORKStepArrayAddStep(steps,step);
    }
    
    self = [super initWithIdentifier:identifier steps:steps];
    return self;
}

@end
