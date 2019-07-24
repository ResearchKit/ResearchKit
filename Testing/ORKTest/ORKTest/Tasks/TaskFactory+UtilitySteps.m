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


#import "TaskFactory+UtilitySteps.h"

@import ResearchKit;


@implementation TaskFactory (UtilitySteps)

- (id<ORKTask>)makeAuxiliaryImageStepTaskWithIdentifier:(NSString *)identifier {
    
    ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"step"];
    step.title = @"Title";
    step.text = @"This is description text.";
    step.detailText = @"This is detail text.";
    step.image = [UIImage imageNamed:@"tremortest3a" inBundle:[NSBundle bundleForClass:[ORKOrderedTask class]] compatibleWithTraitCollection:nil];
    step.auxiliaryImage = [UIImage imageNamed:@"tremortest3b" inBundle:[NSBundle bundleForClass:[ORKOrderedTask class]] compatibleWithTraitCollection:nil];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[step]];
}

- (id<ORKTask>)makeCompletionStepTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKCompletionStep *step1 = [[ORKCompletionStep alloc] initWithIdentifier:@"completionStepWithDoneButton"];
    step1.title = @"Completion Step";
    step1.text = @"Example of a step view controller with the continue button in the standard location below the checkmark.";
    step1.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        ((ORKCompletionStepViewController*)stepViewController).shouldShowContinueButton = YES;
    };
    [steps addObject:step1];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Completion Step";
    stepLast.text = @"Example of an step view controller with the continue button in the upper right.";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

- (id<ORKTask>)makeFootnoteStepTaskWithIdentifier:(NSString *)identifier {
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Footnote example";
    step1.text = @"This is an instruction step with a footnote.";
    step1.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";
    
    ORKInstructionStep *step2 = [[ORKInstructionStep alloc] initWithIdentifier:@"step2"];
    step2.title = @"No Footnote";
    step2.text = @"This is an instruction step with an image and NO footnote.";
    step2.image = [UIImage imageNamed:@"image_example"];
    
    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Image and Footnote";
    step3.text = @"This is an instruction step with an image and a footnote.";
    step3.image = [UIImage imageNamed:@"image_example"];
    step3.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";
    
    ORKFormStep *step4 = [[ORKFormStep alloc] initWithIdentifier:@"step4" title:@"Form Step" text:@"This is a form step with a skip button."];
    step4.formItems = @[[[ORKFormItem alloc] initWithIdentifier:@"formItem1"
                                                           text:@"Are you over 18 years of age?"
                                                   answerFormat:[ORKAnswerFormat booleanAnswerFormat]]];
    step4.optional = YES;
    
    ORKFormStep *step5 = [[ORKFormStep alloc] initWithIdentifier:@"step5" title:@"Footnote example" text:@"This is a form step with a skip button and footnote."];
    step5.formItems = @[[[ORKFormItem alloc] initWithIdentifier:@"formItem1"
                                                           text:@"Are you over 18 years of age?"
                                                   answerFormat:[ORKAnswerFormat booleanAnswerFormat]]];
    step5.optional = YES;
    step5.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";
    
    ORKCompletionStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    lastStep.title = @"Last step.";
    lastStep.text = @"This is a completion step with a footnote.";
    lastStep.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[step1, step2, step3, step4, step5, lastStep]];
}

- (id<ORKTask>)makeIconImageStepTaskWithIdentifier:(NSString *)identifier {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Title";
    step1.text = @"This is an example of a step with an icon image.";
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    step1.iconImage = [UIImage imageNamed:icon];
    
    ORKInstructionStep *step2 = [[ORKInstructionStep alloc] initWithIdentifier:@"step2"];
    step2.text = @"This is an example of a step with an icon image and no title.";
    step2.iconImage = [UIImage imageNamed:icon];
    
    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Title";
    step3.text = @"This is an example of a step with an icon image that is very big.";
    step3.iconImage = [UIImage imageNamed:@"Poppies"];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[step1, step2, step3]];
}


