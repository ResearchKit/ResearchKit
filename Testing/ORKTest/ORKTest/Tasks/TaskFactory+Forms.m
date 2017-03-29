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


#import "TaskFactory+Forms.h"

@import ResearchKit;


@implementation TaskFactory (Forms)

- (id<ORKTask>)makeConfirmationFormItemTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"confirmationForm.step1"];
    step1.title = @"Confirmation Form Items Survey";
    [steps addObject:step1];
    
    // Create a step for entering password with confirmation
    ORKFormStep *step2 = [[ORKFormStep alloc] initWithIdentifier:@"confirmationForm.step2" title:@"Password" text:nil];
    [steps addObject:step2];
    
    {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.secureTextEntry = YES;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"password"
                                                               text:@"Password"
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = @"Enter password";
        
        ORKFormItem *confirmationItem = [item confirmationAnswerFormItemWithIdentifier:@"password.confirmation"
                                                                                  text:@"Confirm"
                                                                          errorMessage:@"Passwords do not match"];
        confirmationItem.placeholder = @"Enter password again";
        
        step2.formItems = @[item, confirmationItem];
    }
    
    // Create a step for entering participant id
    ORKFormStep *step3 = [[ORKFormStep alloc] initWithIdentifier:@"confirmationForm.step3" title:@"Participant ID" text:nil];
    [steps addObject:step3];
    
    {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"participantID"
                                                               text:@"Participant ID"
                                                       answerFormat:answerFormat
                                                           optional:YES];
        item.placeholder = @"Enter Participant ID";
        
        ORKFormItem *confirmationItem = [item confirmationAnswerFormItemWithIdentifier:@"participantID.confirmation"
                                                                                  text:@"Confirm"
                                                                          errorMessage:@"IDs do not match"];
        confirmationItem.placeholder = @"Enter ID again";
        
        step3.formItems = @[item, confirmationItem];
    }
    
    ORKCompletionStep *step4 = [[ORKCompletionStep alloc] initWithIdentifier:@"confirmationForm.lastStep"];
    step4.title = @"Survey Complete";
    [steps addObject:step4];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:ConfirmationFormItemTaskIdentifier steps:steps];
}

/*
 The mini form task is used to test survey forms functionality (`ORKFormStep`).
 */
