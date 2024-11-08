/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.

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

import ResearchKitActiveTask


enum TaskListRowSteps {
    
    // MARK: - ORKFormStep Examples
    
    static var birthdayExample: ORKFormStep {
        let birthDayQuestionAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: nil, minimumDate: nil, maximumDate: Date(), calendar: nil)
        let birthdayQuestion = NSLocalizedString("When is your birthday?", comment: "")
        
        let birthDayQuestionSectionHeader = ORKFormItem(sectionTitle: birthdayQuestion)
        let birthdayQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.birthdayQuestionFormItem), text: nil, answerFormat: birthDayQuestionAnswerFormat)
        birthdayQuestionFormItem.placeholder = "Select Date"
        let birthdayQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.birthdayQuestion), title: "Questionnaire", text: TaskListRowStrings.exampleDetailText)
        birthdayQuestionFormStep.formItems = [birthDayQuestionSectionHeader, birthdayQuestionFormItem]
        
        return birthdayQuestionFormStep
    }
    
    static var booleanExample: ORKFormStep {
        let booleanQuestionAnswerFormat = ORKBooleanAnswerFormat()
        let question1 = NSLocalizedString("Would you like to subscribe to our newsletter?", comment: "")
        
        let booleanQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.booleanFormItem), text: question1, answerFormat: booleanQuestionAnswerFormat)
        booleanQuestionFormItem.learnMoreItem = self.learnMoreItemExample
        
        let booleanQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.booleanFormStep), title: "Questionnaire", text: TaskListRowStrings.exampleDetailText)
        booleanQuestionFormStep.formItems = [booleanQuestionFormItem]
        
        return booleanQuestionFormStep
    }
    
    static var booleanGenericExample: ORKFormStep {
        let booleanQuestionAnswerFormat = ORKBooleanAnswerFormat()
        
        let booleanQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.booleanFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: booleanQuestionAnswerFormat)
        booleanQuestionFormItem.learnMoreItem = self.learnMoreItemExample
        
        let booleanQuestionFormStep = ORKFormStep(identifier: String(describing: Identifier.booleanFormStep), title: NSLocalizedString("Boolean", comment: ""), text: TaskListRowStrings.exampleDetailText)
        booleanQuestionFormStep.formItems = [booleanQuestionFormItem]
        
        return booleanQuestionFormStep
    }
    
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    static var bloodTypeExample: ORKFormStep {
        let bloodType = HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!
        let bloodTypeAnswerFormat = ORKHealthKitCharacteristicTypeAnswerFormat(characteristicType: bloodType)
        
        let formItemSectionHeader = ORKFormItem(sectionTitle: String(describing: TaskListRowStrings.exampleBloodTypeQuestion))
        let bloodTypeFormItem = ORKFormItem(identifier: String(describing: Identifier.healthQuantityFormItem),
                                            text: nil,
                                            answerFormat: bloodTypeAnswerFormat)
        bloodTypeFormItem.placeholder = String(describing: TaskListRowStrings.exampleTapHereText)
        
        let bloodTypeFormStep = ORKFormStep(identifier: String(describing: Identifier.healthQuantityFormStep2),
                                            title: NSLocalizedString("Blood Type", comment: ""),
                                            text: TaskListRowStrings.exampleDetailText)
        bloodTypeFormStep.formItems = [formItemSectionHeader, bloodTypeFormItem]
        
        return bloodTypeFormStep
    }
