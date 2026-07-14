/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

import Testing

@Suite(.tags(.serialization))
struct ORKAnswerFormatSerializationTests {
    @Test
    func testORKAnswerFormatBasicInit() throws {
        let instance = ORKAnswerFormat()
        instance.customDontKnowButtonText = "Don't know"
        instance.dontKnowButtonStyle = .circleChoice
        instance.shouldShowDontKnowButton = true

        let expectation = """
        {
          "_class" : "ORKAnswerFormat",
          "customDontKnowButtonText" : "Don't know",
          "dontKnowButtonStyle" : 1,
          "showDontKnowButton" : true
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

@Suite(.tags(.serialization))
struct ORKNumericAnswerFormatSerializationTests {
    @Test
    func testNumericORKAnswerFormatWithStyle() throws {
        let instance = ORKNumericAnswerFormat(style: .decimal)
        instance.customDontKnowButtonText = ""
        instance.dontKnowButtonStyle = .standard
        instance.hideUnitWhenAnswerIsEmpty = false
        instance.maximumFractionDigits = 10
        instance.maximum = 123000
        instance.minimum = 124
        instance.placeholder = "placeholder"
        instance.defaultNumericAnswer = 123

        let expectation = """
        {
          "_class" : "ORKNumericAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultNumericAnswer" : 123,
          "dontKnowButtonStyle" : 0,
          "hideUnitWhenAnswerIsEmpty" : false,
          "maximum" : 123000,
          "maximumFractionDigits" : 10,
          "minimum" : 124,
          "placeholder" : "placeholder",
          "showDontKnowButton" : false,
          "style" : "decimal"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKNumericAnswerFormatWithStyleAndUnit() throws {
        let instance = ORKNumericAnswerFormat(
            style: .integer,
            unit: "kg"
        )
        instance.customDontKnowButtonText = "Don't know"
        instance.maximumFractionDigits = 123
        instance.maximum = 123
        instance.minimum = 123
        instance.placeholder = "placeholder"
        instance.defaultNumericAnswer = 123

        let expectation = """
        {
          "_class" : "ORKNumericAnswerFormat",
          "customDontKnowButtonText" : "Don't know",
          "defaultNumericAnswer" : 123,
          "displayUnit" : "kg",
          "dontKnowButtonStyle" : 1,
          "hideUnitWhenAnswerIsEmpty" : true,
          "maximum" : 123,
          "maximumFractionDigits" : 123,
          "minimum" : 123,
          "placeholder" : "placeholder",
          "showDontKnowButton" : false,
          "style" : "integer",
          "unit" : "kg"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKNumericAnswerFormatComplexInit() throws {
        let instance = ORKNumericAnswerFormat(
            style: .decimal,
            unit: "kg",
            displayUnit: "lb",
            minimum: 0,
            maximum: 100,
            maximumFractionDigits: 1
        )
        instance.customDontKnowButtonText = ""
        instance.placeholder = "placeholder"
        instance.defaultNumericAnswer = 123

        let expectation = """
        {
          "_class" : "ORKNumericAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultNumericAnswer" : 123,
          "displayUnit" : "lb",
          "dontKnowButtonStyle" : 1,
          "hideUnitWhenAnswerIsEmpty" : true,
          "maximum" : 100,
          "maximumFractionDigits" : 1,
          "minimum" : 0,
          "placeholder" : "placeholder",
          "showDontKnowButton" : false,
          "style" : "decimal",
          "unit" : "kg"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKNumericAnswerFormatMinMaxInit() throws {
        let instance = ORKNumericAnswerFormat(
            style: .decimal,
            unit: "kg",
            minimum: 1,
            maximum: 20
        )
        instance.customDontKnowButtonText = ""
        instance.maximumFractionDigits = 123
        instance.placeholder = "placeholder"
        instance.defaultNumericAnswer = 123

        let expectation = """
        {
          "_class" : "ORKNumericAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultNumericAnswer" : 123,
          "displayUnit" : "kg",
          "dontKnowButtonStyle" : 1,
          "hideUnitWhenAnswerIsEmpty" : true,
          "maximum" : 20,
          "maximumFractionDigits" : 123,
          "minimum" : 1,
          "placeholder" : "placeholder",
          "showDontKnowButton" : false,
          "style" : "decimal",
          "unit" : "kg"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    @Test
    func testInvalidORKNumericAnswerFormat() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKNumericAnswerFormat(
                    style: .decimal,
                    unit: "kg",
                    minimum: 100,
                    maximum: 1
                )
            }
        }
    }
        
}

@Suite(.tags(.serialization))
struct ORKValuePickerAnswerFormatSerializationTests {
    @Test
    func testORKValuePickerAnswerFormatBasicInit() throws {
        let instance = ORKValuePickerAnswerFormat(textChoices: [])
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKValuePickerAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "nullTextChoice" : {
            "_class" : "ORKTextChoice",
            "exclusive" : false,
            "text" : "Select an answer",
            "value" : null
          },
          "showDontKnowButton" : false,
          "textChoices" : [

          ]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKValuePickerAnswerFormatWithNullChoice() throws {
        let instance = ORKValuePickerAnswerFormat(
            textChoices: [],
            nullChoice: ORKTextChoice(
                text: "choice",
                value: 1 as NSNumber
            )
        )
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKValuePickerAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "nullTextChoice" : {
            "_class" : "ORKTextChoice",
            "exclusive" : false,
            "text" : "choice",
            "value" : 1
          },
          "showDontKnowButton" : false,
          "textChoices" : [

          ]
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKValuePickerWithTextChoices() throws {
        let instance = ORKValuePickerAnswerFormat(textChoices: [
            ORKTextChoice(text: "choice 1", value: 1 as NSNumber)
        ])
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKValuePickerAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "nullTextChoice" : {
            "_class" : "ORKTextChoice",
            "exclusive" : false,
            "text" : "Select an answer",
            "value" : null
          },
          "showDontKnowButton" : false,
          "textChoices" : [
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "choice 1",
              "value" : 1
            }
          ]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

@Suite(.tags(.serialization))
struct ORKMultipleValuePickerAnswerFormatSerializationTests {
    @Test
    func testORKMultipleValuePickerAnswerFormatBasicInit() throws {
        let instance = ORKMultipleValuePickerAnswerFormat(valuePickers: [
            ORKValuePickerAnswerFormat(textChoices: [
                ORKTextChoice(
                    text: "choice 1",
                    value: 1 as NSNumber
                )
            ])
        ])
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKMultipleValuePickerAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "separator" : " ",
          "showDontKnowButton" : false,
          "valuePickers" : [
            {
              "_class" : "ORKValuePickerAnswerFormat",
              "dontKnowButtonStyle" : 1,
              "nullTextChoice" : {
                "_class" : "ORKTextChoice",
                "exclusive" : false,
                "text" : "",
                "value" : null
              },
              "showDontKnowButton" : false,
              "textChoices" : [
                {
                  "_class" : "ORKTextChoice",
                  "exclusive" : false,
                  "text" : "choice 1",
                  "value" : 1
                }
              ]
            }
          ]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKMultipleValuePickerAnswerFormatBasicInitWithNoValuePickers() throws {
        let instance = ORKMultipleValuePickerAnswerFormat(valuePickers:[])
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKMultipleValuePickerAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "separator" : " ",
          "showDontKnowButton" : false,
          "valuePickers" : [

          ]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKMultipleValuePickerAnswerFormatWithSeparator() throws {
        let instance = ORKMultipleValuePickerAnswerFormat(
            valuePickers: [],
            separator: "."
        )
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKMultipleValuePickerAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "separator" : ".",
          "showDontKnowButton" : false,
          "valuePickers" : [

          ]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

@Suite(.tags(.serialization))
struct ORKTextChoiceAnswerFormatSerializationTests {
    @Test
    func testORKTextChoiceAnswerFormat() throws {
        let instance = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: [
            ORKTextChoice(text: "choice 1", value: 1 as NSNumber)
        ])
        instance.customDontKnowButtonText = ""
        instance.warningStateMessage = "your message here"
        instance.warningStateTriggerValues = ["answer 1" as NSString]

        let expectation = """
        {
          "_class" : "ORKTextChoiceAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "showDontKnowButton" : false,
          "style" : "singleChoice",
          "textChoices" : [
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "choice 1",
              "value" : 1
            }
          ],
          "warningStateMessage" : "your message here",
          "warningStateTriggerValues" : ["answer 1"]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

@Suite(.tags(.serialization))
struct ORKBooleanAnswerFormatSerializationTests {
    @Test
    func testORKBooleanAnswerFormatBasicInit() throws {
        let instance = ORKBooleanAnswerFormat()
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKBooleanAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "showDontKnowButton" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKBooleanAnswerFormatComplexInit() throws {
        let instance = ORKBooleanAnswerFormat(
            yesString: "yes",
            noString: "no"
        )
        instance.customDontKnowButtonText = ""
        instance.warningStateMessage = "your message here"
        instance.warningStateTriggerValues = [false as NSNumber]

        let expectation = """
        {
          "_class" : "ORKBooleanAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "no" : "no",
          "showDontKnowButton" : false,
          "yes" : "yes",
          "warningStateMessage" : "your message here",
          "warningStateTriggerValues" : [false]
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

@Suite(.tags(.serialization))
struct ORKImageChoiceAnswerFormatSerializationTests {
    @Test
    func testORKImageChoiceAnswerFormatBasicInit() throws {
        let instance = ORKImageChoiceAnswerFormat(imageChoices: [])
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKImageChoiceAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "imageChoices" : [

          ],
          "showDontKnowButton" : false,
          "style" : "singleChoice",
          "vertical" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKImageChoiceAnswerFormatComplexInit() throws {
        let normalImage = UIImage(systemName: "car")!
        let selectedImage = UIImage(systemName: "car")!
        let instance = ORKImageChoiceAnswerFormat(
            imageChoices: [.init(normalImage: normalImage, selectedImage: selectedImage, text: "text", value: 1 as NSNumber)],
            style: .multipleChoice,
            vertical: true
        )
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKImageChoiceAnswerFormat",
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "imageChoices" : [
            {
              "_class" : "ORKImageChoice",
              "text" : "text",
              "value" : 1
            }
          ],
          "showDontKnowButton" : false,
          "style" : "multipleChoice",
          "vertical" : true
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation) { instance in
            let imageChoice = instance.imageChoices[0]
            let instanceCopy = ORKImageChoiceAnswerFormat(
                imageChoices: [
                    .init(
                        normalImage: normalImage, // Not deserialized
                        selectedImage: selectedImage, // Not deserialized
                        text: imageChoice.text,
                        value: imageChoice.value
                    )
                ],
                style: instance.style,
                vertical: instance.isVertical
            )
            return instanceCopy
        }
    }
}

@Suite(.tags(.serialization))
struct ORKColorChoiceAnswerFormatSerializationTests {
    @Test
    func testORKColorChoiceAnswerFormatBasicInit() throws {
        let instance = ORKColorChoiceAnswerFormat(
            style: .multipleChoice,
            colorChoices: [.init(color: .red, text: "text", detailText: "detailText", value: 1 as NSNumber)]
        )
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKColorChoiceAnswerFormat",
          "colorChoices" : [
            {
              "_class" : "ORKColorChoice",
              "color" : {
                "a" : 1,
                "b" : 0,
                "g" : 0,
                "r" : 1
              },
              "detailText" : "detailText",
              "exclusive" : false,
              "text" : "text",
              "value" : 1
            }
          ],
          "customDontKnowButtonText" : "",
          "dontKnowButtonStyle" : 1,
          "showDontKnowButton" : false,
          "style" : "multipleChoice"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION

@Suite(.tags(.serialization))
struct ORKHealthKitQuantityTypeAnswerFormatSerializationTests {
    @Test
    func testORKHealthKitQuantityTypeAnswerFormatBasicInit() throws {
        let instance = ORKHealthKitQuantityTypeAnswerFormat(
            quantityType: HKQuantityType.quantityType(
                forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            unit: HKUnit(from: "kg"),
            style: .decimal
        )
        instance.customDontKnowButtonText = "Don't Know"

        let expectation = """
        {
          "_class" : "ORKHealthKitQuantityTypeAnswerFormat",
          "customDontKnowButtonText" : "Don't Know",
          "dontKnowButtonStyle" : 1,
          "numericAnswerStyle" : "decimal",
          "quantityType" : "HKQuantityTypeIdentifierActiveEnergyBurned",
          "shouldRequestAuthorization" : true,
          "showDontKnowButton" : false,
          "unit" : "kg"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

@Suite(.tags(.serialization))
struct ORKHealthKitCharacteristicTypeAnswerFormatSerializationTests {
    @Test
    func testORKHealthKitCharacteristicTypeAnswerFormatBasicInit() throws {
        let instance = ORKHealthKitCharacteristicTypeAnswerFormat(
            characteristicType: HKCharacteristicType.characteristicType(
                forIdentifier: .dateOfBirth
            )!
        )
        instance.customDontKnowButtonText = "Don't know"
        
        let fixedDate = Date(timeIntervalSince1970: 1234567)
        let fixedDateString = ORKStringFromDateISO8601(fixedDate)
        
        instance.maximumDate = fixedDate
        instance.minimumDate = fixedDate
        instance.defaultDate = fixedDate
        instance.calendar = Calendar(identifier: .gregorian)

        let expectation = """
        {
          "_class" : "ORKHealthKitCharacteristicTypeAnswerFormat",
          "calendar" : "gregorian",
          "characteristicType" : "HKCharacteristicTypeIdentifierDateOfBirth",
          "customDontKnowButtonText" : "Don't know",
          "defaultDate" : "\(fixedDateString)",
          "dontKnowButtonStyle" : 1,
          "maximumDate" : "\(fixedDateString)",
          "minimumDate" : "\(fixedDateString)",
          "shouldRequestAuthorization" : true,
          "showDontKnowButton" : false
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

#endif
