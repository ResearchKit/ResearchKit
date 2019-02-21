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


#import "TaskFactory+TaskCustomization.h"

#import "DragonPokerStep.h"
#import "DynamicTask.h"

@import ResearchKit;


@implementation TaskFactory (TaskCustomization)

- (id<ORKTask>)makeCustomViewControllerTaskWithIdentifier:(NSString *)identifier {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Custom VC";
    step1.text = @"The next step uses a custom subclass of an ORKFormStepViewController.";
    
    DragonPokerStep *dragonStep = [[DragonPokerStep alloc] initWithIdentifier:@"dragonStep"];
    dragonStep.title = @"Custom VC";
    
    ORKStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    lastStep.title = @"Complete";
    
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[step1, dragonStep, lastStep]];
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
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step1"
                                                                      title:@"Interruptible"
                                                                   question:@"How old are you?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step2"
                                                                      title:@"Interruptible"
                                                                   question:@"How much did you pay for your car?"
                                                                     answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"USD"]];
        /*
         Test interrupting navigation from the task view controller delegate.
         
         This is an example of preventing a user from proceeding if they don't
         enter a valid answer.
         */
        step.shouldPresentStepBlock = ^BOOL(ORKTaskViewController *taskViewController, ORKStep *step) {
            BOOL shouldPresentStep = YES;
            ORKQuestionResult *questionResult = (ORKQuestionResult *)[[[taskViewController result] stepResultForStepIdentifier:@"step1"] firstResult];
            if (questionResult == nil || [(NSNumber *)questionResult.answer integerValue] < 18) {
                UIAlertController *alertViewController =
                [UIAlertController alertControllerWithTitle:@"Warning"
                                                    message:@"You can't participate if you are under 18."
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         [alertViewController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alertViewController addAction:okAction];
                
                [taskViewController presentViewController:alertViewController animated:NO completion:nil];
                shouldPresentStep = NO;
            }
            return shouldPresentStep;
        };
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
        step.title = @"Thank you for completing this task.";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
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
    step.title = @"Ordered Loop";
    step.text = @"This task demonstrates an skippable step and an optional loop within a navigable ordered task";
    [steps addObject:step];
    
    // Skippable step
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    questionStep = [ORKQuestionStep questionStepWithIdentifier:@"skipNextStep" title:@"Ordered Loop" question:@"Do you want to skip the next step?" answer:answerFormat];
    questionStep.optional = NO;
    [steps addObject:questionStep];
    
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"skippableStep"];
    step.title = @"Optional Skip";
    step.text = @"You should only see this step if you answered the previous question with 'No'";
    [steps addObject:step];
    
    // Loop target step
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"loopAStep"];
    step.title = @"Optional return";
    step.text = @"You'll optionally return to this step";
    [steps addObject:step];
    
    // Branching paths
    textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Scale" value:@"scale"],
      [ORKTextChoice choiceWithText:@"Text Choice" value:@"textchoice"]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    
    questionStep = [ORKQuestionStep questionStepWithIdentifier:@"branchingStep" title:@"Ordered Loop" question:@"Which kind of question do you prefer?" answer:answerFormat];
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
                                                 title:@"Ordered Loop"
                                              question:@"On a scale of 1 to 10, what is your mood?"
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
    
    questionStep = [ORKQuestionStep questionStepWithIdentifier:@"textChoiceStep" title:@"Ordered Loop" question:@"How is your mood?" answer:answerFormat];
    questionStep.optional = NO;
    [steps addObject:questionStep];
    
    // Loop conditional step
    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    step = [ORKQuestionStep questionStepWithIdentifier:@"loopBStep" title:@"Ordered Loop" question:@"Do you want to repeat the survey?" answer:answerFormat];
    step.optional = NO;
    [steps addObject:step];
    
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"endStep"];
    step.title = @"Complete";
    step.text = @"You have finished the task";
    [steps addObject:step];
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier
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

