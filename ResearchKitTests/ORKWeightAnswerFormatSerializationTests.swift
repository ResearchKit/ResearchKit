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

private let weightAnswerFormatOmittedBoundsDefaultValue = 70.0

@Suite(.tags(.serialization))
struct ORKWeightAnswerFormatSerializationTests {
    @Test
    func testORKWeightAnswerFormat() throws {
        let instance = ORKWeightAnswerFormat(measurementSystem: .USC)
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKWeightAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 1.7976931348623157e+308,
          "dontKnowButtonStyle" : 1,
          "maximumValue" : 1.7976931348623157e+308,
          "measurementSystem" : "USC",
          "minimumValue" : 1.7976931348623157e+308,
          "numericPrecision" : 0,
          "showDontKnowButton" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    @Test
    func testORKWeightAnswerFormatWithNumericPrecisionLow() throws {
        let instance = ORKWeightAnswerFormat(
            measurementSystem: .metric,
            numericPrecision: .low,
            minimumValue: 1,
            maximumValue: 10,
            defaultValue: 5
        )
        instance.customDontKnowButtonText = "Don't Know"
        instance.shouldShowDontKnowButton = true

        let expectation = """
        {
          "_class" : "ORKWeightAnswerFormat",
          "customDontKnowButtonText" : "Don't Know",
          "defaultValue" : 5,
          "dontKnowButtonStyle" : 1,
          "maximumValue" : 10,
          "measurementSystem" : "metric",
          "minimumValue" : 1,
          "numericPrecision" : 1,
          "showDontKnowButton" : true
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    @Test
    func testORKWeightAnswerFormatWithNumericPrecision() throws {
        let instance = ORKWeightAnswerFormat(
            measurementSystem: .USC,
            numericPrecision: .default
        )
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKWeightAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 1.7976931348623157e+308,
          "dontKnowButtonStyle" : 1,
          "maximumValue" : 1.7976931348623157e+308,
          "measurementSystem" : "USC",
          "minimumValue" : 1.7976931348623157e+308,
          "numericPrecision" : 0,
          "showDontKnowButton" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKWeightAnswerFormatWithMinAndMaxValues() throws {
        let instance = ORKWeightAnswerFormat(
            measurementSystem: .USC,
            numericPrecision: .default,
            minimumValue: 1,
            maximumValue: 10,
            defaultValue: 5
        )
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKWeightAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 5,
          "dontKnowButtonStyle" : 1,
          "maximumValue" : 10,
          "measurementSystem" : "USC",
          "minimumValue" : 1,
          "numericPrecision" : 0,
          "showDontKnowButton" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
   
    @Test
    func testORKWeightAnswerFormatDecodesDefaultValueWithOmittedBounds() throws {
        // ResearchKit's own encoder always writes minimumValue/maximumValue, even when they are
        // still the sentinel, so this simulates externally-authored JSON that omits them entirely.
        let dictionary: [AnyHashable: Any] = [
            "_class": "ORKWeightAnswerFormat",
            "measurementSystem": "metric",
            "numericPrecision": 0,
            "defaultValue": weightAnswerFormatOmittedBoundsDefaultValue
        ]

        let format: ORKWeightAnswerFormat = try SerializationTestHelper.deserializeFromDictionary(dictionary)

        #expect(
            format.minimumValue == ORKDoubleDefaultValue,
            "An omitted minimumValue key should decode to the sentinel, not 0"
        )
        #expect(
            format.maximumValue == ORKDoubleDefaultValue,
            "An omitted maximumValue key should decode to the sentinel, not 0"
        )
        #expect(format.defaultValue == weightAnswerFormatOmittedBoundsDefaultValue)
    }

    @Test
    func testInvalidORKWeightAnswerFormat() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKWeightAnswerFormat(
                    measurementSystem: .USC,
                    numericPrecision: .default,
                    minimumValue: 5,
                    maximumValue: 1,
                    defaultValue: 8
                )
            }
        }
    }

}