- (id<ORKTask>)makePageStepTaskWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Page Step";
    step1.text = @"Example of an ORKPageStep";
    [steps addObject:step1];
    
    NSMutableArray<ORKTextChoice *> *textChoices = [[NSMutableArray alloc] init];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Good" detailText:@"" value:[NSNumber numberWithInt:0] exclusive:NO]];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Average" detailText:@"" value:[NSNumber numberWithInt:1] exclusive:NO]];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Poor" detailText:@"" value:[NSNumber numberWithInt:2] exclusive:NO]];
    ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices];
    ORKFormItem *formItem = [[ORKFormItem alloc] initWithIdentifier:@"choice" text:nil answerFormat:answerFormat];
    ORKFormStep *groupStep1 = [[ORKFormStep alloc] initWithIdentifier:@"step1" title:nil text:@"How do you feel today?"];
    groupStep1.formItems = @[formItem];
    
    NSMutableArray<ORKImageChoice *> *imageChoices = [[NSMutableArray alloc] init];
    [imageChoices addObject:[[ORKImageChoice alloc] initWithNormalImage:[UIImage imageNamed:@"left_hand_outline"] selectedImage:[UIImage imageNamed:@"left_hand_solid"] text:@"Left hand" value:[NSNumber numberWithInt:1]]];
    [imageChoices addObject:[[ORKImageChoice alloc] initWithNormalImage:[UIImage imageNamed:@"right_hand_outline"] selectedImage:[UIImage imageNamed:@"right_hand_solid"] text:@"Right hand" value:[NSNumber numberWithInt:0]]];
    ORKQuestionStep *groupStep2 = [ORKQuestionStep questionStepWithIdentifier:@"step2" title:nil question:@"Which hand was injured?" answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices]];
    
    ORKSignatureStep *groupStep3 = [[ORKSignatureStep alloc] initWithIdentifier:@"step3"];
    
    ORKStep *groupStep4 = [[ORKConsentReviewStep alloc] initWithIdentifier:@"groupStep4" signature:nil inDocument:[self buildConsentDocument]];
    
    ORKPageStep *pageStep = [[ORKPageStep alloc] initWithIdentifier:@"pageStep" steps:@[groupStep1, groupStep2, groupStep3, groupStep4]];
    pageStep.title = @"Page Step";
    [steps addObject:pageStep];
    
    ORKOrderedTask *audioTask = [ORKOrderedTask audioTaskWithIdentifier:@"audioTask"
                                                 intendedUseDescription:nil
                                                      speechInstruction:nil
                                                 shortSpeechInstruction:nil
                                                               duration:10
                                                      recordingSettings:nil
                                                        checkAudioLevel:YES
                                                                options:
                                 ORKPredefinedTaskOptionExcludeInstructions |
                                 ORKPredefinedTaskOptionExcludeConclusion];
    ORKPageStep *audioStep = [[ORKNavigablePageStep alloc] initWithIdentifier:@"audioStep" pageTask:audioTask];
    audioStep.title = @"Page Step";
    [steps addObject:audioStep];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Task Complete";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

/*
 This is intended to test the predicate functions and APIs
 */