#endif
    
    static var continuousScaleWithPercentExample: ORKFormStep {
        // The second step is a scale control that allows continuous movement with a percent formatter.
        let scaleAnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: 1.0,
                                                                minimumValue: 0.0,
                                                                defaultValue: 99.0,
                                                                maximumFractionDigits: 0,
                                                                vertical: false,
                                                                maximumValueDescription: nil,
                                                                minimumValueDescription: nil)
        scaleAnswerFormat.numberStyle = .percent
        
        let scaleFormItem = ORKFormItem(identifier: String(describing: Identifier.scaleFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: scaleAnswerFormat)
        let scaleFormStep = ORKFormStep(identifier: String(describing: Identifier.continuousScaleFormStep), title: NSLocalizedString("Scale", comment: ""), text: NSLocalizedString("Continuous Scale", comment: ""))
        scaleFormStep.formItems = [scaleFormItem]
        
        return scaleFormStep
    }
    
    static var continuousVerticalScaleExample: ORKFormStep {
        // The fourth step is a vertical scale control that allows continuous movement.
        let scaleAnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: 5.0,
                                                                minimumValue: 1.0,
                                                                defaultValue: 99.0,
                                                                maximumFractionDigits: 2,
                                                                vertical: true,
                                                                maximumValueDescription: TaskListRowStrings.exampleHighValueText,
                                                                minimumValueDescription: TaskListRowStrings.exampleLowValueText)
        
        let scaleFormItem = ORKFormItem(identifier: String(describing: Identifier.scaleFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: scaleAnswerFormat)
        let scaleFormStep = ORKFormStep(identifier: String(describing: Identifier.continuousVerticalScaleFormStep), title: NSLocalizedString("Scale", comment: ""), text: NSLocalizedString("Continuous Vertical Scale", comment: ""))
        scaleFormStep.formItems = [scaleFormItem]
        
        return scaleFormStep
    }
    
    static var decimalExample: ORKFormStep {
        let localizedQuestionStep1AnswerFormatUnit = NSLocalizedString("Your unit", comment: "")
        let decimalAnswerFormat = ORKAnswerFormat.decimalAnswerFormat(withUnit: localizedQuestionStep1AnswerFormatUnit)
        
        let sectionHeaderFormItem = ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
        let decimalFormItem = ORKFormItem(identifier: String(describing: Identifier.numericFormItem),
                                          text: nil,
                                          answerFormat: decimalAnswerFormat)
        decimalFormItem.placeholder = "Enter value"
        
        let decimalFormStep = ORKFormStep(identifier: String(describing: Identifier.numericQuestionFormStep),
                                          title: NSLocalizedString("Numeric", comment: ""),
                                          text: TaskListRowStrings.exampleDetailText)
        decimalFormStep.formItems = [sectionHeaderFormItem, decimalFormItem]
        
        return decimalFormStep
    }
    
    static var decimalNoUnitExample: ORKFormStep {
        let decimalAnswerFormat = ORKAnswerFormat.decimalAnswerFormat(withUnit: nil)
        
        let sectionHeaderFormItem = ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
        let decimalFormItem = ORKFormItem(identifier: String(describing: Identifier.numericFormItem),
                                          text: nil,
                                          answerFormat: decimalAnswerFormat)
        decimalFormItem.placeholder = "Enter value"
        
        let decimalFormStep = ORKFormStep(identifier: String(describing: Identifier.numericNoUnitQuestionFormStep),
                                          title:NSLocalizedString("Numeric", comment: ""),
                                          text: TaskListRowStrings.exampleDetailText)
        decimalFormStep.formItems = [sectionHeaderFormItem, decimalFormItem]
        
        return decimalFormStep
    }
    
    static var decimalWithDisplayUnitExample: ORKFormStep {
        let decimalAnswerFormat = ORKNumericAnswerFormat(style: .decimal,
                                                         unit: "weeks",
                                                         displayUnit: "semanas",
                                                         minimum: nil,
                                                         maximum: nil,
                                                         maximumFractionDigits: 1)
        
        let sectionHeaderFormItem = ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
        let decimalFormItem = ORKFormItem(identifier: String(describing: Identifier.numericFormItem),
                                          text: nil,
                                          answerFormat: decimalAnswerFormat)
        decimalFormItem.placeholder = "Enter value"
        
        let decimalFormStep = ORKFormStep(identifier: String(describing: Identifier.numericDisplayUnitQuestionFormStep),
                                          title: NSLocalizedString("Numeric with Display Unit", comment: ""),
                                          text: TaskListRowStrings.exampleDetailText)
        decimalFormStep.formItems = [sectionHeaderFormItem, decimalFormItem]
        
        return decimalFormStep
    }
    
    static var emailExample: ORKFormStep {
        let emailDomainRegularExpressionPattern =  "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$"
        let emailDomainRegularExpression = try? NSRegularExpression(pattern: emailDomainRegularExpressionPattern)
        let emailAnswerFormatDomain = ORKAnswerFormat.textAnswerFormat(withValidationRegularExpression: emailDomainRegularExpression!, invalidMessage: "Invalid Email: %@")
        
        let sectionHeaderFormItem = ORKFormItem(sectionTitle: NSLocalizedString("Email", comment: ""))
        let emailFormItem = ORKFormItem(identifier: String(describing: Identifier.validatedTextFormItem), text: nil, answerFormat: emailAnswerFormatDomain)
        emailFormItem.placeholder = "Enter email"
        
        let emailFormStep = ORKFormStep(identifier: String(describing: Identifier.validatedTextFormStepEmail), title: NSLocalizedString("Validated Text", comment: ""), text: TaskListRowStrings.exampleDetailText)
        emailFormStep.formItems = [sectionHeaderFormItem, emailFormItem]
        
        return emailFormStep
    }
    
    static var groupFormExample: ORKFormStep {
        let step = ORKFormStep(identifier: String(describing: Identifier.groupedFormStep),
                               title: NSLocalizedString("Form Step", comment: ""),
                               text: TaskListRowStrings.exampleDetailText)
        
        //Start of first section
        let learnMoreInstructionStep01 = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep01.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep01.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem01 = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep01)
        let section01 = ORKFormItem(sectionTitle: NSLocalizedString("Section title", comment: ""), detailText: NSLocalizedString("Section detail text", comment: ""), learnMoreItem: learnMoreItem01, showsProgress: true)
        
        // A first field, for entering an integer.
        let formItem01Text = NSLocalizedString("Field01", comment: "")
        let formItem01 = ORKFormItem(identifier: String(describing: Identifier.formItem01), text: formItem01Text, answerFormat: ORKAnswerFormat.integerAnswerFormat(withUnit: nil))
        formItem01.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        // A second field, for entering a time interval.
        let formItem02Text = NSLocalizedString("Field02", comment: "")
        let formItem02 = ORKFormItem(identifier: String(describing: Identifier.formItem02), text: formItem02Text, answerFormat: ORKTimeIntervalAnswerFormat())
        formItem02.placeholder = NSLocalizedString("Your placeholder here", comment: "")
        
        let textOnlySection = ORKFormItem(sectionTitle: NSLocalizedString("Text Only Section", comment: ""), detailText: NSLocalizedString("Text section text", comment: ""), learnMoreItem: learnMoreItem01, showsProgress: true)
        let textOnlyFormItemA = ORKFormItem(identifier: "text-section-text-item-a", text: "Text Field A", answerFormat: ORKTextAnswerFormat())
        let textOnlyFormItemB = ORKFormItem(identifier: "text-section-text-item-b", text: "Text Field B", answerFormat: ORKTimeIntervalAnswerFormat())
        
        let sesAnswerFormat = ORKSESAnswerFormat(topRungText: "Best Off", bottomRungText: "Worst Off")
        let sesFormItem = ORKFormItem(identifier: "sesIdentifier", text: "Select where you are on the socioeconomic ladder.", answerFormat: sesAnswerFormat)
        
        //Start of section for scale question
        let formItem03Text = TaskListRowStrings.exampleQuestionText
        let scaleAnswerFormat = ORKContinuousScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 0.0, maximumFractionDigits: 1)
        let formItem03 = ORKFormItem(identifier: String(describing: Identifier.formItem03), text: formItem03Text, detailText: nil, learnMoreItem: nil, showsProgress: true, answerFormat: scaleAnswerFormat, tagText: nil, optional: true)
        
        step.formItems = [
            section01,
            formItem01,
            formItem02,
            textOnlySection,
            textOnlyFormItemA,
            textOnlyFormItemB,
            formItem03,
            sesFormItem
        ]
        
        return step
    }
    
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    static var heartRateExample: ORKFormStep {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let heartRateAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: heartRateType,
                                                                         unit: nil,
                                                                         style: .decimal)
        
        let formItemSectionHeader = ORKFormItem(sectionTitle: String(describing: TaskListRowStrings.exampleHeartRateQuestion))
        let heartRateFormItem = ORKFormItem(identifier: String(describing: Identifier.healthQuantityFormItem),
                                            text: nil,
                                            answerFormat:heartRateAnswerFormat)
        
        let heartRateFormStep = ORKFormStep(identifier: String(describing: Identifier.healthQuantityFormStep1),
                                            title: NSLocalizedString("Heart Rate", comment: ""),
                                            text: TaskListRowStrings.exampleDetailText)
        heartRateFormStep.formItems = [formItemSectionHeader, heartRateFormItem]
        
        return heartRateFormStep
    }