- (id<ORKTask>)makeMiniFormTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"mini_form_001"];
        step.title = @"Mini Form";
        [steps addObject:step];
    }
    
    {
        /*
         A short form for testing behavior when loading multiple HealthKit
         default values on the same form.
         */
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_000" title:@"Mini Form" text:@"Mini form groups multi-entry in one page"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight1"
                                                                   text:@"Weight"
                                                           answerFormat:
                                 [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                               unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                              style:ORKNumericAnswerStyleDecimal]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight2"
                                                                   text:@"Weight"
                                                           answerFormat:
                                 [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                               unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                              style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight3"
                                                                   text:@"Weight"
                                                           answerFormat:
                                 [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                               unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                              style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Input your body weight here. Really long text.";
            [items addObject:item];
        }
        
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight4"
                                                                   text:@"Weight"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input your body weight here";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        /*
         A long "kitchen-sink" form with all the different types of supported
         answer formats.
         */
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_001" title:@"Mini Form" text:@"Mini form groups multi-entry in one page"];
        NSMutableArray *items = [NSMutableArray new];
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_biologicalSex" text:@"Gender" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Pre1"];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Basic Information"];
            [items addObject:item];
        }
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_bloodType" text:@"Blood Type" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
            item.placeholder = @"Choose a type";
            [items addObject:item];
        }
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_dob" text:@"Date of Birth" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
            item.placeholder = @"DOB";
            [items addObject:item];
        }
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight"
                                                                   text:@"Weight"
                                                           answerFormat:
                                 [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                               unit:nil
                                                                                              style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[ORKBooleanAnswerFormat new]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Which fruit do you like most? Please pick one from below."
                                                           answerFormat:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:@[@"Apple", @"Orange", @"Banana"]
                                                                         ]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                           answerFormat:[ORKAnswerFormat textAnswerFormat]];
            item.placeholder = @"Your message";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                           answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                           answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_005" text:@"Email"
                                                           answerFormat:[ORKAnswerFormat emailAnswerFormat]];
            item.placeholder = @"Enter Email";
            [items addObject:item];
        }
        
        {
            
            NSRegularExpression *validationRegularExpression =
            [NSRegularExpression regularExpressionWithPattern:@"^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
                                                      options:(NSRegularExpressionOptions)0
                                                        error:nil];
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithValidationRegularExpression:validationRegularExpression
                                                                                            invalidMessage:@"Invalid URL: %@"];
            format.multipleLines = NO;
            format.keyboardType = UIKeyboardTypeURL;
            format.autocapitalizationType = UITextAutocapitalizationTypeNone;
            format.autocorrectionType = UITextAutocorrectionTypeNo;
            format.spellCheckingType = UITextSpellCheckingTypeNo;
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_006" text:@"URL"
                                                           answerFormat:format];
            item.placeholder = @"Enter URL";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_007" text:@"Message"
                                                           answerFormat:[ORKAnswerFormat textAnswerFormatWithMaximumLength:20]];
            item.placeholder = @"Your message (limit 20 characters).";
            [items addObject:item];
        }
        
        {
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
            format.secureTextEntry = YES;
            format.multipleLines = NO;
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_008" text:@"Passcode"
                                                           answerFormat:format];
            item.placeholder = @"Enter Passcode";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_height_001" text:@"Height"
                                                           answerFormat:[ORKAnswerFormat heightAnswerFormat]];
            item.placeholder = @"Pick a height (local system)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_height_002" text:@"Height"
                                                           answerFormat:[ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric]];
            item.placeholder = @"Pick a height (metric system)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_height_003" text:@"Height"
                                                           answerFormat:[ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC]];
            item.placeholder = @"Pick a height (imperial system)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_date_001" text:@"Birthdate"
                                                           answerFormat:[ORKAnswerFormat dateAnswerFormat]];
            item.placeholder = @"Pick a date";
            [items addObject:item];
        }
        
        {
            NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-30 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-150 toDate:[NSDate date] options:(NSCalendarOptions)0];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_date_002" text:@"Birthdate"
                                                           answerFormat:[ORKAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                                             minimumDate:minDate
                                                                                                             maximumDate:[NSDate date]
                                                                                                                calendar:nil]];
            item.placeholder = @"Pick a date (with default)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_001" text:@"Today sunset time?"
                                                           answerFormat:[ORKAnswerFormat timeOfDayAnswerFormat]];
            item.placeholder = @"No default time";
            [items addObject:item];
        }
        
        {
            NSDateComponents *defaultDC = [[NSDateComponents alloc] init];
            defaultDC.hour = 14;
            defaultDC.minute = 23;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_002" text:@"Today sunset time?"
                                                           answerFormat:[ORKAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:defaultDC]];
            item.placeholder = @"Default time 14:23";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_dateTime_001" text:@"Next eclipse visible in Cupertino?"
                                                           answerFormat:[ORKAnswerFormat dateTimeAnswerFormat]];
            
            item.placeholder = @"No default date and range";
            [items addObject:item];
        }
        
        {
            
            NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:3 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:0 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_dateTime_002" text:@"Next eclipse visible in Cupertino?"
                                                           answerFormat:[ORKAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate
                                                                                                                 minimumDate:minDate
                                                                                                                 maximumDate:maxDate
                                                                                                                    calendar:nil]];
            
            item.placeholder = @"Default date in 3 days and range(0, 10)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeInterval_001" text:@"Wake up interval"
                                                           answerFormat:[ORKAnswerFormat timeIntervalAnswerFormat]];
            item.placeholder = @"No default Interval and step size";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeInterval_002" text:@"Wake up interval"
                                                           answerFormat:[ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:3]];
            
            item.placeholder = @"Default Interval 300 and step size 3";
            [items addObject:item];
        }
        
        {
            /*
             Testbed for image choice.
             
             In a real application, you would use real images rather than square
             colored boxes.
             */
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:YES]
                                                                       text:@"Red" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:YES]
                                                                       text:nil value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:YES]
                                                                       text:@"Yellow" value:@"yellow"];
            
            ORKFormItem *item3 = [[ORKFormItem alloc] initWithIdentifier:@"fqid_009_3" text:@"What is your favorite color?"
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3]]];
            [items addObject:item3];
        }
        
        {
            // Discrete scale
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_001" text:@"Pick an integer" answerFormat:[[ORKScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:NSIntegerMax step:10]];
            [items addObject:item];
        }
        
        {
            // Discrete scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_002" text:@"Pick an integer" answerFormat:[[ORKScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:20 step:10]];
            [items addObject:item];
        }
        
        {
            // Continuous scale
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_003" text:@"Pick a decimal" answerFormat:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:NSIntegerMax maximumFractionDigits:2]];
            [items addObject:item];
        }
        
        {
            // Continuous scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_004" text:@"Pick a decimal" answerFormat:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:87.34 maximumFractionDigits:2]];
            [items addObject:item];
        }
        
        {
            // Vertical Discrete scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_005" text:@"Pick an integer" answerFormat:[[ORKScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:90 step:10 vertical:YES]];
            [items addObject:item];
        }
        
        {
            // Vertical Continuous scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_006" text:@"Pick a decimal" answerFormat:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:12.75 maximumFractionDigits:2 vertical:YES]];
            [items addObject:item];
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
                                                                                                       vertical:NO];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_007"
                                                                   text:@"How are you feeling today?"
                                                           answerFormat:scaleAnswerFormat];
            [items addObject:item];
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
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_008"
                                                                   text:@"How are you feeling today?"
                                                           answerFormat:scaleAnswerFormat];
            [items addObject:item];
        }
        
        {
            //Location
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fiqd_location" text:@"Pick a location" answerFormat:[ORKAnswerFormat locationAnswerFormat]];
            [items addObject:item];
        }
        
        [step setFormItems:items];
        [steps addObject:step];
    }
    
    {
        
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_002" title:@"Required form step" text:nil];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_001"
                                                               text:@"Value"
                                                       answerFormat:[ORKNumericAnswerFormat valuePickerAnswerFormatWithTextChoices:@[@"1", @"2", @"3"]]];
        item.placeholder = @"Pick a value";
        [step setFormItems:@[item]];
        step.optional = NO;
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Thanks";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:MiniFormTaskIdentifier steps:steps];
    
    return task;
}