- (id<ORKTask>)makePredicateTestsTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"introStep"];
        step.title = @"Predicate Tests";
        [steps addObject:step];
    }
    
    // Test Expected Boolean value
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question1" title:@"Predicate Tests" question:@"Pass the Boolean question?" answer:[ORKAnswerFormat booleanAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question1Fail"];
        step.title = @"Predicate Tests";
        step.text = @"You failed the Boolean question.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question1Pass"];
        step.title = @"Predicate Tests";
        step.text = @"You passed the Boolean question.";
        [steps addObject:step];
    }
    
    // Test expected Single Choice
    {
        NSMutableArray<ORKTextChoice *> *textChoices = [[NSMutableArray alloc] init];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Choose Yes" detailText:@"" value:[NSNumber numberWithInt:0] exclusive:NO]];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Choose No" detailText:@"" value:[NSNumber numberWithInt:1] exclusive:NO]];
        ORKAnswerFormat *answer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question2" title:@"Predicate Tests" question:@"Pass the single choice question?" answer:answer];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question2Fail"];
        step.title = @"Predicate Tests";
        step.text = @"You failed the single choice question.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question2Pass"];
        step.title = @"Predicate Tests";
        step.text = @"You passed the single choice question.";
        [steps addObject:step];
    }
    
    //  Test expected multiple choices
    {
        NSMutableArray<ORKTextChoice *> *textChoices = [[NSMutableArray alloc] init];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Cat" detailText:@"" value:[NSNumber numberWithInt:0] exclusive:NO]];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Dog" detailText:@"" value:[NSNumber numberWithInt:1] exclusive:NO]];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Rock" detailText:@"" value:[NSNumber numberWithInt:2] exclusive:NO]];
        ORKAnswerFormat *answer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:textChoices];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question3" title:@"Predicate Tests" question:@"Select all the animals" answer:answer];
        
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question3Fail"];
        step.title = @"Predicate Tests";
        step.text = @"You failed the multiple choice animals question.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question3Pass"];
        step.title = @"Predicate Tests";
        step.text = @"You passed the multiple choice animals question.";
        [steps addObject:step];
    }
    
    //  Test expected multiple choices
    {
        NSMutableArray<ORKTextChoice *> *textChoices = [[NSMutableArray alloc] init];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Cat" detailText:@"" value:@"Cat" exclusive:NO]];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Catheter" detailText:@"" value:@"Catheter" exclusive:NO]];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Cathedral" detailText:@"" value:@"Cathedral" exclusive:NO]];
        [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Dog" detailText:@"" value:@"Dog" exclusive:NO]];
        ORKAnswerFormat *answer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question4" title:@"Predicate Tests" question:@"Choose any word containing the word 'Cat'" answer:answer];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question4Fail"];
        step.title = @"Predicate Tests";
        step.text = @"You failed the 'Cat' pattern match question.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question4Pass"];
        step.title = @"Predicate Tests";
        step.text = @"You passed the 'Cat' pattern match question.";
        [steps addObject:step];
    }
    
    //  Test expected text
    {
        ORKAnswerFormat *answer = [ORKAnswerFormat textAnswerFormat];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question5" title:@"Predicate Tests" question:@"Write the word 'Dog'" answer:answer];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question5Fail"];
        step.title = @"Predicate Tests";
        step.text = @"You didn't write 'Dog'.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question5Pass"];
        step.title = @"Predicate Tests";
        step.text = @"You wrote 'Dog'.";
        [steps addObject:step];
    }
    
    //  Test matching text
    {
        ORKAnswerFormat *answer = [ORKAnswerFormat textAnswerFormat];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question6" title:@"Predicate Tests" question:@"Write a word matching '*og'" answer:answer];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question6Fail"];
        step.title = @"Predicate Tests";
        step.text = @"You didn't write a word matching '*og'.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question6Pass"];
        step.title = @"Predicate Tests";
        step.text = @"You wrote a word matching '*og'.";
        [steps addObject:step];
    }
    
    //  Numeric test - any number over 10
    {
        ORKAnswerFormat *answer = [ORKAnswerFormat integerAnswerFormatWithUnit:nil];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question7" title:@"Predicate Tests" question:@"Enter a number over 10" answer:answer];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question7Fail"];
        step.title = @"Predicate Tests";
        step.text = @"Your number was less then 10.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question7Pass"];
        step.title = @"Predicate Tests";
        step.text = @"Your number was over 10.";
        [steps addObject:step];
    }
    
    {
        /*
         Vertical continuous scale with three decimal places and a default.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:8.725
                                                                                                    maximumFractionDigits:3
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:nil
                                                                                                  minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question8" title:@"Predciate Tests" question:@"Choose a value under 5" answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question8Fail"];
        step.title = @"Predicate Tests";
        step.text = @"Your number was more than 5.";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"question8Pass"];
        step.title = @"Predicate Tests";
        step.text = @"Your number was less than 5.";
        [steps addObject:step];
    }
    
    
    {
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:@"allPassed"];
        step.title = @"Predicate Tests";
        step.text = @"All validation tests now completed.";
        [steps addObject:step];
    }
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    // Build navigation rules.
    {
        // If we answer 'Yes' to Question 1, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question1"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:YES];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question1Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question1"];
    }
    
    {
        // If we arrived at question_01_fail then fall through to question 2
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question2"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question1Fail"];
    }
    
    {
        // If we answer 'Yes' to Question 2, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question2"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:@"Choose Yes"];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question2Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question2"];
    }
    
    {
        // If we arrived at question_02_fail then fall through to question 3
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question3"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question2Fail"];
    }
    
    {
        // If we answer 'Yes' to Question 3, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question3"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValues:[NSArray arrayWithObjects: @"Cat", @"Dog", nil]];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question3Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question3"];
    }
    
    {
        // If we arrived at question_03_fail then fall through to question 4
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question4"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question3Fail"];
    }
    
    {
        // If we answer 'Yes' to Question 4, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question4"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector matchingPattern:@"Cat.*"];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question4Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question4"];
    }
    
    {
        // If we arrived at question_04_fail then fall through to question 5
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question5"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question4Fail"];
    }
    
    {
        // If we answer 'Dog' to Question 5, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question5"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForTextQuestionResultWithResultSelector:resultSelector expectedString:@"Dog"];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question5Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question5"];
    }
    
    {
        // If we arrived at question_05_fail then fall through to question 6
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question6"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question5Fail"];
    }
    
    
    {
        // If we answer '*og' to Question 6, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question6"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForTextQuestionResultWithResultSelector:resultSelector matchingPattern:@".*og"];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question6Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question6"];
    }
    
    {
        // If we arrived at question_06_fail then fall through to question 7
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question7"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question6Fail"];
    }
    
    {
        // If we answer '*og' to Question 7, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question7"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForNumericQuestionResultWithResultSelector:resultSelector minimumExpectedAnswerValue:10];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question7Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question7"];
    }
    
    {
        // If we arrived at question_05_fail then fall through to question 6
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"question8"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question7Fail"];
    }
    
    {
        // If we answer '*og' to Question 7, then proceed to the pass screen
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question8"];
        NSPredicate *predicateQuestion = [ORKResultPredicate predicateForScaleQuestionResultWithResultSelector:resultSelector maximumExpectedAnswerValue:5];
        
        ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                              destinationStepIdentifiers:@[@"question8Pass"]];
        [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question8"];
    }
    
    {
        // If we arrived at question_05_fail then fall through to question 6
        ORKDirectStepNavigationRule *directRule = nil;
        directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"allPassed"];
        [task setNavigationRule:directRule forTriggerStepIdentifier:@"question8Fail"];
    }
    
    return task;
}

- (id<ORKTask>)makeSignatureStepTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Signature Step";
    step1.text = @"Example of an ORKSignatureStep";
    [steps addObject:step1];
    
    ORKSignatureStep *signatureStep = [[ORKSignatureStep alloc] initWithIdentifier:@"signatureStep"];
    signatureStep.title = @"Signature Step";
    [steps addObject:signatureStep];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Task Complete";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

- (id<ORKTask>)makeTableStepTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Table Step";
    step1.text = @"Example of an ORKTableStepViewController";
    [steps addObject:step1];
    
    ORKTableStep *tableStep = [[ORKTableStep alloc] initWithIdentifier:@"tableStep"];
    tableStep.title = @"Table Step";
    tableStep.items = @[@"Item 1", @"Item 2", @"Item 3"];
    tableStep.bulletType = ORKBulletTypeNumber;
    [steps addObject:tableStep];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Task Complete";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

- (id<ORKTask>)makeVideoInstructionStepTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *firstStep = [[ORKInstructionStep alloc] initWithIdentifier:@"firstStep"];
    firstStep.title = @"Video Instruction";
    firstStep.text = @"Example of an ORKVideoInstructionStep";
    [steps addObject:firstStep];
    
    ORKVideoInstructionStep *videoInstructionStep = [[ORKVideoInstructionStep alloc] initWithIdentifier:@"videoInstructionStep"];
    videoInstructionStep.title = @"Video Instruction";
    videoInstructionStep.videoURL = [[NSURL alloc] initWithString:@"https://www.apple.com/media/us/researchkit/2016/a63aa7d4_e6fd_483f_a59d_d962016c8093/films/carekit/researchkit-carekit-cc-us-20160321_r848-9dwc.mov"];
    
    [steps addObject:videoInstructionStep];
    
    ORKCompletionStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    lastStep.title = @"Task Complete";
    [steps addObject:lastStep];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

- (id<ORKTask>)makeWaitStepTaskWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    /*
     To properly use the wait steps, one needs to implement the "" method of ORKTaskViewControllerDelegate to start their background action when the wait task begins, and then call the "finish" method on the ORKWaitTaskViewController when the background task has been completed.
     */
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Setup";
    step1.detailText = @"ORKTest needs to set up some things before you begin, once the setup is complete you will be able to continue.";
    [steps addObject:step1];
    
    // Interterminate wait step.
    ORKWaitStep *step2 = [[ORKWaitStep alloc] initWithIdentifier:@"step2"];
    step2.title = @"Getting Ready";
    step2.text = @"Please wait while the setup completes.";
    step2.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        [((ORKWaitStepViewController *)stepViewController) performSelector:@selector(updateText:) withObject:@"Updated text" afterDelay:2.0];
        [((ORKWaitStepViewController *)stepViewController) performSelector:@selector(goForward) withObject:nil afterDelay:5.0];
    };
    [steps addObject:step2];

    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Account Setup";
    step3.detailText = @"The information you entered will be sent to the secure server to complete your account setup.";
    [steps addObject:step3];
    
    // Determinate wait step.
    ORKWaitStep *step4 = [[ORKWaitStep alloc] initWithIdentifier:@"step4"];
    step4.title = @"Syncing Account";
    step4.text = @"Please wait while the data is uploaded.";
    step4.indicatorType = ORKProgressIndicatorTypeProgressBar;
    step4.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        [self updateProgress:0.0 waitStepViewController:((ORKWaitStepViewController *)stepViewController)];
    };
    [steps addObject:step4];
    
    ORKCompletionStep *step5 = [[ORKCompletionStep alloc] initWithIdentifier:@"step5"];
    step5.title = @"Setup Complete";
    [steps addObject:step5];
    
    ORKOrderedTask *waitTask = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return waitTask;
}