#endif
    
    static var heightExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep1)
        let heightAnswerFormat = ORKAnswerFormat.heightAnswerFormat()
        let title = NSLocalizedString("Height", comment: "")
        let stepText =  NSLocalizedString("Local system", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    static var heightHealthKitExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep4)
        let heightAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!, unit: HKUnit.meterUnit(with: .centi), style: .decimal)
        let title = NSLocalizedString("Height", comment: "")
        let stepText = NSLocalizedString("HealthKit, height", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
#endif
    
    static var heightMetricSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep2)
        let heightAnswerFormat = ORKAnswerFormat.heightAnswerFormat(with: .metric)
        let title = NSLocalizedString("Height", comment: "")
        let stepText = NSLocalizedString("Metric system", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var heightUSCSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.heightQuestionFormStep3)
        let heightAnswerFormat = ORKAnswerFormat.heightAnswerFormat(with: .USC)
        let title = NSLocalizedString("Height", comment: "")
        let stepText = NSLocalizedString("USC system", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:heightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var imageChoiceExample: ORKFormStep {
        let imageChoices = self.imageChoicesExample
        let imageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices)
        
        let imageChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.imageChoiceFormItem),
                                              text: TaskListRowStrings.exampleQuestionText,
                                              answerFormat: imageChoiceAnswerFormat)
        
        let imageChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.imageChoiceFormStep1),
                                              title: NSLocalizedString("Image Choice", comment: ""),
                                              text: TaskListRowStrings.exampleDetailText)
        imageChoiceFormStep.formItems = [imageChoiceFormItem]
        
        return imageChoiceFormStep
    }
    
    static var imageChoiceVerticalExample: ORKFormStep {
        let imageChoices = self.imageChoicesExample
        let imageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices, style: .multipleChoice, vertical: true)
    
        let imageChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.imageChoiceFormItem),
                                              text: TaskListRowStrings.exampleQuestionText,
                                              answerFormat: imageChoiceAnswerFormat)
        
        let imageChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.imageChoiceFormStep2),
                                              title: NSLocalizedString("Image Choice", comment: ""),
                                              text: TaskListRowStrings.exampleDetailText)
        imageChoiceFormStep.formItems = [imageChoiceFormItem]
        
        return imageChoiceFormStep
    }
    
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
    static var locationExample: ORKFormStep {
        let locationAnswerFormat = ORKLocationAnswerFormat()
        let locationFormItem = ORKFormItem(identifier: String(describing: Identifier.locationQuestionFormItem),
                                           text: TaskListRowStrings.exampleQuestionText,
                                           answerFormat: locationAnswerFormat)
        
        let locationFormStep = ORKFormStep(identifier: String(describing: Identifier.locationQuestionFormStep),
                                           title: NSLocalizedString("Location", comment: ""),
                                           text: TaskListRowStrings.exampleDetailText)
        locationFormStep.formItems = [locationFormItem]
        
        return locationFormStep
    }
