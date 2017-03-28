 //
//  TaskFactory+TaskCustomization.m
//  ORKTest
//
//  Created by Ricardo Sanchez-Saez on 3/28/17.
//  Copyright © 2017 ResearchKit. All rights reserved.
//

#import "TaskFactory+TaskCustomization.h"

#import "DragonPokerStep.h"
#import "DynamicTask.h"

@import ResearchKit;


@implementation TaskFactory (TaskCustomization)

- (id<ORKTask>)makeCustomViewControllerTaskWithIdentifier:(NSString *)identifier {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"locationTask.step1"];
    step1.title = @"Instantiate Custom View Controller";
    step1.text = @"The next step uses a custom subclass of an ORKFormStepViewController.";
    
    DragonPokerStep *dragonStep = [[DragonPokerStep alloc] initWithIdentifier:@"dragonStep"];
    
    ORKStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"done"];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:CustomViewControllerTaskIdentifier steps:@[step1, dragonStep, lastStep]];
}

- (id<ORKTask>)makeCustomNavigationItemTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"customNavigationItemTask.step1"];
    step1.title = @"Custom Navigation Item Title";
    ORKInstructionStep *step2 = [[ORKInstructionStep alloc] initWithIdentifier:@"customNavigationItemTask.step2"];
    step2.title = @"Custom Navigation Item Title View";
    [steps addObject: step1];
    [steps addObject: step2];
    return [[ORKOrderedTask alloc] initWithIdentifier: CustomNavigationItemTaskIdentifier steps:steps];
}

- (id<ORKTask>)makeDynamicTaskWithIdentifier:(NSString *)identifier {
    return [DynamicTask new];
}

/*
 This demonstrates a task where if the user enters a value that is too low for
 the first question (say, under 18), the task view controller delegate API can
 be used to reject the answer and prevent forward navigation.
 
 See the implementation of the task view controller delegate methods for specific
 handling of this task.
 */
- (id<ORKTask>)makeInterruptibleTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(5);
        format.maximum = @(90);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"itid_001"
                                                                      title:@"How old are you?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"itid_002"
                                                                      title:@"How much did you pay for your car?"
                                                                     answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"USD"]];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"itid_003"];
        step.title = @"Thank you for completing this task.";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:InterruptibleTaskIdentifier steps:steps];
    return task;
}

- (id<ORKTask>)makeNavigableOrderedLoopTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    ORKAnswerFormat *answerFormat = nil;
    ORKStep *step = nil;
    NSArray *textChoices = nil;
    ORKQuestionStep *questionStep = nil;
    
    // Intro step
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"introStep"];
    step.title = @"This task demonstrates an skippable step and an optional loop within a navigable ordered task";
    [steps addObject:step];
    
    // Skippable step
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    questionStep = [ORKQuestionStep questionStepWithIdentifier:@"skipNextStep" title:@"Do you want to skip the next step?" answer:answerFormat];
    questionStep.optional = NO;
    [steps addObject:questionStep];
    
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"skippableStep"];
    step.title = @"You'll optionally skip this step";
    step.text = @"You should only see this step if you answered the previous question with 'No'";
    [steps addObject:step];
    
    // Loop target step
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"loopAStep"];
    step.title = @"You'll optionally return to this step";
    [steps addObject:step];
    
    // Branching paths
    textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Scale" value:@"scale"],
      [ORKTextChoice choiceWithText:@"Text Choice" value:@"textchoice"]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    
    questionStep = [ORKQuestionStep questionStepWithIdentifier:@"branchingStep" title:@"Which kind of question do you prefer?" answer:answerFormat];
    questionStep.optional = NO;
    [steps addObject:questionStep];
    
    // Scale question step
    ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                         minimumValue:1
                                                                                                         defaultValue:8.725
                                                                                                maximumFractionDigits:3
                                                                                                             vertical:YES
                                                                                              maximumValueDescription:nil
                                                                                              minimumValueDescription:nil];
    
    step = [ORKQuestionStep questionStepWithIdentifier:@"scaleStep"
                                                 title:@"On a scale of 1 to 10, what is your mood?"
                                                answer:scaleAnswerFormat];
    [steps addObject:step];
    
    // Text choice question step
    textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Good" value:@"good"],
      [ORKTextChoice choiceWithText:@"Bad" value:@"bad"]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    
    questionStep = [ORKQuestionStep questionStepWithIdentifier:@"textChoiceStep" title:@"How is your mood?" answer:answerFormat];
    questionStep.optional = NO;
    [steps addObject:questionStep];
    
    // Loop conditional step
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    step = [ORKQuestionStep questionStepWithIdentifier:@"loopBStep" title:@"Do you want to repeat the survey?" answer:answerFormat];
    step.optional = NO;
    [steps addObject:step];
    
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"endStep"];
    step.title = @"You have finished the task";
    [steps addObject:step];
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:NavigableOrderedLoopTaskIdentifier
                                                                                  steps:steps];
    
    // Build navigation rules
    ORKResultSelector *resultSelector = nil;
    ORKPredicateStepNavigationRule *predicateRule = nil;
    ORKDirectStepNavigationRule *directRule = nil;
    ORKPredicateSkipStepNavigationRule *predicateSkipRule = nil;
    
    // skippable step
    resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"skipNextStep"];
    NSPredicate *predicateSkipStep = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector
                                                                                              expectedAnswer:YES];
    predicateSkipRule = [[ORKPredicateSkipStepNavigationRule alloc] initWithResultPredicate:predicateSkipStep];
    [task setSkipNavigationRule:predicateSkipRule forStepIdentifier:@"skippableStep"];
    
    // From the branching step, go to either scaleStep or textChoiceStep
    resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"branchingStep"];
    NSPredicate *predicateAnswerTypeScale = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector
                                                                                               expectedAnswerValue:@"scale"];
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicateAnswerTypeScale ]
                                                          destinationStepIdentifiers:@[ @"scaleStep" ]
                                                               defaultStepIdentifier:@"textChoiceStep"];
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"branchingStep"];
    
    // From the loopB step, return to loopA if user chooses so
    resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"loopBStep"];
    NSPredicate *predicateLoopYes = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector
                                                                                             expectedAnswer:YES];
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicateLoopYes ]
                                                          destinationStepIdentifiers:@[ @"loopAStep" ] ];
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"loopBStep"];
    
    // scaleStep to loopB direct navigation rule
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"loopBStep"];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"scaleStep"];
    
    return task;
}

- (id<ORKTask>)makeStepWillDisappearTaskWithIdentifier:(NSString *)identifier {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:StepWillDisappearFirstStepIdentifier];
    step1.title = @"Step Will Disappear Delegate Example";
    step1.text = @"The tint color of the task view controller is changed to magenta in the `stepViewControllerWillDisappear:` method.";
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"stepLast"];
    stepLast.title = @"Survey Complete";
    
    ORKOrderedTask *locationTask = [[ORKOrderedTask alloc] initWithIdentifier:StepWillDisappearTaskIdentifier steps:@[step1, stepLast]];
    return locationTask;
}

@end
