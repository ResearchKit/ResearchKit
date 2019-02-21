/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015-2017, Ricardo Sanchez-Saez.
 Copyright (c) 2016-2017, Sage Bionetworks
 
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


#import "TaskFactory+TaskReview.h"

@import ResearchKit;


@implementation TaskFactory (TaskReview)

- (NSArray<ORKStep *> *)stepsForReviewTasks {
    // ORKInstructionStep
    ORKInstructionStep *instructionStep = [[ORKInstructionStep alloc] initWithIdentifier:@"instructionStep"];
    instructionStep.title = @"Review Task";
    instructionStep.text = @"The task demonstrates the usage of ORKReviewStep within a task";
    
    NSMutableArray<ORKTextChoice *> *textChoices = [[NSMutableArray alloc] init];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Good" detailText:@"" value:[NSNumber numberWithInt:0] exclusive:NO]];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Average" detailText:@"" value:[NSNumber numberWithInt:1] exclusive:NO]];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Poor" detailText:@"" value:[NSNumber numberWithInt:2] exclusive:NO]];
    ORKQuestionStep *step1 = [ORKQuestionStep questionStepWithIdentifier:@"step1" title:@"Review Task" question:@"How do you feel today?" answer:[ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices]];
    
    // ORKImageChoiceAnswerFormat
    NSMutableArray<ORKImageChoice *> *imageChoices = [[NSMutableArray alloc] init];
    [imageChoices addObject:[[ORKImageChoice alloc] initWithNormalImage:[UIImage imageNamed:@"left_hand_outline"] selectedImage:[UIImage imageNamed:@"left_hand_solid"] text:@"Left hand" value:[NSNumber numberWithInt:1]]];
    [imageChoices addObject:[[ORKImageChoice alloc] initWithNormalImage:[UIImage imageNamed:@"right_hand_outline"] selectedImage:[UIImage imageNamed:@"right_hand_solid"] text:@"Right hand" value:[NSNumber numberWithInt:0]]];
    ORKQuestionStep *step2 = [ORKQuestionStep questionStepWithIdentifier:@"step2" title:@"Review Task" question: @"Which hand was injured?" answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices]];
    
    // ORKTextChoiceAnswerFormat
    ORKQuestionStep *step3 = [ORKQuestionStep questionStepWithIdentifier:@"step3" title:@"Review Task" question: @"How do you feel today?" answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices]];
    
    // ORKBooleanAnswerFormat
    ORKQuestionStep *step4 = [ORKQuestionStep questionStepWithIdentifier:@"step4" title:@"Review Task" question:@"Are you at least 18 years old?" answer:[ORKAnswerFormat booleanAnswerFormat]];
    
    // ORKTimeOfDayAnswerFormat
    ORKQuestionStep *step5 = [ORKQuestionStep questionStepWithIdentifier:@"step5" title:@"Review Task" question:@"When did you wake up today?" answer:[ORKAnswerFormat timeOfDayAnswerFormat]];
    
    // ORKDateAnswerFormat
    ORKQuestionStep *step6 = [ORKQuestionStep questionStepWithIdentifier:@"step6" title:@"Review Task" question:@"When is your birthday?" answer:[ORKAnswerFormat dateAnswerFormat]];
    
    // ORKFormStep
    ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:@"formStep" title:@"Survey" text:@"Please answer the following set of questions"];
    ORKFormItem *formItem1 = [[ORKFormItem alloc] initWithIdentifier:@"formItem1" text:@"How do you feel today?" answerFormat:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices]];
    ORKFormItem *formItem2 = [[ORKFormItem alloc] initWithIdentifier:@"formItem2" text:@"Are you pregnant?" answerFormat:[ORKAnswerFormat booleanAnswerFormat]];
    formStep.formItems = @[formItem1, formItem2];
    
    // ORKReviewStep
    ORKReviewStep *reviewStep = [ORKReviewStep embeddedReviewStepWithIdentifier:@"embeddedReviewStep"];
    reviewStep.title = @"Review";
    reviewStep.text = @"Review your answers";
    
    // ORKNumericAnswerFormat
    ORKQuestionStep *step7 = [ORKQuestionStep questionStepWithIdentifier:@"step7" title:@"Review Task" question:@"How many children do you have?" answer:[ORKAnswerFormat integerAnswerFormatWithUnit:@"children"]];
    
    // ORKScaleAnswerFormat
    ORKQuestionStep *step8 = [ORKQuestionStep questionStepWithIdentifier:@"step8" title:@"Review Task" question:@"On a scale from 1 to 10: How do you feel today?" answer:[ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10 minimumValue:1 defaultValue:6 step:1 vertical:NO maximumValueDescription:@"Excellent" minimumValueDescription:@"Poor"]];
    
    // ORKContinousScaleAnswerFormat
    ORKQuestionStep *step9 = [ORKQuestionStep questionStepWithIdentifier:@"step9" title:@"Review Task" question:@"On a scale from 1 to 10: How do you feel today?" answer:[ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10 minimumValue:1 defaultValue:6 maximumFractionDigits:2 vertical:NO maximumValueDescription:@"Excellent" minimumValueDescription:@"Poor"]];
    
    // ORKTextScaleAnswerFormat
    ORKQuestionStep *step10 = [ORKQuestionStep questionStepWithIdentifier:@"step10" title:@"Review Task" question:@"How do you feel today?" answer:[ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices defaultIndex:0 vertical:NO]];
    
    // ORKTextAnswerFormat
    ORKQuestionStep *step11 = [ORKQuestionStep questionStepWithIdentifier:@"step11" title:@"Review Task" question:@"What books do you like best?" answer:[ORKAnswerFormat textAnswerFormat]];
    
    // ORKEmailAnswerFormat
    ORKQuestionStep *step12 = [ORKQuestionStep questionStepWithIdentifier:@"step12" title:@"Review Task" question:@"What is your e-mail address?" answer:[ORKAnswerFormat emailAnswerFormat]];
    
    // ORKTimeIntervalAnswerFormat
    ORKQuestionStep *step13 = [ORKQuestionStep questionStepWithIdentifier:@"step13" title:@"Review Task" question:@"How many hours did you sleep last night?" answer:[ORKAnswerFormat timeIntervalAnswerFormat]];
    
    // ORKHeightAnswerFormat
    ORKQuestionStep *step14 = [ORKQuestionStep questionStepWithIdentifier:@"step14" title:@"Review Task" question:@"What is your height?" answer:[ORKAnswerFormat heightAnswerFormat]];
    
    // ORKWeightAnswerFormat
    ORKQuestionStep *step15 = [ORKQuestionStep questionStepWithIdentifier:@"step15" title:@"Review Task" question:@"What is your weight?" answer:[ORKAnswerFormat weightAnswerFormat]];

    // ORKLocationAnswerFormat
    ORKQuestionStep *step16 = [ORKQuestionStep questionStepWithIdentifier:@"step16" title:@"Review Task" question:@"Where do you live?" answer:[ORKAnswerFormat locationAnswerFormat]];
    
    return @[instructionStep, step1, step2, step3, step4, step5, step6, formStep, reviewStep, step7, step8, step9, step10, step11, step12, step13, step14, step15, step16];
}

- (id<ORKTask>)makeEmbeddedReviewTaskWithIdentifier:(NSString *)identifier {
    // ORKValuePickerAnswerFormat
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] initWithArray:[self stepsForReviewTasks]];
    ORKReviewStep *reviewStep = [ORKReviewStep embeddedReviewStepWithIdentifier:@"reviewStep"];
    reviewStep.title = @"Review";
    reviewStep.text = @"Review your answers";
    [steps addObject:reviewStep];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    task.isEmbeddedReviewTask = YES;
    return task;
}

- (id<ORKTask>)makeStandaloneReviewTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray alloc] initWithArray:[self stepsForReviewTasks]];
    ORKReviewStep *reviewStep = [ORKReviewStep standaloneReviewStepWithIdentifier:@"reviewStep" steps:steps resultSource:self.embeddedReviewTaskResult];
    reviewStep.title = @"Review";
    reviewStep.text = @"Review your answers from your last survey";
    reviewStep.excludeInstructionSteps = YES;
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[reviewStep]];
}

@end
