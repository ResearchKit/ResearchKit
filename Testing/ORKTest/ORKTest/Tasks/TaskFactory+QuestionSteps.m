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


#import "TaskFactory+QuestionSteps.h"

@import ResearchKit;


@implementation TaskFactory (QuestionSteps)

/*
 This task presents several questions which exercise functionality based on
 `UIDatePicker`.
 */
- (id<ORKTask>)makeDatePickersTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
        step.title = @"Date Survey";
        step.detailText = @"date pickers";
        [steps addObject:step];
    }
    
    /*
     A time interval question with no default set.
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"timeInterval1"
                                                                      title:@"Date Survey"
                                                                   question:@"How long did it take to fall asleep last night?"
                                                                     answer:[ORKAnswerFormat timeIntervalAnswerFormat]];
        [steps addObject:step];
    }
    
    /*
     A time interval question specifying a default and a step size.
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"timeInterval2"
                                                                      title:@"Date Survey"
                                                                   question:@"How long did it take to fall asleep last night?"
                                                                     answer:[ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:5]];
        [steps addObject:step];
    }
    
    /*
     A date answer format question, specifying a specific calendar.
     If no calendar were specified, the user's preferred calendar would be used.
     */
    {
        ORKDateAnswerFormat *dateAnswer = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:nil minimumDate:nil maximumDate:nil calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierHebrew]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"date1"
                                                                      title:@"Date Survey"
                                                                   question:@"When is your birthday?"
                                                                     answer:dateAnswer];
        [steps addObject:step];
    }
    
    /*
     A date question with a minimum, maximum, and default.
     Also specifically requires the Gregorian calendar.
     */
    {
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        ORKDateAnswerFormat *dateAnswer = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                   minimumDate:minDate
                                                                                   maximumDate:maxDate
                                                                                      calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"date2"
                                                                      title:@"Date Survey"
                                                                   question:@"What day are you available?"
                                                                     answer:dateAnswer];
        [steps addObject:step];
    }
    
    /*
     A time of day question with no default.
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"timeOfDay1"
                                                                      title:@"Date Survey"
                                                                   question:@"What time do you get up?"
                                                                     answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormat]];
        [steps addObject:step];
    }
    
    /*
     A time of day question with a default of 8:15 AM.
     */
    {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.hour = 8;
        dateComponents.minute = 15;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"timeOfDay2"
                                                                      title:@"Date Survey"
                                                                   question:@"What time do you get up?"
                                                                     answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:dateComponents]];
        [steps addObject:step];
    }
    
    /*
     A date-time question with default parameters (no min, no max, default to now).
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"dateTime1"
                                                                      title:@"Date Survey"
                                                                   question:@"When is your next meeting?"
                                                                     answer:[ORKDateAnswerFormat dateTimeAnswerFormat]];
        [steps addObject:step];
    }
    
    /*
     A date-time question with specified min, max, default date, and calendar.
     */
    {
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"dateTime2"
                                                                      title:@"Date Survey"
                                                                   question:@"When is your next meeting?"
                                                                     answer:[ORKDateAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate minimumDate:minDate  maximumDate:maxDate calendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]]];
        [steps addObject:step];
        
    }
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