#endif
    
    static var textAnswerExample: ORKFormStep {
        let textAnswerFormat = ORKTextAnswerFormat()
        
        let sectionHeaderFormItem = ORKFormItem(sectionTitle: "What is your name?")
        let textAnswerFormItem = ORKFormItem(identifier: String(describing: Identifier.textQuestionFormItem),
                                             text:  "What is your name?",
                                             answerFormat: textAnswerFormat)
        
        let textAnswerFormStep = ORKFormStep(identifier: String(describing: Identifier.textQuestionFormStep),
                                             title: TaskListRowStrings.exampleQuestionText,
                                             text: TaskListRowStrings.exampleDetailText)
        textAnswerFormStep.formItems = [sectionHeaderFormItem, textAnswerFormItem]
        
        return textAnswerFormStep
    }
    
    static var textChoiceExample: ORKFormStep {
        let textChoices: [ORKTextChoice] = [
            ORKTextChoice(text: "choice 1", detailText: "detail 1", value: 1 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 2", detailText: "detail 2", value: 2 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 3", detailText: "detail 3", value: 3 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 4", detailText: "detail 4", value: 4 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 5", detailText: "detail 5", value: 5 as NSNumber, exclusive: false),
            ORKTextChoice(text: "choice 6", detailText: "detail 6", value: 6 as NSNumber, exclusive: false),
            ORKTextChoiceOther.choice(withText: "choice 7", detailText: "detail 7", value: "choice 7" as NSString, exclusive: true, textViewPlaceholderText: "enter additional information")
        ]
        
        let textChoiceQuestion = NSLocalizedString("Select an option below.", comment: "")
        let textChoiceAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let textChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.textChoiceFormItem), text: textChoiceQuestion, answerFormat: textChoiceAnswerFormat)
        textChoiceFormItem.learnMoreItem = self.learnMoreItemExample
        let textChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.textChoiceFormStep), title: "Questionnaire", text: TaskListRowStrings.exampleDetailText)
        textChoiceFormStep.formItems = [textChoiceFormItem]
        
        return textChoiceFormStep
    }
    
    static var textChoiceImagesExample: ORKFormStep {
        let textChoiceOneText = NSLocalizedString("Choice 1", comment: "")
        let textChoiceTwoText = NSLocalizedString("Choice 2", comment: "")
        let textChoiceThreeText = NSLocalizedString("Choice 3", comment: "")
        
        // The text to display can be separate from the value coded for each choice:
        let textChoices = [
            ORKTextChoice(text: textChoiceOneText, image: UIImage(named: "Face")!, value: "tap 1" as NSString),
            ORKTextChoice(text: textChoiceTwoText, image: UIImage(named: "Face")!, value: "tap 2" as NSString),
            ORKTextChoice(text: textChoiceThreeText, image: UIImage(named: "Face")!, value: "tap 3" as NSString)
        ]
        
        let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
        
        let textChoiceQuestion = NSLocalizedString("Select an option below.", comment: "")
        let textChoiceFormItem = ORKFormItem(identifier: String(describing: Identifier.textChoiceFormItem), text: textChoiceQuestion, answerFormat: textChoiceAnswerFormat)
        
        let textChoiceFormStep = ORKFormStep(identifier: String(describing: Identifier.textChoiceFormStep), title: NSLocalizedString("Text Choice", comment: ""), text: TaskListRowStrings.exampleDetailText)
        textChoiceFormStep.formItems = [textChoiceFormItem]
        
        return textChoiceFormStep
    }
    
    static var textMultiLineAnswerExample: ORKFormStep {
        let textAnswerFormat = ORKTextAnswerFormat()
        textAnswerFormat.multipleLines = true
        textAnswerFormat.maximumLength = 280
        
        let textAnswerFormItem = ORKFormItem(identifier: String(describing: Identifier.textQuestionFormItem),
                                             text: "What is your name?",
                                             answerFormat: textAnswerFormat)
        
        let textAnswerFormStep = ORKFormStep(identifier: String(describing: Identifier.textQuestionFormStep),
                                             title: NSLocalizedString("Text", comment: ""),
                                             text: TaskListRowStrings.exampleDetailText)
        textAnswerFormStep.formItems = [textAnswerFormItem]
        
        return textAnswerFormStep
    }
    
    static var timeIntervalExample: ORKFormStep {
        /*
            The time interval answer format is constrained to entering a time
            less than 24 hours and in steps of minutes. For times that don't fit
            these restrictions, use another mode of data entry.
        */
        let timeIntervalAnswerFormat = ORKAnswerFormat.timeIntervalAnswerFormat()
        
        let formItemSectionHeader = self.formItemSectionHeaderExample
        let timeIntervalFormItem = ORKFormItem(identifier: String(describing: Identifier.timeIntervalFormItem), text: nil, answerFormat: timeIntervalAnswerFormat)
        timeIntervalFormItem.placeholder = "Select interval"
        
        let timeIntervalFormStep = ORKFormStep(identifier: String(describing: Identifier.timeIntervalFormStep), title: NSLocalizedString("Time Interval", comment: ""), text: TaskListRowStrings.exampleDetailText)
        timeIntervalFormStep.formItems = [formItemSectionHeader, timeIntervalFormItem]
        
        return timeIntervalFormStep
    }
    
    static var timeOfDayExample: ORKFormStep {
        /*
        Because we don't specify a default, the picker will default to the
        time the step is presented. For questions like "What time do you have
        breakfast?", it would make sense to set the default on the answer
        format.
        */
        let timeOfDayAnswerFormat = ORKAnswerFormat.timeOfDayAnswerFormat()
        
        let formItemSectionHeader = self.formItemSectionHeaderExample
        let timeOfDayFormItem = ORKFormItem(identifier: String(describing: Identifier.timeOfDayFormItem), text: nil, answerFormat: timeOfDayAnswerFormat)
        timeOfDayFormItem.placeholder = "Select time of day"
        
        let timeIntervalFormStep = ORKFormStep(identifier: String(describing: Identifier.timeOfDayQuestionFormStep), title: NSLocalizedString("Time", comment: ""), text: TaskListRowStrings.exampleDetailText)
        timeIntervalFormStep.formItems = [formItemSectionHeader, timeOfDayFormItem]
        
        return timeIntervalFormStep
    }
    
    static var scaleExample: ORKFormStep {
        // The first step is a scale control with 10 discrete ticks.
        let scaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                      minimumValue: 1,
                                                      defaultValue: NSIntegerMax,
                                                      step: 1,
                                                      vertical: false,
                                                      maximumValueDescription: TaskListRowStrings.exampleHighValueText,
                                                      minimumValueDescription: TaskListRowStrings.exampleLowValueText)
        
        let scaleFormItem = ORKFormItem(identifier: String(describing: Identifier.scaleFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: scaleAnswerFormat)
        let scaleFormStep = ORKFormStep(identifier: String(describing: Identifier.discreteScaleFormStep), title: NSLocalizedString("Scale", comment: ""), text: NSLocalizedString("Discrete Scale", comment: ""))
        scaleFormStep.formItems = [scaleFormItem]
        
        return scaleFormStep
    }
    
    static var scaleWithTextChoicesExample: ORKFormStep {
        // The fifth step is a scale control that allows text choices.
        let textChoices = self.textChoicesExample
        let scaleAnswerFormat = ORKAnswerFormat.textScale(with: textChoices, defaultIndex: NSIntegerMax, vertical: false)
        
        let scaleFormItem = ORKFormItem(identifier: String(describing: Identifier.scaleFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: scaleAnswerFormat)
        let scaleFormStep = ORKFormStep(identifier: String(describing: Identifier.textScaleFormStep), title: NSLocalizedString("Scale", comment: ""), text: NSLocalizedString("Text Scale", comment: ""))
        scaleFormStep.formItems = [scaleFormItem]
        
        return scaleFormStep
    }
    
    static var validatedTextExample: ORKFormStep {
        let urlDomainRegularExpressionPattern = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        let urlDomainRegularExpression = try? NSRegularExpression(pattern: urlDomainRegularExpressionPattern)
        
        let textAnswerFormat = ORKAnswerFormat.textAnswerFormat(withValidationRegularExpression: urlDomainRegularExpression!, invalidMessage: "Invalid URL: %@")
        textAnswerFormat.multipleLines = false
        textAnswerFormat.keyboardType = .URL
        textAnswerFormat.autocapitalizationType = UITextAutocapitalizationType.none
        textAnswerFormat.autocorrectionType = UITextAutocorrectionType.no
        textAnswerFormat.spellCheckingType = UITextSpellCheckingType.no
        textAnswerFormat.textContentType = UITextContentType.URL
        
        let sectionHeaderFormItem = ORKFormItem(sectionTitle: NSLocalizedString("URL", comment: ""))
        let validatedTextFormItem = ORKFormItem(identifier: String(describing: Identifier.validatedTextFormItem), text: nil, answerFormat:textAnswerFormat)
        validatedTextFormItem.placeholder = "enter URL"
        
        let validatedTextFormStep = ORKFormStep(identifier: String(describing: Identifier.validatedTextFormStepDomain), title: NSLocalizedString("Validated Text", comment: ""), text: TaskListRowStrings.exampleDetailText)
        validatedTextFormStep.formItems = [sectionHeaderFormItem, validatedTextFormItem]
        
        return validatedTextFormStep
    }
    
    static var valuePickerChoicesExample: ORKFormStep {
        let textChoices = self.textChoicesExample
        let valuePickerAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: textChoices)
        
        let sectionHeaderFormItem = self.formItemSectionHeaderExample
        let valuePickerFormItem = ORKFormItem(identifier: String(describing: Identifier.valuePickerChoiceFormItem), text: nil, answerFormat: valuePickerAnswerFormat)
        valuePickerFormItem.placeholder = "Select value"
        
        let valuePickerFormStep = ORKFormStep(identifier: String(describing: Identifier.valuePickerChoiceFormStep), title: NSLocalizedString("Value Picker", comment: ""), text: TaskListRowStrings.exampleDetailText)
        valuePickerFormStep.formItems = [sectionHeaderFormItem, valuePickerFormItem]
        
        return valuePickerFormStep
    }
    
    static var verticalScaleWithPercentExample: ORKFormStep {
        // The third step is a vertical scale control with 10 discrete ticks.
        let scaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10,
                                                      minimumValue: 1,
                                                      defaultValue: NSIntegerMax,
                                                      step: 1,
                                                      vertical: true,
                                                      maximumValueDescription: nil,
                                                      minimumValueDescription: nil)
        
        let scaleFormItem = ORKFormItem(identifier: String(describing: Identifier.scaleFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: scaleAnswerFormat)
        let scaleFormStep = ORKFormStep(identifier: String(describing: Identifier.discreteVerticalScaleFormStep), title: NSLocalizedString("Scale", comment: ""), text: NSLocalizedString("Discrete Vertical Scale", comment: ""))
        scaleFormStep.formItems = [scaleFormItem]
        
        return scaleFormStep
    }
    
    static var verticalScaleWithTextChoicesExample: ORKFormStep {
        // The sixth step is a vertical scale control that allows text choices.
        let textChoices = self.textChoicesExample
        let scaleAnswerFormat = ORKAnswerFormat.textScale(with: textChoices, defaultIndex: NSIntegerMax, vertical: true)
        
        let scaleFormItem = ORKFormItem(identifier: String(describing: Identifier.scaleFormItem), text: TaskListRowStrings.exampleQuestionText, answerFormat: scaleAnswerFormat)
        let scaleFormStep = ORKFormStep(identifier: String(describing: Identifier.textVerticalScaleFormStep), title: NSLocalizedString("Scale", comment: ""), text: NSLocalizedString("Text Vertical Scale", comment: ""))
        scaleFormStep.formItems = [scaleFormItem]
        
        return scaleFormStep
    }
    
    static var weightExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep1)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat()
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Local system, default precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    static var weightHealthKitBodyMassExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep7)
        let weightAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, unit: HKUnit.gramUnit(with: .kilo), style: .decimal)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("HealthKit, body mass", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
#endif
    
    static var weightMetricSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep2)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: .metric)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Metric system, default precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightMetricSystemHighPrecisionExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep4)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric, numericPrecision: ORKNumericPrecision.high, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Metric system, high precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightMetricSystemLowPrecisionExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep3)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.metric, numericPrecision: ORKNumericPrecision.low, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("Metric system, low precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightUSCSystemExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep5)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: .USC)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("USC system, default precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    static var weightUSCSystemHighPrecisionExample: ORKFormStep {
        let stepIdentifier = String(describing: Identifier.weightQuestionFormStep6)
        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: ORKMeasurementSystem.USC, numericPrecision: ORKNumericPrecision.high, minimumValue: ORKDoubleDefaultValue, maximumValue: ORKDoubleDefaultValue, defaultValue: ORKDoubleDefaultValue)
        let title = NSLocalizedString("Weight", comment: "")
        let stepText =  NSLocalizedString("USC system, high precision", comment: "")
        
        let formStep = self.heightWeightFormStepExample(identifier:stepIdentifier, answerFormat:weightAnswerFormat, title:title, text:stepText)
        
        return formStep
    }
    
    // MARK: - Steps for consent
    
    static var consentWelcomeStepExample: ORKInstructionStep {
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.consentWelcomeInstructionStep))
        instructionStep.iconImage = UIImage(systemName: "hand.wave")
        instructionStep.title = "Welcome!"
        instructionStep.detailText = "Thank you for joining our study. Tap Next to learn more before signing up."
        
        return instructionStep
    }
    
    static var informedConsentStepExample: ORKInstructionStep {
        let instructionStep = ORKInstructionStep(identifier: String(describing: Identifier.informedConsentInstructionStep))
        instructionStep.iconImage = UIImage(systemName: "doc.text.magnifyingglass")
        instructionStep.title = "Before You Join"
        
        let sharingHealthDataBodyItem = ORKBodyItem(text: "The study will ask you to share some of your Health data.",
                                                    detailText: nil,
                                                    image: UIImage(systemName: "heart.fill"),
                                                    learnMoreItem: nil,
                                                    bodyItemStyle: .image,
                                                    useCardStyle: false,
                                                    alignImageToTop: true)
        
        let completingTasksBodyItem = ORKBodyItem(text: "You will be asked to complete various tasks over the duration of the study.",
                                                  detailText: nil,
                                                  image: UIImage(systemName: "checkmark.circle.fill"),
                                                  learnMoreItem: nil,
                                                  bodyItemStyle: .image,
                                                  useCardStyle: false,
                                                  alignImageToTop: true)
        
        let signatureBodyItem = ORKBodyItem(text: "Before joining, we will ask you to sign an informed consent document.",
                                            detailText: nil,
                                            image: UIImage(systemName: "signature"),
                                            learnMoreItem: nil,
                                            bodyItemStyle: .image,
                                            useCardStyle: false,
                                            alignImageToTop: true)
        
        let secureDataBodyItem = ORKBodyItem(text: "Your data is kept private and secure.",
                                             detailText: nil,
                                             image: UIImage(systemName: "lock.fill"),
                                             learnMoreItem: nil,
                                             bodyItemStyle: .image,
                                             useCardStyle: false,
                                             alignImageToTop: true)
        
        instructionStep.bodyItems = [
            sharingHealthDataBodyItem,
            completingTasksBodyItem,
            signatureBodyItem,
            secureDataBodyItem
        ]
        
        return instructionStep
    }
    
    static var informedConsentSharingStepExample: ORKFormStep {
        // Construct the text choices.
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Institution and qualified researchers worldwide", value: 1 as NSNumber),
                                            ORKTextChoice(text: "Only institution and its partners", value: 2 as NSNumber)]
        let textChoiceAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        // Construct the form item for text choices.
        let textChoiceFormItem = ORKFormItem(identifier: "TextChoiceFormItem", text: "Who would you like to share your data with?", answerFormat: textChoiceAnswerFormat)
        
        // Construct the form step.
        let formStepText = "Institution and its partners will receive your study data from your participation in this study.\n \nSharing your coded study data more broadly (without information such as your name) may benefit this and future research."
        
        let formStep = ORKFormStep(identifier: "ConsentSharingFormStepIdentifier", title: "Sharing Options", text: formStepText)
        formStep.formItems = [textChoiceFormItem]
        
        return formStep
    }
    
    static var webViewStepExample: ORKWebViewStep {
        let instructionSteps = [
            TaskListRowSteps.consentWelcomeStepExample,
            TaskListRowSteps.informedConsentStepExample
        ]
        
        let webViewStep = ORKWebViewStep(identifier: String(describing: Identifier.webViewStep), instructionSteps: instructionSteps)
        webViewStep.showSignatureAfterContent = true
        return webViewStep
    }
    

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    static var requestPermissionsStepExample: ORKRequestPermissionsStep {
        let healthKitTypesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.workoutType()]
        
        let healthKitPermissionType = ORKHealthKitPermissionType(sampleTypesToWrite: healthKitTypesToWrite, objectTypesToRead: healthKitTypesToRead)
        
        let requestPermissionsStep = ORKRequestPermissionsStep(identifier: String(describing: Identifier.requestPermissionsStep), permissionTypes: [healthKitPermissionType])
        requestPermissionsStep.title = "Health Data Request"
        requestPermissionsStep.text = "Please review the health data types below and enable sharing to contribute to the study."
        
        return requestPermissionsStep
    }