/*
 The optional form task is used to test form items' optional functionality (`ORKFormStep`, `ORKFormItem`).
 */
- (id<ORKTask>)makeOptionalFormTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        {
            ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"scale_form_00" title:@"Optional Form Items" text:@"Optional form with a required scale item with a default value"];
            NSMutableArray *items = [NSMutableArray new];
            [steps addObject:step];
            
            {
                ORKScaleAnswerFormat *format = [ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10 minimumValue:1 defaultValue:4 step:1 vertical:YES maximumValueDescription:nil minimumValueDescription:nil];
                ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"scale_form"
                                                                       text:@"Optional scale"
                                                               answerFormat:format];
                item.optional = NO;
                [items addObject:item];
            }
            
            [step setFormItems:items];
        }
        
        
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_000" title:@"Optional Form Items" text:@"Optional form with no required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }
        
        {
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
            format.multipleLines = NO;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_001" title:@"Optional Form Items" text:@"Optional form with some required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }
        
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format
                                                               optional:NO];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]
                                                               optional:NO];
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_002" title:@"Optional Form Items" text:@"Optional form with all items required"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }
        
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format
                                                               optional:NO];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format
                                                               optional:NO];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format
                                                               optional:NO];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]
                                                               optional:NO];
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_003" title:@"Optional Form Items" text:@"Required form with no required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }
        
        {
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:6];
            format.multipleLines = NO;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
        step.optional = NO;
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_004" title:@"Optional Form Items" text:@"Required form with some required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }
        
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.placeholder = @"Input your text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.placeholder = @"Input your text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input your text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.optional = NO;
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
        step.optional = NO;
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_005" title:@"Optional Form Items" text:@"Required form with all items required"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }
        
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.optional = NO;
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
        step.optional = NO;
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:MiniFormTaskIdentifier steps:steps];
    
    return task;
}

@end