- (id<ORKTask>)makeImageCaptureTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    /*
     If implementing an image capture task like this one, remember that people will
     take your instructions literally. So, be cautious. Make sure your template image
     is high contrast and very visible against a variety of backgrounds.
     */
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"begin"];
        step.title = @"Hands";
        step.image = [[UIImage imageNamed:@"hands_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"In this step we will capture images of both of your hands";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"right1"];
        step.title = @"Right Hand";
        step.image = [[UIImage imageNamed:@"right_hand_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Let's start by capturing an image of your right hand";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"right2"];
        step.title = @"Right Hand";
        step.image = [[UIImage imageNamed:@"right_hand_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Align your right hand with the on-screen outline and capture the image.  Be sure to place your hand over a contrasting background.  You can re-capture the image as many times as you need.";
        [steps addObject:step];
    }
    
    {
        ORKImageCaptureStep *step = [[ORKImageCaptureStep alloc] initWithIdentifier:@"right3"];
        step.templateImage = [UIImage imageNamed:@"right_hand_outline_big"];
        step.templateImageInsets = UIEdgeInsetsMake(0.05, 0.05, 0.05, 0.05);
        step.accessibilityInstructions = @"Extend your right hand, palm side down, one foot in front of your device. Tap the Capture Image button, or two-finger double tap the preview to capture the image";
        step.accessibilityHint = @"Captures the image visible in the preview";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"left1"];
        step.title = @"Left Hand";
        step.image = [[UIImage imageNamed:@"left_hand_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Now let's capture an image of your left hand";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"left2"];
        step.title = @"Left Hand";
        step.image = [[UIImage imageNamed:@"left_hand_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Align your left hand with the on-screen outline and capture the image.  Be sure to place your hand over a contrasting background.  You can re-capture the image as many times as you need.";
        [steps addObject:step];
    }
    
    {
        ORKImageCaptureStep *step = [[ORKImageCaptureStep alloc] initWithIdentifier:@"left3"];
        step.templateImage = [UIImage imageNamed:@"left_hand_outline_big"];
        step.templateImageInsets = UIEdgeInsetsMake(0.05, 0.05, 0.05, 0.05);
        step.accessibilityInstructions = @"Extend your left hand, palm side down, one foot in front of your device. Tap the Capture Image button, or two-finger double tap the preview to capture the image";
        step.accessibilityHint = @"Captures the image visible in the preview";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"end"];
        step.title = @"Complete";
        step.detailText = @"Hand image capture complete";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

/*
 Tests various uses of image choices.
 
 All these tests use square colored images to test layout correctness. In a real
 application you would use images to convey an image scale.
 
 Tests image choices both in form items, and in question steps.
 */
- (id<ORKTask>)makeImageChoiceTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    for (NSValue *ratio in @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(2.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 2.0)]])
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:[NSString stringWithFormat:@"formStep%@",NSStringFromCGPoint(ratio.CGPointValue)] title:@"Image Choice" text:@"Testing image choices in a form layout."];
        
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSNumber *dimension in @[@(360), @(60)])
        {
            CGSize size1 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.x, dimension.floatValue * ratio.CGPointValue.y);
            CGSize size2 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.y, dimension.floatValue * ratio.CGPointValue.x);
            
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                       text:@"Red" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                       text:nil value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                       text:@"Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow" value:@"yellow"];
            ORKImageChoice *option4 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                       text:@"Green" value:@"green"];
            ORKImageChoice *option5 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                       text:nil value:@"blue"];
            ORKImageChoice *option6 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                       text:@"Cyan" value:@"cyanColor"];
            
            
            ORKFormItem *item1 = [[ORKFormItem alloc] initWithIdentifier:[@"item1" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color"
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1] ]];
            [items addObject:item1];
            
            ORKFormItem *item2 = [[ORKFormItem alloc] initWithIdentifier:[@"item2" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color"
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2] ]];
            [items addObject:item2];
            
            ORKFormItem *item3 = [[ORKFormItem alloc] initWithIdentifier:[@"item3" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color"
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3] ]];
            [items addObject:item3];
            
            ORKFormItem *item6 = [[ORKFormItem alloc] initWithIdentifier:[@"item4" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color"
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3, option4, option5, option6] ]];
            [items addObject:item6];
        }
        
        [step setFormItems:items];
        [steps addObject:step];
        
        for (NSNumber *dimension in @[@(360), @(60), @(20)]) {
            CGSize size1 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.x, dimension.floatValue * ratio.CGPointValue.y);
            CGSize size2 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.y, dimension.floatValue * ratio.CGPointValue.x);
            
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                       text:@"Red\nRed\nRed\nRed" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                       text:@"Orange" value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                       text:@"Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow" value:@"yellow"];
            ORKImageChoice *option4 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                       text:@"Green" value:@"green"];
            ORKImageChoice *option5 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                       text:@"Blue" value:@"blue"];
            ORKImageChoice *option6 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                       text:@"Cyan" value:@"cyanColor"];
            
            ORKQuestionStep *step1 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color1_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Image Choice"
                                                                        question:@"Pick a color"
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1] ]];
            [steps addObject:step1];
            
            ORKQuestionStep *step2 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color2_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Image Choice"
                                                                        question:@"Pick a color"
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2] ]];
            [steps addObject:step2];
            
            ORKQuestionStep *step3 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color3_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Image Choice"
                                                                        question:@"Pick a color"
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3] ]];
            [steps addObject:step3];
            
            ORKQuestionStep *step6 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color6_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Image Choice"
                                                                        question:@"Pick a color"
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3, option4, option5, option6]]];
            [steps addObject:step6];
        }
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"end"];
        step.title = @"Image Choices End";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