#endif
    
    static var consentCompletionStepExample: ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: "completionId")
        completionStep.title = "Enrollment Complete"
        completionStep.text = "Thank you for enrolling in this study. Your participation will contribute to meaningful research!"
        return completionStep
    }
    
    // MARK: - ORKReviewStep
    
    static var embeddedReviewStepExample: ORKReviewStep {
        let embeddedReviewStep = ORKReviewStep.embeddedReviewStep(withIdentifier: String(describing: Identifier.embeddedReviewStep))
        embeddedReviewStep.bodyItems = [
            ORKBodyItem(text: "Review Item #1", detailText: nil, image: nil, learnMoreItem: nil, bodyItemStyle: .bulletPoint),
            ORKBodyItem(text: "Review Item #2", detailText: nil, image: nil, learnMoreItem: nil, bodyItemStyle: .bulletPoint),
            ORKBodyItem(text: "Review Item #3", detailText: nil, image: nil, learnMoreItem: nil, bodyItemStyle: .bulletPoint),
            ORKBodyItem(text: "Review Item #4", detailText: nil, image: nil, learnMoreItem: nil, bodyItemStyle: .bulletPoint)
        ]
        embeddedReviewStep.title = "Embedded Review Step"
        
        return embeddedReviewStep
    }
    
    // MARK: - ORK3DModelStep
    
    static var usdzModelExample: ORK3DModelStep {
        let modelManager = ORKUSDZModelManager(usdzFileName: "sphere_model")
        modelManager.allowsSelection = true
        modelManager.enableContinueAfterSelection = true
        modelManager.highlightColor = .systemBlue
        
        let usdzModelStep = ORK3DModelStep(identifier: String(describing: Identifier.usdzModelStep), modelManager: modelManager)
        usdzModelStep.title = "Example USDZ Model"
        usdzModelStep.text = "Tap the model to continue"
        
        return usdzModelStep
    }
    
    // MARK: - ORKCompletionStep
    
    static var completionStepExample: ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.completionStep))
        completionStep.iconImage = UIImage(systemName: "checkmark.circle.fill")
        completionStep.title = "Task Completed"
        completionStep.text = "Thank you for completing the task."
        
        return completionStep
    }
    
    // MARK: - ORKFamilyHistoryStep
    
    static var familyHistoryStepExample: ORKFamilyHistoryStep {
        // create ORKHealthConditions
        
        let healthConditions = [
        ORKHealthCondition(identifier: "healthConditionIdentifier1", displayName: "Diabetes", value: "Diabetes" as NSString),
        ORKHealthCondition(identifier: "healthConditionIdentifier2", displayName: "Heart Attack", value: "Heart Attack" as NSString),
        ORKHealthCondition(identifier: "healthConditionIdentifier3", displayName: "Stroke", value: "Stroke" as NSString)
        ]
        
        // add ORKHealthConditions to ORKConditionStepConfiguration object
        
        let conditionStepConfiguration = ORKConditionStepConfiguration(stepIdentifier: "FamilyHistoryConditionStepIdentifier", conditionsFormItemIdentifier: "HealthConditionsFormItemIdentifier", conditions: healthConditions, formItems: [])
        
        // create formItems and formStep for parent relative group
        let learnMoreInstructionStep01 = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep01.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep01.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem01 = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep01)
        
        let relativeNameSectionHeaderFormItem = ORKFormItem(sectionTitle: "Add a label to identify this family member", detailText: "Instead of their full name, please use a nickname, alias, or initials. Your response will only be saved on your device.", learnMoreItem: learnMoreItem01, showsProgress: true)
        relativeNameSectionHeaderFormItem.tagText = "OPTIONAL"
        let parentTextEntryAnswerFormat = ORKAnswerFormat.textAnswerFormat()
        parentTextEntryAnswerFormat.multipleLines = false
        parentTextEntryAnswerFormat.maximumLength = 3

        let parentNameFormItem = ORKFormItem(identifier: "ParentNameIdentifier", text: "enter optional name", answerFormat: parentTextEntryAnswerFormat)
        parentNameFormItem.isOptional = true
        
        let sexAtBirthOptions = [
            ORKTextChoice(text: "Female", value: "Female" as NSString),
            ORKTextChoice(text: "Male", value: "Male" as NSString),
            ORKTextChoice(text: "Intersex", value: "Intersex" as NSString),
            ORKTextChoice(text: "I don't know", value: "i_dont_know" as NSString),
            ORKTextChoice(text: "I prefer not to answer", value: "i_prefer_not_to_answer" as NSString)
        ]
        
        let parentSexAtBirthChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: sexAtBirthOptions)
        let parentSextAtBirthFormItem = ORKFormItem(identifier: "ParentSexAtBirthIdentifier", text: "What was the sex assigned on their original birth certificate?", answerFormat: parentSexAtBirthChoiceAnswerFormat)
        parentSextAtBirthFormItem.isOptional = false
        
        let vitalStatusOptions = [
            ORKTextChoice(text: "Living", value: "living" as NSString),
            ORKTextChoice(text: "Deceased", value: "deceased" as NSString),
            ORKTextChoice(text: "I don't know", value: "dont_know" as NSString),
            ORKTextChoice(text: "I prefer not to answer", value: "prefer_not_to_answer" as NSString),
        ]
        
        let parentVitalStatusChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: vitalStatusOptions)
        let parentVitalStatusFormItem = ORKFormItem(identifier: "ParentVitalStatusIdentifier", text: "What is their current vital status?", answerFormat: parentVitalStatusChoiceAnswerFormat)
        parentVitalStatusFormItem.isOptional = false
        
        let parentFormStep = ORKFormStep(identifier: "ParentSurveyIdentifier")
        let visibilityRule = ORKPredicateFormItemVisibilityRule(
            predicate: ORKResultPredicate.predicateForChoiceQuestionResult(
                with: .init(stepIdentifier: parentFormStep.identifier, resultIdentifier: parentVitalStatusFormItem.identifier),
                expectedAnswerValue: NSString(string: "living")
            )
        )

        let parentAgePickerSectionHeaderFormItem = ORKFormItem(identifier: "ParentAgeSectionHeaderIdentifier", text: "What is their approximate birth year?", answerFormat: nil)
        parentAgePickerSectionHeaderFormItem.visibilityRule = visibilityRule
        
        let parentAgePickerAnswerFormat = ORKAgeAnswerFormat(
            minimumAge: 18,
            maximumAge: 90,
            minimumAgeCustomText: "18 or younger",
            maximumAgeCustomText: "90 or older",
            showYear: true,
            useYearForResult: true,
            treatMinAgeAsRange: true,
            treatMaxAgeAsRange: false,
            defaultValue: 30)
        parentAgePickerAnswerFormat.shouldShowDontKnowButton = true
        
        let parentAgeFormItem = ORKFormItem(identifier: "ParentAgeFormItemIdentifier", text: nil, answerFormat: parentAgePickerAnswerFormat)
        parentAgeFormItem.isOptional = false
        parentAgeFormItem.visibilityRule = visibilityRule
        
        parentFormStep.isOptional = false
        parentFormStep.title = "Parent"
        parentFormStep.detailText = "Answer these questions to the best of your ability."
        parentFormStep.formItems = [
            relativeNameSectionHeaderFormItem,
            parentNameFormItem,
            parentSextAtBirthFormItem,
            parentVitalStatusFormItem,
            parentAgePickerSectionHeaderFormItem,
            parentAgeFormItem
        ]
        
        // create formItems and formStep for siblings relative group
        
        let siblingTextEntryAnswerFormat = ORKAnswerFormat.textAnswerFormat()
        siblingTextEntryAnswerFormat.multipleLines = false
        siblingTextEntryAnswerFormat.placeholder = "enter optional name"
        siblingTextEntryAnswerFormat.maximumLength = 3
        
        let siblingNameFormItem = ORKFormItem(identifier: "SiblingNameIdentifier", text: "Name or Nickname", answerFormat: siblingTextEntryAnswerFormat)
        siblingNameFormItem.isOptional = false
        
        let siblingSexAtBirthChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: sexAtBirthOptions)
        let siblingSextAtBirthFormItem = ORKFormItem(identifier: "SiblingSexAtBirthIdentifier", text: "What was the sex assigned on their original birth certificate?", answerFormat: siblingSexAtBirthChoiceAnswerFormat)
        siblingSextAtBirthFormItem.isOptional = false
        
        let siblingVitalStatusChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: vitalStatusOptions)
        let siblingVitalStatusFormItem = ORKFormItem(identifier: "SiblingVitalStatusIdentifier", text: "What is their current vital status?", answerFormat: siblingVitalStatusChoiceAnswerFormat)
        siblingVitalStatusFormItem.isOptional = false
        
        let siblingAgePickerAnswerFormat = ORKAgeAnswerFormat(
            minimumAge: 18,
            maximumAge: 90,
            minimumAgeCustomText: "18 or younger",
            maximumAgeCustomText: "90 or older",
            showYear: true,
            useYearForResult: true,
            treatMinAgeAsRange: true,
            treatMaxAgeAsRange: false,
            defaultValue: 30)
        siblingAgePickerAnswerFormat.shouldShowDontKnowButton = true
        
        let siblingAgePickerSectionHeaderFormItem = ORKFormItem(identifier: "SiblingAgeSectionHeaderIdentifier", text: "What is their approximate birth year?", answerFormat: nil)
        
        let siblingAgeFormItem = ORKFormItem(identifier: "SiblingAgeFormItemIdentifier", text: nil, answerFormat: siblingAgePickerAnswerFormat)
        siblingAgeFormItem.isOptional = false
        
        let siblingFormStep = ORKFormStep(identifier: "SiblingSurveyIdentifier")
        let siblingAgeVisibilityRule = ORKPredicateFormItemVisibilityRule(
            predicate: ORKResultPredicate.predicateForChoiceQuestionResult(
                with: .init(stepIdentifier: siblingFormStep.identifier, resultIdentifier: siblingVitalStatusFormItem.identifier),
                expectedAnswerValue: NSString(string: "living")
            )
        )
        siblingAgePickerSectionHeaderFormItem.visibilityRule = siblingAgeVisibilityRule
        siblingAgeFormItem.visibilityRule = siblingAgeVisibilityRule
        
        siblingFormStep.title = "Sibling"
        siblingFormStep.detailText = "Answer these questions to the best of your ability."
        siblingFormStep.formItems = [
            relativeNameSectionHeaderFormItem,
            siblingNameFormItem,
            siblingSextAtBirthFormItem,
            siblingVitalStatusFormItem,
            siblingAgePickerSectionHeaderFormItem,
            siblingAgeFormItem
        ]
        
        // create ORKRelativeGroups
        
        let relativeGroups = [
        ORKRelativeGroup(identifier: "ParentGroupIdentifier",
                         name: "Biological Parent",
                         sectionTitle: "Biological Parents",
                         sectionDetailText: "Include your blood-related parents.",
                         identifierForCellTitle: "ParentNameIdentifier",
                         maxAllowed: 2,
                         formSteps: [parentFormStep],
                         detailTextIdentifiers: ["ParentSexAtBirthIdentifier", "ParentVitalStatusIdentifier", "ParentAgeFormItemIdentifier"]),
        ORKRelativeGroup(identifier: "SiblingGroupIdentifier",
                         name: "Sibling",
                         sectionTitle: "Biological Siblings",
                         sectionDetailText: "Include all siblings who share one or both of your blood-related parents.",
                         identifierForCellTitle: "SiblingNameIdentifier",
                         maxAllowed: 10,
                         formSteps: [siblingFormStep],
                         detailTextIdentifiers: ["SiblingSexAtBirthIdentifier", "SiblingVitalStatusIdentifier", "SiblingAgeFormItemIdentifier"])
        ]
        
        // create ORKFamilyHistoryStep and add to a ORKOrderedTask
        
        let familyHistoryStep = ORKFamilyHistoryStep(identifier: String(describing: Identifier.familyHistoryStep))
        familyHistoryStep.title = "Family Health History"
        familyHistoryStep.detailText = "The overview of your biological family members can inform health risks and lifestyle."
        familyHistoryStep.conditionStepConfiguration = conditionStepConfiguration
        familyHistoryStep.relativeGroups = relativeGroups
        
        return familyHistoryStep
    }
    
    
    // MARK: - Helpers
    
    private static var formItemSectionHeaderExample: ORKFormItem {
        return ORKFormItem(sectionTitle: TaskListRowStrings.exampleQuestionText)
    }
    
    private static var learnMoreItemExample: ORKLearnMoreItem {
        let learnMoreInstructionStep = ORKLearnMoreInstructionStep(identifier: "LearnMoreInstructionStep01")
        learnMoreInstructionStep.title = NSLocalizedString("Learn more title", comment: "")
        learnMoreInstructionStep.text = NSLocalizedString("Learn more text", comment: "")
        let learnMoreItem = ORKLearnMoreItem(text: nil, learnMoreInstructionStep: learnMoreInstructionStep)
        
        return learnMoreItem
    }
    
    private static func heightWeightFormStepExample(identifier: String, answerFormat: ORKAnswerFormat, title: String, text: String) -> ORKFormStep {
        let formItemSectionHeader = self.formItemSectionHeaderExample
        let heightQuestionFormItem = ORKFormItem(identifier: String(describing: Identifier.heightQuestionFormItem1), text: nil, answerFormat: answerFormat)
        heightQuestionFormItem.placeholder = TaskListRowStrings.exampleTapHereText
        
        let heightQuestionFormStep = ORKFormStep(identifier: String(describing: identifier), title: title, text: text)
        heightQuestionFormStep.formItems = [formItemSectionHeader, heightQuestionFormItem]
        
        return heightQuestionFormStep
    }
    
    private static var imageChoicesExample: [ORKImageChoice] {
        let roundShapeImage = UIImage(named: "round_shape")!
        let roundShapeText = NSLocalizedString("Round Shape", comment: "")
        
        let squareShapeImage = UIImage(named: "square_shape")!
        let squareShapeText = NSLocalizedString("Square Shape", comment: "")
        
        let imageChoices = [
            ORKImageChoice(normalImage: roundShapeImage, selectedImage: nil, text: roundShapeText, value: roundShapeText as NSString),
            ORKImageChoice(normalImage: squareShapeImage, selectedImage: nil, text: squareShapeText, value: squareShapeText as NSString)
        ]
        
        return imageChoices
    }
    
    private static var textChoicesExample: [ORKTextChoice] {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Poor", value: 1 as NSNumber),
                                            ORKTextChoice(text: "Fair", value: 2 as NSNumber),
                                            ORKTextChoice(text: "Good", value: 3 as NSNumber),
                                            ORKTextChoice(text: "Above Average", value: 10 as NSNumber),
                                            ORKTextChoice(text: "Excellent", value: 5 as NSNumber)]
        
        return textChoices
    }
    
}