- (id<ORKTask>)makeWebViewStepTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *firstStep = [[ORKInstructionStep alloc] initWithIdentifier:@"firstStep"];
    firstStep.title = @"Web View";
    firstStep.text = @"Example of an ORKWebViewStep";
    [steps addObject:firstStep];
    
    NSString * html = @"<!DOCTYPE html>"
    "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\">"
    "<head>"
    "<meta name=\"viewport\" content=\"width=400, user-scalable=no\">"
    "<script type=\"text/javascript\">"
    "function completeStep() {"
    "    var answer = document.getElementById(\"answer\").value;"
    "    window.webkit.messageHandlers.ResearchKit.postMessage(answer);"
    "}"
    "</script>"
    "</head>"
    "<body>"
    "<div class=\"container\">"
    "<input type=\"text\" id=\"answer\" class=\"answer-box\" placeholder=\"Answer\" />"
    "<button onclick=\"completeStep();\" class=\"continue-button\">Continue</button>"
    "</div>"
    "</body>"
    "</html>";
    
    ORKWebViewStep *webViewStep = [ORKWebViewStep webViewStepWithIdentifier:@"webViewStep" html:html];
    webViewStep.title = @"Web View";
    [steps addObject:webViewStep];
    
    ORKCompletionStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    lastStep.title = @"Task Complete";
    [steps addObject:lastStep];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

// Update progress on the Wait Task
- (void)updateProgress:(CGFloat)progress waitStepViewController:(ORKWaitStepViewController *)waitStepviewController {
    if (progress <= 1.0) {
        [waitStepviewController setProgress:progress animated:true];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self updateProgress:(progress + 0.01) waitStepViewController:waitStepviewController];
            if (progress > 0.495 && progress < 0.505) {
                NSString *newText = @"Please wait while the data is downloaded.";
                [waitStepviewController updateText:newText];
            }
        });
    } else {
        [waitStepviewController goForward];
    }
}

@end