- (id<ORKTask>)makeLocationTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Location Survey";
    [steps addObject:step1];
    
    // Location question with current location observing on
    ORKQuestionStep *step2 = [[ORKQuestionStep alloc] initWithIdentifier:@"step2"];
    step2.title = @"Location Survey";
    step2.text = @"Where are you right now?";
    step2.answerFormat = [[ORKLocationAnswerFormat alloc] init];
    [steps addObject:step2];
    
    // Location question with current location observing off
    ORKQuestionStep *step3 = [[ORKQuestionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Location Survey";
    step3.text = @"Where is your home?";
    ORKLocationAnswerFormat *locationAnswerFormat  = [[ORKLocationAnswerFormat alloc] init];
    locationAnswerFormat.useCurrentLocation= NO;
    step3.answerFormat = locationAnswerFormat;
    [steps addObject:step3];
    
    ORKCompletionStep *step4 = [[ORKCompletionStep alloc] initWithIdentifier:@"step4"];
    step4.title = @"Location Survey";
    step4.text = @"Survey Complete";
    [steps addObject:step4];
    
    ORKOrderedTask *locationTask = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return locationTask;
}

/*
 This task is used to test various uses of discrete and continuous, horizontal and vertical valued sliders.
 */
- (id<ORKTask>)makeScaleTaskWithIdentifier:(NSString *)identifier {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        /*
         Continuous scale with two decimal places.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:NSIntegerMax
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:NO
                                                                                                  maximumValueDescription:nil
                                                                                                  minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale1"
                                                                      title:@"Scale"
                                                                   question:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale, no default.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:300
                                                                                         minimumValue:100
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:50
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale2"
                                                                      title:@"Scale"
                                                                      question:@"How much money do you need?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale, with a default.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:5
                                                                                                 step:1
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale3"
                                                                      title:@"Scale"
                                                                      question:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale, with a default that is not on a step boundary.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:300
                                                                                         minimumValue:100
                                                                                         defaultValue:174
                                                                                                 step:50
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale4"
                                                                      title:@"Scale"
                                                                      question:@"How much money do you need?"
                                                                     answer:scaleAnswerFormat];
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
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale5"
                                                                      title:@"Scale"
                                                                      question:@"On a scale of 1 to 10, what is your mood?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical discrete scale, with a default on a step boundary.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:5
                                                                                                 step:1
                                                                                             vertical:YES
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale6"
                                                                      title:@"Scale"
                                                                   question:@"How was your mood yesterday?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical discrete scale, with min and max labels.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:1
                                                                                             vertical:YES
                                                                              maximumValueDescription:@"A lot"
                                                                              minimumValueDescription:@"Not at all"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale7"
                                                                      title:@"Scale"
                                                                   question:@"On a scale of 1 to 10, what is your mood?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical continuous scale, with min and max labels.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:99
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:@"High value"
                                                                                                  minimumValueDescription:@"Low value"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale8"
                                                                      title:@"Scale"
                                                                   question:@"How would you measure your mood improvement?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical discrete scale, with min and max labels.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:1
                                                                                             vertical:NO
                                                                              maximumValueDescription:@"A lot"
                                                                              minimumValueDescription:@"Not at all"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale9"
                                                                      title:@"Scale"
                                                                   question:@"On a scale of 1 to 10, what is your mood?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical continuous scale, with min and max labels.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:99
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:NO
                                                                                                  maximumValueDescription:@"High value"
                                                                                                  minimumValueDescription:@"Low value"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale10"
                                                                      title:@"Scale"
                                                                   question:@"How would you measure your mood improvement?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical continuous scale with three decimal places, a default, and a format style.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:1.0
                                                                                                             minimumValue:0.0
                                                                                                             defaultValue:0.8725
                                                                                                    maximumFractionDigits:0
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:nil
                                                                                                  minimumValueDescription:nil];
        
        scaleAnswerFormat.numberStyle = ORKNumberFormattingStylePercent;
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale11"
                                                                      title:@"Scale"
                                                                   question:@"How much has your mood improved?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Continuous scale with images.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:NSIntegerMax
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:@"Hot"
                                                                                                  minimumValueDescription:@"Warm"];
        
        scaleAnswerFormat.minimumImage = [self imageWithColor:[UIColor yellowColor] size:CGSizeMake(30, 30) border:NO];
        scaleAnswerFormat.maximumImage = [self imageWithColor:[UIColor redColor] size:CGSizeMake(30, 30) border:NO];
        scaleAnswerFormat.minimumImage.accessibilityHint = @"A yellow colored square to represent warmness.";
        scaleAnswerFormat.maximumImage.accessibilityHint = @"A red colored square to represent hot.";
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale12"
                                                                      title:@"Scale"
                                                                   question:@"On a scale of 1 to 10, how warm do you feel?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale with images.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:1
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        scaleAnswerFormat.minimumImage = [self imageWithColor:[UIColor yellowColor] size:CGSizeMake(30, 30) border:NO];
        scaleAnswerFormat.maximumImage = [self imageWithColor:[UIColor redColor] size:CGSizeMake(30, 30) border:NO];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale13"
                                                                      title:@"Scale"
                                                                   question:@"On a scale of 1 to 10, how warm do you feel?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        ORKTextChoice *textChoice1 = [ORKTextChoice choiceWithText:@"Poor" value:@(1)];
        ORKTextChoice *textChoice2 = [ORKTextChoice choiceWithText:@"Fair" value:@(2)];
        ORKTextChoice *textChoice3 = [ORKTextChoice choiceWithText:@"Good" value:@(3)];
        ORKTextChoice *textChoice4 = [ORKTextChoice choiceWithText:@"Above Average" value:@(4)];
        ORKTextChoice *textChoice5 = [ORKTextChoice choiceWithText:@"Excellent" value:@(5)];
        
        NSArray *textChoices = @[textChoice1, textChoice2, textChoice3, textChoice4, textChoice5];
        
        ORKTextScaleAnswerFormat *scaleAnswerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices
                                                                                               defaultIndex:3
                                                                                                   vertical:NO];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale14"
                                                                      title:@"Scale"
                                                                   question:@"How are you feeling today?"
                                                                     answer:scaleAnswerFormat];
        
        [steps addObject:step];
    }
    
    {
        ORKTextChoice *textChoice1 = [ORKTextChoice choiceWithText:@"Poor" value:@(1)];
        ORKTextChoice *textChoice2 = [ORKTextChoice choiceWithText:@"Fair" value:@(2)];
        ORKTextChoice *textChoice3 = [ORKTextChoice choiceWithText:@"Good" value:@(3)];
        ORKTextChoice *textChoice4 = [ORKTextChoice choiceWithText:@"Above Average" value:@(4)];
        ORKTextChoice *textChoice5 = [ORKTextChoice choiceWithText:@"Excellent" value:@(5)];
        
        NSArray *textChoices = @[textChoice1, textChoice2, textChoice3, textChoice4, textChoice5];
        
        ORKTextScaleAnswerFormat *scaleAnswerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices
                                                                                               defaultIndex:NSIntegerMax
                                                                                                   vertical:YES];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale15"
                                                                      title:@"Scale"
                                                                   question:@"How are you feeling today?"
                                                                     answer:scaleAnswerFormat];
        
        [steps addObject:step];
    }
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
    
}

- (id<ORKTask>)makeScaleColorGradientTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = (ORKOrderedTask *)[self makeScaleTaskWithIdentifier:identifier];
    
    for (ORKQuestionStep *step in task.steps) {
        if ([step isKindOfClass:[ORKQuestionStep class]]) {
            ORKAnswerFormat *answerFormat  = step.answerFormat;
            if ([answerFormat respondsToSelector:@selector(setGradientColors:)]) {
                [answerFormat performSelector:@selector(setGradientColors:) withObject:@[[UIColor redColor],
                                                                                         [UIColor greenColor],
                                                                                         [UIColor greenColor],
                                                                                         [UIColor yellowColor],
                                                                                         [UIColor yellowColor]]];
                [answerFormat performSelector:@selector(setGradientLocations:) withObject:@[@0.2, @0.2, @0.7, @0.7, @0.8]];
            }
        }
    }
    return task;
}

/*
 The selection survey task is just a collection of various styles of survey questions.
 */
- (id<ORKTask>)makeSelectionSurveyTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
        step.title = @"Selection Survey";
        [steps addObject:step];
    }
    
    {
        /*
         A numeric question requiring integer answers in a fixed range, with no default.
         */
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step2"
                                                                      title:@"Selection Survey"
                                                                   question:@"How old are you?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A boolean question.
         */
        ORKBooleanAnswerFormat *format = [ORKBooleanAnswerFormat new];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step3"
                                                                      title:@"Selection Survey"
                                                                   question:@"Do you consent to a background check?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A custom boolean question.
         */
        ORKBooleanAnswerFormat *format = [ORKAnswerFormat booleanAnswerFormatWithYesString:@"Agree" noString:@"Disagree"];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step4"
                                                                      title:@"Selection Survey"
                                                                   question:@"Do you agree to proceed to the background check questions?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A single-choice question presented in the tableview format.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Less than seven"
                                                                             value:@(7)],
                                                     [ORKTextChoice choiceWithText:@"Between seven and eight"
                                                                             value:@(8)],
                                                     [ORKTextChoice choiceWithText:@"More than eight"
                                                                             value:@(9)]
                                                     ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step5"
                                                                      title:@"Selection Survey"
                                                                   question:@"How many hours did you sleep last night?"
                                                                     answer:answerFormat];
        
        step.optional = NO;
        [steps addObject:step];
    }
    
    {
        /*
         A multiple-choice question presented in the tableview format.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Cough"
                                                                             value:@"cough"],
                                                     [ORKTextChoice choiceWithText:@"Fever"
                                                                             value:@"fever"],
                                                     [ORKTextChoice choiceWithText:@"Headaches"
                                                                             value:@"headache"],
                                                     [ORKTextChoice choiceWithText:@"None of the above"
                                                                        detailText:nil
                                                                             value:@"none"
                                                                         exclusive:YES]
                                                     ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step6"
                                                                      title:@"Selection Survey"
                                                                   question:@"Which symptoms do you have?"
                                                                     answer:answerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         A multiple-choice question with text choices that have detail text.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Cough"
                                                                        detailText:@"A cough and/or sore throat"
                                                                             value:@"cough"
                                                                         exclusive:NO],
                                                     [ORKTextChoice choiceWithText:@"Fever"
                                                                        detailText:@"A 100F or higher fever or feeling feverish"
                                                                             value:@"fever"
                                                                         exclusive:NO],
                                                     [ORKTextChoice choiceWithText:@"Headaches"
                                                                        detailText:@"Headaches and/or body aches"
                                                                             value:@"headache"
                                                                         exclusive:NO]
                                                     ]];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step7"
                                                                      title:@"Selection Survey"
                                                                   question:@"Which symptoms do you have?"
                                                                     answer:answerFormat];
        
        [steps addObject:step];
    }
    
    {
        /*
         A text question with the default multiple-line text entry.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step8"
                                                                      title:@"Selection Survey"
                                                                   question:@"How did you feel last night?"
                                                                     answer:[ORKAnswerFormat textAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        /*
         A text question with single-line text entry, with autocapitalization on
         for words, and autocorrection, and spellchecking turned off.
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormat];
        format.multipleLines = NO;
        format.autocapitalizationType = UITextAutocapitalizationTypeWords;
        format.autocorrectionType = UITextAutocorrectionTypeNo;
        format.spellCheckingType = UITextSpellCheckingTypeNo;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step9"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your name?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A text question with a length limit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step10"
                                                                      title:@"Selection Survey"
                                                                   question:@"How did you feel last night?"
                                                                     answer:[ORKTextAnswerFormat textAnswerFormatWithMaximumLength:20]];
        [steps addObject:step];
    }
    
    {
        /*
         An email question with single-line text entry.
         */
        ORKEmailAnswerFormat *format = [ORKAnswerFormat emailAnswerFormat];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step11"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your email?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A text question demos secureTextEntry feature
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:10];
        format.secureTextEntry = YES;
        format.multipleLines = NO;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step12"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your passcode?"
                                                                     answer:format];
        step.placeholder = @"Tap your passcode here";
        [steps addObject:step];
    }
    
    {
        /*
         A text question with single-line text entry and a length limit.
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:20];
        format.multipleLines = NO;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step13"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your name?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A single-select value-picker question. Rather than seeing the items in a tableview,
         the user sees them in a picker wheel. This is suitable where the list
         of items can be long, and the text describing the options can be kept short.
         */
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:
                                                    @[
                                                      [ORKTextChoice choiceWithText:@"Cough"
                                                                              value:@"cough"],
                                                      [ORKTextChoice choiceWithText:@"Fever"
                                                                              value:@"fever"],
                                                      [ORKTextChoice choiceWithText:@"Headaches"
                                                                              value:@"headache"]
                                                      ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step14"
                                                                      title:@"Selection Survey"
                                                                   question:@"Select a symptom"
                                                                     answer:answerFormat];
        
        [steps addObject:step];
    }
    
    {
        /*
         A multiple component value-picker question.
         */
        ORKValuePickerAnswerFormat *colorFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Red"
                                                                             value:@"red"],
                                                     [ORKTextChoice choiceWithText:@"Blue"
                                                                             value:@"blue"],
                                                     [ORKTextChoice choiceWithText:@"Green"
                                                                             value:@"green"]
                                                     ]];
        
        ORKValuePickerAnswerFormat *animalFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:
                                                    @[
                                                      [ORKTextChoice choiceWithText:@"Cat"
                                                                              value:@"cat"],
                                                      [ORKTextChoice choiceWithText:@"Dog"
                                                                              value:@"dog"],
                                                      [ORKTextChoice choiceWithText:@"Turtle"
                                                                              value:@"turtle"]
                                                      ]];
        
        ORKMultipleValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat multipleValuePickerAnswerFormatWithValuePickers:
                                                            @[colorFormat, animalFormat]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step15"
                                                                      title:@"Selection Survey"
                                                                   question:@"Select a pet:"
                                                                     answer:answerFormat];
        
        [steps addObject:step];
    }
    
    
    {
        /*
         A multiple component value-picker question.
         */
        ORKValuePickerAnswerFormat *f1 = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:
                                          @[
                                            [ORKTextChoice choiceWithText:@"A"
                                                                    value:@"A"],
                                            [ORKTextChoice choiceWithText:@"B"
                                                                    value:@"B"],
                                            [ORKTextChoice choiceWithText:@"C"
                                                                    value:@"C"]
                                            ]];
        
        ORKValuePickerAnswerFormat *f2 = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:
                                          @[
                                            [ORKTextChoice choiceWithText:@"0"
                                                                    value:@0],
                                            [ORKTextChoice choiceWithText:@"1"
                                                                    value:@1],
                                            [ORKTextChoice choiceWithText:@"2"
                                                                    value:@2]
                                            ]];
        
        ORKMultipleValuePickerAnswerFormat *answerFormat = [[ORKMultipleValuePickerAnswerFormat alloc] initWithValuePickers:@[f1, f2] separator:@"-"];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step16"
                                                                      title:@"Selection Survey"
                                                                   question:@"Select a letter and number code:"
                                                                     answer:answerFormat];
        
        [steps addObject:step];
    }
    
    {
        /*
         A continuous slider question.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step17"
                                                                      title:@"Selection Survey"
                                                                   question:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                     answer:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:10 minimumValue:1 defaultValue:NSIntegerMax maximumFractionDigits:1]];
        [steps addObject:step];
    }
    
    {
        /*
         The same as the previous question, but now using a discrete slider.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step18"
                                                                      title:@"Selection Survey"
                                                                   question:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                     answer:[ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                                                  minimumValue:1
                                                                                                                  defaultValue:NSIntegerMax
                                                                                                                          step:1
                                                                                                                      vertical:NO
                                                                                                       maximumValueDescription:@"High value"
                                                                                                       minimumValueDescription:@"Low value"]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for gender.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step19"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your gender"
                                                                     answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for blood type.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step20"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your blood type?"
                                                                     answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for date of birth.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step21"
                                                                      title:@"Selection Survey"
                                                                   question:@"What is your date of birth?"
                                                                     answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for weight.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step22"
                                                                      title:@"Selection Survey"
                                                                   question:@"How much do you weigh?"
                                                                     answer:[ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                                                                          unit:nil
                                                                                                                                         style:ORKNumericAnswerStyleDecimal]];
        [steps addObject:step];
    }
    
    {
        /*
         A multiple choice question where the items are mis-formatted.
         This question is used for verifying correct layout of the table view
         cells when the content is mixed or very long.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Cough, A cough and/or sore throat, A cough and/or sore throat"
                                                                        detailText:@"A cough and/or sore throat, A cough and/or sore throat, A cough and/or sore throat"
                                                                             value:@"cough"
                                                                         exclusive:NO],
                                                     [ORKTextChoice choiceWithText:@"Fever, A 100F or higher fever or feeling feverish"
                                                                        detailText:nil
                                                                             value:@"fever"
                                                                         exclusive:NO],
                                                     [ORKTextChoice choiceWithText:@""
                                                                        detailText:@"Headaches, Headaches and/or body aches"
                                                                             value:@"headache"
                                                                         exclusive:NO]
                                                     ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"step23"
                                                                      title:@"Selection Survey"
                                                                   question:@"(Misused) Which symptoms do you have?"
                                                                     answer:answerFormat];
        [steps addObject:step];
    }
    
    {
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:@"completion"];
        step.title = @"Survey Complete";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

- (id<ORKTask>)makeVideoCaptureTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    /*
     If implementing an video capture task like this one, remember that people will
     take your instructions literally. So, be cautious. Make sure your template image
     is high contrast and very visible against a variety of backgrounds.
     */
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"begin"];
        step.title = @"Hands";
        step.image = [[UIImage imageNamed:@"hands_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"In this step we will capture 5 second videos of both of your hands";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"right1"];
        step.title = @"Right Hand";
        step.image = [[UIImage imageNamed:@"right_hand_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Let's start by capturing a video of your right hand";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"right2"];
        step.title = @"Right Hand";
        step.image = [[UIImage imageNamed:@"right_hand_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Align your right hand with the on-screen outline and record the video.  Be sure to place your hand over a contrasting background.  You can re-capture the video as many times as you need.";
        [steps addObject:step];
    }
    
    {
        ORKVideoCaptureStep *step = [[ORKVideoCaptureStep alloc] initWithIdentifier:@"right3"];
        step.templateImage = [UIImage imageNamed:@"right_hand_outline_big"];
        step.templateImageInsets = UIEdgeInsetsMake(0.05, 0.05, 0.05, 0.05);
        step.duration = @5.0;
        step.accessibilityInstructions = @"Extend your right hand, palm side down, one foot in front of your device. Tap the Start Recording button, or two-finger double tap the preview to capture the video";
        step.accessibilityHint = @"Records the video visible in the preview";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"left1"];
        step.title = @"Left Hand";
        step.image = [[UIImage imageNamed:@"left_hand_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Now let's capture a video of your left hand";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"left2"];
        step.title = @"Left Hand";
        step.image = [[UIImage imageNamed:@"left_hand_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Align your left hand with the on-screen outline and record the video.  Be sure to place your hand over a contrasting background.  You can re-capture the video as many times as you need.";
        [steps addObject:step];
    }
    
    {
        ORKVideoCaptureStep *step = [[ORKVideoCaptureStep alloc] initWithIdentifier:@"left3"];
        step.templateImage = [UIImage imageNamed:@"left_hand_outline_big"];
        step.templateImageInsets = UIEdgeInsetsMake(0.05, 0.05, 0.05, 0.05);
        step.duration = @5.0;
        step.accessibilityInstructions = @"Extend your left hand, palm side down, one foot in front of your device. Tap the Start Recording button, or two-finger double tap the preview to capture the video";
        step.accessibilityHint = @"Records the video visible in the preview";
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"end"];
        step.title = @"Complete";
        step.detailText = @"Hand video capture complete";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

@end