- (id<ORKTask>)makeStepWillAppearTaskWithIdentifier:(NSString *)identifier {
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Will Appear";
    step1.text = @"This task will test several usages of the delegate's 'taskViewController:stepViewControllerWillAppear:\' method.";
    
    /*
     Test adding a custom view to a view controller for an active step, without
     subclassing.
     
     This is possible, but not recommended. A better choice would be to create
     a custom active step subclass and a matching active step view controller
     subclass, so you completely own the view controller and its appearance.
     */
    ORKActiveStep *step2 = [[ORKActiveStep alloc] initWithIdentifier:@"step2"];
    step2.title = @"Will Appear";
    step2.text = @"Custom View On Active Step";
    step2.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                               ORKStepViewController *stepViewController) {
        UIView *customView = [UIView new];
        customView.backgroundColor = [UIColor cyanColor];
        
        // Have the custom view request the space it needs.
        // A little tricky because we need to let it size to fit if there's not enough space.
        customView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(==160)]"
                                                                               options:(NSLayoutFormatOptions)0
                                                                               metrics:nil
                                                                                 views:@{@"c":customView}];
        for (NSLayoutConstraint *constraint in verticalConstraints) {
            constraint.priority = UILayoutPriorityFittingSizeLevel;
        }
        [NSLayoutConstraint activateConstraints:verticalConstraints];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(==280)]"
                                                                                        options:(NSLayoutFormatOptions)0
                                                                                        metrics:nil
                                                                                          views:@{@"c":customView}]];
        
        [(ORKActiveStepViewController *)stepViewController setCustomView:customView];
        
        // Set custom button on navigation bar
        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
    };
    
    /*
     Customize the continue and learn more buttons.
     */
    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Will Appear";
    step3.text = @"Custom Next and Learn More Buttons";
    step3.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        stepViewController.continueButtonTitle = @"Next Customized Step";
        stepViewController.learnMoreButtonTitle = @"Learn more about this customized task";
    };

    /*
     Customize the back and cancel buttons.
     */
    ORKInstructionStep *step4 = [[ORKInstructionStep alloc] initWithIdentifier:@"step4"];
    step4.title = @"Will Appear";
    step4.text = @"Custom Back and Cancel Buttons";
    step4.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        stepViewController.backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Backwards"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:stepViewController.backButtonItem.target
                                                                            action:stepViewController.backButtonItem.action];
        stepViewController.cancelButtonItem.title = @"Abort";
    };

    /*
     Customize the navigation item title.
     */
    ORKInstructionStep *step5 = [[ORKInstructionStep alloc] initWithIdentifier:@"step5"];
    step5.title = @"Will Appear";
    step5.text = @"Custom Navigation Item Title";
    step5.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        taskViewController.showsProgressInNavigationBar = NO;
        stepViewController.navigationItem.title = @"Custom title";
    };
    step5.stepViewControllerWillDisappearBlock = ^(ORKTaskViewController *taskViewController,
                                                   ORKStepViewController *stepViewController,
                                                   ORKStepViewControllerNavigationDirection navigationDirection) {
        taskViewController.showsProgressInNavigationBar = YES;
    };
    
    /*
     Customize the navigation item title view.
     */
    ORKInstructionStep *step6 = [[ORKInstructionStep alloc] initWithIdentifier:@"step6"];
    step6.title = @"Will Appear";
    step6.text = @"Custom Navigation Item Title View";
    step6.stepViewControllerWillAppearBlock = ^(ORKTaskViewController *taskViewController,
                                                ORKStepViewController *stepViewController) {
        taskViewController.showsProgressInNavigationBar = NO;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:@"Item1"];
        [items addObject:@"Item2"];
        [items addObject:@"Item3"];
        stepViewController.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:items];
    };
    step6.stepViewControllerWillDisappearBlock = ^(ORKTaskViewController *taskViewController,
                                                   ORKStepViewController *stepViewController,
                                                   ORKStepViewControllerNavigationDirection navigationDirection) {
        taskViewController.showsProgressInNavigationBar = YES;
    };

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier
                                                                steps:@[step1, step2, step3, step4, step5, step6]];
    return task;
}

- (id<ORKTask>)makeStepWillDisappearTaskWithIdentifier:(NSString *)identifier {
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Will Disappear";
    step1.text = @"The tint color of the task view controller will be changed to magenta in the delegate's 'taskViewController:stepViewControllerWillDisappear:navigationDirection:' method after this step.";
    
    step1.stepViewControllerWillDisappearBlock = ^(ORKTaskViewController *taskViewController,
                                                   ORKStepViewController *stepViewController,
                                                   ORKStepViewControllerNavigationDirection navigationDirection) {
        taskViewController.view.tintColor = [UIColor magentaColor];
    };

    ORKCompletionStep *step2 = [[ORKCompletionStep alloc] initWithIdentifier:@"step2"];
    step2.title = @"Survey Complete";
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[step1, step2]];
    return task;
}

@end
